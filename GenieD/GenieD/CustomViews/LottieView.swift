//
//  LottieView.swift
//  GenieD
//
//  Created by OK on 29.03.2023.
//

import UIKit
import SwiftUI
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce

    var animationView = LottieAnimationView()
    let onStartAnimated: ((TimeInterval)->Void)?

    func makeUIView(context: UIViewRepresentableContext<LottieView>) -> UIView {
        let view = UIView(frame: .zero)

        animationView.animation = LottieAnimation.named(name)
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = loopMode
        animationView.play()
        onStartAnimated?(animationView.animation?.duration ?? 0.0)

        animationView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(animationView)

        NSLayoutConstraint.activate([
            animationView.heightAnchor.constraint(equalTo: view.heightAnchor),
            animationView.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        return view
    }

    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<LottieView>) {}
}
