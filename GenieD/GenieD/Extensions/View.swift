//
//  UIView.swift
//  GenieD
//
//  Created by OK on 10.03.2023.
//

import SwiftUI

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.edgesIgnoringSafeArea(.all))
        let view = controller.view
        var targetSize = controller.view.intrinsicContentSize
        targetSize.height += 20
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = UIColor(named: "mainBg")
        let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}

extension View {
    func shareChatAsImage(messages: [MessageItem]) {
        DispatchQueue.main.async {
            if let image = renderSnapshot(messages: messages) {
                Utils.shareImage(image)
            }
        }
    }
    
    @MainActor private func renderSnapshot(messages: [MessageItem]) -> UIImage? {
        let contentView = viewForRender(messages: messages)
        if #available(iOS 16.0, *) {
            let renderer = ImageRenderer(content: contentView)
            renderer.scale = UIScreen.main.scale
            return renderer.uiImage
        } else {
            return contentView.snapshot()
        }
    }
    
    private func viewForRender(messages: [MessageItem]) -> some View {
        VStack(spacing: 0) {
            ForEach(messages, id: \.self) { message in
                messageView(message)
            }
        }
        .frame(width: UIScreen.main.bounds.width)
        .foregroundColor(CustomColor.blackText)
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
    
}
