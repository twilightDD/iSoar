//
//  OGNMessage.swift
//  Glider Tool
//
//  Created by sonic on 13.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation
import CoreLocation

struct OGNMessage: Hashable {
    
    var flarmID: String
    var timestamp: String
    var location: CLLocationCoordinate2D
    var heading: String
    var speed: String
    var altitude: String
    var climbRate: String
    
    static func == (lhs: OGNMessage, rhs: OGNMessage) -> Bool {
        return lhs.flarmID == rhs.flarmID
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(flarmID)
    }
    
}
