import Foundation

class OpenAISession {
    
    static let shared = OpenAISession()
    private init() {}
    
    func decodeUrl<T: Decodable>(
        with url: URL,
        body: [String: Any],
        appCheckToken: String,
        completion: @escaping (T?) -> Void
    ) {
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        

        // asyncData(
        //     with: url,  
        //     body: jsonData,
        //     headers: ["X-Firebase-AppCheck": appCheckToken]) { data in
            
        asyncData(
            with: url,
            body: jsonData,
            headers: [:]) { data in
                guard let data = data else { return completion(nil) }
                
                #if DEBUG
                    print("#### json = \(data.prettyPrintedJSONString ?? "nil")")
                #endif
                
                self.decodeData(with: data) { data in
                    completion(data)
                }
        }
    }

    private func decodeData<T: Decodable>(
        _ type: T.Type = T.self,
        with data: Data,
        keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys,
        dataDecodingStrategy: JSONDecoder.DataDecodingStrategy = .deferredToData,
        dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
        completion: @escaping (T?) -> Void
    ) {
        let decoder = JSONDecoder()

        decoder.keyDecodingStrategy = keyDecodingStrategy
        decoder.dataDecodingStrategy = dataDecodingStrategy
        decoder.dateDecodingStrategy = dateDecodingStrategy

        guard let decoded = try? decoder.decode(type, from: data) else {
            return completion(nil)
        }
        
        completion(decoded)
    }
    
    private func asyncData(
        with url: URL,
        method: HTTPMethod = .post,
        headers: [String: String] = [:],
        body: Data? = nil,
        completion: @escaping (Data?) -> Void
    ) {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = [
            "Content-Type": "application/json"
        ]
        request.httpBody = body

        headers.forEach { key, value in
            request.allHTTPHeaderFields?[key] = value
        }

        asyncData(request: request, completion: completion)
    }
    
    private func asyncData(request: URLRequest, completion: @escaping (Data?) -> Void) {
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 240.0
        let session = URLSession(configuration: sessionConfig)
        let task = session.dataTask(with: request) { data, _, error in
            if error != nil {
                completion(nil)
            } else if let data = data {
                completion(data)
            } else {
                completion(Data())
            }
        }
        task.resume()
    }
}

public enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
}
