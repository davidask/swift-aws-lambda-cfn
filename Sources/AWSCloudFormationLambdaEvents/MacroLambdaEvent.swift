import struct AWSLambdaEvents.AWSRegion

struct MacroLambdaEvent: Decodable {
    public let region: AWSRegion
    public let accountId: String
    public let transformId: String
    public let fragment: Fragment
    public let requestId: String
}

struct CodableMacroLambdaEvent: Decodable {
    public let region: AWSRegion
    public let accountId: String
    public let transformId: String
    public let fragment: Fragment
    public let requestId: String
}
