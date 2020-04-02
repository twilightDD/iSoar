//
//  OGNSocketConnectionManager.swift
//  Glider Tool
//
//  Created by sonic on 06.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation
import Network

// MARK: - DL_OGNSocketConnectionManagerDelegate
protocol DL_OGNSocketConnectionManagerDelegate: class {

    func updateNearbyGlider(gliderTelemetryData: GliderTelemetryData)
    func removeNearbyGlider(gliderTelemetryData: GliderTelemetryData)

}

// MARK: -
// MARK: - OGNSocketConnectionManager
class OGNSocketConnectionManager {

    // MARK: - Lets and Vars
    static let shared = OGNSocketConnectionManager()
    
    private var connection: NWConnection?
    private var queue = DispatchQueue(label: "NetworkQueue", qos: .utility)
    private var userName: String {
        return generateRandomUserName()
    }
    
    var isLoggedIn = false
    
    private var loginTimeStamp = Date.currentUnixTimeStamp
    
    var version: String = "iSoar \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "?")_\(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "?")"

    var regionInKm: Double = Presets.OGNSocketConnection.regionInKm

    var buddyFlarmID: String = UserDefaultsManager.getBuddyFlarmID()
    
    weak var delegate: DL_OGNSocketConnectionManagerDelegate?
    
    // MARK: - Init&Co.
    
    // MARK: - Public Methods
    // Connect to Server Socket
    func connectToOGNServerSocket() {
        // Check if Nearby Gliders should be shown on Map
        print("We are loggin into the OGN Server: \(isLoggedIn)")
        
        if UserDefaultsManager.getShowNearbyGlidersSwitch() && !isLoggedIn {
            // Delay Login
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.connection = NWConnection(host: Presets.OGNSocketConnection.host,
                                               port: Presets.OGNSocketConnection.hostPortFiltered,
                                               using: .tcp)
                
                self.connection?.stateUpdateHandler = { newConnectionState in
                    switch newConnectionState {
                    case .setup:
                        //The connection has been initialized but not started
                        print("Connection: setup")
                    case .waiting:
                        //The connection has been initialized but not started
                        print("Connection: waiting")
                    case .preparing:
                        //The connection in the process of being established
                        print("Connection: preparing")
                    case .ready:
                        //The connection is established and ready to send and recieve data.
                        print("Connection: ready")
                        self.setupReceive()
                    case .failed:
                        //The connection in the process of being established
                        print("Connection: failed")
                        self.isLoggedIn = false
                        self.login()
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
    // Generate random alphanumerical Username witch 9 characters
    private func generateRandomUserName()
        -> String {
            let length = 9
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let randomCharacters = (0..<length).map {_ in characters.randomElement()!}
            let username = String(randomCharacters)
            
            return username
    }
    
    // Setup Receive Data
    private func setupReceive() { connection?.receive(minimumIncompleteLength: 1,
                                                      maximumLength: 9000,
                                                      completion: { [unowned self] (data, context, isComplete, error) in
                                
                                if let receivedData = data,
                                    let receivedMessage = String(data: receivedData, encoding: .utf8) {
                                    self.messageReceived(receivedMessage)
                                }
                                
                                if !self.isLoggedIn {
                                    self.login()
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
        guard let currentLocation = MapScreen.shared?.currentLocation, !isLoggedIn else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.login()
            }
            return
        }

        if UserDefaultsManager.getShowFlarmBuddySwitchKey() {
            // Filter for unique FlarmID or multiple IDs seperated bei /
            sendPaket("user \(userName) pass -1 vers \(version) filter b/\(buddyFlarmID)\n")
        } else {
            // Filter via Radius
            sendPaket("user \(userName) pass -1 vers \(version) filter r/\(currentLocation.coordinate.latitude)/\(currentLocation.coordinate.longitude)/\(regionInKm)\n")
        }
        
        isLoggedIn = true
        loginTimeStamp = Date.currentUnixTimeStamp
    }
    
    // Disconnect from Server
    func cancelConnection() {
        connection?.cancel()
    }
    
    // Send Filter Request to Server
    private func sendPaket(_ packet: String) {
        let packetData = packet.data(using: .utf8)
        
        print("Sent PaketData: \(packetData!)")
        
        connection?.send(content: packetData,
                         completion: .contentProcessed { (error) in
                            if let err = error {
                                print("Sending error \(err)")
                            } else {
                                print("Filter Request successfully sent")
                            }
            })
        
    }
    
    // Received Message from OGN Server
    private func messageReceived(_ receivedMessage: String) {
       // print("Original OGN Message: \(receivedMessage)")

        let splittedMessages = receivedMessage.split(separator: "\r\n")
        // print("Anzahl Teilnachrichten: \(splittedMessages.count)")

        for splittedMessage in splittedMessages {
            guard splittedMessage.hasPrefix("FLR")
                || splittedMessage.hasPrefix("ICA")
                else { continue }

            let gliderSpecificMessage = String(splittedMessage)
            if let telemetryData = GliderTelemetryData.telemetryDataFromOGNGliderResponse(gliderSpecificMessage) {
                delegate?.updateNearbyGlider(gliderTelemetryData: telemetryData)
            }

        }
    }
    
}
