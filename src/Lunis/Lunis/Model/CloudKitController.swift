//
//  CloudKitController.swift
//  Lunis
//
//  Created by Christoph on 23.04.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit
import CloudKit
import CoreLocation

struct CloudKitAdministrationSection {
    var country: String
    var rows: [CloudKitAdministrationRow]
}

struct CloudKitAdministrationRow {
    var city: String
    var region: String
    var centroid: CLLocationCoordinate2D
    var countOfSchools: Int
    var source: String
    var lastUpdate: Date
    var geojson: CKAsset
    var recordName: String
}

class CloudKitController: NSObject {
    
    //CloudKit vars
    var container: CKContainer
    var publicDB: CKDatabase
    
    override init() {
        
        //init CloudKit connection
        self.container = CKContainer.default()
        self.publicDB = self.container.publicCloudDatabase
        
    }
    
    /// This functions queries all administrations from the public database of the default container.
    ///
    /// - Parameters:
    ///   - query: the query to execute
    ///   - zone: the zoneID
    /// - Returns: an array of CloudKitAdministrationSection, that is ready to be used in the download views
    private func queryAdministrations(query: CKQuery, zone: CKRecordZone.ID?) -> [CloudKitAdministrationSection] {
        //init the result object
        var result: [CloudKitAdministrationSection] = []
        
        self.publicDB.perform(query, inZoneWith: zone) { results, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    print("Cloud Query Error - Fetch Establishments: \(error)")
                }
                return
            }
            
            results?.forEach({ (record: CKRecord) in
                
                //create a new section if necessary
                if result.count == 0 || result[result.count - 1].country != record["country"] {
                    let newSection = CloudKitAdministrationSection(country: record["country"]!, rows: [])
                    result.append(newSection)
                }
                
                //add a new row
                result[result.count - 1].rows.append(CloudKitAdministrationRow(city: record["city"]!, region: record["region"]!, centroid: record["centroid"]! as! CLLocationCoordinate2D, countOfSchools: record["countOfSchools"]! as! Int, source: record["source"]!, lastUpdate: record["modifiedAt"]! as! Date, geojson: record["geojson"]! as! CKAsset, recordName: record["recordName"]!))
            })
        }
        
        return result
    }
    
    /// This function queries all administrations from CloudKit.
    ///
    /// - Parameters:
    ///   - sortBy: the name of the column for sorting the records
    ///   - ascending: true if records should be sortered ascending, otherwise desending
    /// - Returns: an array of CloudKitAdministrationSection, that is ready to be used in the download views
    func queryAllAdministrations(sortBy: String, ascending: Bool) -> [CloudKitAdministrationSection] {
        let predicate = NSPredicate(format: "recordName = %@", "*")
        let query = CKQuery(recordType: "administration", predicate: predicate)
        query.sortDescriptors?.append(NSSortDescriptor(key: sortBy, ascending: ascending))
        
        return self.queryAdministrations(query: query, zone: nil)
    }
}
