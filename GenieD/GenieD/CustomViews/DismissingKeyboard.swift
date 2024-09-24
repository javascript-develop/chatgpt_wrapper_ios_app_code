//
//  DismissingKeyboard.swift
//  GenieD
//
//  Created by OK on 16.03.2023.
//

import SwiftUI

struct DismissingKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                Utils.keyWindow?.endEditing(true)
            }
    }
}
