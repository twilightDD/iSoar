//
//  NSManagedObject+EntityName.swift
//  Glider Tool
//
//  Created by sonic on 27.07.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import CoreData

extension NSManagedObject {
    class func entityName() -> String {
        let entityName = String(describing: self)
        return entityName
    }
}
