//
//  Administration+CoreDataClass.swift
//  Lunis
//
//  Created by Christoph on 18.01.19.
//  Copyright © 2019 jagodki. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Administration)
public class Administration: NSManagedObject {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.y, longitude: self.x)
    }
    
    public var polygon: MKPolygon {
        let vertices = self.boundary?.vertices
        let polygon = MKPolygon(coordinates: vertices!, count: vertices!.count)
        polygon.title = "Administration"
        return polygon
    }
    

}
