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
public class School: NSManagedObject, MKAnnotation {
    
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
    
    public var index: Int = 0
    
    public var maxIndex: Int = 1
    
    public var markerTintColor: UIColor  {
        var hue = 350.0 / 360.0
        
        if self.maxIndex > 1 {
            let ratio = Double(self.index) / Double(self.maxIndex - 1)
            hue = (350.0 / 360.0) - (ratio * (140.0 / 360.0))
        }
        return UIColor(hue: CGFloat(hue), saturation: 1.0, brightness: 1.0, alpha: 1)
        
//        switch discipline {
//        case "Grundschule":
//            return .blue
//        case "Gymnasium":
//            return .purple
//        default:
//            return .red
//        }
    }
    
}
