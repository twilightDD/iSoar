//
//  OGNLocations.swift
//  Glider Tool
//
//  Created by sonic on 06.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import SocketIO

//MARK: - SocketIO
class OGNLocations{
    
    //MARK: - Lets and Vars
    static let shared = OGNLocations()
    
    //MARK: - Init&Co.
    private init(){
    }
    
    //MARK: - Public Methods
    // Connect to Socket
    func socketConnect () {
        let manager = SocketManager(socketURL: URL(string: "aprs.glidernet.org:14580")!, config: [.log(true), .compress])
        
        let socket = manager.defaultSocket
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on("currentAmount") {data, ack in
            guard let cur = data[0] as? Double else { return }
            
            socket.emitWithAck("canUpdate", cur).timingOut(after: 0) {data in
                socket.emit("update", ["amount": cur + 2.50])
            }
            ack.with("Got your currentAmount", "dude")
        }
        socket.connect()
    }
    
}







// http://wiki.glidernet.org/wiki:subscribe-to-ogn-data

// http://www.aprs-is.net/Connecting.aspx

// The APRS servers are available via TCP at aprs.glidernet.org , port 14580 for server-side filters.

// A sample receive only log in sent to a server TCP port 14580 might be:
// user AE5PL-TS pass -1 vers testsoftware 1.0_05 filter r/33.25/-96.5/50



// Generate random Username String
//func randomString(length: Int) -> String {
//  let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//  return String((0..<length).map{ _ in letters.randomElement()! })
//}

//let user = "Q56T2LPV"
//let pass = "-1"
//let softwarename = "iSoar"
//let softwareversion = "1"
//let filter = "r/47/9/100"
//
//let connectString = "user \(user) pass \(pass) vers \(softwarename) \(softwareversion) filter \(filter)"
