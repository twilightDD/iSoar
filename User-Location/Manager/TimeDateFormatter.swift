//
//  TimeDateFormatter.swift
//  Glider Tool
//
//  Created by sonic on 24.01.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

// MARK: - TimeDateFormatter
class TimeDateFormatter {
    
    // MARK: Private Lets and Vars
    static let shared = TimeDateFormatter()
    
    // MARK: - Public Methods
    // Create Date without Seconds
    func formattedDateWithoutSeconds()
        -> Date {
            
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
            components.second = 0
            let date = calendar.date(from: components)! as Date
            
            return date
            
    }
    
    // Format the TimeInterval from Seconds to Hours and Minutes
    func formattedTimeIntervall()
        -> String {
            
            let timeDifference = FlightComputer.shared.flightEndTime.timeIntervalSince(FlightComputer.shared.flightStartTime)

            let formatter = DateComponentsFormatter()
            formatter.allowedUnits = [.hour, .minute]
            formatter.unitsStyle = .positional
            formatter.zeroFormattingBehavior = .pad

            let formattedTimeDifference = formatter.string(from: TimeInterval(timeDifference))!
            
            return formattedTimeDifference
            
    }
    
}
