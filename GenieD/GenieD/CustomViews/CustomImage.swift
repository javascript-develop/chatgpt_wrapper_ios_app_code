//
//  CustomImage.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import SwiftUI

struct CustomImage: View {
    
    private let name: String
    private let width: CGFloat
    private let height: CGFloat
    
    init(_ name: String, width: CGFloat, height: CGFloat) {
        self.name = name
        self.width = width
        self.height = height
    }
    
    var body: some View {
        Image(name)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: height)
    }
}
