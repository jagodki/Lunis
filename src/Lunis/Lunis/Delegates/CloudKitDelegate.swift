//
//  CloudKitDelegate.swift
//  Lunis
//
//  Created by Christoph on 24.04.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

protocol CloudKitDelegate: AnyObject {
    
    func errorUpdating(_ error: NSError)
    
    func modelUpdated()
    
    func updateTableData(with data: [CloudKitAdministrationSection])
    
}
