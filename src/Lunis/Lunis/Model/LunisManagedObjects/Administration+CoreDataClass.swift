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
public class Administration: NSManagedObject, MKOverlay {
    
    public var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.y, longitude: self.x)
    }
    
    public var boundingMapRect: MKMapRect {
        let vertices = (self.boundary?.vertices)!
        let longitudes = vertices.map({$0.longitude})
        let latitudes = vertices.map({$0.latitude})
                
        return MKMapRect(
            x: longitudes.min()!,
            y: latitudes.min()!,
            width: fabs(longitudes.max()! - longitudes.min()!),
            height: fabs(latitudes.max()! - latitudes.min()!))
    }
    
    public var polygon: MKPolygon {
        let vertices = self.boundary?.vertices
        return MKPolygon(coordinates: vertices!, count: vertices!.count)
    }
    

}
