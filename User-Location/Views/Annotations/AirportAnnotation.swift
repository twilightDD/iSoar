//
//  AirportAnnotation.swift
//  Glider Tool
//
//  Created by sonic on 26.05.20.
//  Copyright © 2020 Denis Leupold. All rights reserved.
//

// https://docs.mapbox.com/ios/maps/examples/annotation-views/

import Mapbox

class AirportAnnotation: MGLPointAnnotation {
    
    var airport: AirportDatabase.Airport?

}
