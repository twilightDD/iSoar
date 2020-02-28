//
//  NearbyGlidersDatabase.swift
//  Glider Tool
//
//  Created by sonic on 27.02.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

// MARK: - NearbyGlidersDatabase
class NearbyGlidersDatabase {
    
    // MARK: - Lets and Vars
    
    var nearbyGliderDatas = [NearbyGliderData]()
    
}

// MARK: - Methods


//message received in OGNSocketConnectionManager
//parse
//if exist FID12345 in DBArray
//    remove FID12345 anno from map
//    remove FID12345 in DBArray - (or maybe only update entry)
//    add FID12345 anno to map
//else .append FID12345 to DBArray
//add FID12345 anno to map

//func doSomething() {
//   nearbyGliderDatas.append(nearbyGliders)
//}



// MARK: - Extension - Struct

struct NearbyGliderData: Codable {
    var flarmID: String
    var timestamp: String
    var latitude: Double
    var longitude: Double
    var altitude: String
    var climbRate: String
    
}
