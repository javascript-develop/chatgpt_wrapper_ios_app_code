//
//  SettingsView.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import Foundation

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var buyProService: BuyProService
    @StateObject private var viewModel = SettingsViewModel()
    
    var body: some View {
        contentView()
            .fullScreenCover(isPresented: $viewModel.showBuyPro) {
                PaywallView()
            }
            .fullScreenCover(isPresented: $viewModel.showVoice) {
                VoiceView()
            }
            .fullScreenCover(isPresented: $viewModel.showChooseLaguage) {
                ChooseLanguageView()
            }
            .alert(isPresented: $viewModel.showingAlert) {
                Alert(title: Text(""), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK".localized())){})
            }
    }
    
    private func contentView() -> some View {
        ZStack {
            CustomColor.grayBg.ignoresSafeArea()
            VStack(spacing: 0) {
                topBar()
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        VSpacer(5.scaled)
                        if buyProService.activeSubscription == nil {
                            buyProBanner()
                            VSpacer(15.scaled)
                        }
                        ForEach(viewModel.sections) {
                            sectionView($0)
                                .padding(.horizontal, 15.scaled)
                        }
                        VSpacer(20.scaled)
                        if let version = Utils.appVersion {
                            appVersionView(version)
                        }
                    }
                }
            }
            if viewModel.isLoading {
                LoadingView()
                    .ignoresSafeArea()
            }
        }
    }
    
    private func topBar() -> some View {
        ZStack() {
            Capsule()
                .fill(CustomColor.textGrayLight)
                .frame(width: 38, height: 4)
        }
        .frame(height: 50)
    }
    
    private func sectionView(_ section: SettingsSection) -> some View {
        VStack(spacing: 0) {
            VSpacer(20.scaled)
            HStack {
                HSpacer(10.scaled)
                Text(section.title.localized().uppercased())
                    .font(CustomFont.body(.bold))
                    .foregroundColor(CustomColor.textGray)
                Spacer()
            }
            VSpacer(10.scaled)
            VStack(spacing: 0) {
                ForEach(section.items.indices, id: \.self) {
                    sectionItemView(section.items[$0])
                    if $0 < section.items.count - 1 {
                        CustomColor.grayBg.frame(height: 1)
                    }
                }
            }
            .background {
                RoundedRectangle(cornerRadius: 20.scaled)
                    .fill(CustomColor.mainBg)
            }
        }
    }
    
    private func sectionItemView(_ item: SectionItem) -> some View {
        Button(action: {
            Utils.hapticFeedback()
            viewModel.onTapMenuItem(item)
        }) {
            HStack(spacing: 0){
                HSpacer(14.scaled)
                ZStack {
                    RoundedRectangle(cornerRadius: 10.scaled)
                        .fill(CustomColor.grayBg)
                    CustomImage(item.iconImage, width: 26.scaled, height: 26.scaled)
                }
                .frame(width: 38.scaled, height: 38.scaled)
                HSpacer(20.scaled)
                Text(item.title)
                    .font(CustomFont.body(.bold))
                Spacer()
                if item == .yourPlan, let access = buyProService.activeSubscription?.access {
                    Text(access.title)
                        .font(CustomFont.body(.bold))
                        .foregroundColor(CustomColor.green)
                }
                HSpacer(14.scaled)
                SystemImage("chevron.forward", width: 8.scaled)
                    .foregroundColor(CustomColor.textGrayLight)
                HSpacer(14.scaled)
            }
        }
        .foregroundColor(CustomColor.blackText)
        .frame(minHeight: 69.scaled)
    }
    
    private func buyProBanner() -> some View {
        BuyProBanner()
            .padding(.horizontal, 15.scaled)
        .onTapGesture {
            viewModel.showBuyPro = true
        }
    }
    
    private func appVersionView(_ version: String) -> some View {
        VStack(spacing: 0) {
            VSpacer(30.scaled)
            Text("v" + version)
                .font(CustomFont.bodySmall(.bold))
                .foregroundColor(CustomColor.textGray)
            VSpacer(20.scaled)
        }
    }
}

extension SectionItem {
    var iconImage: String {
        switch self {
        case .language:
            return "language"
        case .yourPlan:
            return "crown"
        case .voice:
            return "volume_up"
        case .help:
            return "Support"
        case .restorePurchases:
            return "replay_black"
        case .rateUs:
            return "star"
        case .shareWithFriends:
            return "share_f"
        case .termsOfUse:
            return "description"
        case .privacyPolicy:
            return "verified_user"
        }
    }
    
    var title: String {
        switch self {
        case .language:
            return "Language".localized()
        case .yourPlan:
            return "Your Plan".localized()
        case .voice:
            return "Voice".localized()
        case .help:
            return "Support".localized()
        case .restorePurchases:
            return "Restore Purchases".localized()
        case .rateUs:
            return "Rate Us".localized()
        case .shareWithFriends:
            return "Share with Friends".localized()
        case .termsOfUse:
            return "Terms of Use".localized()
        case .privacyPolicy:
            return "Privacy Policy".localized()
        }
    }
}
