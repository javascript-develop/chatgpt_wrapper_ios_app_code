//
//  String.swift
//  GenieD
//
//  Created by OK on 21.03.2023.
//

import Foundation

extension String {
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        return Range(nsRange, in: self)
    }
    
    func localized() -> String {
        let resultLang = LocalizationService.shared.language
        let path = Bundle.main.path(forResource: resultLang.rawValue, ofType: "lproj")
        let bundle: Bundle
        if let path = path {
            bundle = Bundle(path: path) ?? .main
        } else {
            bundle = .main
        }
        return localized(bundle: bundle)
    }

    private func localized(bundle: Bundle) -> String {
        return NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")
    }
}
