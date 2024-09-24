//
//  NoConnectionView.swift
//  GenieD
//
//  Created by OK on 08.05.2023.
//

import SwiftUI

struct NoConnectionView: View {
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    let onTryAgain: (()->Void)?
    
    var body: some View {
        ZStack {
            CustomColor.mainBg.ignoresSafeArea()
            VStack(spacing: 20.scaled) {
                CustomImage("noConnection", width: UIScreen.main.bounds.width - 60, height: 200.scaled)
                VSpacer(20.scaled)
                Text("No connection".localized())
                    .font(.system(size: 20.scaled, weight: .semibold))
                    .foregroundColor(CustomColor.blackText)
                
                Text("We couldn't connect to the internet. Please check network settings and try again.".localized()) 
                    .font(.system(size: 16.scaled, weight: .regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(CustomColor.textGray)
                actionButton()
            }
            .padding(.horizontal, 40.scaled)
        }
    }
    
    private func actionButton() -> some View {
        Button(action: {
            onTryAgain?()
            dissmiss()
        }) {
            Text("Try Again".localized())
                .font(.system(size: 16.scaled, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20.scaled)
                .padding(.vertical, 10.scaled)
                .background {
                    RoundedRectangle(cornerRadius: 10.scaled)
                        .fill(.blue)
                }
        }
    }
    
    private func dissmiss() {
        presentationMode.wrappedValue.dismiss()
    }
}


