//
//  MessageItem.swift
//  GenieD
//
//  Created by OK on 03.03.2023.
//

import SwiftUI

struct MessageItem: Identifiable, Hashable {
    init(id: String = UUID().uuidString, text: String, isMy: Bool, image: UIImage? = nil, created: Date = Date(), usageTokens: Int = 0) {
        self.id = id
        self.text = text
        self.image = image
        self.isMy = isMy
        self.created = created
        self.usageTokens = usageTokens
    }
    
    init(coreDataMessage message: Message) {
        self.id = message.id ?? ""
        self.text = message.text ?? ""
        self.image = UIImage(data: message.image ?? Data())
        self.isMy = message.isMy
        self.created = message.created ?? Date()
        self.usageTokens = Int(message.usageTokens)
    }
    
    let id: String
    var text: String
    let isMy: Bool
    let created: Date
    var image: UIImage?
    var usageTokens: Int
}
