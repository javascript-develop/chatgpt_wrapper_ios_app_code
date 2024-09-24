//
//  DrawerView.swift
//  GenieD
//
//  Created by OK on 08.03.2023.
//

import SwiftUI

struct DrawerView<MainContent: View, DrawerContent: View>: View {
        
    @Binding var isOpened: Bool
    let drowerWidth: CGFloat
    @State private var skipFirstOffsetChanged = true
    @State private var isDrawerAnimationApdating = false
    @State private var overlayOpacity: CGFloat = 0
    private let overlayMaxOpacity = 0.5
    private let main: () -> MainContent
    private let drawer: () -> DrawerContent
    private let overlap: CGFloat = 0.84
    private let overlayColor = Color.black
    private let secondViewId = "secondViewId"
    private let firstViewId = "firstViewId"
        
    init(drowerWidth: CGFloat, isOpen: Binding<Bool>,
         @ViewBuilder main: @escaping () -> MainContent,
         @ViewBuilder drawer: @escaping () -> DrawerContent) {
        self.drowerWidth = drowerWidth
        self._isOpened = isOpen
        self.main = main
        self.drawer = drawer
    }
    
    var body: some View {
        UIScrollViewWrapper(isOpened: $isOpened, onChangeOffset: { offset in
            onOffsetChanged(offset)
        }) {
            HStack(spacing: 0) {
                drawer()
                    .frame(width: drowerWidth)
                main()
                    .overlay {
                        mainOverlay()
                    }
            }
            .frame(height: UIScreen.main.bounds.height)
            .ignoresSafeArea()
        }
        .ignoresSafeArea()
    }
    
    private func mainOverlay() -> some View {
        ZStack {
            if overlayOpacity < 0.01 {
                EmptyView()
            } else {
                overlayColor.opacity(overlayOpacity)
                    .onTapGesture {
                        withAnimation {
                            isOpened = false
                        }
                    }
            }
        }
    }
    
    private func onOffsetChanged(_ value: CGFloat) {
        overlayOpacity = abs(overlayMaxOpacity * (1.0 - (value / drowerWidth)))
    }
}

struct ViewOffsetKey: PreferenceKey {
    typealias Value = CGFloat
    static var defaultValue = CGFloat.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value += nextValue()
    }
}
