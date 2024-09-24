//
//  LocalStorage.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import Foundation

class LocalStorage: ObservableObject {
    
    static let shared: LocalStorage = LocalStorage()
    
    @Published private(set) var accessQuestionsCount: Int = LocalStorage._getStoredAccessQuestionsCount()
    
    var onboardingWasShown: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "onboardingWasShownKey")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "onboardingWasShownKey")
            UserDefaults.standard.synchronize()
        }
    }
    
    var launchCount: Int {
        get {
            return UserDefaults.standard.integer(forKey: "launchCountKey")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "launchCountKey")
            UserDefaults.standard.synchronize()
        }
    }
    
    var questionsCountForReview: Int {
        get {
            UserDefaults.standard.integer(forKey: "questionsCountForReviewKey")
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "questionsCountForReviewKey")
            UserDefaults.standard.synchronize()
        }
    }
    
    var activeSubscription: Subsciption? {
        get {
            var result: Subsciption?
            if let data = UserDefaults.standard.object(forKey: "activeSubscriptionKey") as? Data,
               let decoded = try? JSONDecoder().decode(Subsciption.self, from: data) {
                if decoded.expirationDate > Date() {
                    result = decoded
                }
            }
            return result
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.setValue(encoded, forKey: "activeSubscriptionKey")
                UserDefaults.standard.synchronize()
            }
        }
    }
    
    var isSoundOff: Bool {
        get {
            return UserDefaults.standard.value(forKey: "isSoundOffKey") as? Bool ?? true
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "isSoundOffKey")
            UserDefaults.standard.synchronize()
        }
    }
    
    var temperature: Double?
    
    private var resetQuestionCounterTimestamp: Date? {
        get {
            if let keychainData = KeychainStorage.resetQuestionCounterTimestamp {
                return keychainData
            }
            if let ts = UserDefaults.standard.value(forKey: "resetQuestionCounterTimestampKey") as? Double {
                return Date(timeIntervalSince1970: ts)
            }
            return nil
        }
        set {
            KeychainStorage.resetQuestionCounterTimestamp = newValue
            UserDefaults.standard.set(newValue?.timeIntervalSince1970, forKey: "resetQuestionCounterTimestampKey")
        }
    }
    
    private static func _getStoredAccessQuestionsCount() -> Int {
        let localValue = UserDefaults.standard.integer(forKey: "_accessQuestionsCountKey")
        if let keychainData = KeychainStorage.accessQuestionsCount {
            return max(keychainData, localValue)
        }
        return localValue
    }
    
    private func _setAccessQuestionsCount(_ value: Int) {
        accessQuestionsCount = value
        KeychainStorage.accessQuestionsCount = value
        UserDefaults.standard.setValue(value, forKey: "_accessQuestionsCountKey")
        UserDefaults.standard.synchronize()
    }
    
    func getAccessQuestionsCount() -> Int {
        let access = BuyProService.shared.activeSubscription?.access
        if (access == nil || access! == .lite), let timeDifference = ServerTimeManager.shared.timeDifference {
            let tsNow = Date().addingTimeInterval(-timeDifference)
            if resetQuestionCounterTimestamp == nil || resetQuestionCounterTimestamp!.day != tsNow.day {
            //if resetQuestionCounterTimestamp == nil || (tsNow.timeIntervalSince(resetQuestionCounterTimestamp!) >= 60*60*24*7) {// 7 days
                resetQuestionCounterTimestamp = tsNow
                resetAccessQuestionCount()
            }
        }
        
        return accessQuestionsCount
    }
    
    func questionsCountIncrement() {
        _setAccessQuestionsCount(accessQuestionsCount + 1)
    }
    
    func resetAccessQuestionCount() {
        _setAccessQuestionsCount(0)
    }
}
