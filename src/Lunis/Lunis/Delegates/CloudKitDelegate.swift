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
    
    /// A function for updating a table model.
    func modelUpdated()
    
    /// A function for updating a table
    ///
    /// - Parameter data: the data, that should be displazed in the table
    func updateTableData(with data: [CloudKitAdministrationSection])
    
}
