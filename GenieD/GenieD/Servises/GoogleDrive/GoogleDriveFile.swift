//
//  GoogleDriveFile.swift
//  GenieD
//
//  Created by OK on 21.04.2023.
//

import Foundation
import GoogleAPIClientForREST

struct GoogleDriveFile {
    
    let gtlrDrive_File: GTLRDrive_File
    init(_ file: GTLRDrive_File) {
        self.gtlrDrive_File = file
    }
    
    var name: String {
        gtlrDrive_File.name ?? ""
    }
    
    var size: Double {
        gtlrDrive_File.size?.doubleValue ?? 0
    }
    
    var thumbnailLink: String? {
        gtlrDrive_File.thumbnailLink
    }
    
    var modifiedTime: Date? {
        gtlrDrive_File.modifiedTime?.date
    }
}
