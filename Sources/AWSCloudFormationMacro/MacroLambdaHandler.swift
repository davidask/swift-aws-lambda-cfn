@_exported import AWSLambdaRuntimeCore
import AWSCloudFormationLambdaEvents
import NIO
import NIOFoundationCompat
import class Foundation.JSONEncoder
import class Foundation.JSONDecoder
import Dispatch

internal extension Lambda {
    static let defaultOffloadQueue = DispatchQueue(label: "LambdaHandler.cfn.macro.offload")
}

public protocol MacroLambdaHandler: ByteBufferLambdaHandler {
    associatedtype ReturnFragment: Encodable

    func transform(context: Lambda.Context, fragment: Fragment, callback: @escaping (Result<ReturnFragment, Error>) -> Void)

    var offloadQueue: DispatchQueue { get }
}

public extension MacroLambdaHandler {

    var offloadQueue: DispatchQueue {
        Lambda.defaultOffloadQueue
    }

    func transform(context: Lambda.Context, fragment: Fragment) -> EventLoopFuture<ReturnFragment> {
        let promise = context.eventLoop.makePromise(of: ReturnFragment.self)
        self.offloadQueue.async {
            transform(context: context, fragment: fragment, callback: promise.completeWith)
        }
        return promise.futureResult
    }
}

public protocol EventLoopMacroLambdaHandler: ByteBufferLambdaHandler {
    associatedtype ReturnFragment: Encodable

    func transform(context: Lambda.Context, fragment: Fragment) -> EventLoopFuture<ReturnFragment>
}

public extension EventLoopMacroLambdaHandler {


    func handle(context: Lambda.Context, event: ByteBuffer) -> EventLoopFuture<ByteBuffer?> {
        do {
            let macroEvent = try JSONDecoder().decode(MacroLambdaEvent.self, from: event)

            return transform(context: context, fragment: macroEvent.fragment)
                .map { fragment in
                    MacroLambdaResult<ReturnFragment>(requestId: macroEvent.requestId, status: .success(fragment))
                }.recover { error in
                    MacroLambdaResult<ReturnFragment>(
                        requestId: macroEvent.requestId,
                        status: .failure
                    )
                }.flatMapThrowing { result in
                    try ByteBuffer(data: JSONEncoder().encode(result))
                }

        } catch {
            return context.eventLoop.makeFailedFuture(error)
        }
    }
}


