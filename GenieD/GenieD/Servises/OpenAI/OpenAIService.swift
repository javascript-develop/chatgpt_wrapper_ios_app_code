import Foundation
import UIKit

class OpenAIService: ObservableObject {
    
    var maxTokens: Int { _maxTokens() }
    
    func sendText(messages: [MessageItem], completion: @escaping (ChatResponse?) -> Void) {
        _sendTurbo(chat: messages, refreshToken: true, completion: completion)
    }
    
    private func getServerUrl() -> URL {
        URL(string: "https://us-central1-chatleo-541ec.cloudfunctions.net/proxyOpenAIRequest")!
    }
    
    private func _sendTurbo(chat: [MessageItem], refreshToken: Bool, completion: @escaping (ChatResponse?) -> Void) {
        guard !chat.isEmpty else { return completion(nil) }

        let checkRefreshKeyAndRestartBlock = {
            if refreshToken {
                FirestoreManager.shared.fetchSystem {
                    if FirestoreManager.shared.aikey != nil {
                        self._sendTurbo(chat: chat, refreshToken: false, completion: completion)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }

        guard FirestoreManager.shared.aikey != nil else {
            checkRefreshKeyAndRestartBlock()
            return
        }

        let addTokens = 50
        let modelMaxTokens = 4097
        let availableTokens = modelMaxTokens - Int(Double(maxTokens) * 0.5) - addTokens

        var messages: [[String: String]] = []
        var sumTokens = 0

        for item in chat.reversed() {
            if sumTokens + item.usageTokens > availableTokens {
                break
            }

            sumTokens += item.usageTokens
            let role = item.isMy ? "user" : "assistant"
            let message: [String: String] = ["role": role, "content": item.text]
            messages.insert(message, at: 0)
        }

        let resultMaxTokens = min(maxTokens, modelMaxTokens - addTokens - sumTokens)
        var body: [String: Any] = [
            "model": GPTModel.turbo.rawValue,
            "messages": messages,
            "max_tokens": resultMaxTokens
        ]
        if let temperature = LocalStorage.shared.temperature {
            body["temperature"] = temperature
        }

        let serverUrl = getServerUrl()

        /*
        AppCheck.shared.getToken(forcingRefresh: false) { token, error in
            guard let token = token?.token else {
                print("Error getting App Check token: \(error?.localizedDescription ?? "Unknown error")")
                return completion(nil)
            }
        */

        OpenAISession.shared.decodeUrl(with: serverUrl, body: body) { response in
            DispatchQueue.main.async {
                if let response: TextTurboResponse = response {
                    completion(response.toChatResponse())
                } else {
                    checkRefreshKeyAndRestartBlock()
                }
            }
        }
        // }
    }

    private func _maxTokens() -> Int {
        guard let access = BuyProService.shared.activeSubscription?.access else {
            return FirestoreManager.shared.freeTokens
        }

        switch access {
        case .lite:
            return FirestoreManager.shared.liteTokens
        case .pro, .advanced:
            return FirestoreManager.shared.proTokens
        }
    }
}

enum ImageSize: String {
    case small = "256x256"
    case medium = "512x512"
    case large = "1024x1024"
}

enum ResponseFormat: String {
    case url = "url"
    case base64Json = "b64_json"
}

enum GPTModel: String {
    case turbo = "gpt-4o-mini"
}
