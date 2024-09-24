//
//  SwiftConfiguration.swift
//  GenieD
//
//  Created by OK on 21.11.2023.
//

import Foundation

public typealias Configuration = Dictionary<String, Any>

class SwiftConfiguration {
    
    enum ConfigurationKey: String, CaseIterable {
        case firebaseLogin, firebasePassword, sharedSecret, googleClientId, gptFileQueryToken
    }
    
    // MARK: Shared instance
    
    static let current = SwiftConfiguration()
    
    // MARK: Properties
    
    private let configurationKey = "CurrentConfiguration"
    private let configurationPlistFileName = "Info.plist"
    private let configurationDictionary: NSDictionary
    let configuration: Configuration
    
    // MARK: Configuration properties
    
    var firebaseLogin: String {
        return value(for: .firebaseLogin)
    }
    
    var firebasePassword: String {
        return value(for: .firebasePassword)
    }
    
    var sharedSecret: String {
        return value(for: .sharedSecret)
    }
    
    var googleClientId: String {
        return value(for: .googleClientId)
    }
    
    var gptFileQueryToken: String {
        return value(for: .gptFileQueryToken)
    }
    
    // MARK: Lifecycle
    
    init(targetConfiguration: Configuration? = nil) {
        let bundle = Bundle(for: SwiftConfiguration.self)
        guard let configurationDictionaryPath = bundle.path(forResource: configurationPlistFileName, ofType: nil),
              let configurationDictionary = NSDictionary(contentsOfFile: configurationDictionaryPath),
              let configuration = configurationDictionary[configurationKey] as? Configuration
        else {
            fatalError("Configuration Error")
        }
        self.configuration = configuration
        self.configurationDictionary = configurationDictionary
    }
    
    // MARK: Methods
    
    func value<T>(for key: ConfigurationKey) -> T {
        guard let value = configuration[key.rawValue] as? T else {
            fatalError("No value satisfying requirements")
        }
        return value
    }
}
