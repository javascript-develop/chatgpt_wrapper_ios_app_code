//
//  PaywallView.swift
//  GenieD
//
//  Created by OK on 12.03.2023.
//

import SwiftUI

struct PaywallView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var buyProService: BuyProService
    @StateObject var viewModel: PaywallViewModel
    let isOnboarding: Bool
    let onDone: (()->Void)?
    private var borderColor: Color { CustomColor.textGrayLight.opacity(0.5) }
    
    init(isOnboarding: Bool = false, onDone: (()->Void)? = nil) {
        self.onDone = onDone
        self.isOnboarding = isOnboarding
        _viewModel = StateObject(wrappedValue: PaywallViewModel())
    }
    
    var body: some View {
        ZStack {
            CustomColor.mainBg.ignoresSafeArea()
            VStack(spacing: 0){
                Group {
                    topBar()
                    VSpacer(isIPhoneX ? 8.scaled : 0)
//                    if !isOnboarding {
//                        modelSwitch()
//                        VSpacer(isIPhoneX ?  25.scaled : 20.scaled)
//                    }
                }
                Group {
                    HStack {
                        Text(viewModel.selectedAccess.subtitle)
                            .font(CustomFont.headerLarge(.bold))
                            .multilineTextAlignment(.leading)
                        Spacer()
                    }
                    .padding(.horizontal, 20.scaled)
                    VSpacer(isIPhoneX ? 30.scaled : 15.scaled)
                    HStack {
                        Text("Features".localized().uppercased())
                            .font(CustomFont.body(.bold))
                            .foregroundColor(CustomColor.textGray)
                        Spacer()
                    }
                    .padding(.horizontal, 20.scaled)
                    VSpacer(15.scaled)
                    modelInfoView()
                    VSpacer(20.scaled)
                }
                
                if viewModel.showPurchaseControls {
                    buttonsScrollView()
                    securedInfoView()
                    VSpacer(14.scaled)
                    continueButton()
                    VSpacer(20.scaled)
                } else {
                    Spacer()
                }
            }
            if viewModel.isLoading {
                LoadingView()
                    .ignoresSafeArea()
            }
        }
        .foregroundColor(CustomColor.blackText)
        .onAppear {
            viewModel.onViewDidAppear()
        }
        .alert(isPresented: $viewModel.showingAlert) {
            Alert(title: Text(""), message: Text(viewModel.alertMessage), dismissButton: .default(Text("OK".localized())){
                if BuyProService.shared.subscribed {
                    dissmiss()
                }
            })
        }
    }
    
    private func topBar() -> some View {
        ZStack {
            HStack(spacing: 0) {
                Button(action: {
                    Utils.hapticFeedback()
                    dissmiss()
                }) {
                    Text((isOnboarding ? "Skip" : "Back").localized())
                        .font(CustomFont.buttonSmall(.bold))
                        .foregroundColor(CustomColor.textGrayLight)
                }
                .padding(.leading, 15.scaled)
                Spacer()
            }
        }
        .frame(height: 60.scaled)
    }
    
    private func modelSwitch() -> some View {
        GeometryReader { geometry in
            let padding = 2.scaled
            let width: CGFloat = geometry.size.width - 2 * padding
            let barWidth = width / 3
            
            return ZStack {
                Capsule().fill(CustomColor.grayBg)
                Capsule().strokeBorder(borderColor)
                ZStack(alignment: .leading) {
                    switchBar()
                            .frame(width: barWidth)
                            .offset(x: barWidth * viewModel.selectedAccess.barOffset)
                    if let access = buyProService.activeSubscription?.access {
                        currentPlanSticker(access, barWidth: barWidth)
                    }
                    HStack(spacing: 0) {
                        switchButton(.lite, width: barWidth)
                        switchButton(.pro, width: barWidth)
                        switchButton(.advanced, width: barWidth)
                    }
                }
                .padding(padding)
            }
        }
        .frame(height: 46.scaled)
        .padding(.horizontal, 20.scaled)
    }
    
    private func switchBar() -> some View {
        ZStack {
            Capsule().fill(CustomColor.green)
            Capsule().strokeBorder(CustomColor.greenBorder)
        }
    }
    
    private func currentPlanSticker(_ access: BuyProAccess, barWidth: CGFloat) -> some View {
        ZStack {
            Capsule().fill(CustomColor.blackText)
            Text("Your Current Plan".localized())
                .font(Font.system(size: 11.scaled, weight: .medium))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
                .foregroundColor(CustomColor.whiteText)
                .padding(.horizontal, 5.scaled)
                
        }
        .frame(width: barWidth, height: 24.scaled)
        .offset(x: barWidth * access.barOffset, y: -24.scaled)
    }
    
    private func buttonsScrollView() -> some View {
        GeometryReader { geometry in
            ScrollView(.vertical) {
                VStack(spacing: 15.scaled) {
                    subscriptionButton(.year)
                    subscriptionButton(.week)
                }
                .frame(minHeight: geometry.size.height)
            }
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
        }
    }
    
    private func switchButton(_ access: BuyProAccess, width: CGFloat) -> some View {
        Button(action: {
            Utils.hapticFeedback()
            viewModel.selectedPeriod = .year
            withAnimation(.easeInOut(duration: 0.1)) {
                viewModel.selectedAccess = access
            }
        }) {
            ZStack {
                Color.clear
                Text(access.title)
                    .font(CustomFont.body(.bold))
            }
        }
        .frame(width: width)
    }
    
    private func modelInfoView() -> some View {
        ZStack {
            VStack(spacing: 16.scaled) {
                ForEach(viewModel.selectedAccess.info.indices, id: \.self) { index in
                    modelInfoItem(viewModel.selectedAccess.info[index])
                }
                if let period = viewModel.selectedAccess.freePeriod, period == viewModel.selectedPeriod {
                    modelInfoItemFree()
                }
            }
            .padding(.vertical, 20.scaled)
            .padding(.trailing, 20.scaled)
        }
        .background {
            RoundedRectangle(cornerRadius: 10.scaled)
                .fill(CustomColor.grayBg)
        }
        .padding(.horizontal, 20.scaled)
    }
    
    private func modelInfoItem(_ text: String) -> some View {
        HStack(spacing: 0) {
            ZStack {
                SystemImage("checkmark", width: 18.scaled)
                    .foregroundColor(.green)
                    .frame(height: 18.scaled)
            }
            .frame(width: 60.scaled)
            Text(text)
                .font(CustomFont.bodySmall(.bold))
            Spacer()
        }
    }
    
    private func modelInfoItemFree() -> some View {
        HStack(spacing: 0) {
            ZStack {
                CustomImage("trial", width: 40.scaled, height: 30.scaled)
            }
            .frame(width: 60.scaled)
            Text("Try 3 Days for Free".localized())
                .font(CustomFont.bodySmall(.bold))
            Spacer()
        }
    }
    
    
    private func subscriptionButton(_ period: SubscriptionPeriod) -> some View {
        let priceWithCurrency = viewModel.productForPeriod(period)?.priceWithCurrency ?? ""
        
        var text = ""
        if let aperiod = viewModel.selectedAccess.freePeriod, aperiod == period {
            switch period {
            case .week:
                text = "3 days free trial, then <PRICE_WITH_CURRENCY>/week".localized().replacingOccurrences(of: "<PRICE_WITH_CURRENCY>", with: priceWithCurrency)
            case .year:
                text = "3 days free trial, then <PRICE_WITH_CURRENCY>/year".localized().replacingOccurrences(of: "<PRICE_WITH_CURRENCY>", with: priceWithCurrency)
            }
        } else {
            switch period {
            case .week:
                text = "<PRICE_WITH_CURRENCY>/week".localized().replacingOccurrences(of: "<PRICE_WITH_CURRENCY>", with: priceWithCurrency)
            case .year:
                text = "<PRICE_WITH_CURRENCY>/year".localized().replacingOccurrences(of: "<PRICE_WITH_CURRENCY>", with: priceWithCurrency)
            }
        }
        
        return ZStack {
            Capsule().fill(viewModel.selectedPeriod == period ? CustomColor.green.opacity(0.5) : Color.clear)
            Capsule().strokeBorder(viewModel.selectedPeriod == period ? CustomColor.greenBorder : borderColor, lineWidth: 2)
            HStack {
                Text(text)
                    .font(CustomFont.bodySmall(.bold))
                    Spacer()
            }
            .padding(.horizontal, 20.scaled)
        }
        .frame(height: 58.scaled)
        .padding(.horizontal, 20.scaled)
        .contentShape(Rectangle())
        .onTapGesture {
            Utils.hapticFeedback()
            withAnimation(.easeInOut(duration: 0.1)) {
                viewModel.selectedPeriod = period
            }
        }
    }
    
    private func securedInfoView() -> some View {
        HStack(spacing: 12.scaled) {
            SystemImage("lock.fill", width: 12.scaled)
            Text("Secured with iTunes. Cancel anytime".localized())
                .font(CustomFont.bodySmall(.bold))
        }
        .padding(.vertical, 5.scaled)
        .foregroundColor(CustomColor.textGray)
    }
    
    private func continueButton() -> some View {
        Button(action: {
            Utils.hapticFeedback()
            viewModel.onContinueAction()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10.scaled)
                    .fill(CustomColor.green)
                RoundedRectangle(cornerRadius: 10.scaled)
                    .strokeBorder(CustomColor.greenBorder)
                Text("Continue".localized())
                    .font(CustomFont.header(.bold))
                    .foregroundColor(CustomColor.whiteText)
                HStack {
                    Spacer()
                    SystemImage("arrow.forward", width: 22.scaled)
                    HSpacer(15.scaled)
                }
            }
        }
        .frame(height: 58.scaled)
        .padding(.horizontal, 20.scaled)
    }
    
    private func dissmiss() {
        onDone?()
        presentationMode.wrappedValue.dismiss()
    }
}

extension BuyProAccess {
    var barOffset: CGFloat {
        switch self {
        case .lite:
            return 0
        case .pro:
            return 1
        case .advanced:
            return 2
        }
    }
    
    var title: String {
        switch self {
        case .lite:
            return "Lite".localized()
        case .pro:
            return "Pro".localized()
        case .advanced:
            return "Premium".localized()
        }
    }
    
    var subtitle: String {
        switch self {
        case .lite:
            return "Ask smarter, live better with Leo.".localized()
        case .pro:
            return "Unlock endless knowledge with Leo.".localized()
        case .advanced:
            return "Leo: The Smartest Way to Chat, Period.".localized()
        }
    }
    
    var info: [String] {
        switch self {
        case .lite:
            return ["Limited Questions and Answers".localized(),
                    "Higher Word Limit".localized(),
                    "Most Advanced AI Model".localized()]
        case .pro:
            return ["Unlimited Questions & Answers".localized(),
                    "Higher Word Limit".localized(),
                    "Most Advanced AI Model".localized()]
                   
        case .advanced:
            return ["Unlimited Questions & Answers".localized(),
                    "Dialogs (AI remembers chat history)".localized(),
                    "Most Advanced AI Model".localized(),
                    "Higher Word Limit".localized()]
        }
    }
    
    var freePeriod: SubscriptionPeriod? {
        switch self {
        case .lite:
            return nil
        case .pro:
            return .year
        case .advanced:
            return .week
        }
    }
}
