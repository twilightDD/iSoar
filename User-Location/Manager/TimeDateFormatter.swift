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

    private lazy var timeIntervallToHourMinutesDateComponentsFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute]
        formatter.unitsStyle = .positional
        formatter.zeroFormattingBehavior = .pad

        return formatter
    }()

    // MARK: - Public Methods
    // Create Date without Seconds
    class func yearMonthDayHourMinuteDateFrom(_ date: Date)
        -> Date {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second],
                                                     from: date)
            components.second = 0
            let date = calendar.date(from: components)! as Date

            return date
    }

    // Year Month Day Hour Minute Date From Now
    class func yearMonthDayHourMinuteDateFromNow()
        -> Date {
            return yearMonthDayHourMinuteDateFrom(Date())
    }


    /**
     Creates a string with human readable time span.

     I.E. "2:51"

     - Parameter timeIntervall: the timeIntervall.

     - Returns: The time span as string or "-" if an error occured on conversion.
     */
    class func hourMinutesStringFromTimeIntervall(_ timeIntervall: TimeInterval)
        -> String {
            var hourMinutesStringFromTimeIntervall = "-"

            if let formattedTimeDifference = shared.timeIntervallToHourMinutesDateComponentsFormatter.string(from: timeIntervall) {
                hourMinutesStringFromTimeIntervall = formattedTimeDifference
            }

            return hourMinutesStringFromTimeIntervall
    }


    /**
     Creates a string with human readable time span.

     I.E. "2:51"

     - Parameter startTime: The start time.
     - Parameter endTime: The end time.

     - Returns: The time span as string or "-" if an error occured on conversion.
     */
    class func hourMinutesStringFrom(startTime: Date, toEndTime endTime: Date)
        -> String {
            let timeIntervall = endTime.timeIntervalSince(startTime)
            let hourMinutesStringFrom = hourMinutesStringFromTimeIntervall(timeIntervall)
            return hourMinutesStringFrom
    }
}
