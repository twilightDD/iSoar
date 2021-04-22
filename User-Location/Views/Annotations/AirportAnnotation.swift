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

    private(set) var airport: Airport

    required init(airport: Airport) {
        self.airport = airport

        super.init()

        title = airport.icao
        subtitle = airport.name
        coordinate = airport.locationCoordinate2D
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
