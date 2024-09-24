//
//  FileType.swift
//  GenieD
//
//  Created by OK on 25.04.2023.
//

import Foundation

enum FileType {
    case image, pdf
    
    var fileName: String {
        switch self {
        case .image:
            return "image.png"
        case .pdf:
            return "document.pdf"
        }
    }
    
    var contentType: String {
        switch self {
        case .image:
            return "image/png"
        case .pdf:
            return "application/pdf"
        }
    }
}
