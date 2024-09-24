//
//  AnimatedSplashView.swift
//  GenieD
//
//  Created by OK on 29.03.2023.
//

import SwiftUI
import AppTrackingTransparency

struct AnimatedSplashView: View {
    
    @Binding var isActive: Bool
    
    var body: some View {
        ZStack {
            CustomColor.logoGreen
            LottieView(name: "SplashLoading", loopMode: .playOnce) { duration in
                DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                    isActive = false
                }
            }
        }
        .ignoresSafeArea()
    }
}
