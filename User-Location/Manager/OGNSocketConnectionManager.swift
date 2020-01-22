//
//  OGNSocketConnectionManager.swift
//  Glider Tool
//
//  Created by sonic on 06.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Network

class OGNSocketConnectionManager {
    
    // MARK: - Lets and Vars
    static let shared = OGNSocketConnectionManager()
    
    private var connection: NWConnection?
    private var queue = DispatchQueue(label: "NetworkQueue", qos: .utility)
    private lazy var userName = generateRandomUserName()
    
    var receivedServerIdentification: Bool = false
    var isLoggedIn = false
    
    var latitude = MapScreen.shared?.currentLocation?.coordinate.latitude
    var longitude = MapScreen.shared?.currentLocation?.coordinate.longitude
    
    // MARK: - Init&Co.
    // Generate Random Username
    private func generateRandomUserName()
        -> String {
            let length = 9
            let characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            let randomCharacters = (0..<length).map{_ in characters.randomElement()!}
            let username = String(randomCharacters)
            return username
    }
    
    // MARK: - Public Methods
    // Connect to Server Socket
    func connectToServerSocket()
    {
        connection = NWConnection(host: "aprs.glidernet.org",
                                  port: 14580,
                                  using: .tcp)
        
        connection?.stateUpdateHandler = { NewConnectionState in
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
            case .cancelled:
                //The connection has been cancelled
                print("Connection: cancelled")
            default:
                //The connection has disconnected or encountered an error
                print("waiting or failed")
            }
        }
        connection?.start(queue: .main)
        
    }
    
    // MARK: - Private Methods
    // Setup Receive Data
    private func setupReceive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 9000, completion: { (data, context, isComplete, error) in
            
            print("Message received")
            
            if let rcvData = data,
                let receivedData = String(data:rcvData, encoding: .utf8) {
                print("Message: \(receivedData)")
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
        // ToDo: guard let for currentLocation
        sendPaket("user \(userName) pass -1 vers iSoar 1.0_04 filter r/\(latitude!)/\(longitude!)/50\r\n")
        isLoggedIn = true
    }
    
    // Send Filter Request to Server
    private func sendPaket(_ packet:String)
    {
        let packetData = packet.data(using: .utf8)
        
        print("Sent PaketData: \(packetData!)")
        
        connection?.send(content: packetData, completion: .contentProcessed({ (error) in
            if let err = error {
                print("Sending error \(err)")
            } else {
                print("Filter Request successfully sent")
            }
        }))
        
    }
}

