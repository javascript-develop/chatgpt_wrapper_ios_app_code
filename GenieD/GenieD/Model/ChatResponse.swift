//
//  ChatResponse.swift
//  GenieD
//
//  Created by OK on 08.05.2023.
//

import Foundation

struct ChatResponse {
    let output: String
    let promptTokens: Int
    let completionTokens: Int
}

extension TextTurboResponse {
    func toChatResponse() -> ChatResponse {
        let output = (self.choices.first?.message.content.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
        return ChatResponse(output: output,
                     promptTokens: self.usage.promptTokens ?? 0,
                     completionTokens: self.usage.completionTokens ?? 0)
    }
}
