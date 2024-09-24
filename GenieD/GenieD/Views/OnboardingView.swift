//
//  OnboardingView.swift
//  GenieD
//
//  Created by OK on 14.03.2023.
//

import SwiftUI

struct OnboardingView: View {
    
    let onDone: (()->Void)?
    @State var index = 0
    
    var body: some View {
        ZStack {
            CustomColor.mainBg.ignoresSafeArea()
            VStack(spacing: 0) {
                VSpacer(30.scaled)
                contentView()
                privacyView()
                VSpacer(15.scaled)
                continueButton()
            }
            .padding(.horizontal, 20.scaled)
        }
        .foregroundColor(CustomColor.textGray)
    }
    
    private func contentView() -> some View {
        var title = ""
        var info = ""
        var image = ""
        var imageWidth = 300.scaled
        
        switch index {
        case 0:
            title = "Chat with Leo".localized()
            info = "Welcome to Leo, your personal AI assistant available 24/7 to help with any task, question, or conversation. Let us show you how easy and enjoyable it is to use Leo for work, personal life, or just a fun chat.".localized()
            image = "onb_1"
        case 1:
            title = "Leo Pro Tips".localized()
            info = "Make use of natural language: Leo is designed to understand natural language, so don't be afraid to ask questions and speak in a conversational tone. Try out different commands: Leo can do a lot more than just answer questions, so try out different commands to see what it can do. Keep the conversation going: Leo is always ready to chat, so keep the conversation going and see where it takes you.".localized()
            image = "onb_2"
            imageWidth = 240.scaled
        case 2:
            title = "Enable Notifications".localized()
            info = "Enable notifications to ensure that you stay up-to-date and never miss any important information.".localized()
            image = "onb_3"
        default: break
        }
        
        return VStack(spacing: 0) {
            HStack {
                Text(title)
                    .font(CustomFont.headerLarge(.bold))
                    .foregroundColor(CustomColor.blackText)
                Spacer()
            }
            
            VSpacer(30.scaled)
            HStack {
                Text(info)
                    .font(.system(size: 16.scaled, weight: .bold))
                    .lineSpacing(6.scaled)
                Spacer()
            }
            
            ZStack {
                Color.clear
                CustomImage(image, width: imageWidth, height: imageWidth)
            }
        }
    }
    
    private func privacyView() -> some View {
        
        let lText = "By continuing, you agree to our <BUTTON><PRIVACY>Privacy Policy<BUTTON> & <BUTTON><TERMS>Terms of Use<BUTTON>".localized()
        let arr = lText.components(separatedBy: "<BUTTON>")
        var result = AttributedString("")
        
        for stringItem in arr {
            if stringItem.hasPrefix("<PRIVACY>") {
                var tappableText = AttributedString(stringItem.replacingOccurrences(of: "<PRIVACY>", with: ""))
                tappableText.link = Constants.Link.privacy
                tappableText.font = .system(size: 11.scaled, weight: .bold)
                tappableText.foregroundColor = CustomColor.blackText
                result.append(tappableText)
            } else if stringItem.hasPrefix("<TERMS>") {
                var tappableText = AttributedString(stringItem.replacingOccurrences(of: "<TERMS>", with: ""))
                tappableText.link = Constants.Link.terms
                tappableText.font = .system(size: 11.scaled, weight: .bold)
                tappableText.foregroundColor = CustomColor.blackText
                result.append(tappableText)
            } else if !stringItem.isEmpty {
                result.append(AttributedString(stringItem))
            }
        }
        
        return Text(result)
            .font(.system(size: 11.scaled))
    }
    
    private func continueButton() -> some View {
        Button(action: {
            Utils.hapticFeedback()
            if index < 2 {
                index += 1
            } else {
                registerNotifications()
            }
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10.scaled)
                    .fill(CustomColor.green)
                RoundedRectangle(cornerRadius: 10.scaled)
                    .strokeBorder(CustomColor.greenBorder)
                Text("Continue".localized())
                    .font(CustomFont.header(.bold))
                HStack {
                    Spacer()
                    SystemImage("arrow.forward", width: 22.scaled)
                    HSpacer(15.scaled)
                }
            }
            .foregroundColor(CustomColor.whiteText)
        }
        .frame(height: 68.scaled)
        .padding(.bottom, 20.scaled)
    }
    
    private func registerNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            onDone?()
        }
    }
}

