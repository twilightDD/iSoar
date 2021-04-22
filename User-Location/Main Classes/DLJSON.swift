//
//  DLJSON.swift
//  Glider Tool
//
//  Created by sonic on 30.11.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

import Foundation

class DLJSON {

    class func decode(_ data: Data?)
    -> [String: Any]? {
        guard let data = data
        else { return nil }

        do {
            // Convert Data to Dictionary
            let result = try JSONSerialization.jsonObject(with: data,
                                                          options: .allowFragments) as? [String: Any]
            return result
        } catch {
            print("Could not deserialize JSON")
        }

        return nil
    }

}
