//
//  OGNSocketConnectionManager.swift
//  Glider Tool
//
//  Created by sonic on 06.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Network
import CoreLocation

// MARK: - DL_OGNSocketConnectionManagerDelegate
protocol DL_OGNSocketConnectionManagerDelegate: class {
    
    func updateNearbyGlider(gliderTelemetryData: GliderTelemetryData)
    func removeNearbyGlider(gliderTelemetryData: GliderTelemetryData)
    func removeAllNearbyGliders()
    
}

// MARK: -
// MARK: - OGNSocketConnectionManager
class OGNSocketConnectionManager {
    
    // MARK: - Lets and Vars
    // Statics
    static private let shared = OGNSocketConnectionManager()
    
    // Private
    private var connection: NWConnection?
    private var queue = DispatchQueue(label: "NetworkQueue", qos: .utility)
    private var userName: String {
        let userName = generateRandomUserName()
        return userName
    }
    
    private var isLoggedIn = false
    private var loginCoordinates: CLLocation?
    
    private var delegates = NSHashTable<AnyObject>.weakObjects()
    
    private var gliderTelemetryDatas = Set<GliderTelemetryData>()
    
    // MARK: - Public Class Methods
    class func registerForSocketUpdates(_ delegate: DL_OGNSocketConnectionManagerDelegate?) {
        
        //print("\(#function) - willAdd delegates.count = \(shared.delegates.count)")
        shared.delegates.add(delegate)
        //print("\(#function) - did Add delegates.count = \(shared.delegates.count)")
        //print(shared.delegates)
    }
    
    class func unregisterForSocketUpdates(_ delegate: DL_OGNSocketConnectionManagerDelegate?) {
        
        //print("\(#function) - willRemove delegates.count = \(shared.delegates.count)")
        shared.delegates.remove(delegate)
        //print("\(#function) - did Remove delegates.count = \(shared.delegates.count)")
        //print(shared.delegates)
    }
    
    class func start() {
        shared.connectToOGNServerSocket()
        LocationManager.registerForLocationUpdates(shared)
    }
    
    class func stop() {
        shared.cancelConnection()
        LocationManager.unRegisterForLocationUpdates(shared)
    }
    
    class func reconnect() {
        // Disconnect from OGN Server
        OGNSocketConnectionManager.stop()
        // Reconnect to OGN Server
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            OGNSocketConnectionManager.start()
        }
    }
    
    class func didUpdateBuddiesOrSelectedOtherGlider() {
        if UserDefaultsManager.showAllNearbyGlidersState() == true,
            UserDefaultsManager.showOnlyBuddySwitchState() == true {
            
            OGNSocketConnectionManager.reconnect()
        }
        
    }

}

// MARK: - Extension - Instance Methods
extension OGNSocketConnectionManager {
    
    // MARK: Private Instance Methods
    // Connect to Server Socket
    private func connectToOGNServerSocket() {
        // Check if Schow Nearby Gliders Switch is On
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
                        // The connection has been initialized but not started
                        print("OGN Connection: setup")
                    case .waiting:
                        // The connection has been initialized but not started
                        print("OGN Connection: waiting")
                    case .preparing:
                        // The connection in the process of being established
                        print("OGN Connection: preparing")
                    case .ready:
                        // The connection is established and ready to send and recieve data.
                        print("OGN Connection: ready")
                        self.setupReceive()
                    case .failed:
                        // The connection has failed or interrupted
                        print("OGN Connection: failed")
                        self.isLoggedIn = false
                        self.connectToOGNServerSocket()
                    case .cancelled:
                        // The connection has been cancelled
                        print("OGN Connection: cancelled")
                        self.isLoggedIn = false
                    default:
                        // The connection has disconnected or encountered an error
                        print("OGN Connection: waiting or failed")
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
        
        for delegate in delegates.allObjects {
            if let ognSocketConnectionManagerDelegate = delegate as? DL_OGNSocketConnectionManagerDelegate {
                ognSocketConnectionManagerDelegate.removeAllNearbyGliders()
            }
        }
        
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
            let buddyFlarmIDs = Buddy.allFlarmIDs()
            let joinedBuddyFlarmIDs = buddyFlarmIDs.joined(separator: "/")
            
            let packet = "user \(userName) pass -1 vers \(appVersion) filter b/\(joinedBuddyFlarmIDs) -p/\(UserDefaultsManager.ownFlarmID())/A/B/C/D/E/G/H/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y/Z\n"
            sendPaket(packet)
        } else {
            // Filter via Radius
            let packet = "user \(userName) pass -1 vers \(appVersion) filter r/\(currentLocation.coordinate.latitude)/\(currentLocation.coordinate.longitude)/\(UserDefaultsManager.trafficMonitorRadius()) -p/\(UserDefaultsManager.ownFlarmID())/A/B/C/D/E/G/H/J/K/L/M/N/O/P/Q/R/S/T/U/V/W/X/Y/Z\n"
            sendPaket(packet)
        }
        
        isLoggedIn = true
        loginCoordinates = LocationManager.currentLocation()
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
        
        // If receivedMessage contains more than one Message - split them in single Messages
        let splittedMessages = receivedMessage.split(separator: "\r\n")
        // print("Anzahl Teilnachrichten: \(splittedMessages.count)")
        
        // Check every single Message
        for splittedMessage in splittedMessages {
            // Check if Message has Prefix FLR or ICA - AND is NOT ownFlarmID
            guard splittedMessage.hasPrefix("FLR")
                || splittedMessage.hasPrefix("ICA")
                // Otherwise discard this message
                else {
                    // print("\(#function): Discard Message! No FLR or ICA Prefix - OR ownFlarmID:   \(splittedMessage)")
                    continue }
            
            // Create gliderTelemetryData from message
            let gliderSpecificMessage = String(splittedMessage)
            if var newGliderTelemetryData = GliderTelemetryData.telemetryDataFromOGNGliderResponse(gliderSpecificMessage) {
                
                // Check if verticalPosition has changed state
                if let oldGliderTelemetryData = gliderTelemetryDatas.first(where: {$0.flarmID == newGliderTelemetryData.flarmID}) {
                    
                    let didChange = oldGliderTelemetryData.verticalPosition != newGliderTelemetryData.verticalPosition
                    newGliderTelemetryData.aircraftImageNeedsUpdate = didChange
                    
                } else {
                    // FlarmID not found in Set
                }
                
                // Inform delegates
                for delegate in delegates.allObjects {
                    if let ognSocketConnectionManagerDelegate = delegate as? DL_OGNSocketConnectionManagerDelegate {
                        ognSocketConnectionManagerDelegate.updateNearbyGlider(gliderTelemetryData: newGliderTelemetryData)
                    }
                }
                
                // Book keeping
                gliderTelemetryDatas.insert(newGliderTelemetryData)
                
                // TODO: Is this the correct time to call this method?; 220420, ph
                checkForOutdatedNearbyAircraftTelemetryData()
            }
        }
        
    }
    
    // Check for outdated Nearby Aircraft Telemetry Data
    private func checkForOutdatedNearbyAircraftTelemetryData() {
        // Check for Views to remove
        
        let currentTimeStamp = Date.currentUnixTimeStamp
        
        for gliderTelemetryData in gliderTelemetryDatas {
            let timestamp = gliderTelemetryData.timestamp
            
            if timestamp + Presets.OGNSocketConnection.telemetryDataExpirationTimespan < currentTimeStamp {
                
                // Inform Delegate about removing
                for delegate in delegates.allObjects {
                    if let ognSocketConnectionManagerDelegate = delegate as? DL_OGNSocketConnectionManagerDelegate {
                        ognSocketConnectionManagerDelegate.removeNearbyGlider(gliderTelemetryData: gliderTelemetryData)
                    }
                }
                
                // Remove outdated gliderTelemetryData from book keeping
                gliderTelemetryDatas.remove(gliderTelemetryData)
            }
        }
    }
    
}
// MARK: - Extension - LocationManagerDelegate
extension OGNSocketConnectionManager: LocationManagerDelegate {
    
    func locationManager(didUpdateLocations locations: [CLLocation]) {
        
        if isLoggedIn == true {
            guard let loginCoordinates = self.loginCoordinates,
                UserDefaultsManager.showOnlyBuddySwitchState() == false,
                let distance = LocationManager.distanceFromCurrentLocationTo(location: loginCoordinates)
                else { return }
            
            if distance > Presets.OGNSocketConnection.distanceLimitForReconnect {
                OGNSocketConnectionManager.reconnect()
                
            }
        }
    }
}
