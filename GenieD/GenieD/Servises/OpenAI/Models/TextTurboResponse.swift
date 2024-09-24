//
//  TextTurboResponse.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import Foundation

public struct TextTurboResponse: Codable {
    public let object: String
    public let choices: [TurboChoice]
    public let usage: TurboUsage
}

public struct TurboChoice: Codable {
    public let index: Int
    public let message: TurboMessage
}

public struct TurboMessage: Codable {
    public let role: String
    public let content: String
}

public struct TurboUsage: Codable {
    public let completionTokens: Int?
    public let promptTokens: Int?
    
    enum CodingKeys: String, CodingKey {
        case completionTokens = "completion_tokens"
        case promptTokens = "prompt_tokens"
    }
}
