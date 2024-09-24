//
//  LocalizationService.swift
//  GenieD
//
//  Created by OK on 20.03.2023.
//

import Foundation

class LocalizationService: ObservableObject {

    static let shared = LocalizationService()

    private init() {}
    
    @Published private(set) var language: Language = getCurrentLanguage()
    
    private static func getCurrentLanguage() -> Language {
        if let storedLangCode = UserDefaults.standard.string(forKey: "languageKey") {
            return Language(code: storedLangCode)
        }
        return systemLanguage()
    }
    
    func setLanguage(_ newValue: Language) {
        language = newValue
        UserDefaults.standard.setValue(newValue.rawValue, forKey: "languageKey")
        UserDefaults.standard.synchronize()
    }
    
    private static func systemLanguage() -> Language {
        let prefLangLowercased = Locale.preferredLanguages.first?.lowercased() ?? "en"
        var resultCode = String(prefLangLowercased.prefix(2))
        if (resultCode == "zh") {
            resultCode = prefLangLowercased.contains("zh-hans") ? "zh-Hans" : "zh-Hant"
        }
        if (resultCode == "pt") {
            resultCode = "pt-PT"
        }
        return Language(code: resultCode)
    }
    
    var allLanguages: [Language] {
        Language.allCases
    }
}

enum Language: String, CaseIterable {
    case english_us = "en"
    case english_uk = "en-GB"
    case english_au = "en-AU"
    case english_ca = "en-CA"
    case chinese_simpl = "zh-Hans"
    case chinese_trad = "zh-Hant"
    case arabic = "ar"
    case catalan = "ca"
    case croatian = "hr"
    case czech = "cs"
    case danish = "da"
    case dutch = "nl"
    case finnish = "fi"
    case french = "fr"
    case french_ca = "fr-CA"
    case german = "de"
    case greek = "el"
    case hebrew = "he"
    case hindi = "hi"
    case hungarian = "hu"
    case indonesian = "id"
    case italian = "it"
    case japanese = "ja"
    case korean = "ko"
    case malay = "ms"
    case norwegian = "nb"
    case polish = "pl"
    case protuguese_portugal = "pt-PT"
    case protuguese_brazil = "pt-BR"
    case romanian = "ro"
    case russian = "ru"
    case slovak = "sk"
    case spanish = "es"
    case spanish_mexico = "es-MX"
    case swedish = "sv"
    case thai = "th"
    case turkish = "tr"
    case ukranian  = "uk"
    case vietnamese = "vi"
    
    
    init(code: String) {
        self = Language(rawValue: code) ?? .english_us
    }
}

extension Language {
    var title: String {
        switch self {
        case .english_us:
            return "English"
        case .english_uk:
            return "English - UK"
        case .english_au:
            return "English (Australia)"
        case .english_ca:
            return "English (Canada)"
        case .chinese_simpl:
            return "Chinese (Simplified)"
        case .chinese_trad:
            return "Chinese (Traditional)"
        case .arabic:
            return "Arabic"
        case .catalan:
            return "Catalan"
        case .croatian:
            return "Croatian"
        case .czech:
            return "Czech"
        case .danish:
            return "Danish"
        case .dutch:
            return "Dutch"
        case .finnish:
            return "Finnish"
        case .french:
            return "French"
        case .french_ca:
            return "French (Canada)"
        case .german:
            return "German"
        case .greek:
            return "Greek"
        case .hebrew:
            return "Hebrew"
        case .hindi:
            return "Hindi"
        case .hungarian:
            return "Hungarian"
        case .indonesian:
            return "Indonesian"
        case .italian:
            return "Italian"
        case .japanese:
            return "Japanese"
        case .korean:
            return "Korean"
        case .malay:
            return "Malay"
        case .norwegian:
            return "Norwegian"
        case .polish:
            return "Polish"
        case .protuguese_portugal:
            return "Portuguese (Portugal)"
        case .protuguese_brazil:
            return "Portuguese (Brazil)"
        case .romanian:
            return "Romanian"
        case .russian:
            return "Russian"
        case .slovak:
            return "Slovak"
        case .spanish:
            return "Spanish (Spanish)"
        case .spanish_mexico:
            return "Spanish (Mexico)"
        case .swedish:
            return "Swedish"
        case .thai:
            return "Thai"
        case .turkish:
            return "Turkish"
        case .ukranian:
            return "Ukranian"
        case .vietnamese:
            return "Vietnamese"
        }
    }
}
