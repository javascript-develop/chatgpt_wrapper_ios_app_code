//
//  QuestionsSection.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import Foundation


struct QuestionsSection {
    let icon: String
    let title: String?
    let questions: [String]
    let shouldOpenFilesOptions: Bool
    
    init(icon: String, title: String?, questions: [String], shouldOpenFilesOptions: Bool = false) {
        self.icon = icon
        self.title = title
        self.questions = questions
        self.shouldOpenFilesOptions = shouldOpenFilesOptions
    }
}
