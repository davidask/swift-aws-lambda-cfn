import struct AWSLambdaEvents.AWSRegion

public struct TemplateParameter {
    public let type: String
    public let `default`: String?
    public let allowedValues: [String]?
    public let allowedPattern: String?
    public let constraintDescription: String?
    public let description: String?
    public let maxLength: Int?
    public let minLength: Int?
    public let maxValue: Int?
    public let minValue: Int?
    public let noEcho: Bool?
}

extension TemplateParameter: Decodable {
        
    private enum CodingKeys: String, CodingKey {
        case type = "Type"
        case `default` = "Default"
        case allowedValues = "AllowedValues"
        case allowedPattern = "AllowedPattern"
        case constraintDescription = "ConstraintDescription"
        case description = "Description"
        case maxLength = "MaxLength"
        case minLength = "MinLength"
        case maxValue = "MaxValue"
        case minValue = "MinValue"
        case noEcho = "NoEcho"
    }
}

public struct MacroLambdaEvent: Decodable {
    public let region: AWSRegion
    public let accountId: String
    public let transformId: String
    public let fragment: Fragment
    public let requestId: String
    public let templateParameterValues: [String: TemplateParameter]
}
