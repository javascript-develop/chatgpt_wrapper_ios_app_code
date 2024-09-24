//
//  Constants.swift
//  GenieD
//
//  Created by OK on 28.02.2023.
//

import SwiftUI


let isIPhoneX = UIScreen.main.bounds.height / UIScreen.main.bounds.width > 2.0

struct CustomFont {
    static func body(_ weight: Font.Weight = .regular) -> Font {
        Font.system(size: 15.scaled, weight: weight)
    }
    static func bodySmall(_ weight: Font.Weight = .regular) -> Font {
        Font.system(size: 13.scaled, weight: weight)
    }
    static func header(_ weight: Font.Weight = .regular) -> Font {
        Font.system(size: 20.scaled, weight: weight)
    }
    static func headerLarge(_ weight: Font.Weight = .regular) -> Font {
        Font.system(size: 30.scaled, weight: weight)
    }
    static func button(_  weight: Font.Weight = .regular) -> Font {
        Font.system(size: 20.scaled, weight: weight)
    }
    
    static func buttonSmall(_  weight: Font.Weight = .regular) -> Font {
        Font.system(size: 15.scaled, weight: weight)
    }
}

struct CustomColor {
    static let mainBg = Color.white
    static let graySeparator = Color("graySeparator")//#F3F3F6
    static let green = Color("green")//#5C9D82
    static let greenBorder = Color("greenBorder")//#489677
    static let blackText = Color.black
    static let whiteText = Color.white
    static let textGray = Color("textGray")//#838589
    static let textGrayLight = Color("textGrayLight")//#E0E2E6
    static let blackBg = Color("blackBg")//#2D3843
    static let grayBg = Color("grayBg")//#F1F1F4
    static let logoGreen = Color("logoGreen") //9EE5DB
}

struct Constants {
    struct Link {
        static let iTunesUrl = "https://itunes.apple.com/app/id6446223839"
        static let terms = URL(string: "https://nisos.co.uk/terms")!
        static let privacy = URL(string: "https://nisos.co.uk/privacy")!
    }
}

struct Test {
    static let textSetTo = "Test Leo. Change temp to "
    static let textTemperatureIsSetTo = "Temperature is set to "
    static let textError = "Error setting temperature. Temperature must be set between 0 and 2"
}
