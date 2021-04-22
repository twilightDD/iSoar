//
//  DLNetworkMonitor.swift
//  Glider Tool
//
//  Created by sonic on 30.03.21.
//  Copyright © 2021 Denis Leupold. All rights reserved.
//

import Foundation
import Network

// MARK: - Protocol - NetworkCheckDelegate
protocol DLNetworkMonitorDelegate: AnyObject {
    func networkStatus(status: NWPath.Status)
}

class DLNetworkMonitor {

    // MARK: - Lets and Vars
    // Statics
    static private let shared = DLNetworkMonitor()

    // Private
    private var monitor = NWPathMonitor()

    private var isConnected: NWPath.Status = .satisfied {
        didSet {
            if oldValue != isConnected {
                // Inform delegates
                for delegate in delegates.allObjects {
                    if let networkMonitorDelegate = delegate as? DLNetworkMonitorDelegate {
                        networkMonitorDelegate.networkStatus(status: isConnected)

                    }
                }
            }
        }
    }

    // MARK: - Delegate
    private var delegates = NSHashTable<AnyObject>.weakObjects()

    // MARK: - Public Class Methods
    class func start() {
        let shared =  DLNetworkMonitor.shared
        shared.startMonitoring()
    }

    class func stop() {
        let shared =  DLNetworkMonitor.shared
        shared.stopMonitoring()
    }

    class func registerForNetworkCheckUpdates(_ delegate: DLNetworkMonitorDelegate) {
        shared.delegates.add(delegate)
    }

    class func unRegisterForNetworkCheckUpdates(_ delegate: DLNetworkMonitorDelegate) {
        shared.delegates.remove(delegate)
    }

    // MARK: - Private Instance Methods
    private func startMonitoring() {
        monitor.pathUpdateHandler = { path in
            DispatchQueue.main.async(execute: {
                self.isConnected = path.status
            })
        }

        monitor.start(queue: DispatchQueue.global(qos: .background))
    }

    private func stopMonitoring() {
        monitor.cancel()
    }
}
