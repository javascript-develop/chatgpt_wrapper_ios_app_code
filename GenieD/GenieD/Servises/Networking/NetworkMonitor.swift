//
//  NetworkMonitor.swift
//  GenieD
//
//  Created by OK on 08.05.2023.
//

import SwiftUI
import Network


final class NetworkMonitor: ObservableObject {
    @Published private(set) var isConnected = false
    @Published private(set) var isCellular = false
    
    private let nwMonitor = NWPathMonitor()
    private let workerQueue = DispatchQueue.global()
    
    public func start() {
        nwMonitor.start(queue: workerQueue)
        nwMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isCellular = path.usesInterfaceType(.cellular)
            }
        }
    }
    
    public func stop() {
        nwMonitor.cancel()
    }
}
