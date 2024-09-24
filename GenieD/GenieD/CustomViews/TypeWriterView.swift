//
//  TypeWriterView.swift
//  GenieD
//
//  Created by OK on 04.03.2023.
//

import SwiftUI

struct TypeWriterView: View {
    
    @Binding var isFastTyping: Bool
    @State var text: String = ""
      
    let finalText: String
    let didFinishTyping: (()->Void)?
    let onTextRemain: ((String)->Void)?
    var typingDelay: TimeInterval {
        isFastTyping ? 0.014 : 0.055
    }
    
    init(finalText: String, isFastTyping: Binding<Bool>, didFinishTyping: @escaping ()->Void, onTextRemain: @escaping (String)->Void) {
        self.finalText = finalText
        self._isFastTyping = isFastTyping
        self.didFinishTyping = didFinishTyping
        self.onTextRemain = onTextRemain
    }
    
    var body: some View {
        Text(text)
            .onAppear {
                typeWriter()
            }
    }
    
    func typeWriter(at position: Int = 0) {
        if position == 0 {
            text = ""
        }
        if position < finalText.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + typingDelay) {
                if !text.isEmpty {
                    text.removeLast()
                }
                
                text.append(finalText[position])
                onTextRemain?(finalText.replacingOccurrences(of: text, with: ""))
                if position + 1 < finalText.count {
                    text.append("_")
                }
                typeWriter(at: position + 1)
            }
        } else {
            didFinishTyping?()
        }
    }
}

extension String {
    subscript(offset: Int) -> Character {
        self[index(startIndex, offsetBy: offset)]
    }
}
