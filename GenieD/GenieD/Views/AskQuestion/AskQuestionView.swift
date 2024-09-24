//
//  AskQuestionView.swift
//  GenieD
//
//  Created by OK on 03.03.2023.
//

import SwiftUI

struct AskQuestionView: View {
    
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var buyProService: BuyProService
    @Environment(\.managedObjectContext) private var moc
    @StateObject var viewModel: AskQuestionViewModel
    @StateObject var networkMonitor = NetworkMonitor()
    @FocusState private var isFocused: Bool
    @State private var showingOptions = false
    @State private var showBanner = false
    @State private var hideWriteYourMessagePlaceholder = false
    @State private var isFastTyping = LocalStorage.shared.isSoundOff
    
    init(isDialog: Bool, chat: Chat?) {
        _viewModel = StateObject(wrappedValue: AskQuestionViewModel(isDialog: isDialog, chat: chat))
    }
    
    private var headerFont: Font {
        .system(size: 20.scaled, weight: .bold)
    }
    
    var body: some View {
            ZStack {
                CustomColor.mainBg.ignoresSafeArea()
                VStack(spacing: 0){
                    topBar()
                    Group {
                        if viewModel.showQuestionExamplesMode {
                            sampleQuestionsView()
                                .padding(.horizontal, 20.scaled)
                        } else {
                            chatView()
                        }
                    }
                    
                    if viewModel.isLoading {
                        LottieView(name: "lottie-leo-fixed", loopMode: .loop){ _ in }
                                .frame(height: 30.scaled)
                                .padding(.top, 10.scaled)
                    }
                    Group {
                        if viewModel.isDialog {
                            askQuestionView()
                        } else {
                            if viewModel.showQuestionExamplesMode {
                                askQuestionView()
                            } else {
                                askNewQuestionButton()
                            }
                        }
                    }
                    .padding(.horizontal, 16.scaled)
                    .padding(.top, 18.scaled)
                    .padding(.bottom, (isIPhoneX ? 10 : 20).scaled)
                }
            }
            .foregroundColor(CustomColor.blackText)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .modifier(DismissingKeyboard())
            .onChange(of: viewModel.isSoundOff, perform: { newValue in
                isFastTyping = newValue
            })
            .onAppear {
                networkMonitor.start()
            }
            .onDisappear {
                networkMonitor.stop()
                viewModel.stopSynthesizer()
                viewModel.saveChat()
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIScene.didEnterBackgroundNotification)) { _ in
                    viewModel.saveChat()
            }
            .fullScreenCover(isPresented: $viewModel.showBuyPro) {
                PaywallView() {
                    viewModel.onPaywallDoneAction()
                }
            }
            .fullScreenCover(isPresented: $viewModel.showNoConnection) {
                NoConnectionView(onTryAgain: {
                    if networkMonitor.isConnected {
                        viewModel.onSendAction()
                    }
                })
            }
            .alert(isPresented: $viewModel.showingAlert) {
                switch viewModel.alertType! {
                case .newChat:
                    return Alert(title: Text("Are you sure you want start a new chat?".localized()),
                                 message: Text("Proceeding will start a new chat and you can still access this chat from chat history.".localized()),
                                 primaryButton: .default(Text("No".localized()), action: {}),
                                 secondaryButton: .destructive(Text("Yes".localized()), action: {
                        viewModel.onNewChatAction()
                                }))
                case .deleteChat:
                    return Alert(title: Text("Are you sure you want to delete?".localized()),
                                 message: Text("By proceeding, you'll lose access to this chat.".localized()),
                                 primaryButton: .default(Text("No".localized()), action: {}),
                                 secondaryButton: .destructive(Text("Yes".localized()), action: {
                        onDeleteChatAction()
                                    })
                    )
                case .upgrade:
                    let leftCount = FirestoreManager.shared.freeRequests - LocalStorage.shared.getAccessQuestionsCount()
                    let text = "<numberofquestions> questions left in your weekly free package. Upgrade for unlimited questions.".localized().replacingOccurrences(of: "<numberofquestions>", with: "\(max(0, leftCount))")
                    return Alert(title: Text("Upgrade to unlimited".localized()),
                          message: Text(text),
                          primaryButton: .default(Text("Upgrade".localized()), action: {
                        viewModel.showBuyPro = true
                    }),
                          secondaryButton: .default(Text("OK".localized()))
                    )
                case .settings(let message):
                    return Alert(title: Text("Error".localized()),
                                 message: Text(message),
                                 primaryButton: .cancel(Text("Cancel".localized()), action: {}),
                                 secondaryButton: .default(Text("Settings".localized()), action: {
                                    if let url = URL(string: UIApplication.openSettingsURLString) {
                                        Utils.onLinkAction(link: url)
                                    }
                                    })
                                 )
                }
            }
            .sheet(isPresented: $viewModel.shouldPresentImagePicker) {
                SUImagePickerView(sourceType: self.viewModel.shouldPresentCamera ? .camera : .photoLibrary, image: self.$viewModel.image, isPresented: self.$viewModel.shouldPresentImagePicker)
            }
            .sheet(isPresented: $viewModel.showGoogleDriveFiles) {
                GoogleDriveFilesView(onDone: { result in
                    //viewModel.pdfData = result.first
                    if let firstData = result.first, let image = UIImage(data: firstData), let resized = Utils.resizeImage(image: image) {
                        viewModel.image = resized
                    }
                })
            }
            .actionSheet(isPresented: $showingOptions) {
                            ActionSheet(
                                title: Text(""),
                                message: Text("Choose image".localized()),
                                buttons: [
                                    .default(Text("Gallery".localized())) {
                                        viewModel.onGalleryAction()
                                    },
                                    .default(Text("Camera".localized())) {
                                        viewModel.onCameraAction()
                                    },
                                    .default(Text("iCloud".localized())) {
                                        viewModel.shouldPresentFiles = true
                                    },
                                    .default(Text("Google Drive".localized())) {
                                        viewModel.showGoogleDriveFiles = true
                                    },
                                    .default(Text("PDF/Document Summary (Coming Soon)".localized())) {
                                    },
                                    .cancel(Text("Cancel".localized()))
                                ]
                            )
                        }
            .fileImporter(
                isPresented: $viewModel.shouldPresentFiles,
                allowedContentTypes: [.png, .jpeg],
                       allowsMultipleSelection: false
                   ) { result in
                       let sf: URL? = try? result.get().first
                       if let sf = sf {
                           if sf.startAccessingSecurityScopedResource() {
                               let stringUrl = sf.absoluteString.lowercased()
                               guard let data = try? Data(contentsOf: sf) else { return }
                            
                               if stringUrl.hasSuffix(".png") || stringUrl.hasSuffix(".jpg") || stringUrl.hasSuffix(".jpeg") {
                                   if let image = UIImage(data: data), let resized = Utils.resizeImage(image: image) {
                                       viewModel.image = resized
                                   }
                               } else if stringUrl.hasSuffix(".pdf") {
                                   viewModel.pdfData = data
                               }
                           }
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
                    guard !viewModel.isLoading else { return }
                    
                    Utils.hapticFeedback()
                    dissmiss()
                }) {
                    SystemImage("arrow.backward", width: 25.scaled)
                        .padding(10)
                }
                .padding(.leading, 15.scaled)
                
                if viewModel.chat != nil {
                    nameTextField()
                } else {
                    CustomImage("leoLogo", width: 80.scaled, height: 30.scaled)
                        .padding(.leading, 5.scaled)
                    Spacer()
                    Button(action: {
                        Utils.hapticFeedback()
                        viewModel.showAlert(.upgrade)
                    }) {
                        QuestionCountInfoView()
                    }
                    .disabled(buyProService.subscribed)
                    HSpacer(5.scaled)
                }
                if viewModel.showDeleteChatButton {
                    Button(action: {
                        viewModel.showAlert(.deleteChat)
                    }) {
                        SystemImage("trash", width: 20.scaled)
                            .padding(10)
                    }
                }
                Button(action: {
                    viewModel.onToggleIsSoundOff()
                }) {
                    SystemImage(viewModel.isSoundOff ? "speaker.slash" : "speaker.wave.2", width: 25.scaled)
                        .padding(10)
                }
                Button(action: {
                    onShareAction()
                }) {
                    SystemImage("square.and.arrow.up", width: 20.scaled)
                        .padding(10)
                }
                .opacity(viewModel.showQuestionExamplesMode ? 0.5 : 1)
                .disabled(viewModel.showQuestionExamplesMode)
                .padding(.trailing, 20.scaled)
            }
        }
        .frame(height: 60.scaled)
    }
    
    private func nameTextField() -> some View {
        TextField("", text: $viewModel.chatNameText, onEditingChanged: { editingChanged in
            if editingChanged {
                hideWriteYourMessagePlaceholder = true
            } else {
                hideWriteYourMessagePlaceholder = false
            }
        })
            .font(CustomFont.body(.bold))
            .padding(.horizontal, 30.scaled)
    }
    
    private func chatView() -> some View {
        GeometryReader { reader in
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer()
                        ForEach(viewModel.messages, id: \.self) { message in
                            messageView(message)
                        }
                        if viewModel.isAnswerError {
                            tryAgainButton()
                        }
                        VSpacer(1)
                            .id("BottomConstant")
                    }
                    .frame(minHeight: reader.size.height)
                }
                .onChange(of: viewModel.shouldScrollToBottom) { _ in
                    if viewModel.shouldScrollToBottom {
                        viewModel.shouldScrollToBottom = false
                        withAnimation {
                            proxy.scrollTo("BottomConstant", anchor: .bottom)
                        }
                    }
                }
                .onAppear {
                    proxy.scrollTo("BottomConstant", anchor: .bottom)
                }
            }
        }
    }
    
    private func sampleQuestionsView() -> some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 20) {
                ForEach(viewModel.questionSections.indices, id: \.self) { index in
                    questionsSectionView(viewModel.questionSections[index])
                }
                VSpacer(10.scaled)
            }
        }
        
    }
    
    private func questionsSectionView(_ section: QuestionsSection) -> some View {
        VStack(spacing: 0) {
            CustomImage(section.icon, width: UIScreen.main.bounds.width * 0.9, height: 35.scaled)
                .padding(.top, 20.scaled)
                .padding(.bottom, 16.scaled)
            
            if let title = section.title {
                Text(title)
                    .font(headerFont)
                    .multilineTextAlignment(.center)
                    .padding(.bottom, 16.scaled)
            }
            
            VStack(spacing: 20.scaled) {
                ForEach(section.questions.indices, id: \.self) { index in
                    questionSampleItemView(section: section, questionIndex: index)
                }
            }
        }
    }
    
    private func questionSampleItemView(section: QuestionsSection, questionIndex: Int) -> some View {
        let text = section.questions[questionIndex]
        return ZStack {
            RoundedRectangle(cornerRadius: 10.scaled)
                .fill(CustomColor.graySeparator)
            VStack(spacing: 5.scaled) {
                Text(text)
                    .font(Font.system(size: 15.scaled))
                    .multilineTextAlignment(.center)
                if section.shouldOpenFilesOptions {
                    HStack(spacing: 5.scaled) {
                        CustomImage("image_summary", width: 16.scaled, height: 16.scaled)
                        Text("Upload a photo".localized())
                            .font(Font.system(size: 15.scaled))
                            .foregroundColor(CustomColor.green)
                    }
                }
            }
                .padding(.vertical, 18.scaled)
                .padding(.horizontal, 18.scaled)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            Utils.hapticFeedback()
            viewModel.text = text
            if section.shouldOpenFilesOptions {
                showingOptions = true
            }
        }
    }
    
    private func messageView(_ message: MessageItem) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .top, spacing: 15.scaled) {
                CustomImage(message.isMy ? "person" : "logoSmall", width: 30.scaled, height: 30.scaled)
                    .padding(.leading, 15.scaled)
                Group {
                    if viewModel.typingMessageId == message.id {
                        TypeWriterView(finalText: message.text, isFastTyping: $isFastTyping,
                                       didFinishTyping: { [weak viewModel] in
                            viewModel?.onFinishTyping()
                        },
                                       onTextRemain: { [weak viewModel] text in
                            viewModel?.onTypingTextRemain(text)
                        })
                    } else {
                        Text(message.text)
                    }
                }
                    .font(CustomFont.body())
                    .padding(.trailing, 15.scaled)
                Spacer()
            }
            if let resultImage = message.image {
                VSpacer(10.scaled)
                HStack(spacing: 0) {
                    Spacer()
                    Image(uiImage: resultImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250.scaled)
                        .cornerRadius(10.scaled)
                    Spacer()
                }
            }
            if !message.isMy {
                Button(action: {
                    viewModel.onCopyAction(text: message.text)
                }) {
                    SystemImage("square.on.square", width: 25)
                        .foregroundColor(CustomColor.textGray)
                        .padding(10.scaled)
                }
                .padding(.top, 10.scaled)
                .padding(.bottom, 15.scaled)
                .padding(.trailing, 20.scaled)
                
                if !viewModel.isDialog, !viewModel.wasRegeneratedAnswer {
                    Button(action: {
                        Utils.hapticFeedback()
                        showingOptions = true
                    }) {
                        Text("Are you not satisfied?".localized())
                            .underline()
                            .font(CustomFont.bodySmall())
                            .foregroundColor(.red)
                    }
                    .padding(.trailing, 20.scaled)
                    .padding(.bottom, 10.scaled)
                }
            } else {
                Button(action: {
                    viewModel.onCopyAction(text: message.text)
                }) {
                    SystemImage("square.on.square", width: 25)
                        .foregroundColor(CustomColor.textGray)
                        .padding(10.scaled)
                }
                .padding(.top, 10.scaled)
                .padding(.trailing, 20.scaled)
            }
        }
        .padding(.vertical, 15.scaled)
        .background {
            message.isMy ? Color.clear : CustomColor.graySeparator
        }
    }
    
    private func askQuestionView() -> some View {
        HStack(spacing: 0) {
            selectImageView()
            ZStack {
                HStack(spacing: 0) {
                    FlexibleTextView(text: $viewModel.text, isFocused: $isFocused)
                        .focused($isFocused, equals: true)
                        .padding(.leading, 20.scaled)
                        .padding(.trailing, 5.scaled)
                        .padding(.vertical, 20.scaled)
                        .overlay {
                            if hideWriteYourMessagePlaceholder, viewModel.text.isEmpty {
                                CustomColor.mainBg
                                    .padding(10.scaled)
                            } else if !isFocused, viewModel.text.isEmpty, !viewModel.isLoading, !viewModel.isTyping {
                                TypingPlaceholderView(texts: viewModel.typingPlaceholderTexts, onTapAction: {
                                    isFocused = true
                                })
                            }
                        }
                    Button(action: {
                        if networkMonitor.isConnected {
                            viewModel.onSendAction()
                        } else {
                            Utils.hapticFeedback()
                            Utils.keyWindow?.endEditing(true)
                            viewModel.showNoConnection = true
                        }
                    }) {
                        SystemImage("paperplane.fill", width: 28)
                            .rotationEffect(.degrees(45))
                            .padding(5.scaled)
                            .foregroundColor(viewModel.text.isEmpty ? CustomColor.textGray : CustomColor.green)
                    }
                    .padding(.trailing, 10.scaled)
                }
            }
            .frame(minHeight: 60.scaled)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 10.scaled)
                        .foregroundColor(CustomColor.mainBg)
                        .shadow(color: .gray.opacity(0.6), radius: 2, x: 0, y: 0)
                }
            }
            .onTapGesture {
                if !isFocused {
                    isFocused = true
                }
            }
        }
    }
    
    @ViewBuilder
    private func selectImageView() -> some View {
        if let image = viewModel.image {
            ZStack {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30.scaled, height: 30.scaled)
                    .cornerRadius(6.scaled)
                    .padding(.top, 9.scaled)
                    .padding(.trailing, 9.scaled)
            }
            .overlay {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                    Button(action: {
                        viewModel.text = ""
                        viewModel.image = nil
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(CustomColor.mainBg)
                                .shadow(color: .gray.opacity(0.6), radius: 2, x: 0, y: 0)
                                .frame(width: 18.scaled, height: 18.scaled)
                            Capsule()
                                .fill(CustomColor.textGray)
                                .frame(width: 10.scaled, height: 2.scaled)
                        }
                    }
                }
            }
            .padding(.trailing, 6.scaled)
        } else if viewModel.pdfData != nil {
            ZStack {
                CustomImage("description", width: 30.scaled, height: 30.scaled)
                    .cornerRadius(6.scaled)
                    .padding(.top, 9.scaled)
                    .padding(.trailing, 9.scaled)
            }
            .overlay {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                    Button(action: {
                        viewModel.text = ""
                        viewModel.pdfData = nil
                    }) {
                        ZStack {
                            Circle()
                                .foregroundColor(CustomColor.mainBg)
                                .shadow(color: .gray.opacity(0.6), radius: 2, x: 0, y: 0)
                                .frame(width: 18.scaled, height: 18.scaled)
                            Capsule()
                                .fill(CustomColor.textGray)
                                .frame(width: 10.scaled, height: 2.scaled)
                        }
                    }
                }
            }
            .padding(.trailing, 6.scaled)
        } else {
            Button(action: {
                if !viewModel.isLoading {
                    showingOptions = true
                }
            }) {
                ZStack {
                    Circle()
                        .foregroundColor(CustomColor.mainBg)
                        .shadow(color: .gray.opacity(0.6), radius: 2, x: 0, y: 0)
                    SystemImage("plus", width: 20.scaled)
                        .foregroundColor(CustomColor.textGray)
                }
            }
            .frame(width: 40.scaled, height: 40.scaled)
            .padding(.trailing, 10.scaled)
        }
    }
    
    private func tryAgainButton() -> some View {
        ZStack {
            Button(action: {
                viewModel.onTryAgainAction()
            }) {
                Text("Try Again".localized())
                    .font(CustomFont.body(.medium))
                    .foregroundColor(.red)
            }
        }
        .frame(height: 50.scaled)
    }
    
    private func askNewQuestionButton() -> some View  {
        Button(action: {
            viewModel.onAskNewQuestionButtonPressed()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10.scaled)
                    .fill(CustomColor.green)
                Text("Ask new question".localized())
                    .font(CustomFont.button(.bold))
                    .foregroundColor(CustomColor.whiteText)
            }
        }
        .frame(height: 60.scaled)
    }
    
    private func onShareAction() {
        guard !viewModel.messages.isEmpty else { return }
        
        self.shareChatAsImage(messages: viewModel.messages)
    }
    
    private func onDeleteChatAction() {
        if let chat = viewModel.chat {
            moc.delete(chat)
            try? moc.save()
        }
        dissmiss()
    }
    
    private func dissmiss() {
        viewModel.stopSynthesizer()
        presentationMode.wrappedValue.dismiss()
    }
    
}
