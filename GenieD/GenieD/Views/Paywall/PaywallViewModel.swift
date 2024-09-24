//
//  PaywallViewModel.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import Foundation

class PaywallViewModel: ObservableObject {
    @Published var selectedAccess: BuyProAccess
    @Published var selectedPeriod: SubscriptionPeriod = .year
    @Published private(set) var isLoading = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    
    init() {
//        var resultAccess = BuyProAccess.pro
//        if let access = BuyProService.shared.activeSubscription?.access, access == .pro {
//            resultAccess = .advanced
//        }
//
//        self.selectedAccess = resultAccess
        self.selectedAccess = .advanced
    }
    
    var showPurchaseControls: Bool {
        _showPurchaseControls()
    }
    
    private func fetchSubscriptions() {
        isLoading = true
        BuyProService.shared.retrieveProductInfo {
            self.isLoading = false
        }
    }
    
    func productForPeriod(_ _period: SubscriptionPeriod) -> BuyProProduct? {
        var product: BuyProProduct?
        switch selectedAccess {
        case .lite:
            switch _period {
            case .week:
                product = BuyProService.shared.allProducts.first(where: { $0.period == .liteWeek })
            case .year:
                product =  BuyProService.shared.allProducts.first(where: { $0.period == .liteYear })
            }
        case .pro:
            switch _period {
            case .week:
                product =  BuyProService.shared.allProducts.first(where: { $0.period == .proWeek })
            case .year:
                product =  BuyProService.shared.allProducts.first(where: { $0.period == .proYear })
            }
        case .advanced:
            switch _period {
            case .week:
                product =  BuyProService.shared.allProducts.first(where: { $0.period == .advancedWeek })
            case .year:
                product =  BuyProService.shared.allProducts.first(where: { $0.period == .advancedYear })
            }
        }
        return product
    }
    
    private func _showPurchaseControls() -> Bool {
        guard BuyProService.shared.isProductsReady else { return false }
        guard let purchasedAccess = BuyProService.shared.activeSubscription?.access else { return true }
        
        if purchasedAccess == .lite, selectedAccess != .lite {
            return true
        }
        
        if purchasedAccess == .pro, selectedAccess == .advanced {
            return true
        }
        
        return false
    }
    
    //MARK: Actions
    
    func onViewDidAppear() {
        if !BuyProService.shared.isProductsReady {
            fetchSubscriptions()
        }
    }
    
    func onContinueAction() {
        guard let product = productForPeriod(selectedPeriod) else { return }
        
        isLoading = true
        BuyProService.shared.purchase(product: product) { [weak self] success, error in
            guard let self = self else { return }
            
            self.isLoading = false
            if success {
                self.alertMessage = "Subscription purchased".localized()
                self.showingAlert = true
            } else {
                if(!error.isEmpty) {
                    self.alertMessage = error
                    self.showingAlert = true
                }
            }
        }
    }
}

