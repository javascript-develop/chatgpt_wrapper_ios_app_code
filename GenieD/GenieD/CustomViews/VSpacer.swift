//
//  VSpacer.swift
//  GenieD
//
//  Created by OK on 28.02.2023.
//

import SwiftUI

struct VSpacer: View {
    
    private let height: CGFloat
    
    init(_ height: CGFloat) {
        self.height = height
    }
    
    var body: some View {
        Rectangle().fill(.clear).frame(height: height)
    }
}

