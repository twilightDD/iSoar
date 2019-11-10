//
//  OGNLocations.swift
//  Glider Tool
//
//  Created by sonic on 06.11.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

// http://wiki.glidernet.org/wiki:subscribe-to-ogn-data

// http://www.aprs-is.net/Connecting.aspx

// The APRS servers are available via TCP at aprs.glidernet.org , port 14580 for server-side filters.

// A sample receive only log in sent to a server TCP port 14580 might be:
// user AE5PL-TS pass -1 vers testsoftware 1.0_05 filter r/33.25/-96.5/50

let api = "aprs.glidernet.org"
let port = "14580"
let url = URL(string: api + ":" + port)



// Generate random Username String
//func randomString(length: Int) -> String {
//  let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
//  return String((0..<length).map{ _ in letters.randomElement()! })
//}

let user = "Q56T2LPV"
let pass = "-1"
let softwarename = "iSoar"
let softwareversion = "1"
let filter = "r/47/9/100"

let connectString = "user \(user) pass \(pass) vers \(softwarename) \(softwareversion) filter \(filter)"
