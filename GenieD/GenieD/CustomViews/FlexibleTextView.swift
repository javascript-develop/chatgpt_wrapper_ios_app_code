//
//  FlexibleTextView.swift
//  GenieD
//
//  Created by OK on 03.03.2023.
//

import SwiftUI

struct FlexibleTextView: View {
    
    var text: Binding<String>
    var isFocused: FocusState<Bool>.Binding
    //private let placeholderText = "Speak your mind to Leo".localized()
    private let placeholderText = ""
    private var fontSize: CGFloat { 20.scaled }
    private let lineLimit = 4
    
    var body: some View {
        if #available(iOS 16.0, *) {
            TextField(
                "free_form",
                text: text,
                prompt: Text(placeholderText).foregroundColor(CustomColor.textGray),
                axis: .vertical
            )
            .lineLimit(lineLimit)
            .font(.system(size: fontSize))
            .background(Color.clear)
            .focused(isFocused, equals: true)
        } else {
            TextEditorView(placeholderText: placeholderText, text: text, fontSize: fontSize, lineLimit: lineLimit, isFocused: isFocused)
        }
    }
}

struct TextEditorView: View {

    var isFocused: FocusState<Bool>.Binding
    var text: Binding<String>
    @State var textEditorHeight: CGFloat
    private let fontSize: CGFloat
    private let lineLimit: Int
    private let placeholderText: String

    init(placeholderText: String, text: Binding<String>, fontSize: CGFloat, lineLimit: Int, isFocused: FocusState<Bool>.Binding) {
        self.placeholderText = placeholderText
        self.text = text
        self.fontSize = fontSize
        self.lineLimit = lineLimit
        self.textEditorHeight = fontSize
        self.isFocused = isFocused
    }

    var body: some View {
        ZStack(alignment: .leading) {
            Text(text.wrappedValue.isEmpty ? placeholderText : text.wrappedValue)
                .lineLimit(lineLimit)
                .font(.system(size: fontSize))
                .lineSpacing(0)
                .foregroundColor(text.wrappedValue.isEmpty ? CustomColor.textGray : .clear)
                .background(GeometryReader {
                    Color.clear.preference(key: ViewHeightKey.self,
                                           value: $0.frame(in: .local).size.height)
                })
            
            TextEditor(text: text)
                .font(.system(size: fontSize))
                .lineSpacing(0)
                .focused(isFocused, equals: true)
                .onAppear {
                    let hPadding: CGFloat = 4.8//TODO:
                    UITextView.appearance().backgroundColor = .clear
                    UITextView.appearance().textContainerInset = UIEdgeInsets(top: 0, left: -hPadding, bottom: 0, right: -hPadding)
                }
                .background(.clear)
                .frame(height: max(fontSize, textEditorHeight))
            
        }.onPreferenceChange(ViewHeightKey.self) {
            textEditorHeight = $0
        }
    }
}

struct ViewHeightKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = value + nextValue()
    }
}
