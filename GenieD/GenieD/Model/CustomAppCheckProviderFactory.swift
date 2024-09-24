//
//  CustomAppCheckProviderFactory.swift
//  GenieD
//
//  Created by OK on 08.11.2023.
//

import Foundation

import Foundation
import FirebaseAppCheck
import Firebase

class CustomAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
    
    func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
        return AppAttestProvider(app: app)
    }
}
