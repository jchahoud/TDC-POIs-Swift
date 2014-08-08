//
//  TDCAnnotation.swift
//  TDC-POIs
//
//  Created by Juliana Chahoud on 8/4/14.
//  Copyright (c) 2014 jchahoud. All rights reserved.
//

import Foundation
import MapKit


class TDCAnnotation: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
}
