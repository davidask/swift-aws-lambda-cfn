import XCTest
@testable import AWSCloudFormationLambdaEvents

final class CustomResourceLambdaEventDecodingTests: XCTestCase {

    struct TestResourceProperties: Equatable, Decodable {

        struct Key3: Equatable, Decodable {
            let key4: String
        }

        let key1: String
        let key2: [String]
        let key3: Key3
    }

    static let createEventBody = """
    {
       "RequestType" : "Create",
       "RequestId" : "cd2d12bb-bb4b-4c0d-96bc-094a64ac5501",
       "ResponseURL" : "http://pre-signed-S3-url-for-response",
       "ResourceType" : "Custom::MyCustomResourceType",
       "LogicalResourceId" : "MyTestResource",
       "StackId" : "arn:aws:cloudformation:us-east-2:namespace:stack/stack-name/guid",
       "ResourceProperties" : {
          "key1" : "string",
          "key2" : [ "list" ],
          "key3" : { "key4" : "map" }
       }
    }
    """

    func testCustomResourceEventDecoding() {

        let data = CustomResourceLambdaEventDecodingTests.createEventBody.data(using: .utf8)!
        var event: CustomResourceLambdaEvent<TestResourceProperties>!

        XCTAssertNoThrow(
            event = try JSONDecoder().decode(
                CustomResourceLambdaEvent<TestResourceProperties>.self,
                from: data
            )
        )

        guard event != nil else {
            XCTFail("Event was not decoded successfully")
            return
        }

        let anyEvent = event.eraseToAny()

        XCTAssertEqual(anyEvent.responseUrl, URL(string: "http://pre-signed-S3-url-for-response")!)
        XCTAssertEqual(anyEvent.stackId, "arn:aws:cloudformation:us-east-2:namespace:stack/stack-name/guid")
        XCTAssertEqual(anyEvent.requestId, "cd2d12bb-bb4b-4c0d-96bc-094a64ac5501")
        XCTAssertEqual(anyEvent.resourceType, "Custom::MyCustomResourceType")
        XCTAssertEqual(anyEvent.logicalResourceId, "MyTestResource")

    }

    static var allTests = [
        ("testCustomResourceEventDecode", testCustomResourceEventDecoding),
    ]
}
