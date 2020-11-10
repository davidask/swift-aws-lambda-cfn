import XCTest
import NIO
import AWSLambdaTesting
import AWSLambdaRuntimeCore
import Foundation
@testable import AWSCloudFormationLambdaEvents
@testable import AWSCloudFormationCustomResource
import AWSCloudFormationCore
import Logging

final class InvocationTests: XCTestCase {

    struct Resource: EventLoopCloudFormationCustomResource {

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

        struct ResourceProperties: Decodable {
            let property1: String
        }

        struct ResourceData: Encodable {
            let attribute1: String
        }
    }

//    static var allTests = [
////        ("testInvocation", testInvocation),
//    ]
}
