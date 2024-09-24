//
//  ChatHistoryView.swift
//  GenieD
//
//  Created by OK on 08.03.2023.
//

import SwiftUI
import SPIndicator

struct ChatHistoryView: View {
    
    @Environment(\.managedObjectContext) var moc
    @Environment(\.presentationMode) private var presentationMode: Binding<PresentationMode>
    @State var showingAlert = false
    @State var chatNameText: String = ""
    let qaItem: QAItem?
    let messages: [MessageItem]
    
    init(qaItem: QAItem) {
        self.qaItem = qaItem
        self.messages = [MessageItem(text: qaItem.question ?? "", isMy: true),
                         MessageItem(text: qaItem.answer ?? "", isMy: false)]
        _chatNameText = State(initialValue: qaItem.name ?? qaItem.question ?? "")
    }
    
    var body: some View {
            ZStack {
                CustomColor.mainBg.ignoresSafeArea()
                VStack(spacing: 0){
                    topBar()
                    chatView()
                    VSpacer(18.scaled)
                    shareButton()
                    .padding(.horizontal, 16.scaled)
                    .padding(.bottom, (isIPhoneX ? 10 : 20).scaled)
                }
            }
            .foregroundColor(CustomColor.blackText)
            .navigationBarTitle("", displayMode: .inline)
            .navigationBarHidden(true)
            .navigationBarBackButtonHidden(true)
            .modifier(DismissingKeyboard())
            .onDisappear {
                saveChat()
            }
            .onReceive(NotificationCenter.default.publisher(
                for: UIScene.didEnterBackgroundNotification)) { _ in
                    saveChat()
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Are you sure you want to delete?".localized()),
                      message: Text("By proceeding, you'll lose access to this chat.".localized()),
                      primaryButton: .default(Text("No".localized()), action: {}),
                      secondaryButton: .destructive(Text("Yes".localized()), action: {
                                onDeleteAction()
                                })
                )
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
                    dissmiss()
                }) {
                    SystemImage("arrow.backward", width: 25.scaled)
                        .padding(10)
                }
                .padding(.leading, 15.scaled)
                
                nameTextField()
                
                Button(action: {
                    showingAlert = true
                }) {
                    SystemImage("trash", width: 20.scaled)
                        .padding(10)
                }
                .padding(.trailing, 20.scaled)
            }
        }
        .frame(height: 60.scaled)
    }
    
    private func nameTextField() -> some View {
        TextField("", text: $chatNameText)
            .font(CustomFont.body(.bold))
            .padding(.horizontal, 30.scaled)
    }
    
    private func chatView() -> some View {
        GeometryReader { reader in
            ScrollViewReader { proxy in
                ScrollView(.vertical) {
                    VStack(spacing: 0) {
                        Spacer()
                        ForEach(messages, id: \.self) { message in
                            messageView(message)
                        }
                    }
                    .frame(minHeight: reader.size.height)
                }
            }
        }
    }
    
    private func messageView(_ message: MessageItem) -> some View {
        VStack(alignment: .trailing, spacing: 0) {
            HStack(alignment: .top, spacing: 15.scaled) {
                SystemImage(message.isMy ? "person.circle.fill" : "ellipsis.bubble.fill", width: 30.scaled)
                    .foregroundColor(message.isMy ? CustomColor.blackText : CustomColor.green)
                    .padding(.leading, 15.scaled)
                Text(message.text)
                    .font(.system(size: 15.scaled))
                    .padding(.trailing, 15.scaled)
                Spacer()
            }
            if !message.isMy {
                Button(action: {
                    onCopyAction(text: message.text)
                }) {
                    SystemImage("square.on.square", width: 25)
                        .foregroundColor(CustomColor.textGray)
                        .padding(10.scaled)
                }
                .padding(.top, 10.scaled)
                .padding(.bottom, 15.scaled)
                .padding(.trailing, 20.scaled)
            }
        }
        .padding(.vertical, 15.scaled)
        .background {
            message.isMy ? Color.clear : CustomColor.graySeparator
        }
    }
    
    private func shareButton() -> some View  {
        Button(action: {
            onShareAction()
        }) {
            ZStack {
                RoundedRectangle(cornerRadius: 10.scaled)
                    .fill(CustomColor.green)
                HStack(spacing: 15.scaled) {
                    Text("Share".localized())
                        .font(CustomFont.button(.bold))
                    SystemImage("square.and.arrow.up", width: 20.scaled)
                }
                .foregroundColor(CustomColor.whiteText)
            }
        }
        .frame(height: 60.scaled)
    }
    
    private func onShareAction() {
        shareChatAsImage(messages: messages)
    }
    
    private func onDeleteAction() {
        if let qaItem = qaItem {
            moc.delete(qaItem)
            try? moc.save()
        }
        dissmiss()
    }
    
    private func onCopyAction(text: String) {
        Utils.copyToClipboard(text: text)
        let indicatorView = SPIndicatorView(title: "Copied".localized(), preset: .done)
        indicatorView.dismissByDrag = true
        indicatorView.presentSide = .bottom
        indicatorView.present(duration: 3)
    }
    
    private func dissmiss() {
        presentationMode.wrappedValue.dismiss()
    }
    
    private func saveChat() {
        qaItem?.name = chatNameText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : chatNameText
        try? moc.save()
    }
}

