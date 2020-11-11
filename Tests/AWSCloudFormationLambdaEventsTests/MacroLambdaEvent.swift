import XCTest
@testable import AWSCloudFormationLambdaEvents

final class MacroLambdaEventDecodingTests: XCTestCase {

    static let createEventBody = """
    {
        "region": "us-east-1",
        "accountId": "ACCOUNT_ID",
        "fragment": {
          "PipelineNotificationRule": {
            "Type": "AWS::CodeStarNotifications::NotificationRule",
            "Properties": {
              "DetailType": "FULL",
              "EventTypeIds": [
                "codepipeline-pipeline-pipeline-execution-failed",
                "codepipeline-pipeline-pipeline-execution-succeeded",
                "codepipeline-pipeline-pipeline-execution-started"
              ],
              "Name": "ResourcePipeline",
              "Resource": "testResourceArn",
              "Status": "ENABLED"
            }
          }
        },
        "transformId": "$TRANSFORM_ID",
        "params": {},
        "requestId": "$REQUEST_ID",
        "templateParameterValues": {}
    }
    """

    func testMacroLambdaEventDecoding() throws {

        let data = MacroLambdaEventDecodingTests.createEventBody.data(using: .utf8)!
        let event: MacroLambdaEvent = try JSONDecoder().decode(
            MacroLambdaEvent.self,
            from: data
        )

        XCTAssertEqual(
            event.fragment.PipelineNotificationRule?.Type?.string,
            "AWS::CodeStarNotifications::NotificationRule"
        )

        XCTAssertEqual(
            event.fragment.PipelineNotificationRule?.Properties?.EventTypeIds?[2]?.string,
            "codepipeline-pipeline-pipeline-execution-started"
        )
    }

    static var allTests = [
        ("testMacroLambdaEventDecoding", testMacroLambdaEventDecoding),
    ]
}
