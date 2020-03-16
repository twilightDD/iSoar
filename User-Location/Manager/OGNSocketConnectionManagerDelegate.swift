//
//  OGNSocketConnectionManagerDelegate.swift
//  Glider Tool
//
//  Created by sonic on 13.03.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

protocol OGNSocketConnectionManagerDelegate: class {
    
    func messageReceived(message: GliderTelemetryData)
    
}
