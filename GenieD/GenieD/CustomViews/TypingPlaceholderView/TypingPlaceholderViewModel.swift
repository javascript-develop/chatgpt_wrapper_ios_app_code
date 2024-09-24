//
//  TypingPlaceholderViewModel.swift
//  GenieD
//
//  Created by OK on 30.04.2023.
//

import SwiftUI

class TypingPlaceholderViewModel: ObservableObject {
    
    @Published var text = ""
    private var finalText = ""
    private var randomTexts: [String]
    private let texts: [String]
    private let typingDelay = 0.055
    
    init(texts: [String]) {
        self.texts = texts
        self.randomTexts = texts
    }
    
    private func typeWriter(at position: Int = 0) {
        if position == 0 {
            text = ""
        }
        if position < finalText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) { [weak self] in
                guard let self = self else { return }
                
                if !self.text.isEmpty {
                    self.text.removeLast()
                }
                
                self.text.append(self.finalText[position])
                if position + 1 < self.finalText.count {
                    self.text.append("_")
                }
                self.typeWriter(at: position + 1)
            }
        } else {
            restartWithNewText()
        }
    }
    
    private func restartWithNewText() {
        setFinalText()
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            guard let self = self else { return }
            
            self.typeWriter()
        }
    }
    
    private func setFinalText() {
        if randomTexts.isEmpty {
            randomTexts = texts
        }
        let randomIndex = randomTexts.indices.randomElement() ?? 0
        finalText = randomTexts[randomIndex]
        randomTexts.remove(at: randomIndex)
    }
    
    //MARK: - Actions
    func onViewAppear() {
        setFinalText()
        typeWriter()
    }
}
