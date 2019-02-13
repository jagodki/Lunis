//
//  SchoolMarkerView.swift
//  Lunis
//
//  Created by Christoph on 13.02.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit
import MapKit

class SchoolMarkerView: MKMarkerAnnotationView {
    
    override var annotation: MKAnnotation? {
        willSet {
            
            guard let school = newValue as? SchoolMO else { return }
            canShowCallout = true
            calloutOffset = CGPoint(x: -5, y: 5)
            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
            markerTintColor = school.markerTintColor
            glyphText = String(school.name.first!)
        }
    }
    
}
