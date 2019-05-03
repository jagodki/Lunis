//
//  Decoder.swift
//  Lunis
//
//  Created by Christoph on 03.05.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit

class Decoder: NSObject {
    
    var coreDataController: DataController!
    var cloudKitController: CloudKitController!
    
    override init() {
        
    }
    
    init(coreDataController: DataController, cloudKitController: CloudKitController) {
        self.coreDataController = coreDataController
        self.cloudKitController = cloudKitController
    }
    
    func downloadDataset(administration: CloudKitAdministrationRow) {
        let jsonData = String(contentsOf: fileURL, encoding: .utf8)
        let decoder = JSONDecoder()
        do {
            let schools = decoder.decode(SchoolFile.self, from: jsonData)
        } catch {
            
        }
    }
    
    private func parseGridFile() {
        
    }
    
}
