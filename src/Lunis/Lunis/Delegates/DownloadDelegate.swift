//
//  DownloadDetailDelegate.swift
//  Lunis
//
//  Created by Christoph on 17.05.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

protocol DownloadDelegate: AnyObject {
    
    /// A function for downloading data.
    ///
    /// - Parameters:
    ///   - schoolURL: the URL of a school file
    ///   - gridURL: the URL of a grid file
    func downloadData(schoolURL: URL, gridURL: URL)
    
}
