import XCTest
import NIO
import AWSLambdaTesting
import AWSLambdaRuntimeCore
import Foundation
@testable import AWSCloudFormationLambdaEvents
@testable import AWSCloudFormationMacro

final class InvocationTests: XCTestCase {

    struct Macro: MacroLambdaHandler {

        enum TransformError: Error {
            case invalidFragment
        }

        // Define an `Encodable` fragment to return
        typealias ReturnFragment = String

        func handle(context: Lambda.Context, event: MacroLambdaEvent, callback: @escaping (Result<ReturnFragment, Error>) -> Void) {
            guard let string = event.fragment.string else {
                callback(.failure(TransformError.invalidFragment))
                return
            }

            callback(.success("MyStringPrefix_" + string))
        }
    }
}
