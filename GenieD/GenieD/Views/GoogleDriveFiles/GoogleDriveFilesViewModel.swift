//
//  GoogleDriveFilesViewModel.swift
//  GenieD
//
//  Created by OK on 21.04.2023.
//

import Foundation

class GoogleDriveFilesViewModel: ObservableObject {
    
    @Published var files: [GoogleDriveFile] = []
    @Published var selectedIndexes: [Int] = []
    @Published var isLoading = false
    var lastToken: String?
    
    init() {
        fetchFiles()
    }
    
    private func fetchFiles() {
        isLoading = true
        GoogleDriveManager.shared.listAllPdfFiles(token: lastToken) { [weak self] files, token, error in
            guard let self = self else { return }
            
            self.isLoading = false
            guard let files = files else { return }
            
            self.files = files
            self.lastToken = token
        }
    }
    
    func loadData(completion: @escaping ([Data]?)-> Void ) {
        isLoading = true
        let selectedItems = selectedIndexes.map { files[$0] }
        GoogleDriveManager.shared.download(fileItems: selectedItems) { [weak self] result, error in
            guard let self = self else { return completion([]) }
            
            print("GoogleDriveFilesViewModel:: loadData... result.count = \(result?.count)")
            self.isLoading = false
            completion(result)
        }
    }
    
    //MARK: - Actions
    
    func onTapFileAtIndex(_ index: Int) {
        if selectedIndexes.contains(index) {
            selectedIndexes.removeAll(where: { $0 == index})
        } else {
            selectedIndexes.append(index)
        }
    }
}

extension GoogleDriveFile {
    var formatedFileSize: String {
        let bcf = ByteCountFormatter()
        bcf.allowedUnits = [.useKB, .useMB, .useGB] // optional: restricts the units to MB only
        bcf.countStyle = .file
        return bcf.string(fromByteCount: Int64(size))
    }
}
