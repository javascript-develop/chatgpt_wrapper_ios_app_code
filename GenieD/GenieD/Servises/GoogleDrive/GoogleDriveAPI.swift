//
//  GoogleDriveAPI.swift
//  GenieD
//
//  Created by OK on 20.04.2023.
//

import Foundation

import GoogleAPIClientForREST
import Foundation


class GoogleDriveAPI {
    private let service: GTLRDriveService
    
    init(service: GTLRDriveService) {
        self.service = service
    }
    
    public func search(onCompleted: @escaping ([GTLRDrive_File]?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        //query.q = "mimeType ='\(mimeType)' or mimeType = 'application/vnd.google-apps.folder'"
        query.q = "'root' in parents"
        self.service.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files, error)
        }
    }
    
    public func listFiles(_ folderID: String, onCompleted: @escaping ([GTLRDrive_File]?, Error?) -> ()) {
        let query = GTLRDriveQuery_FilesList.query()
        query.pageSize = 100
        query.q = "'\(folderID)' in parents"
        //        self.service.shouldFetchNextPages = true
        self.service.executeQuery(query) { (ticket, results, error) in
            onCompleted((results as? GTLRDrive_FileList)?.files, error)
        }
    }
    
    public func download(_ fileItem: GTLRDrive_File, onCompleted: @escaping (Data?, Error?) -> ()) {
        guard let fileID = fileItem.identifier else {
            return onCompleted(nil, nil)
        }
        
        self.service.executeQuery(GTLRDriveQuery_FilesGet.queryForMedia(withFileId: fileID)) { (ticket, file, error) in
            if let error = error {
                return onCompleted(nil, error)
            }
            
            guard let data = (file as? GTLRDataObject)?.data else {
                return onCompleted(nil, nil)
            }
            
            onCompleted(data, nil)
        }
    }
}
