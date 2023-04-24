//
//  Annotation.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/10/23.
//

import Foundation
import MapKit

class Annotation: NSObject, MKAnnotation {
    let title: String?
    let subtitle: String?
    let coordinate: CLLocationCoordinate2D
    let coordinateType: CoordinateType
    
    init(coordinateType: CoordinateType, coordinate: CLLocationCoordinate2D) {
        self.coordinateType = coordinateType
        self.title = coordinateType == .start ? "Starting Point" : "Ending Point"
        self.subtitle = coordinateType == .start ? "This is where you started" : "This is where you ended"
        self.coordinate = coordinate
    }
}

enum CoordinateType {
    case start
    case end
}
