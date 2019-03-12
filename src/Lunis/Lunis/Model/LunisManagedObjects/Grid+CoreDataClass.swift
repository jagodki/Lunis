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

@objc(Grid)
public class Grid: NSManagedObject {
    
    public func maximumCellValue(for schoolName: String) -> Double {
        return ((self.cells?.array as! [Cell]).map({$0.cellValue(for: schoolName)})).max()!
    }
    
    public func minimumCellValue(for schoolName: String) -> Double {
        return ((self.cells?.array as! [Cell]).map({$0.cellValue(for: schoolName)})).min()!
    }
    
    
}
