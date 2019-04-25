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
    var recordID: CKRecord.ID
}

class CloudKitController: NSObject {
    
    //CloudKit vars
    var container: CKContainer
    var publicDB: CKDatabase
    
    //instance vars
    var delegate: CloudKitDelegate?
    var cloudKitAdministrations: [CloudKitAdministrationSection] = []
    var query: CKQuery?
    
    override init() {
        
        //init CloudKit connection
        self.container = CKContainer.default()
        self.publicDB = self.container.publicCloudDatabase
        
    }
    
    /// This functions queries all administrations from the public database of the default container.
    ///
    /// - Parameters:
    ///   - query: the argument that should be used to filter the records of the database
    ///   - sortBy: the name of the column for sorting the records
    ///   - ascending: true if records should be sortered ascending, otherwise desending
    @objc func queryAdministrations(filterArgument: String, sortBy: String, ascending: Bool) {
        //clear the result array
        self.cloudKitAdministrations.removeAll()
        
        //create the query object
        let predicate = NSPredicate(format: filterArgument)
        self.query = CKQuery(recordType: "administration", predicate: predicate)
        self.query!.sortDescriptors?.append(NSSortDescriptor(key: sortBy, ascending: ascending))
        
        self.fetchAdministrations()
    }
    
    /// This function queries all administrations from CloudKit.
    ///
    /// - Parameters:
    ///   - sortBy: the name of the column for sorting the records
    ///   - ascending: true if records should be sortered ascending, otherwise desending
    func queryAllAdministrations(sortBy: String, ascending: Bool) {
        let predicate = NSPredicate(value: true)
        self.query = CKQuery(recordType: "administration", predicate: predicate)
        self.query!.sortDescriptors?.append(NSSortDescriptor(key: sortBy, ascending: ascending))
        
        self.fetchAdministrations()
    }
    
    @objc func fetchAdministrations() {
        self.publicDB.perform(self.query!, inZoneWith: nil) { results, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.errorUpdating(error as NSError)
                    print("Cloud Query Error - Fetch Establishments: \(error)")
                }
                return
            }
            
            for record in results! {
                //create a new section if necessary
                if self.cloudKitAdministrations.count == 0 || self.cloudKitAdministrations[self.cloudKitAdministrations.count - 1].country != record["country"] {
                    let newSection = CloudKitAdministrationSection(country: record["country"]!, rows: [])
                    self.cloudKitAdministrations.append(newSection)
                }
                
                //add a new row
                self.cloudKitAdministrations[self.cloudKitAdministrations.count - 1].rows.append(CloudKitAdministrationRow(city: record["city"]!, region: record["region"]!, centroid: (record["centroid"]! as! CLLocation).coordinate, countOfSchools: record["countOfSchools"]! as! Int, source: record["source"]!, lastUpdate: record.modificationDate!, geojson: record["geojson"]! as! CKAsset, recordID: record.recordID))
            }
            
            DispatchQueue.main.async {
                for index in 0...(self.cloudKitAdministrations.count - 1) {
                    self.cloudKitAdministrations[index].rows = self.cloudKitAdministrations[index].rows.sorted {$0.city < $1.city}
                }
                self.delegate?.updateTableData(with: self.cloudKitAdministrations)
                self.delegate?.modelUpdated()
            }
            
        }
    }
}
