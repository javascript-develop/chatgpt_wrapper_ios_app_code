//
//  ChooseLanguageView.swift
//  GenieD
//
//  Created by OK on 20.03.2023.
//

import SwiftUI

struct ChooseLanguageView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var localizationService: LocalizationService
    @ObservedObject private var viewModel = ChooseLanguageViewModel()
    
    var body: some View {
            ZStack {
                CustomColor.grayBg.ignoresSafeArea()
                VStack(spacing: 0){
                    topBar()
                    VStack(spacing: 0){
                        VSpacer(5.scaled)
                        HStack {
                            Text("Language".localized())
                                .font(CustomFont.headerLarge(.bold))
                            Spacer()
                        }
                        .padding(.horizontal, 20.scaled)
                        VSpacer(25.scaled)
                        ScrollView() {
                            sectionView()
                                .padding(.horizontal, 20.scaled)
                        }
                    }
                }
                
            }
            .foregroundColor(CustomColor.blackText)
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
    
    private func sectionView() -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                ForEach(viewModel.allLanguages.indices, id: \.self) { index in
                    menuItem(viewModel.allLanguages[index])
                    if index < viewModel.allLanguages.count - 1 {
                        CustomColor.grayBg.frame(height: 1)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 20.scaled)
                    .fill(CustomColor.mainBg)
            }
            VSpacer(20.scaled)
        }
    }
    
    private func menuItem(_ language: Language) -> some View {
        Button(action: {
            Utils.hapticFeedback()
            viewModel.onLanguageSelected(language)
        }) {
            HStack(spacing: 0){
                HSpacer(18.scaled)
                Text(language.title)
                    .font(CustomFont.body(.bold))
                Spacer()
                if localizationService.language == language {
                    SystemImage("checkmark", width: 18.scaled)
                        .foregroundColor(.green)
                } else {
                    HSpacer(8.scaled)
                }
                
                HSpacer(14.scaled)
            }
        }
        .foregroundColor(CustomColor.blackText)
        .frame(minHeight: 69.scaled)
    }
    
    private func dissmiss() {
        presentationMode.wrappedValue.dismiss()
    }
}



