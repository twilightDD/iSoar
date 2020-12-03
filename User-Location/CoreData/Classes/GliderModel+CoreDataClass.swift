//
//  GliderModel+CoreDataClass.swift
//  Glider Tool
//
//  Created by sonic on 10.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//
//

import CoreData

@objc(GliderModel)
public class GliderModel: NSManagedObject {
    class func importOrUpdate(_ gliderModelDictionaries: [[String: Any]]) {
        
        // TODO: 20201202 muss auf background context laufen
        let context = CoreDataManager.editContextInBackground()
        
        for gliderModelDictionary in gliderModelDictionaries {
            // Check for existing  gliderModelDictionary or create a new one
            guard let uuidString = gliderModelDictionary[GliderModel.Attributes.uuid] as? String,
                  let uuid = UUID.init(uuidString: uuidString)
            else { fatalError() }
            let gliderModelsWithUUID = context.fetchObjects(forEntityClass: GliderModel.self,
                                                            sortByKeypath: nil,
                                                            predicateString: "%K == %@",
                                                            predicateArguments: [GliderModel.Attributes.uuid, uuid])
            
            var gliderModelWithUUID: GliderModel!
            
            if gliderModelsWithUUID.isEmpty == true {
                gliderModelWithUUID = GliderModel.init(context: context)
                gliderModelWithUUID.uuid = uuid
            } else if gliderModelsWithUUID.count == 1 {
                if let uniqueGliderModel = gliderModelsWithUUID.first {
                    gliderModelWithUUID = uniqueGliderModel
                }
            } else {
                print("\(#function) - UUID already exists")
                DLLogger.writeStringToLogFile("\(#function) - UUID already exists")
                break
            }
            
            // Update Values
            gliderModelWithUUID.handicap = gliderModelDictionary[GliderModel.Attributes.handicap] as? Double ?? 0
            gliderModelWithUUID.manufacturer = gliderModelDictionary[GliderModel.Attributes.manufacturer] as? String ?? "<kein Wert>"
            gliderModelWithUUID.modelName = gliderModelDictionary[GliderModel.Attributes.modelName] as? String ?? "<kein Wert>"
            gliderModelWithUUID.seats = gliderModelDictionary[GliderModel.Attributes.seats] as? Double ?? 0
            gliderModelWithUUID.sink1 = gliderModelDictionary[GliderModel.Attributes.sink1] as? Double ?? 0
            gliderModelWithUUID.sink2 = gliderModelDictionary[GliderModel.Attributes.sink2] as? Double ?? 0
            gliderModelWithUUID.sink3 = gliderModelDictionary[GliderModel.Attributes.sink3] as? Double ?? 0
            gliderModelWithUUID.span = gliderModelDictionary[GliderModel.Attributes.span] as? Double ?? 0
            gliderModelWithUUID.speed1 = gliderModelDictionary[GliderModel.Attributes.speed1] as? Double ?? 0
            gliderModelWithUUID.speed2 = gliderModelDictionary[GliderModel.Attributes.speed2] as? Double ?? 0
            gliderModelWithUUID.speed3 = gliderModelDictionary[GliderModel.Attributes.speed3] as? Double ?? 0
            gliderModelWithUUID.wingarea = gliderModelDictionary[GliderModel.Attributes.wingarea] as? Double ?? 0
            
        }
        
        print("\(#function) - \(context.insertedObjects.count) GliderModels imported.")
        
        context.saveContext()
    }
}

extension GliderModel {
    struct Attributes {
        static let handicap = "handicap"
        static let manufacturer = "manufacturer"
        static let modelName = "modelName"
        static let seats = "seats"
        static let sink1 = "sink1"
        static let sink2 = "sink2"
        static let sink3 = "sink3"
        static let span = "span"
        static let speed1 = "speed1"
        static let speed2 = "speed2"
        static let speed3 = "speed3"
        static let uuid = "uuid"
        static let wingarea = "wingarea"
    }
    
    struct Relationships {
        static let gliders = "gliders"
    }
}
