//
//  TypingPlaceholderView.swift
//  GenieD
//
//  Created by OK on 30.04.2023.
//

import SwiftUI

struct TypingPlaceholderView: View {
    
    @StateObject var viewModel: TypingPlaceholderViewModel
    let onTapAction: (()->Void)?
       
    init(texts: [String], onTapAction: @escaping ()->Void) {
        _viewModel = StateObject(wrappedValue: TypingPlaceholderViewModel(texts: texts))
        self.onTapAction = onTapAction
    }
    
    var body: some View {
        ZStack {
            Color.clear
            ScrollView(.horizontal) {
                Text(viewModel.text)
                    .font(Font.system(size: 15.scaled))
                    .lineLimit(1)
                    .foregroundColor(CustomColor.textGray)
                    .padding(.horizontal, 15.scaled)
            }
            .disabled(true)
        }
        .onTapGesture {
            onTapAction?()
        }
        .onAppear {
            viewModel.onViewAppear()
        }
    }
}

