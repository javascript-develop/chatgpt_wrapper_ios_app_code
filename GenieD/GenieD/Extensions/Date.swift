//
//  Date.swift
//  GenieD
//
//  Created by OK on 15.03.2023.
//

import Foundation

extension Date {
    
    var day: Int? {
        Calendar.current.dateComponents([.day], from: self).day
    }
    
    func formatedString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        return dateFormatter.string(from: self)
    }
    
    func formatedStringDayMonthYear() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM yyyy"
        dateFormatter.locale = Locale(identifier: LocalizationService.shared.language.rawValue)
        return dateFormatter.string(from: self)
    }
}
