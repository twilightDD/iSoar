//
//  Date+UnixTime.swift
//  Glider Tool
//
//  Created by Peter Hauke on 04.04.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

extension Date {

    static var currentUnixTimeStamp: Int64 {
        let currentUnixTimeStamp = Int64(Date().timeIntervalSince1970)
        return currentUnixTimeStamp
    }

}
