//
//  AskQuestionViewModel.swift
//  GenieD
//
//  Created by OK on 03.03.2023.
//

import Foundation
import SPIndicator
import AVFoundation
import Photos

class AskQuestionViewModel: ObservableObject {
    
    let isDialog: Bool//todo: delete if unused
    var chat: Chat?
    var qaItem: QAItem?

    init(isDialog: Bool, chat: Chat?) {
        self.chat = chat
        self.isDialog = isDialog
        self.showDeleteChatButton = chat != nil
        if let chat = chat {
            let result = chat.messages?.allObjects.compactMap { ($0 as? Message != nil) ? MessageItem(coreDataMessage: $0 as! Message) : nil } ?? []
            self.messages = result.sorted(by: { $0.created < $1.created })
            chatNameText = chat.name ?? chat.lastQuestion ?? ""
        }
        
        LocalStorage.shared.temperature = nil
        
        var textsResult: [String] = []
        for item in _questionSectionsDialog {
            if !item.shouldOpenFilesOptions {
                textsResult += item.questions.map { String($0.prefix(Utils.isIpad ? 55 : 45)) }
            }
        }
        typingPlaceholderTexts = textsResult
    }
    
    @Published var text = "" {
        didSet {
            if !isDialog, text.count > characterLimit {
                text = String(text.prefix(characterLimit))
            }
        }
    }
    @Published var image: UIImage? {
        didSet {
            if image != nil, text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                text = "What is this image about?".localized()
            }
        }
    }
    @Published var pdfData: Data? {
        didSet {
            if pdfData != nil {
                text = "What is this document about?".localized()//check text
            }
        }
    }
    @Published var messages: [MessageItem] = []
    @Published var isLoading = false
    @Published var shouldScrollToBottom = false
    @Published private(set) var isSoundOff = LocalStorage.shared.isSoundOff
    @Published private(set) var alertType: AskQuestionView.AlertType?
    @Published var showingAlert = false
    @Published var wasRegeneratedAnswer = false
    @Published var isAnswerError = false
    @Published var typingMessageId: String?
    @Published var showDeleteChatButton: Bool
    @Published var chatNameText: String = ""
    @Published var showBuyPro = false
    @Published var showNoConnection = false
    @Published var showGoogleDriveFiles = false
    @Published var shouldPresentImagePicker = false
    @Published var shouldPresentCamera = false
    @Published var shouldPresentFiles: Bool = false
    
    private var typingTextRemain: String = ""
    var isTyping: Bool {
        typingMessageId != nil
    }
    
    private var synthesizer: AVSpeechSynthesizer?
    private let openAI = OpenAIService()
    private let _questionSections: [QuestionsSection] = [
        QuestionsSection(icon: "explain",
                         title: "Explain".localized(),
                         questions: ["Explain Bitcoin".localized(),
                                     "How does the internet work, explain like I am 5 years old".localized()]),
        QuestionsSection(icon: "edit",
                         title: "Write & Edit".localized(),
                         questions: ["Write a tweet about global warming".localized(),
                                     "Write a poem about flowers and love".localized(),
                                     "Write a rap song lyrics about being smart".localized()]),
        QuestionsSection(icon: "language",
                         title: "Translate".localized(),
                         questions: ["Write a tweet about global warming in Korean".localized()]),
        QuestionsSection(icon: "email",
                         title: "Write an email".localized(),
                         questions: ["Write an email to decline the offer but request a discount.".localized()]),
        QuestionsSection(icon: "pizza",
                         title: "Get recipes".localized(),
                         questions: ["How to make banana pancakes".localized()]),
        QuestionsSection(icon: "calculate",
                         title: "Do Math".localized(),
                         questions: ["Solve this math problem: 3^(9)÷3^(2)".localized()]),
        
    ]
    
    private let _questionSectionsDialog: [QuestionsSection] = [
        QuestionsSection(icon: "star_new",
                         //title: "Summarise picture".localized(),
                         title: nil,
                         questions: ["Write an Instagram caption for this image.".localized()],
                         shouldOpenFilesOptions: true),
        
        QuestionsSection(icon: "act_as",
                         title: "Ask Anything".localized(),
                         questions: ["Ask me grade 12 math questions".localized(),
                                     "Ask me questions as a job interviewer".localized()]),
        
        QuestionsSection(icon: "smile",
                         title: "Explain".localized(),
                         questions: ["Explain Bitcoin".localized(),
                                     "How does the internet work, explain like I am 5 years old".localized(),
                                     "Tell me a joke about a kangaroo".localized(),
                                     "Write an essay about Global Warming. Maximum 200 words.".localized()
                                     ]),
        
        QuestionsSection(icon: "language",
                         title: "Translate".localized(),
                         questions: ["Write a tweet about global warming in Korean".localized()]),
        
        QuestionsSection(icon: "book",
                         title: "Business".localized(),
                         questions: ["Generate 10 different brand names for my company which will sell women's shoes on the internet. I want a modern brand name. My target audience is women under the age of 30. Make sure the .com domain is available on the internet.".localized()]),
        
        QuestionsSection(icon: "help_2",
                         title: "Ask for help".localized(),
                         questions: ["What's the best marketing channel for second-hand electronics in America?".localized()]),
        
        QuestionsSection(icon: "edit",
                         title: "Write & Edit".localized(),
                         questions: ["Write a tweet about global warming".localized(),
                                     "Write a poem about flowers and love".localized(),
                                     "Write a rap song lyrics about being smart".localized()]),
        
        QuestionsSection(icon: "email",
                         title: "Write an email".localized(),
                         questions: ["Write an email to decline the offer but request a discount.".localized()]),
        
        QuestionsSection(icon: "pizza",
                         title: "Get recipes".localized(),
                         questions: ["How to make banana pancakes".localized()]),
        
        QuestionsSection(icon: "calculate",
                         title: "Do Math".localized(),
                         questions: ["Solve this math problem: 3^(9)÷3^(2)".localized()]),
        
    ]
    
    var questionSections: [QuestionsSection] {
        isDialog ? _questionSectionsDialog : _questionSections
    }
    
    let typingPlaceholderTexts: [String]
   
    private let characterLimit = 255
    
    var showQuestionExamplesMode: Bool {
        messages.isEmpty
    }
    
    var maxQuestionsPerDay: Int? {
        guard let access = BuyProService.shared.activeSubscription?.access else {
            return FirestoreManager.shared.freeRequests
        }
        
        switch access {
        case .lite:
            return FirestoreManager.shared.liteRequests
        case .pro, .advanced:
            return nil
        }
    }
    
    var isSendMessageLocked: Bool {
        guard let maxQuestions = maxQuestionsPerDay else { return false }
         
        let usedCount = LocalStorage.shared.getAccessQuestionsCount()
        return usedCount >= maxQuestions
    }
    
    private var wasTryAgainActionBeforeNavigationToPaywall = false
    private var wasSendActionBeforeNavigationToPaywall = false
        
    func stopSynthesizer() {
        if synthesizer?.isSpeaking ?? false {
            synthesizer?.stopSpeaking(at: .immediate)
        }
    }
    
    func speakText(_ text: String) {
        guard !isSoundOff, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        if synthesizer == nil {
            synthesizer = AVSpeechSynthesizer()
        }
        
        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)
        
        let utterance = AVSpeechUtterance(string: text)
        //utterance.voice = AVSpeechSynthesisVoice(language: LocalizationService.shared.language.speechSynthesisVoiceCode)//TODO: ???
        synthesizer?.speak(utterance)
    }
    
    func showAlert(_ type: AskQuestionView.AlertType) {
        alertType = type
        showingAlert = true
    }
    
    //MARK: - Actions
    
    func onCameraAction() {
        let openCameraBlock = {
            self.shouldPresentImagePicker = true
            self.shouldPresentCamera = true
        }
        
        switch AVCaptureDevice.authorizationStatus(for: AVMediaType.video) {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { granted in
               if granted == true {
                   openCameraBlock()
               }
           })
        case .authorized:
            openCameraBlock()
        default:
            showAlert(.settings(message: "Camera access is denied.".localized()))
        }
    }
    
    func onGalleryAction() {
        let openPhotosBlock = {
            DispatchQueue.main.async {
                self.shouldPresentImagePicker = true
                self.shouldPresentCamera = false
            }
        }
        
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            openPhotosBlock()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
                    openPhotosBlock()
                }
            }
        default:
            showAlert(.settings(message: "Photo Library access is denied.".localized()))
        }
    }
    
    func onFinishTyping() {
        typingMessageId = nil
    }
    
    func onSendAction() {
        guard !isAnswerError, !isTyping, !isLoading else { return }
        
        Utils.hapticFeedback()
        Utils.keyWindow?.endEditing(true)
        
        do {
            if text.lowercased().contains(Test.textSetTo.lowercased()) {
                let strValue = text.lowercased().replacingOccurrences(of: Test.textSetTo.lowercased(), with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                let newQuestion = MessageItem(text: text, isMy: true, created: Date())
                if let doubleValue = Double(strValue) {
                    messages.append(newQuestion)
                    text = ""
                    if doubleValue >= 0, doubleValue <= 2 {
                        LocalStorage.shared.temperature = doubleValue
                        let newAnswer = MessageItem(text: Test.textTemperatureIsSetTo + "\(doubleValue)", isMy: false, created: Date())
                        messages.append(newAnswer)
                    } else {
                        let newAnswer = MessageItem(text: Test.textError, isMy: false, created: Date())
                        messages.append(newAnswer)
                    }
                    shouldScrollToBottom = true
                    return
                }
            }
        }
        
        guard !isSendMessageLocked else {
            wasSendActionBeforeNavigationToPaywall = true
            handleSendWhenLimitReached()
            return
        }
        
        let resultText = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !resultText.isEmpty else { return }
        
        if let resultImage = image {
            let newQuestion = MessageItem(text: text, isMy: true, image: resultImage, created: Date())
            messages.append(newQuestion)
            text = ""
            image = nil
            
            isLoading = true
            _describeImage(resultImage, text: resultText) { [weak self] result in
                if let result = result {
                    self?.handleSendTextResponse(ChatResponse(output: result, promptTokens: 0, completionTokens: 0), questionId: newQuestion.id)
                } else {
                    self?.handleSendTextResponse(nil, questionId: newQuestion.id)
                }
            }
        } else if let resultPdf = pdfData {
            let newQuestion = MessageItem(text: text, isMy: true, created: Date())
            messages.append(newQuestion)
            text = ""
            pdfData = nil
            
            isLoading = true
            _describeDocument(resultPdf, text: resultText) { [weak self] result in
                if let result = result {
                    self?.handleSendTextResponse(ChatResponse(output: result, promptTokens: 0, completionTokens: 0), questionId: newQuestion.id)
                } else {
                    self?.handleSendTextResponse(nil, questionId: newQuestion.id)
                }
            }
        } else {
            let newQuestion = MessageItem(text: text, isMy: true, created: Date())
            messages.append(newQuestion)
            text = ""
            
            isLoading = true
            _sendText(messages: messages) { [weak self] result in
                self?.handleSendTextResponse(result, questionId: newQuestion.id)
            }
        }
    }
    
//    func onRegenerateAnswer() {
//        guard let question = messages.first else { return }
//
//        Utils.hapticFeedback()
//        guard !isSendMessageLocked else {
//            handleSendWhenLimitReached()
//            return
//        }
//
//        wasRegeneratedAnswer = true
//        messages = [question]
//        isLoading = true
//        _sendText(messages: [question]) { [weak self] result in
//            self?.handleSendTextResponse(result)
//        }
//    }
    
    private func handleSendTextResponse(_ result: ChatResponse?, questionId: String) {
        isLoading = false
        
        if let result = result {
            LocalStorage.shared.questionsCountForReview += 1
            LocalStorage.shared.questionsCountIncrement()
            if let index = messages.firstIndex(where: { $0.id == questionId}) {
                messages[index].usageTokens = result.promptTokens
            }
            let newAnswer = MessageItem(text: result.output, isMy: false, created: Date(), usageTokens: result.completionTokens)
            typingMessageId = newAnswer.id
            messages.append(newAnswer)
            speakText(newAnswer.text)
        } else {
            isAnswerError = true
        }
        
        shouldScrollToBottom = true
    }
    
    private func handleSendWhenLimitReached() {
        Utils.keyWindow?.endEditing(true)
        showBuyPro = true
    }
    
    func onPaywallDoneAction() {
        if BuyProService.shared.subscribed {
            if wasTryAgainActionBeforeNavigationToPaywall {
                onTryAgainAction()
            } else if wasSendActionBeforeNavigationToPaywall {
                onSendAction()
            }
        }
        wasSendActionBeforeNavigationToPaywall = false
        wasTryAgainActionBeforeNavigationToPaywall = false
    }
    
    func onTryAgainAction() {
        guard let lastQuestion = messages.last, lastQuestion.isMy else { return }

        Utils.hapticFeedback()
        guard !isSendMessageLocked else {
            wasTryAgainActionBeforeNavigationToPaywall = true
            handleSendWhenLimitReached()
            return
        }
        isAnswerError = false
        messages.removeLast()
        text = lastQuestion.text
        image = lastQuestion.image
        onSendAction()
    }
    
    func onNewChatAction() {
        Utils.hapticFeedback()
        saveChat()
        qaItem = nil
        isAnswerError = false
        messages = []
    }

    func onAskNewQuestionButtonPressed() {
        guard !isLoading else { return }
        
        Utils.hapticFeedback()
        showAlert(.newChat)
    }
    
    func onToggleIsSoundOff() {
        Utils.hapticFeedback()
        isSoundOff.toggle()
        LocalStorage.shared.isSoundOff = isSoundOff
        
        if isSoundOff {
            stopSynthesizer()
        } else {
            if isTyping, !typingTextRemain.isEmpty {
                speakText(typingTextRemain)
            }
        }
    }
    
    func onTypingTextRemain(_ text: String) {
        typingTextRemain = text
    }
    
    func onCopyAction(text: String) {
        Utils.hapticFeedback()
        Utils.copyToClipboard(text: text)
        let indicatorView = SPIndicatorView(title: "Copied".localized(), preset: .done)
        indicatorView.dismissByDrag = true
        indicatorView.presentSide = .bottom
        indicatorView.present(duration: 3)
    }
    
    private func _describeImage(_ image: UIImage, text: String, completion: @escaping (String?)-> Void) {
        guard let data = image.pngData() else { return completion(nil) }
        
        NetworkManager.shared.describeFile(data, fileType: .image, text: text, completion: completion)
    }
    
    private func _describeDocument(_ data: Data, text: String, completion: @escaping (String?)-> Void) {
        NetworkManager.shared.describeFile(data, fileType: .pdf, text: text, completion: completion)
    }
    
    private func _sendText(messages: [MessageItem], completion: @escaping (ChatResponse?)-> Void) {
        //openAI.sendText(mode: .turbo, isChat: isDialog, messages: messages, completion: completion)
        let testFiltered = messages.filter{ !$0.text.contains(Test.textSetTo) && !$0.text.contains(Test.textTemperatureIsSetTo) && !$0.text.contains(Test.textError) }
        openAI.sendText(messages: testFiltered, completion: completion)
    }
    
    func saveChat() {
        let moc = PersistenceController.shared.container.viewContext
        
        var resultMessages: [Message] = []
        for messageItem in messages {
            let item = Message(context: moc)
            item.id = messageItem.id
            item.text = messageItem.text
            item.created = messageItem.created
            item.isMy = messageItem.isMy
            if let pngData = messageItem.image?.pngData() {
                item.image = pngData
            }
            item.usageTokens = Int64(messageItem.usageTokens)
            resultMessages.append(item)
        }
        if resultMessages.last?.isMy == true {
            resultMessages.removeLast()
        }
        
        guard !resultMessages.isEmpty, let lastQuestion = resultMessages.last(where: { $0.isMy }) else {
            if let chat = chat {
                moc.delete(chat)
                try? moc.save()
            }
            return
        }
        
        if chat == nil {
            chat = Chat(context: moc)
            chat?.id = UUID().uuidString
        }
        chat?.name = chatNameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : chatNameText
        chat?.lastQuestion = lastQuestion.text
        chat?.lastQuestionCreated = lastQuestion.created
        chat?.messages = NSSet(array: resultMessages)
        
        try? moc.save()
    }
    
}

extension AskQuestionView {
    enum AlertType {
        case newChat
        case deleteChat
        case upgrade
        case settings(message: String)
    }

}
