//
//  ChooseLanguageViewModel.swift
//  GenieD
//
//  Created by OK on 20.03.2023.
//

import Foundation

class ChooseLanguageViewModel: NSObject, ObservableObject {
    
    var allLanguages: [Language] {
        LocalizationService.shared.allLanguages
    }
    
    @Published var selectedLanguage: Language = LocalizationService.shared.language
    
    func onLanguageSelected(_ language: Language) {
        LocalizationService.shared.setLanguage(language)
        selectedLanguage = language
    }
}
