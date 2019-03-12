//
//  Cell+CoreDataClass.swift
//  Lunis
//
//  Created by Christoph on 12.03.19.
//  Copyright © 2019 jagodki. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Cell)
public class Cell: NSManagedObject {
    
    public var polygon: MKPolygon {
        let vertices = self.boundary?.vertices
        let polygon = MKPolygon(coordinates: vertices!, count: vertices!.count)
        polygon.title = "Cell"
        return polygon
    }
    
    public func cellValue(for schoolName: String) -> Double {
        let filteredCellValues = (self.cellValues?.allObjects as! [CellValue]).filter({$0.schoolName == schoolName})
        if filteredCellValues.count != 0 {
            return filteredCellValues[0].value as! Double
        } else {
            return -99.9
        }
    }

}
