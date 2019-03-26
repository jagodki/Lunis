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
    
    /// This functions is looking for an intersection between the cell and a given position.
    ///
    /// - Parameter position: a position with lat/lon-coordinates
    /// - Returns: 1 ... position is within the cell, 0 ... position touches the cell, -1 ... no intersection
    public func interacts(with position: CLLocationCoordinate2D) -> Int {
        //init the counter of intersections and the result value
        var intersections: Int = 0
        
        //iterate over all vertices of the cell
        for index in 0...((self.boundary?.points?.count)! - 1) {
            
            //extract the current points
            let pointA = self.boundary?.points?.object(at: index) as! Point
            let pointB: Point
            
            if (index + 1) >= (self.boundary?.points?.count)! {
                pointB = self.boundary?.points?.object(at: 0) as! Point
            } else {
                pointB = self.boundary?.points?.object(at: index + 1) as! Point
            }
            
            //check, whether the position has the same coordinates like one of the two points, i.e. the position is touching the cell
            if (pointA.x == position.longitude && pointA.y == position.latitude) || (pointB.x == position.longitude && pointB.y == position.latitude) {
                return 0
            }
            
            //check the slope of the line from pointA to pointB
            if pointA.y != pointB.y {
                
                //slope unequal zero means (= y-values are different), that the line will intersect with a horizontal line
                //check whether we have a vertical line
                if pointA.x == pointB.x {
                    
                    //lines are crossing, if latitude is between the y-values of the two points (vertical line)
                    if (pointA.y <= position.latitude && position.latitude < pointB.y) || (pointA.y > position.latitude && position.latitude >= pointB.y) {
                        intersections += 1
                    }
                    
                } else {
                    
                    //create the linear equation based on the two points
                    let m = (pointB.x - pointA.x) != 0.0 ? (pointB.y - pointA.y) / (pointB.x - pointA.x) : 0.0
                    let n = pointA.y - (m * pointA.x)
                    
                    //get the intersection point
                    let intersectionPointX = (position.latitude - n) / m
                    
                    //compare the coordinates of the intersection point with the two points
                    let betweenXValues = (pointA.x <= intersectionPointX && intersectionPointX < pointB.x) || (pointA.x > intersectionPointX && intersectionPointX >= pointB.x)
                    let betweenYValues = (pointA.y <= position.latitude && position.latitude < pointB.y) || (pointA.y > position.latitude && position.latitude >= pointB.y)
                    
                    if betweenXValues && betweenYValues {
                        intersections += 1
                    }
                    
                }
                
            } else if pointA.y == position.latitude {
                
                //now we have two horizontal lines on the same place
                if (pointA.x <= position.longitude && position.longitude <= pointB.x) || (pointA.x >= position.longitude && position.longitude >= pointB.x) {
                    return 0
                }
                
            }
            
        }
        
        //now investigate the number of intersections
        if intersections % 2 == 0 {
            //even number of intersections, i.e. position is not within the cell
            return -1
        } else {
            //odd number of intersections, i.e. position is  within the cell
            return 1
        }
        
    }
}
