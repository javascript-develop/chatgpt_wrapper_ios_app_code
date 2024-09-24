//
//  GenieDApp.swift
//  GenieD
//
//  Created by Oleksiy Kryvtsov on 28.02.2023.
//

import SwiftUI

@main
struct GenieDApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    let persistenceController = PersistenceController.shared
    
    @State var showSizeMenu = false
    @State private var isShowingSplash = true

    var body: some Scene {
        WindowGroup {
            if isShowingSplash {
                AnimatedSplashView(isActive: $isShowingSplash)
            } else {
                ContentView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .environmentObject(BuyProService.shared)
                    .environmentObject(LocalizationService.shared)
                    .environmentObject(ServerTimeManager.shared)
                    .environmentObject(FirestoreManager.shared)
                    .environmentObject(LocalStorage.shared)
                    .environmentObject(GoogleDriveManager.shared)
            }
        }
    }
}
