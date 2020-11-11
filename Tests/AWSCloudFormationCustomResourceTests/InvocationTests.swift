import XCTest
import NIO
import AWSLambdaTesting
import AWSLambdaRuntimeCore
import Foundation
@testable import AWSCloudFormationLambdaEvents
@testable import AWSCloudFormationCustomResource

final class InvocationTests: XCTestCase {

    struct Resource: CloudFormationCustomResource {

        struct ResourceProperties: Decodable {
            let property1: String
        }

        struct ResourceData: Encodable {
            let attribute1: String
        }

        func create(context: Lambda.Context, event: CreateEvent, completion: @escaping (Result<ResourceResult, Error>) -> Void) {
            // Create resource
            completion(.success(
                ResourceResult(
                    physicalResourceId: "PhysicalResourceID",
                    data: ResourceData(attribute1: "Attribute1")
                )
            ))
        }

        func update(context: Lambda.Context, event: UpdateEvent, completion: @escaping (Result<ResourceResult, Error>) -> Void) {
            // Update resource
            completion(.success(
                ResourceResult(
                    physicalResourceId: "PhysicalResourceID",
                    data: ResourceData(attribute1: "Attribute1")
                )
            ))
        }

        func delete(context: Lambda.Context, event: DeleteEvent, completion: @escaping (Result<Void, Error>) -> Void) {
            // Delete resource
            completion(.success(()))
        }

    }

    struct EventLoopResource: EventLoopCloudFormationCustomResource {

        struct ResourceProperties: Decodable {
            let property1: String
        }

        struct ResourceData: Encodable {
            let attribute1: String
        }

        func create(context: Lambda.Context, event: CreateEvent) -> EventLoopFuture<ResourceResult> {
            context.eventLoop.makeSucceededFuture(
                ResourceResult(physicalResourceId: "OK", data: ResourceData(attribute1: "OK"))
            )
        }

        func update(context: Lambda.Context, event: UpdateEvent) -> EventLoopFuture<ResourceResult> {
            context.eventLoop.makeSucceededFuture(
                ResourceResult(physicalResourceId: "OK", data: ResourceData(attribute1: "OK"))
            )
        }

        func delete(context: Lambda.Context, event: DeleteEvent) -> EventLoopFuture<Void> {
            context.eventLoop.makeSucceededFuture(())
        }
    }
}
