//
//  OGNLocations.swift
//  Glider Tool
//
//  Created by sonic on 06.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Network

// MARK: - OGNLocations
class OGNLocations{
    
    // MARK: - Lets and Vars
    static let shared = OGNLocations()
    var connection: NWConnection?
    private var queue = DispatchQueue(label: "NetworkQuue", qos: .utility)
    
    // MARK: - Init&Co.
    private init(){
    }
    
    // MARK: - Public Methods
    // Connect to Server Socket
    func connectToServerSocket()
    {
        connection = NWConnection(host: "aprs.glidernet.org", port: 14580, using: .tcp)
        connection?.stateUpdateHandler =
            {
                (newState) in switch (newState)
                {
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
                    self.sendPaket("user XYZ1ADL27 pass -1 vers iSoar 1 filter r/47.80/8.97/1")
                    print("Sending Filter Request")
                    self.receiveMessage()
                case .failed:
                    //The connection in the process of being established
                    print("failed")
                case .cancelled:
                    //The connection has been cancelled
                    print("cancelled")
                default:
                    //The connection has disconnected or encountered an error
                    print("waiting or failed")
                }
        }
        connection?.start(queue: self.queue)
    }
    
    // MARK: - Private Methods
    // Send Filter Request to Server
    private func sendPaket(_ packet:String)
    {
        let packetData = packet.data(using: .utf8)
        self.connection?.send(content: packetData, completion: NWConnection.SendCompletion.contentProcessed(({ (error) in
            if let err = error {
                print("Sending error \(err)")
            } else {
                print("Filter Request successfully sent")
            }
        })))
        
    }
    
    // Receive Messages from Server
    private func receiveMessage()
    {
        self.connection?.receiveMessage(completion:
            {
                (data, context, isComplete, error) in
                print("Message received")
                if let messageError = error {
                    print("Recieve error: \(messageError)")
                }
                
                if let rcvData = data,
                    let receivedData = String(data:rcvData, encoding: .utf8) {
                    print("Received: \(receivedData)")
                }
                
                self.receiveMessage()
                
        })
    }
}
