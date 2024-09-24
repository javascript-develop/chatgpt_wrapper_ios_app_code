//
//  BuyProService.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import Foundation
import StoreKit
import SwiftyStoreKit

class BuyProService: NSObject, ObservableObject {
    
    static let shared = BuyProService()
    
    override init() {
        super.init()
        
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return true
        }
    }
    
    @Published private(set) var allProducts = [BuyProProduct.Period.advancedWeek, BuyProProduct.Period.advancedYear].map { BuyProProduct(period: $0) }
    @Published var activeSubscription: Subsciption? = LocalStorage.shared.activeSubscription {
        didSet {
            LocalStorage.shared.activeSubscription = activeSubscription
        }
    }
    
    var productsPriceInfo: [BuyProProduct.Period : String]? {
        var result: [BuyProProduct.Period : String] = [:]
        allProducts.forEach {
            if let price = $0.priceWithCurrency {
                result[$0.period] = price
            }
        }
        return result.count == allProducts.count ? result : nil
    }
    
    var isProductsReady: Bool {
        productsPriceInfo != nil
    }
    
    var purchasedPeriod: BuyProProduct.Period? {
        activeSubscription?.period
    }

    var subscribed: Bool {
        activeSubscription != nil
    }
    
    func completeTransactions() {
        SwiftyStoreKit.completeTransactions(atomically: true) { (purchases) in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    // Unlock content
                    self.verifyPurchases(purchaseDate: purchase.originalPurchaseDate) {}
                    
                case .failed, .purchasing, .deferred:
                    break // do nothing
                default:
                    break
                }
            }
        }
    }
    
    func retrieveProductInfo(completion: (()->Void)? = nil) {
        let products = Set(allProducts.map{$0.id})

        SwiftyStoreKit.retrieveProductsInfo(products) { (result) in
            guard result.error == nil else {
                print("Retrieved Products ERROR = \(result.error!.localizedDescription)")
                completion?()
                return
            }

            for product in result.retrievedProducts {
                let priceString = product.localizedPrice!
                print("Retrieved Product: \(product.localizedDescription), price: \(priceString)")
            }

            for invalidProductId in result.invalidProductIDs {
                print("Invalid product identifier: \(invalidProductId)")
            }

            for index in 0..<self.allProducts.count {
                self.allProducts[index].skProduct = result.retrievedProducts.first(where: { $0.productIdentifier == self.allProducts[index].id })
            }

            completion?()
        }
    }
    
    func purchase(product: BuyProProduct, completion: @escaping (_ success: Bool, _ error: String) -> Void) {
        
        print("#### purchase product: id = \(product.id)")
        SwiftyStoreKit.purchaseProduct(product.id) { (result) in
            switch result {
            case .success(let details):
                self.verifyPurchases(purchaseDate: details.originalPurchaseDate) {
                    if self.subscribed {
                        LocalStorage.shared.resetAccessQuestionCount()
                        completion(true, "")
                    } else {
                        completion(false, "Unknown error. Please contact support".localized())
                    }
                }
            case .error(let error):
                switch error.code {
                case .unknown: completion(false, "Sorry, the purchase is unavailable for an unknown reason. Please try again later".localized())
                case .clientInvalid: completion(false, "The purchase cannot be completed. Please, change your account or device".localized())
                case .paymentCancelled: completion(false, "")
                case .paymentInvalid: completion(false, "Your purchase was declined. Please, check the payment details and make sure there are enough funds in your account".localized())
                case .paymentNotAllowed: completion(false, "The purchase is not available for the selected payment method. Please, make sure your payment method allows you to make online purchases".localized())
                case .storeProductNotAvailable: completion(false, "This product is not available in your region. Please, change the store and try again".localized())
                case .cloudServicePermissionDenied:completion(false, "Access to cloud service information is not allowed".localized())
                case .cloudServiceNetworkConnectionFailed: completion(false, "The purchase cannot be completed because your device is not connected to the Internet. Please, try again later with a stable internet connection".localized())
                case .cloudServiceRevoked: completion(false, "Sorry, an error has occurred".localized())
                case .privacyAcknowledgementRequired: completion(false, "The purchase cannot be completed because you have not accepted the terms of use of the AppStore. Please, confirm your consent in the settings and then return to the purchase".localized())
                case .unauthorizedRequestData: completion(false, "An error has occurred. Please, try again later".localized())
                case .invalidOfferIdentifier: completion(false, "The promotional offer is invalid or expired".localized())
                case .invalidSignature: completion(false, "Sorry, an error has occurred when applying the promo code. Please, try again later".localized())
                case .missingOfferParams: completion(false, "Sorry, an error has occurred when applying the promo offer. Please, try again later".localized())
                case .invalidOfferPrice: completion(false, "Sorry, your purchase cannot be completed. Please, try again later".localized())
                    
                default: completion(false, error.localizedDescription)
                }
            }
        }
    }
    
    private func updateSubscriptionsWithReceipt(_ receipt: ReceiptInfo, purchaseDate: Date?) {
        for product in allProducts {
            let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: product.id, inReceipt: receipt)
            switch purchaseResult {
            case .purchased(let expiryDate, _):
                print("✅ product: \(product.id) is valid until \(expiryDate)\n")
                let currentSub = Subsciption(period: product.period, expirationDate: expiryDate)
                if activeSubscription == nil || activeSubscription!.priority < currentSub.priority {
                    activeSubscription = currentSub
                }
                NotificationCenter.default.post(name: NSNotification.ProductPurchased,
                                                                object: nil, userInfo: nil)
            case .expired(let expiryDate, _):
                print("\(product.id) is expired since \(expiryDate)\n")
            case .notPurchased:
                    print("The user has never purchased \(product.id)")
            }
        }
    }
    
    func verifyPurchases(purchaseDate: Date?, completion: @escaping () -> Void) {
        var service: AppleReceiptValidator.VerifyReceiptURLType = .production
        #if DEBUG
            service = .sandbox
        #endif
        let appleValidator = AppleReceiptValidator(service: service, sharedSecret: sharedSecret)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            self.activeSubscription = nil
            
            switch result {
            case .success(let receipt):
                self.updateSubscriptionsWithReceipt(receipt, purchaseDate: purchaseDate)
            case .error(let error):
                print("Receipt verification failed: \(error)")
            }
            
            completion()
        }
    }
    
    func restore(completion: @escaping (_ message: String, _ success: Bool) -> Void) {
        SwiftyStoreKit.restorePurchases(atomically: true) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
                completion("Restore failed".localized(), false)
            }
            else if results.restoredPurchases.count > 0 {
                self.verifyPurchases(purchaseDate: nil) {
                    if self.subscribed {
                        completion("Restored Successfully".localized(), true)
                    } else {
                        completion("Nothing to Restore".localized(), true)
                    }
                }
            }
            else {
                completion("Nothing to Restore".localized(), true)
            }
        }
    }
}

extension NSNotification {
    static let ProductPurchased = Notification.Name.init("ProductPurchased")
}
