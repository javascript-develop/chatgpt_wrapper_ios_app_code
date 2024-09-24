//
//  BuyProProduct.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import Foundation
import StoreKit
import SwiftyStoreKit

var sharedSecret: String {
    SwiftConfiguration.current.sharedSecret
}

struct BuyProProduct {
    enum Period: Codable, CaseIterable {
        case liteWeek, liteYear, proWeek, proYear, advancedWeek, advancedYear
    }
    
    let period: Period
    
    var id: String {
        switch period {
        case .liteWeek:
            return "com.nisos.gpt.lite.week"
        case .liteYear:
            return "com.nisos.gpt.lite"
        case .proWeek:
            return "com.nisos.gpt.pro.week"
        case .proYear:
            return "com.nisos.gpt.pro"
        case .advancedWeek:
            return "com.nisos.gpt.advanced.week"
        case .advancedYear:
            return "com.nisos.gpt.advanced"
        }
    }
    
    var skProduct: SKProduct? = nil
    var priceWithCurrency: String? {
        guard let product = skProduct else { return nil }
        
        if let currencySymbol = product.priceLocale.currencySymbol {
            let mSymbol = currencySymbol
            return "\(mSymbol)\(product.price)"
        }
        
        if let currencyCode = product.priceLocale.currencyCode {
            return "\(currencyCode)\(product.price)"
        }
        
        return product.localizedPrice
    }
}

struct Subsciption: Codable {
    let period: BuyProProduct.Period
    let expirationDate: Date
    
    var access: BuyProAccess {
        switch period {
        case .liteWeek, .liteYear:
            return .lite
        case .proWeek, .proYear:
            return .pro
        case .advancedWeek, .advancedYear:
            return .advanced
        }
    }
    
    var priority: Int {
        switch period {
        case .liteWeek, .liteYear:
            return 0
        case .proWeek, .proYear:
            return 1
        case .advancedWeek, .advancedYear:
            return 2
        }
    }
}
