//
//  BuyProBanner.swift
//  GenieD
//
//  Created by OK on 14.03.2023.
//

import SwiftUI

struct BuyProBanner: View {
    @EnvironmentObject var localizationService: LocalizationService
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.scaled)
                .fill(CustomColor.blackBg)
            HStack(spacing: 0) {
                HSpacer(18.scaled)
                CustomImage("gift", width: 32, height: 32)
                HSpacer(13.scaled)
                Text("Try Leo 3 days for free. Tap to activate premium.".localized())
                    .font(CustomFont.body(.bold))
                    .foregroundColor(CustomColor.whiteText)
                Spacer()
                HSpacer(13.scaled)
                
                SystemImage("chevron.right", width: 10.scaled)
                    .foregroundColor(.brown)
                HSpacer(18.scaled)
            }
        }
        .frame(height: 70.scaled)
        .contentShape(Rectangle())
    }
}
