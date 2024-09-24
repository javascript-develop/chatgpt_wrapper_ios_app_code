//
//  SettingsSection.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import Foundation

struct SettingsSection: Identifiable {
    let id = UUID().uuidString
    let title: String
    let items: [SectionItem]
}


enum SectionItem {
    //Settings
    case language
    case yourPlan
    case voice
    
    //Support
    case help
    case restorePurchases
    
    //About
    case rateUs
    case shareWithFriends
    case termsOfUse
    case privacyPolicy
}
