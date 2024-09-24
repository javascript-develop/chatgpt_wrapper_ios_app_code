//
//  VoiceView.swift
//  GenieD
//
//  Created by OK on 14.03.2023.
//

import SwiftUI

struct VoiceView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State private var isSoundOn = !LocalStorage.shared.isSoundOff
    
    var body: some View {
            ZStack {
                CustomColor.mainBg.ignoresSafeArea()
                VStack(spacing: 0){
                    topBar()
                    VStack(spacing: 0){
                        VSpacer(5.scaled)
                        HStack {
                            Text("Voice")
                                .font(CustomFont.headerLarge(.bold))
                            Spacer()
                        }
                        VSpacer(25.scaled)
                        switchView()
                        VSpacer(20.scaled)
                        HStack {
                            Text("This setting can be overriden on the chat screen by tapping on the sound icon.".localized())
                                .font(CustomFont.body(.bold))
                                .foregroundColor(CustomColor.textGray)
                            Spacer()
                        }
                    }
                    .padding(.horizontal, 20.scaled)
                    Spacer()
                }
                
            }
            .foregroundColor(CustomColor.blackText)
            .onChange(of: isSoundOn) { newValue in
                LocalStorage.shared.isSoundOff = !newValue
            }
    }
    
    private func topBar() -> some View {
        ZStack {
            HStack(spacing: 0) {
                Button(action: {
                    Utils.hapticFeedback()
                    dissmiss()
                }) {
                    SystemImage("arrow.backward", width: 25.scaled)
                        .padding(10)
                }
                .padding(.leading, 15.scaled)
                Spacer()
            }
        }
        .frame(height: 60.scaled)
    }
    
    private func switchView() -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20.scaled)
                .fill(CustomColor.grayBg)
            HStack {
                Text("Spoken Responses".localized())
                    .font(CustomFont.body(.bold))
                Spacer()
                Toggle("", isOn: $isSoundOn)
            }
            .padding(.horizontal, 20.scaled)
        }
        .frame(height: 78.scaled)
    }
    
    private func dissmiss() {
        presentationMode.wrappedValue.dismiss()
    }
}
