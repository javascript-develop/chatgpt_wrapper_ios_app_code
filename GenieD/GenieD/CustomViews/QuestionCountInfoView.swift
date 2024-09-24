//
//  QuestionCountInfoView.swift
//  GenieD
//
//  Created by OK on 01.04.2023.
//

import SwiftUI

struct QuestionCountInfoView: View {
    @EnvironmentObject var buyProService: BuyProService
    @EnvironmentObject var firestoreManager: FirestoreManager
    @EnvironmentObject var serverTimeManager: ServerTimeManager
    @EnvironmentObject var localStorage: LocalStorage
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        ZStack {
            HStack(spacing: 5.scaled) {
                Text(title)
                    .font(CustomFont.buttonSmall(.bold))
                SystemImage("sparkles", width: 15.scaled)
            }
            .padding(.vertical, 5.scaled)
            .padding(.horizontal, 10.scaled)
            .foregroundColor(CustomColor.blackText)
        }
        .background {
            Capsule()
                .fill(CustomColor.logoGreen)
        }
    }
    
    private var title: String {
        if buyProService.subscribed {
            return "Premium".localized()
        }
        
        let result = firestoreManager.freeRequests - localStorage.getAccessQuestionsCount()
        return "\(max(0, result))"
    }
}
