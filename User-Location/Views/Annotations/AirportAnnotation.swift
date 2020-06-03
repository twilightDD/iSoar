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
    
    private(set) var airport: AirportDatabase.Airport
    
    required init(airport: AirportDatabase.Airport) {
        self.airport = airport
        
        super.init()
        
        title = airport.name
        subtitle = airport.icao
        coordinate = airport.locationCoordinate2D()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
