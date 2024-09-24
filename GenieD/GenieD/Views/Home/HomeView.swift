//
//  HomeView.swift
//  GenieD
//
//  Created by OK on 28.02.2023.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var buyProService: BuyProService
    @EnvironmentObject var localizationService: LocalizationService
    @StateObject var viewModel = HomeViewModel()
    @State var isDrowerOpened = false
    @State var presentingSettings = false
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State private var animationAmount: CGFloat = 1
    private let scaleValue: CGFloat = 0.05
    
    private let drowerWidth = UIScreen.main.bounds.width * 0.85
    private let cornerRadius = 10.scaled
    
    var body: some View {
        NavigationView {
            DrawerView(drowerWidth: drowerWidth, isOpen: $isDrowerOpened) {
                contentView()
                    .frame(width: UIScreen.main.bounds.width)
            } drawer: {
                SideMenuView(isOpened: $isDrowerOpened)
            }
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .alert(isPresented: $viewModel.showingUpgradeAlert) {
            let leftCount = FirestoreManager.shared.freeRequests - LocalStorage.shared.getAccessQuestionsCount()
            let text = "<numberofquestions> questions left in your weekly free package. Upgrade for unlimited questions.".localized().replacingOccurrences(of: "<numberofquestions>", with: "\(max(0, leftCount))")
            return Alert(title: Text("Upgrade to unlimited".localized()),
                  message: Text(text),
                  primaryButton: .default(Text("Upgrade".localized()), action: {
                viewModel.showBuyPro = true
            }),
                  secondaryButton: .default(Text("OK".localized()))
            )
        }
        .sheet(isPresented: $presentingSettings) { SettingsView() }
        .fullScreenCover(isPresented: $viewModel.showBuyPro) {
            PaywallView()
        }
    }
    
    private func contentView() -> some View {
        ZStack {
            CustomColor.mainBg.ignoresSafeArea()
            VStack(spacing: 0){
                NavigationLink(destination: AskQuestionView(isDialog: true, chat: nil), tag: "AskQuestionViewDialog", selection: $viewModel.tagSelection) { EmptyView() }
                VSpacer(safeAreaInsets.top)
                topBar()
                VStack(spacing: 0){
                    VSpacer(20.scaled)
                    if buyProService.activeSubscription == nil {
                        buyProBanner()
                    }
                    
                    ZStack {
                        Color.clear
                        Text("Tap below to start".localized())
                            .font(CustomFont.header(.bold))
                            .multilineTextAlignment(.center)
                    }
                    
                    Button(action: {
                        Utils.hapticFeedback()
                        viewModel.tagSelection = "AskQuestionViewDialog"
                    }) {
                        CustomImage("logo", width: 300.scaled, height: 300.scaled)
                            .cornerRadius(30.scaled)
                            .scaleEffect(animationAmount)
                            .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: animationAmount)
                    }
                    ZStack {
                        Color.clear
                    }
                }
                .padding(.horizontal, 20.scaled)
            }
            .padding(.bottom, max(20.scaled, safeAreaInsets.bottom))
        }
        
        .onAppear {
            DispatchQueue.main.async {
                animationAmount = 1 + scaleValue
            }
        }
    }
     
    private func topBar() -> some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                CustomColor.graySeparator.frame(height: 1)
            }
            HStack(spacing: 0) {
                Button(action: {
                    Utils.hapticFeedback()
                    isDrowerOpened = true
                }) {
                    SystemImage("line.horizontal.3", width: 25.scaled)
                        .foregroundColor(CustomColor.blackText)
                        .padding(10)
                    
                }
                .padding(.leading, 15.scaled)
                CustomImage("leoLogo", width: 80.scaled, height: 30.scaled)
                    .padding(.leading, 5.scaled)
                
                Spacer()
                
                Button(action: {
                    Utils.hapticFeedback()
                    viewModel.showingUpgradeAlert = true
                }) {
                    QuestionCountInfoView()
                }
                .disabled(buyProService.subscribed)
                HSpacer(5.scaled)
                Button(action: {
                    Utils.hapticFeedback()
                    presentingSettings = true
                }) {
                    SystemImage("gearshape", width: 25.scaled)
                        .foregroundColor(CustomColor.blackText)
                        .padding(10)
                }
                .padding(.trailing, 15.scaled)
            }
        }
        .frame(height: 60.scaled)
    }
    
    private func buyProBanner() -> some View {
        BuyProBanner()
        .onTapGesture {
            Utils.hapticFeedback()
            viewModel.onShowBuyPro()
        }
    }
    
    private func customButtom(title: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(CustomColor.mainBg)
            Text(title)
                .font(CustomFont.button(.bold))
                .foregroundColor(CustomColor.blackText)
        }
    }
    
}
