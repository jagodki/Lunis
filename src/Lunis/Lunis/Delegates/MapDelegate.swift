//
//  MapDelegate.swift
//  Lunis
//
//  Created by Christoph on 12.06.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

protocol MapDelegate: AnyObject {
    
    /// A function for loading new objects into a map.
    func loadMapObjects()
    
}
