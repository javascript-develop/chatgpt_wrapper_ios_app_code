//
//  LoadingView.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import SwiftUI

struct DotsLoadingView: View {
    
    @State private var currentIndex = 0
    
    var body: some View {
        HStack {
            DotView(isHidden: false)
            DotView(isHidden: currentIndex == 0)
            DotView(isHidden: currentIndex != 2)
        }
        .onAppear {
            updateIndex()
        }
    }
    
    private func updateIndex() {
        if currentIndex < 2 {
            currentIndex += 1
        } else {
            currentIndex = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            updateIndex()
        }
    }
}

struct DotView: View {
    let isHidden: Bool
    var body: some View {
        Circle()
            .fill(CustomColor.textGrayLight)
            .frame(width: 10.scaled, height:10.scaled)
            .opacity(isHidden ? 0 : 1)
    }
}

