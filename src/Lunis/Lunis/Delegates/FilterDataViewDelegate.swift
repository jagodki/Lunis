//
//  FilterDataViewDelegate.swift
//  Lunis
//
//  Created by Christoph on 16.11.18.
//  Copyright © 2018 jagodki. All rights reserved.
//

import Foundation

protocol FilterDataViewDelegate: AnyObject {
    
    /// A function to delegate filter settings for the data view.
    ///
    /// - Parameters:
    ///   - country: the name of the country as String
    ///   - district: the name of the district as String
    ///   - city: the name of the city as String
    ///   - schoolType: the school type as String
    func sendFilterSettings(country: String, district: String, city: String, schoolType: String)
    
    /// A function to get the current filter settings via delegation.
    ///
    /// - Returns: a dictionary with keys and values as String
    func getCurrentFilterSettings() -> [String: String]!
}
