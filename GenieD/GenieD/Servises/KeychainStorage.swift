//
//  KeychainStorage.swift
//  GenieD
//
//  Created by OK on 15.03.2023.
//

import Foundation
import KeychainSwift

class KeychainStorage {
    
    private static let keychain = KeychainSwift()
    
    static var accessQuestionsCount: Int? {
        get {
            keychain.synchronizable = true
            return Int(keychain.get("accessQuestionsCountKey") ?? "")
        }
        set {
            if let value = newValue {
                keychain.synchronizable = true
                keychain.set(String(value), forKey: "accessQuestionsCountKey")
            }
        }
    }
    
    static var resetQuestionCounterTimestamp: Date? {
        get {
            keychain.synchronizable = true
            if let timestamp = Double(keychain.get("resetQuestionCounterTimestampKey") ?? "") {
                return Date(timeIntervalSince1970: timestamp)
            }
            return nil
        }
        set {
            if let value = newValue {
                keychain.synchronizable = true
                keychain.set(String(value.timeIntervalSince1970), forKey: "resetQuestionCounterTimestampKey")
            } else {
                keychain.delete("resetQuestionCounterTimestampKey")
            }
        }
    }
}
