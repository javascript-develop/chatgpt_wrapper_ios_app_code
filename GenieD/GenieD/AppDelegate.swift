//
//  AppDelegate.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        BuyProService.shared.completeTransactions()
        BuyProService.shared.retrieveProductInfo {}
        
        FirebaseApp.configure()
    
        // Commented out App Check setup for testing
        /*
        let factory: AppCheckProviderFactory!
        
        #if DEBUG
            factory = AppCheckDebugProviderFactory()
        #else
            factory = AppAttestProviderFactory()
        #endif
        
        AppCheck.setAppCheckProviderFactory(factory)
        */
        
        // Handle user authentication
        if Auth.auth().currentUser == nil {
            FirestoreManager.shared.signIn(email: SwiftConfiguration.current.firebaseLogin, password: SwiftConfiguration.current.firebasePassword) { error in
                // Handle sign-in error if needed
            }
        }
        
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
        
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
}
