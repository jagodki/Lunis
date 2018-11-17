//
//  DataViewDelegate.swift
//  Lunis
//
//  Created by Christoph on 16.11.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import Foundation

protocol DataViewDelegate: AnyObject {
    func sendCurrentSettings(country: String, district: String, city: String, schholType: String)
}
