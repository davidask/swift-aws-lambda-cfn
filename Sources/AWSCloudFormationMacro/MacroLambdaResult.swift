struct MacroLambdaResult<Fragment> where Fragment: Encodable {
    enum Status {
        case success(Fragment)
        case failure
    }

    let requestId: String
    let status: Status
}

extension MacroLambdaResult: Encodable {
    private enum CodingKeys: String, CodingKey {
        case requestId
        case status
        case fragment
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(requestId, forKey: .requestId)

        switch status {
        case .failure:
            try container.encode("failure", forKey: .status)
            try container.encodeNil(forKey: .fragment)
        case .success(let fragment):
            try container.encode("success", forKey: .status)
            try container.encode(fragment, forKey: .fragment)

        }
    }
}
