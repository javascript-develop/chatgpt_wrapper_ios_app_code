//
//  TextResponse.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import Foundation

public struct TextResponse: Codable {
    public let object: String
    public let model: String?
    public let choices: [TextChoice]
}

public struct TextChoice: Codable {
    public let text: String
}
