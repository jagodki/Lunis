//
//  DownloadDetailDelegate.swift
//  Lunis
//
//  Created by Christoph on 17.05.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

protocol DownloadDelegate: AnyObject {
    
    func downloadData(schoolURL: URL, gridURL: URL)
    
}
