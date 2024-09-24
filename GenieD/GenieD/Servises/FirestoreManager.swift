//
//  FirestoreManager.swift
//  GenieD
//
//  Created by OK on 28.02.2023.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

class FirestoreManager: ObservableObject {
    
    private let COLLECTION_SYSTEM = "system"
    
    static let shared: FirestoreManager = FirestoreManager()
    
    let db = Firestore.firestore()
    private(set) var aikey: String?
    @Published private(set) var freeRequests = 3
    private(set) var liteRequests = 10
    private(set) var freeTokens = 3000
    private(set) var liteTokens = 300
    private(set) var proTokens = 3000

    func signIn(email: String, password: String, completion: @escaping (String?)->Void) {
        Auth.auth().signIn(withEmail: email, password: password, completion: { (result, error) in
            completion(error?.localizedDescription)
        })
    }
    
    func fetchSystem(completion: @escaping () -> Void) {
        db.collection(COLLECTION_SYSTEM)
            .getDocuments { snapshot, error in
                guard let documents = snapshot?.documents else { return completion() }
                
                for docItem in documents {
                    if docItem.documentID == "GPT" {
                        if let key = docItem.data()["key"] as? String {
                            self.aikey = key
                        }
                    } else if docItem.documentID == "DAYLIMIT" {
                        if let res = docItem.data()["freeRequests"] as? Int {
                            self.freeRequests = res
                        }
                        if let res = docItem.data()["freeTokens"] as? Int {
                            self.freeTokens = res
                        }
                        if let res = docItem.data()["liteRequests"] as? Int {
                            self.liteRequests = res
                        }
                        if let res = docItem.data()["liteTokens"] as? Int {
                            self.liteTokens = res
                        }
                        if let res = docItem.data()["proTokens"] as? Int {
                            self.proTokens = res
                        }
                    }
                }
                
                completion()
            }
    }
}


