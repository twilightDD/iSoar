//
//  ISoarFileManager.swift
//  Glider Tool
//
//  Created by Peter Hauke on 11.12.19.
//  Copyright © 2019 Denis Leupold. All rights reserved.
//

import Foundation

//MARK: - ISoarFileManager
class ISoarFileManager {

    //MARK: Private Lets and Vars
    private static let documentPath: String = {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentPath = dirPaths[0]

        return documentPath
    }()

}


//MARK: - Extension - Check Directory Class Methods
extension ISoarFileManager {
    class func checkForTasksFolder() {
        if !FileManager.default.fileExists(atPath: gpxPath()) {
            print("Tasks Folder dont exist in Documents Folder. Creating...")
            do {
                try FileManager.default.createDirectory(atPath: gpxPath(),
                                                        withIntermediateDirectories: true,
                                                        attributes: nil)
            } catch {
                print(error.localizedDescription);
            }
        }
        else {
            print("Tasks Folder exist in Documents Folder.")
        }
    }
}


//MARK: - Extension - GPX File Handling
extension ISoarFileManager {

    //MARK:  Public Class Methods
    class func gpxFileNames()
        -> [String] {
            var gpxFileNames = [String]()

            // get files from disc
            var files = [String]()
            do {
                files = try FileManager.default.contentsOfDirectory(atPath: gpxPath())
            }
            catch let contentsOfDirectory {
                fatalError("\(contentsOfDirectory.localizedDescription)")
            }


            // parse fileNames
            for file in files {
                gpxFileNames.append(file)
            }

            return gpxFileNames
    }

    
    //MARK: Private Class Methods
    fileprivate class func gpxPath()
        -> String {
            let gpxPath = documentPath.appending("/Tasks")

            return gpxPath
    }


}
