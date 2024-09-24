//
//  HSpacer.swift
//  GenieD
//
//  Created by OK on 08.03.2023.
//

import SwiftUI

struct HSpacer: View {
    
    private let width: CGFloat
    
    init(_ width: CGFloat) {
        self.width = width
    }
    
    var body: some View {
        Rectangle().fill(.clear).frame(width: width)
    }
}
