//
//  NSManagedObjectContext+Save.swift
//  Glider Tool
//
//  Created by Peter Hauke on 17.07.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

import CoreData

extension NSManagedObjectContext {

    func saveContext() {
        do {
            try self.save() // das self. könnte eigentlich weg, verdeutlicht hier aber, WER speichert.
        } catch let saveError {
            print("\(saveError)")
            fatalError()
        }
    }

}
