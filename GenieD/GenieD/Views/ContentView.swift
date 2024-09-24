//
//  ContentView.swift
//  GenieD
//
//  Created by Oleksiy Kryvtsov on 28.02.2023.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.scenePhase) var scenePhase
    @EnvironmentObject var googleDriveManager: GoogleDriveManager
    @State var onboardingWasShown = LocalStorage.shared.onboardingWasShown
    @State var paywallWasShown = LocalStorage.shared.onboardingWasShown || BuyProService.shared.subscribed
    
    var body: some View {
        Group {
            if onboardingWasShown {
                if paywallWasShown {
                    HomeView()
                } else {
                    PaywallView(isOnboarding: true) {
                        paywallWasShown = true
                    }
                }
            } else {
                OnboardingView() {
                    LocalStorage.shared.onboardingWasShown = true
                    onboardingWasShown = true
                }
            }
        }
        .onAppear {
            FirestoreManager.shared.fetchSystem {}
            handleActivePhase()
            googleDriveManager.restoreSignIn()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                handleActivePhase()
            }
        }
    }
    
    private func handleActivePhase() {
        ServerTimeManager.shared.updateServerTime()
        if LocalStorage.shared.questionsCountForReview >= 2 {
            LocalStorage.shared.questionsCountForReview = 0
            Utils.requestReview()
        }
    }
}

