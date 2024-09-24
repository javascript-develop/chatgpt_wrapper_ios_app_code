//
//  SystemImage.swift
//  GenieD
//
//  Created by OK on 03.03.2023.
//

import SwiftUI

struct SystemImage: View {
    
    private let name: String
    private let width: CGFloat
    
    init(_ name: String, width: CGFloat) {
        self.name = name
        self.width = width
    }
    
    var body: some View {
        Image(systemName: name)
            .resizable()
            .scaledToFit()
            .frame(width: width, height: width)
    }
}


