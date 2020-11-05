//
//  DLLogger.swift
//  Glider Tool
//
//  Created by sonic on 05.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

class DLLogger {
    
    static var logFile: URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: Date())
        let fileName = "\(dateString).log"
        return documentsDirectory.appendingPathComponent(fileName)
    }
    
    class func writeStringToLogFile(_ message: String) {
        guard let logFile = logFile else {
            return
        }
        
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        timeFormatter.timeZone = NSTimeZone(abbreviation: "UTC") as TimeZone?
        
        let timestamp = timeFormatter.string(from: Date())
        guard let data = (timestamp + ": " + message + "\n").data(using: String.Encoding.utf8) else { return }
        
        if FileManager.default.fileExists(atPath: logFile.path) {
            if let fileHandle = try? FileHandle(forWritingTo: logFile) {
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()
            }
        } else {
            try? data.write(to: logFile, options: .atomicWrite)
        }
    }
}
