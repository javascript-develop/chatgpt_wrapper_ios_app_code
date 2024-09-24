//
//  NetworkManager.swift
//  GenieD
//
//  Created by OK on 07.04.2023.
//

import Foundation
import UIKit

class NetworkManager {
    
    static let shared = NetworkManager()
    
    func describeFile(_ data: Data, fileType: FileType, text: String, completion: @escaping (String?)->Void) {
        let form = MultipartForm(parts: [
            MultipartForm.Part(name: "query", value: text),
            MultipartForm.Part(name: "file", data: data, filename: fileType.fileName, contentType: fileType.contentType),
        ])

        let url = URL(string: "https://gpt-file-querry.vercel.app")!
        let token = SwiftConfiguration.current.gptFileQueryToken
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(token, forHTTPHeaderField: "Authorization")
        request.setValue(form.contentType, forHTTPHeaderField: "Content-Type")
        
        let session = URLSession.shared
        let task = session.uploadTask(with: request, from: form.bodyData) { responseData, response, error in
            #if DEBUG
                print("#### error = \(error)")
                print("#### json = \(responseData?.prettyPrintedJSONString ?? "nil")")
            #endif
            guard let responseData = responseData else {
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }
            
            let jsonData = try? JSONSerialization.jsonObject(with: responseData, options: .allowFragments)
            if let json = jsonData as? [String: Any], let message = json["message"] as? String {
                
                DispatchQueue.main.async {
                    completion(message)
                }
            } else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        task.resume()
    }
}
