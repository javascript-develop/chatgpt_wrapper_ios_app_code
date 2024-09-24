//
//  GoogleDriveManager.swift
//  GenieD
//
//  Created by OK on 20.04.2023.
//

import SwiftUI
import GoogleSignIn
import GoogleAPIClientForREST

class GoogleDriveManager: ObservableObject {
    
    static let shared: GoogleDriveManager = GoogleDriveManager()
    private var clientID: String {
        SwiftConfiguration.current.googleClientId
    }
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
    let service = GTLRDriveService()
    var googleAPIs: GoogleDriveAPI?
    private static let internalError = "Internal error";
        
    init(){
        check()
    }
    
    func checkStatus(){
        if let user = GIDSignIn.sharedInstance.currentUser {
            isLoggedIn = true
            createGoogleDriveService(user: user)
        } else {
            isLoggedIn = false
            googleAPIs = nil
        }
    }
        
    func check(){
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            
            self.checkStatus()
        }
    }
        
    func signIn(completion: @escaping ()-> Void) {
        guard let presentingViewController = (UIApplication.shared.connectedScenes.first as? UIWindowScene)?.windows.first?.rootViewController else {
            completion()
            return
        }
        
        let signInConfig = GIDConfiguration.init(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = signInConfig
        
       
        GIDSignIn.sharedInstance.signIn(withPresenting: presentingViewController, hint: nil, additionalScopes: [kGTLRAuthScopeDriveReadonly]) { [weak self] signInResult, error in
            guard let self = self else { return }
            
            if let error = error {
                self.errorMessage = "error: \(error.localizedDescription)"
            }
            self.checkStatus()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    func restoreSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] user, error in
            if error != nil || user == nil {
                print("### restoreSignIn() ... ERRRR: \(String(describing: error)), \(String(describing: error?.localizedDescription))")
                
            } else {
                print("### restrestoreSignIn() ... DONE")
                self?.checkStatus()
            }
        }
    }
    
    func checkAutorization(completion: @escaping ()-> Void) {
        if googleAPIs != nil {
            completion()
        } else {
            signIn(completion: completion)
        }
    }
    
    func signOut(){
        GIDSignIn.sharedInstance.signOut()
        checkStatus()
    }
    
    func createGoogleDriveService(user: GIDGoogleUser) {
        service.authorizer = user.fetcherAuthorizer
        googleAPIs = GoogleDriveAPI(service: service)
    }
    
    //https://developers.google.com/drive/api/guides/ref-export-formats
    public func listAllPdfFiles(token: String?, completion: @escaping ([GoogleDriveFile]?, String?, String?) -> ()) {
        checkAutorization { [weak self] in
            guard let self = self else { return completion(nil, nil, GoogleDriveManager.internalError) }
            guard self.googleAPIs != nil else { return completion(nil, nil, GoogleDriveManager.internalError) }
            
//            let root = "mimeType = 'image/jpeg' or mimeType = 'image/png' or mimeType = 'application/pdf' or mimeType = 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'"
            let root = "mimeType = 'image/jpeg' or mimeType = 'image/png'"
            let query = GTLRDriveQuery_FilesList.query()
            query.pageSize = 1000
            query.pageToken = token
            query.q = root
            query.fields = "files(id,name,mimeType,modifiedTime,fileExtension,size,iconLink, thumbnailLink, hasThumbnail),nextPageToken"
            self.service.executeQuery(query) { (ticket, results, error) in
                
                guard let files = (results as? GTLRDrive_FileList)?.files else {
                    return completion(nil, nil, error?.localizedDescription ?? GoogleDriveManager.internalError)
                }
                
                let resultFiles = files.map { GoogleDriveFile($0) }
                let nextPageToken = (results as? GTLRDrive_FileList)?.nextPageToken
                completion(resultFiles, nextPageToken, nil)
            }
        }
    }
    
    public func download(fileItems: [GoogleDriveFile], completion: @escaping ([Data]?, String?) -> ()) {
        guard let api = googleAPIs else { return completion(nil, GoogleDriveManager.internalError) }
        guard !fileItems.isEmpty else { return completion([], nil) }
        
        let firstItem = fileItems[0].gtlrDrive_File
        api.download(firstItem) { data, error in
            if let data = data {
                completion([data], nil)
            } else {
                completion(nil, error?.localizedDescription ?? GoogleDriveManager.internalError)
            }
        }
    }
}
