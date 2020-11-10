import class Foundation.JSONEncoder
import struct Foundation.URL

public protocol AnyCloudFormationCustomResourceLambdaEvent {
    var stackId: String { get }
    var requestId: String { get }
    var responseUrl: URL { get }
    var logicalResourceId: String { get }
    var resourceType: String { get }
}

public enum CustomResourceLambdaEvent<ResourceProperties: Decodable> {

    internal enum RequestType: String, Decodable {
        case create = "Create"
        case update = "Update"
        case delete = "Delete"
    }

    case create(Create)
    case update(Update)
    case delete(Delete)

    public func eraseToAny() -> AnyCloudFormationCustomResourceLambdaEvent {
        switch self {
        case .create(let inner): return inner
        case .update(let inner): return inner
        case .delete(let inner): return inner
        }
    }


    // https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/crpg-ref-requesttypes-create.html
    public struct Create: AnyCloudFormationCustomResourceLambdaEvent {

        public let stackId: String

        public let requestId: String

        public let responseUrl: URL

        public let logicalResourceId: String

        public let resourceType: String

        public let resourceProperties: ResourceProperties
    }

    // https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/crpg-ref-requesttypes-update.html
    public struct Update: AnyCloudFormationCustomResourceLambdaEvent {

        public let stackId: String

        public let requestId: String

        public let responseUrl: URL

        public let logicalResourceId: String

        public let physicalResourceId: String

        public let resourceType: String

        public let resourceProperties: ResourceProperties

        public let oldResourceProperties: ResourceProperties
    }

    // https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/crpg-ref-requesttypes-delete.html
    public struct Delete: AnyCloudFormationCustomResourceLambdaEvent {

        public let stackId: String

        public let requestId: String

        public let responseUrl: URL

        public let logicalResourceId: String

        public let physicalResourceId: String

        public let resourceType: String
    }
}

public struct CustomResourceResponse<ResourceData: Encodable>: Encodable {

    public enum Status: String, Encodable {
        case success = "SUCCESS"
        case failure = "FAILURE"
    }

    public let status: Status
    public let stackId: String
    public let requestId: String
    public let logicalResourceId: String
    public let physicalResourceId: String?
    public let data: ResourceData?
    public let reason: String?

    public init(
        status: Status,
        stackId: String,
        requestId: String,
        logicalResourceId: String,
        physicalResourceId: String?,
        data: ResourceData?,
        reason: String?
    ) {
        self.status = status
        self.stackId = stackId
        self.requestId = requestId
        self.logicalResourceId = logicalResourceId
        self.physicalResourceId = physicalResourceId
        self.data = data
        self.reason = reason
    }
}

extension CustomResourceLambdaEvent: Decodable {

    private enum CodingKeys: String, CodingKey {
        case requestType = "RequestType"
        case responseUrl = "ResponseURL"
        case stackId = "StackId"
        case requestId = "RequestId"
        case resourceType = "ResourceType"
        case logicalResourceId = "LogicalResourceId"
        case physicalResourceId = "PhysicalResourceId"
        case resourceProperties = "ResourceProperties"
        case oldResourceProperties = "OldResourceProperties"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let requestType = try container.decode(RequestType.self, forKey: .requestType)
        let stackId = try container.decode(String.self, forKey: .stackId)
        let responseUrl = try container.decode(URL.self, forKey: .responseUrl)
        let requestId = try container.decode(String.self, forKey: .requestId)
        let resourceType = try container.decode(String.self, forKey: .resourceType)
        let logicalResourceId = try container.decode(String.self, forKey: .logicalResourceId)
        let resourcePropreties = try container.decode(ResourceProperties.self, forKey: .resourceProperties)


        switch requestType {
        case .create:
            self = .create(
                Create(
                    stackId: stackId,
                    requestId: requestId,
                    responseUrl: responseUrl,
                    logicalResourceId: logicalResourceId,
                    resourceType: resourceType,
                    resourceProperties: resourcePropreties
                )
            )
        case .update:
            self = .update(
                Update(
                    stackId: stackId,
                    requestId: requestId,
                    responseUrl: responseUrl,
                    logicalResourceId: logicalResourceId,
                    physicalResourceId: try container.decode(String.self, forKey: .physicalResourceId),
                    resourceType: resourceType,
                    resourceProperties: resourcePropreties,
                    oldResourceProperties: try container.decode(ResourceProperties.self, forKey: .oldResourceProperties)
                )
            )
        case .delete:
            self = .delete(
                Delete(
                    stackId: stackId,
                    requestId: requestId,
                    responseUrl: responseUrl,
                    logicalResourceId: logicalResourceId,
                    physicalResourceId: try container.decode(String.self, forKey: .physicalResourceId),
                    resourceType: resourceType
                )
            )
        }
    }
}

