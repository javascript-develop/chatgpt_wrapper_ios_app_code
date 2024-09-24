//
//  SettingsViewModel.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import Foundation

class SettingsViewModel: ObservableObject {
    
    @Published var sections: [SettingsSection] = [
        SettingsSection(title: "Settings",
                        items: [.language, .yourPlan, .voice]),
        SettingsSection(title: "Support",
                        items: [.restorePurchases]),
        SettingsSection(title: "About",
                        items: [.rateUs, .shareWithFriends, .termsOfUse, .privacyPolicy]),
    ]
    
    @Published var showBuyPro = false
    @Published var showVoice = false
    @Published var showChooseLaguage = false
    @Published var isLoading = false
    @Published var showingAlert = false
    @Published var alertMessage = ""

    
    //MARK: - Actions
    
    func onTapMenuItem(_ item: SectionItem) {
        switch item {
        case .language:
            showChooseLaguage = true
        case .yourPlan:
            showBuyPro = true
        case .voice:
            showVoice = true
        case .help:
            ()
        case .restorePurchases:
            onRestorePurchases()
        case .rateUs:
            Utils.writeReview()
        case .shareWithFriends:
            Utils.shareApp()
        case .termsOfUse:
            Utils.onLinkAction(link: Constants.Link.terms)
        case .privacyPolicy:
            Utils.onLinkAction(link: Constants.Link.privacy)
        }
    }
    
    private func onRestorePurchases() {
        isLoading = true
        BuyProService.shared.restore { [weak self] message, success in
            guard let self = self else { return }
            
            self.isLoading = false
            self.alertMessage = message
            self.showingAlert = true
        }
    }
}

