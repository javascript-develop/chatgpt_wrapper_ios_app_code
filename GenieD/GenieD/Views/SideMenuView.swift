//
//  SideMenuView.swift
//  GenieD
//
//  Created by OK on 08.03.2023.
//

import SwiftUI

struct SideMenuView: View {
    
    @Binding var isOpened: Bool
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    @State var tagSelection: String?
    @Environment(\.managedObjectContext) var moc
    
    @FetchRequest(
             entity: QAItem.entity(),
             sortDescriptors: [
                 NSSortDescriptor(keyPath: \QAItem.created, ascending: false),
             ]
         ) var qaItems: FetchedResults<QAItem>
    @State var qaItem: QAItem?
    
    @FetchRequest(
        entity: Chat.entity(),
        sortDescriptors: [
            NSSortDescriptor(keyPath: \Chat.lastQuestionCreated, ascending: false)
        ]
    ) var chats: FetchedResults<Chat>
    @State var chat: Chat?
    
    
    var body: some View {
        ZStack {
            CustomColor.mainBg.ignoresSafeArea()
            ScrollView(.vertical) {
                VStack(spacing: 0) {
//                    if let qaItem = qaItem {
//                        NavigationLink(destination: ChatHistoryView(qaItem: qaItem), tag: "ChatItemHistoryView", selection: $tagSelection) { EmptyView() }
//                    }
                    if let chat = chat {
                        NavigationLink(destination: AskQuestionView(isDialog: true, chat: chat), tag: "AskQuestionView", selection: $tagSelection) { EmptyView() }
                    }
                    VSpacer(safeAreaInsets.top)
                    topBar()
                    
                    VSpacer(40.scaled)
                    if chats.isEmpty {
                        noHistoryView()
                    } else {
                        HStack {
                            Text("My Chats".localized())
                                .font(CustomFont.header(.bold))
                            Spacer()
                        }
                        VSpacer(20.scaled)
                        LazyVStack(spacing: 20.scaled) {
                            ForEach(chats) { item in
                                historyItem(chat: item)
                            }
                        }
                    }
                }
                .padding(.horizontal, 20.scaled)
                .padding(.bottom, max(20.scaled, safeAreaInsets.bottom))
            }
        }
        .foregroundColor(CustomColor.blackText)
    }
    
    private func topBar() -> some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                CustomColor.graySeparator.frame(height: 1)
            }
            
            Text("History".localized())
                .font(CustomFont.header(.bold))
        }
        .frame(height: 60.scaled)
    }
    
    private func bodyFont(_ weight: Font.Weight = .regular) -> Font {
        Font.system(size: 16.scaled, weight: weight)
    }
    
    private func noHistoryView() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                Text("Get chatting now! Start your conversation with Leo today.".localized())
                    .font(CustomFont.body(.bold))
                    .foregroundColor(CustomColor.textGray)
                Spacer()
            }
        }
    }
    
//    private func historyItem(qaItem: QAItem) -> some View {
//        HStack(spacing: 0) {
//            HSpacer(6.scaled)
//            Text("#")
//                .font(bodyFont(.bold))
//            HSpacer(6.scaled)
//            Text(qaItem.name ?? qaItem.question ?? "")
//                .font(bodyFont())
//                .lineLimit(1)
//            Spacer()
//        }
//        .contentShape(Rectangle())
//        .onTapGesture {
//            self.qaItem = qaItem
//            tagSelection = "ChatItemHistoryView"
//        }
//    }
    
    private func historyItem(chat: Chat) -> some View {
        HStack(spacing: 0) {
            HSpacer(6.scaled)
            Text("#")
                .font(bodyFont(.bold))
            HSpacer(6.scaled)
            Text(chat.name ?? chat.lastQuestion ?? "")
                .font(bodyFont())
                .lineLimit(1)
            Spacer()
        }
        .contentShape(Rectangle())
        .onTapGesture {
            self.chat = chat
            tagSelection = "AskQuestionView"
        }
    }
}

