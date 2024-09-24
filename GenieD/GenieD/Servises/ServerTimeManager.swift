//
//  ServerTimeManager.swift
//  GenieD
//
//  Created by OK on 15.03.2023.
//

import Foundation

class ServerTimeManager: ObservableObject {
    
    static let shared = ServerTimeManager()
    @Published var timeDifference: TimeInterval?
    private var isLoading = false
    private var failedRequestsCount = 0
    
    func updateServerTime() {
        failedRequestsCount = 0
        _requestTimestamp { date in
            self._handleResponse(date: date)
        }
    }
    
    func _handleResponse(date: Date?) {
        if let ts = date {
            failedRequestsCount = 0
            timeDifference = Date().timeIntervalSince(ts)
        } else {
            self.failedRequestsCount += 1
            if self.failedRequestsCount <= 5 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self._requestTimestamp { date in
                        self._handleResponse(date: date)
                    }
                }
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 60) {
                    self._requestTimestamp { date in
                        self._handleResponse(date: date)
                    }
                }
            }
        }
    }
    
    private func _requestTimestamp(completion: @escaping (Date?)-> Void) {
        guard !isLoading else { return }
        
        isLoading = true
        let url = URL(string: "https://worldtimeapi.org/api/timezone/Etc/GMT")!

        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            #if DEBUG
                print("#### json = \(data?.prettyPrintedJSONString ?? "nil")")
            #endif
            DispatchQueue.main.async {
                self.isLoading = false
                guard
                    let data = data,
                    let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                    let unixtime = json["unixtime"] as? Double
                else { return completion(nil) }
                
                let resultDate = Date(timeIntervalSince1970: unixtime)
                completion(resultDate)
            }
        }

        task.resume()
    }
}

extension Data {
    var prettyPrintedJSONString: NSString? {
        guard let object = try? JSONSerialization.jsonObject(with: self, options: []),
              let data = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
              let prettyPrintedString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) else { return nil }

        return prettyPrintedString
    }
}
