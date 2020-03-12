//
//  OGNSocketConnectionManager.swift
//  Glider Tool
//
//  Created by sonic on 06.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import Network

class OGNSocketConnectionManager {
    
    // MARK: - Lets and Vars
    static let shared = OGNSocketConnectionManager()
    
    private var connection: NWConnection?
    private var queue = DispatchQueue(label: "NetworkQueue", qos: .utility)
    private lazy var userName = generateRandomUserName()
    
    var showFlarmBuddy = false
    
    var receivedServerIdentification: Bool = false
    var isLoggedIn = false
    
    var version: String = "iSoar \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")_\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")"
    
    var latitude: Double = 47.8
    var longitude: Double = 8.9
    var regionInKm: Double = 20
    var buddyFlarmID: String = UserDefaultsManager.getBuddyFlarmID()
    
    // MARK: - Init&Co.
    // Generate Random Username
    private func generateRandomUserName()
        -> String {
            let length = 9
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let randomCharacters = (0..<length).map {_ in characters.randomElement()!}
            let username = String(randomCharacters)
            
            return username
    }
    
    // MARK: - Public Methods
    // Connect to Server Socket
    func connectToOGNServerSocket() {
        // Check if Nearby Gliders should be shown on Map
        print("We are loggin in: \(isLoggedIn)")
        
        showFlarmBuddy = UserDefaultsManager.getShowFlarmBuddySwitchKey()
        if showFlarmBuddy == true && isLoggedIn == false {
            // Delay Login
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                // 10152 Full Feed, 14580 Filtered Feed
                self.connection = NWConnection(host: "aprs.glidernet.org",
                                               port: 14580,
                                               using: .tcp)
                
                self.connection?.stateUpdateHandler = { NewConnectionState in
                    switch (NewConnectionState) {
                    case .setup:
                        //The connection has been initialized but not started
                        print("setup")
                    case .waiting:
                        //The connection has been initialized but not started
                        print("waiting")
                    case .preparing:
                        //The connection in the process of being established
                        print("Connection: Preparing")
                    case .ready:
                        //The connection is established and ready to send and recieve data.
                        print("Connection: Ready")
                        self.setupReceive()
                    case .failed:
                        //The connection in the process of being established
                        print("Connection: failed")
                        self.isLoggedIn = false
                    case .cancelled:
                        //The connection has been cancelled
                        print("Connection: cancelled")
                        self.isLoggedIn = false
                    default:
                        //The connection has disconnected or encountered an error
                        print("waiting or failed")
                    }
                }
                self.connection?.start(queue: .main)
            }
        } else {
            print("OGN Connect Switch OFF or already logged in")
        }
        
    }
    
    // MARK: - Private Methods
    // Setup Receive Data
    private func setupReceive() {
        connection?.receive(minimumIncompleteLength: 1,
                            maximumLength: 9000,
                            completion: { [unowned self] (data, context, isComplete, error) in
                                
                                if let receivedData = data,
                                    let receivedMessage = String(data: receivedData, encoding: .utf8) {
                                    self.messageReceived(receivedMessage)
                                }
                                
                                if self.receivedServerIdentification == false {
                                    self.receivedServerIdentification = true
                                    print("Received Server Ident: \(self.receivedServerIdentification)")
                                    
                                    if !self.isLoggedIn {
                                        self.login()
                                    }
                                }
                                
                                if context?.identifier == "Final Message" && isComplete {
                                    self.connection?.cancel()
                                    return
                                }
                                
                                if let messageError = error {
                                    print("Recieve error: \(messageError)")
                                } else {
                                    self.setupReceive()
                                }
        })
    }
    
    // Send Login String with generated Username and Current Location
    private func login() {
        // Filter for unique FlarmID or multiple IDs seperated bei /
        //sendPaket("user \(userName) pass -1 vers \(version) filter b/\(buddyFlarmID)\n")
        
        // Filter via Radius
        sendPaket("user \(userName) pass -1 vers \(version) filter r/\(latitude)/\(longitude)/\(regionInKm)\n")
        
        isLoggedIn = true
    }
    
    // Send Filter Request to Server
    private func sendPaket(_ packet: String) {
        let packetData = packet.data(using: .utf8)
        
        print("Sent PaketData: \(packetData!)")
        
        connection?.send(content: packetData,
                         completion: .contentProcessed( { (error) in
                            if let err = error {
                                print("Sending error \(err)")
                            } else {
                                print("Filter Request successfully sent")
                            }
                         }))
        
    }
    
    // Received Message from Sender
    // https://github.com/svoop/ogn_client-ruby/wiki/SenderBeacon
    private func messageReceived(_ receivedMessage: String) {
        print("\(#function): \(receivedMessage)")
        
        guard receivedMessage.hasPrefix("FLR") ||
            receivedMessage.hasPrefix("ICA")
            else { return }
        
        print("FOUND PREFIX")
        let messages = receivedMessage.split(separator: "\r\n")
        print("Teilnachrichten: \(messages.count)")
        
        var helper = receivedMessage
        
        if let anfang = helper.firstIndex(of: ">"),
            let ende = helper.firstIndex(of: ":") {
            let range = anfang..<ende
            print("Range: \(range)")
            
            helper.replaceSubrange(range, with: "")
        }
        
        helper = helper
            .replacingOccurrences(of: ">", with: " ")
            .replacingOccurrences(of: ":\\", with: " ")
            .replacingOccurrences(of: ":/", with: " ")
            .replacingOccurrences(of: "h", with: " ")
            .replacingOccurrences(of: "N/", with: " ")
            .replacingOccurrences(of: "N\\", with: " ")
            .replacingOccurrences(of: "Eg", with: " ")
            .replacingOccurrences(of: "En", with: " ")
            .replacingOccurrences(of: "EX", with: " ")
            .replacingOccurrences(of: "E'", with: " ")
            .replacingOccurrences(of: "E\'", with: " ")
            .replacingOccurrences(of: "/", with: " ")
            .replacingOccurrences(of: "A=", with: " ")
            .replacingOccurrences(of: "\n", with: "")
            .replacingOccurrences(of: "\r", with: "")
        
        print("bereinigt: \(helper)")
        
        let components = helper.split(separator: " ")
        print("Componets:\n\(components)")
    }
    
}
