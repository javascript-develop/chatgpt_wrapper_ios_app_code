//
//  HomeViewModel.swift
//  GenieD
//
//  Created by OK on 28.02.2023.
//

import Foundation

class HomeViewModel: ObservableObject {
    
    private let openAIService = OpenAIService()
    @Published var showBuyPro = false
    @Published var tagSelection: String?
    @Published var showingUpgradeAlert = false
    
    func onShowBuyPro() {
        showBuyPro = true
    }
    
    //MARK: - Actions
    
//    func onQuestionAction() {
//        tagSelection = "AskQuestionView"
//    }
//
//    func onDialogAction() {
//        if BuyProService.shared.activeSubscription?.access == .advanced {
//            tagSelection = "AskQuestionViewDialog"
//        } else {
//            showBuyPro(selectedAccess: .advanced)
//        }
//    }
   
}
