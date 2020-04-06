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
    func removeAllNearbyGlider()
    
}

// MARK: -
// MARK: - OGNSocketConnectionManager
class OGNSocketConnectionManager {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = OGNSocketConnectionManager()
    
    // Public
    weak var delegate: DL_OGNSocketConnectionManagerDelegate?
    
    // Private
    private var connection: NWConnection?
    private var queue = DispatchQueue(label: "NetworkQueue", qos: .utility)
    private var userName: String {
        let userName = generateRandomUserName()
        return userName
    }
    
    private var isLoggedIn = false
    private var loginTimeStamp = Date.currentUnixTimeStamp //TODO: wozu wird der gebraucht?; 03042020, ph
    
    private var buddyFlarmID: String = UserDefaultsManager.buddyFlarmID()
    private var regionInKm: Double = Presets.OGNSocketConnection.regionInKm
    
    // MARK: - Public Class Methods
    class func registerForSocketUpdates(_ delegate: DL_OGNSocketConnectionManagerDelegate?) {
        shared.delegate = delegate
    }
    
    class  func unregisterForSocketUpdates(_ delegate: DL_OGNSocketConnectionManagerDelegate?) {
        shared.delegate = nil
    }
    
    class func start() {
        shared.connectToOGNServerSocket()
    }
    
    class func stop() {
        shared.cancelConnection()
    }
    
}

// MARK: - Extension - Instance Methods
extension OGNSocketConnectionManager {
    
    // MARK: Private Instance Methods
    // Connect to Server Socket
    private func connectToOGNServerSocket() {
        // Check if Nearby Gliders should be shown on Map
        print("We are loggin into the OGN Server: \(isLoggedIn)")
        
        let showAllNearbyGlidersState = UserDefaultsManager.showAllNearbyGlidersState()
        if showAllNearbyGlidersState == true
            && isLoggedIn == false {
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
    
    // Disconnect from Server
    private func cancelConnection() {
        connection?.cancel()
        
        delegate?.removeAllNearbyGlider()
    }
    
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
    private func setupReceive() {
        connection?.receive(minimumIncompleteLength: 1,
                            maximumLength: 9000,
                            completion: { [unowned self] (data, context, isComplete, error) in
                                
                                if let receivedData = data,
                                    let receivedMessage = String(data: receivedData, encoding: .utf8) {
                                    self.messageReceived(receivedMessage)
                                }
                                
                                if self.isLoggedIn == false {
                                    self.login()
                                }
                                
                                let contextIdentifier = context?.identifier
                                if  contextIdentifier == "Final Message"
                                    && isComplete == true {
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

        guard let currentLocation = LocationManager.currentLocation(),
            isLoggedIn == false
            else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.login()
                }
                return
        }
        
        let appVersion = Presets.OGNSocketConnection.appVersion
        if UserDefaultsManager.showOnlyBuddySwitchState() {
            // Filter for unique FlarmID or multiple IDs seperated bei /
            let packet = "user \(userName) pass -1 vers \(appVersion) filter b/\(buddyFlarmID)\n"
            sendPaket(packet)
        } else {
            // Filter via Radius
            let packet = "user \(userName) pass -1 vers \(appVersion) filter r/\(currentLocation.coordinate.latitude)/\(currentLocation.coordinate.longitude)/\(regionInKm)\n"
            sendPaket(packet)
        }
        
        isLoggedIn = true
        loginTimeStamp = Date.currentUnixTimeStamp
    }
    
    // Send Filter Request to Server
    private func sendPaket(_ packet: String) {
        let packetData = packet.data(using: .utf8)
        
        connection?.send(content: packetData,
                         completion: .contentProcessed { (error) in
                            if let err = error {
                                print("\(#function) Sending error \(err)")
                            } else {
                                print("\(#function) Filter Request successfully sent:\n\(packet)")
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
                else {
                    //print("\(#function): splittedMessage dismissed:   \(splittedMessage)")
                    continue }
            
            let gliderSpecificMessage = String(splittedMessage)
            if let telemetryData = GliderTelemetryData.telemetryDataFromOGNGliderResponse(gliderSpecificMessage) {
                delegate?.updateNearbyGlider(gliderTelemetryData: telemetryData)
            }
//            else {
//                print("~~~~~~~~~~~~~~~~~")
//                print("TelemetryData konnten nicht geparst werden.")
//                print("original OGN Message (receivedMessage) war:")
//                print("\(receivedMessage)")
//                print("~~~~~~~~~~~~~~~~~")
//                print("~~~~~~~~~~~~~~~~~")
//                print("~~~~~~~~~~~~~~~~~")
//
//            }
        }

    }
    
}
