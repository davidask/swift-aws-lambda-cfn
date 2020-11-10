@_exported import AWSCloudFormationLambdaEvents
@_exported import AWSLambdaRuntimeCore
import NIO
import NIOHTTP1
import AsyncHTTPClient
import AsyncHTTPClient
import class Foundation.JSONEncoder
import class Foundation.JSONDecoder
import Dispatch

public struct CustomResourcePutResult<Data: Encodable> {

    public let physicalResourceId: String
    public let data: Data

    public init(physicalResourceId: String, data: Data) {
        self.physicalResourceId = physicalResourceId
        self.data = data
    }
}

internal extension Lambda {
    static let defaultOffloadQueue = DispatchQueue(label: "LambdaHandler.cfn.customresource.offload")
}

public enum CustomResourceHandlerError: Error {
    case unexpectedStatus(HTTPResponseStatus)
}

public protocol CustomResourceHandler: EventLoopCloudFormationCustomResource {

    func create(context: Lambda.Context, event: CreateEvent, completion: @escaping (Result<ResourceResult, Error>) -> Void)

    func update(context: Lambda.Context, event: UpdateEvent, completion: @escaping (Result<ResourceResult, Error>) -> Void)

    func delete(context: Lambda.Context, event: DeleteEvent, completion: @escaping (Result<Void, Error>) -> Void)
}

public extension CustomResourceHandler {

    func create(context: Lambda.Context, event: CreateEvent) -> EventLoopFuture<ResourceResult> {

        let promise = context.eventLoop.makePromise(of: ResourceResult.self)

        Lambda.defaultOffloadQueue.async {
            create(context: context, event: event, completion: promise.completeWith)
        }

        return promise.futureResult
    }

    func update(context: Lambda.Context, event: UpdateEvent) -> EventLoopFuture<ResourceResult> {
        let promise = context.eventLoop.makePromise(of: ResourceResult.self)

        Lambda.defaultOffloadQueue.async {
            update(context: context, event: event, completion: promise.completeWith)
        }

        return promise.futureResult
    }

    func delete(context: Lambda.Context, event: DeleteEvent) -> EventLoopFuture<Void> {
        let promise = context.eventLoop.makePromise(of: Void.self)

        Lambda.defaultOffloadQueue.async {
            delete(context: context, event: event, completion: promise.completeWith)
        }

        return promise.futureResult
    }
}

public protocol EventLoopCloudFormationCustomResource: ByteBufferLambdaHandler {
    associatedtype ResourceProperties: Decodable
    associatedtype ResourceData: Encodable

    typealias CreateEvent = CustomResourceLambdaEvent<ResourceProperties>.Create
    typealias UpdateEvent = CustomResourceLambdaEvent<ResourceProperties>.Update
    typealias DeleteEvent = CustomResourceLambdaEvent<ResourceProperties>.Delete

    typealias ResourceResult = CustomResourcePutResult<ResourceData>

    func create(context: Lambda.Context, event: CreateEvent) -> EventLoopFuture<ResourceResult>

    func update(context: Lambda.Context, event: UpdateEvent) -> EventLoopFuture<ResourceResult>

    func delete(context: Lambda.Context, event: DeleteEvent) -> EventLoopFuture<Void>
}

public extension EventLoopCloudFormationCustomResource {

    typealias In = CustomResourceLambdaEvent<ResourceProperties>
    typealias Out = Void

    func handle(context: Lambda.Context, event: ByteBuffer) -> EventLoopFuture<ByteBuffer?> {
        do {
            return handle(
                context: context,
                event: try JSONDecoder().decode(CustomResourceLambdaEvent<ResourceProperties>.self, from: event)
            ).map {
                nil
            }
        } catch {
            return context.eventLoop.makeFailedFuture(error)
        }
    }

    func handle(context: Lambda.Context, event: In) -> EventLoopFuture<Out> {
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(context.eventLoop))

        let promise = context.eventLoop.makePromise(of: Void.self)

        let successResponse: EventLoopFuture<CustomResourceResponse<ResourceData>>

        switch event {
        case .create(let inner):
            successResponse = self.create(context: context, event: inner).map { result in
                self.makeSuccessResponse(for: inner, physicalResourceId: result.physicalResourceId, data: result.data)
            }
        case .update(let inner):
            successResponse = self.update(context: context, event: inner).map { result in
                self.makeSuccessResponse(for: inner, physicalResourceId: result.physicalResourceId, data: result.data)
            }

        case .delete(let inner):
            successResponse = self.delete(context: context, event: inner).map {
                self.makeSuccessResponse(for: inner)
            }
        }

        successResponse.recover { error in
            self.makeFailureResponse(for: event.eraseToAny(), reason: "\(error)")
        }.flatMapThrowing { response in
            try HTTPClient.Request(
                url: event.eraseToAny().responseUrl,
                method: .PUT,
                headers: [
                    "content-type": ""
                ],
                body: .data(try JSONEncoder().encode(response)))

        }.flatMap { request in
            httpClient.execute(request: request, logger: context.logger).flatMapThrowing { response -> HTTPClient.Response in
                guard (200..<299).contains(response.status.code) else {
                    throw CustomResourceHandlerError.unexpectedStatus(response.status)
                }

                return response
            }
        }.whenComplete { result in

            httpClient.shutdown { error in

                if let error = error {
                    context.logger.error("\(error)")
                }

                switch result {
                case .failure(let error):
                    promise.fail(error)
                case .success(let response):
                    context.logger.log(level: .error, "\(response)")
                    promise.succeed(())
                }
            }
        }

        return promise.futureResult
    }

    private func makeSuccessResponse(
        for event: AnyCloudFormationCustomResourceLambdaEvent,
        physicalResourceId: String? = nil,
        data: ResourceData? = nil,
        reason: String? = nil
    ) -> CustomResourceResponse<ResourceData> {

        CustomResourceResponse(
            status: .success,
            stackId: event.stackId,
            requestId: event.requestId,
            logicalResourceId: event.logicalResourceId,
            physicalResourceId: physicalResourceId,
            data: data,
            reason: reason
        )
    }

    private func makeFailureResponse(
        for event: AnyCloudFormationCustomResourceLambdaEvent,
        reason: String? = nil
    ) -> CustomResourceResponse<ResourceData> {
        CustomResourceResponse(
            status: .success,
            stackId: event.stackId,
            requestId: event.requestId,
            logicalResourceId: event.logicalResourceId,
            physicalResourceId: nil,
            data: nil,
            reason: reason
        )
    }
}
