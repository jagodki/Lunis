//
//  School+CoreDataClass.swift
//  Lunis
//
//  Created by Christoph on 18.01.19.
//  Copyright © 2019 jagodki. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(School)
public class SchoolMO: NSManagedObject, MKAnnotation {
    
    public var title: String? {
        return self.name
    }
    
    public var subtitle: String? {
        return self.schoolType
    }
    
    public var discipline: String? {
        return self.schoolType
    }
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.y, longitude: self.x)
    }
    
    public var markerTintColour: UIColor  {
        switch discipline {
        case "Grundschule":
            return .blue
        case "Gymnasium":
            return .purple
        default:
            return .red
        }
    }
    
}
