//
//  Boundary+CoreDataClass.swift
//  Lunis
//
//  Created by Christoph on 11.03.19.
//  Copyright © 2019 jagodki. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Boundary)
public class Boundary: NSManagedObject {
    
    public var vertices: [CLLocationCoordinate2D] {
        var verticesArray: [CLLocationCoordinate2D] = []
        for point in self.points! {
            verticesArray.append(CLLocationCoordinate2D(latitude: (point as! Point).y, longitude: (point as! Point).x))
        }
        return verticesArray
    }
    
}
