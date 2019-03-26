//
//  Grid+CoreDataClass.swift
//  Lunis
//
//  Created by Christoph on 12.03.19.
//  Copyright © 2019 jagodki. All rights reserved.
//
//

import Foundation
import CoreData
import MapKit

@objc(Grid)
public class Grid: NSManagedObject {
    
    public func maximumCellValue(for schoolName: String) -> Double {
        return ((self.cells?.array as! [Cell]).map({$0.cellValue(for: schoolName)})).max()!
    }
    
    public func minimumCellValue(for schoolName: String) -> Double {
        return ((self.cells?.array as! [Cell]).map({$0.cellValue(for: schoolName)})).min()!
    }
    
    /// This function returns the value for a specific school at a given position.
    ///
    /// - Parameters:
    ///   - position: a position with lat/lon-coordinates
    ///   - school: the name of the school
    /// - Returns: the value for the school at the position, returns -99.9 if the position is not interacting with the grid
    public func cellValue(at position: CLLocationCoordinate2D, for school: String) -> Double {
        //iterate over all cells
        for cell in self.cells?.array as! [Cell] {
            
            let intersectionCode = cell.interacts(with: position)
            
            if intersectionCode > -1 {
                return cell.cellValue(for: school)
            }
            
        }
        
        return -99.9
    }
    
    
}
