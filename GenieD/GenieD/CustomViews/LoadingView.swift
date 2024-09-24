//
//  LoadingView.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
            LottieView(name: "SplashLoading", loopMode: .loop) { _ in }
        }
    }
}
