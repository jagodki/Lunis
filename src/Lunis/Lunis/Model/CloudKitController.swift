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
    var gridReference: CKRecord.Reference
    var schoolReference: CKRecord.Reference
}

class CloudKitController: NSObject {
    
    //CloudKit vars
    var container: CKContainer
    var publicDB: CKDatabase
    
    //instance vars
    var delegate: CloudKitDelegate?
    var cloudKitAdministrations: [CloudKitAdministrationSection] = []
    var schoolURL: URL!
    var gridURL: URL!
    
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
        let query = CKQuery(recordType: "administration", predicate: predicate)
        query.sortDescriptors?.append(NSSortDescriptor(key: sortBy, ascending: ascending))
        
        self.fetchAdministrations(with: query)
    }
    
    /// This function queries all administrations from CloudKit.
    ///
    /// - Parameters:
    ///   - sortBy: the name of the column for sorting the records
    ///   - ascending: true if records should be sortered ascending, otherwise desending
    func queryAllAdministrations(sortBy: String, ascending: Bool) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: "administration", predicate: predicate)
        query.sortDescriptors?.append(NSSortDescriptor(key: sortBy, ascending: ascending))
        
        self.fetchAdministrations(with: query)
    }
    
    /// This function fetches all administrations for a given query from the public database.
    ///
    /// - Parameter query: the query for searching records in the database
    @objc func fetchAdministrations(with query: CKQuery) {
        self.cloudKitAdministrations.removeAll()
        
        self.publicDB.perform(query, inZoneWith: nil) { results, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.errorUpdating(error as NSError)
                    print("Cloud not query administrations \nError - Fetch Establishments: \(error)")
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
                self.cloudKitAdministrations[self.cloudKitAdministrations.count - 1].rows.append(CloudKitAdministrationRow(city: record["city"]!, region: record["region"]!, centroid: (record["centroid"]! as! CLLocation).coordinate, countOfSchools: record["countOfSchools"]! as! Int, source: record["source"]!, lastUpdate: record.modificationDate!, geojson: record["geojson"]! as! CKAsset, recordID: record.recordID, gridReference: record["grid"]! as! CKRecord.Reference, schoolReference: record["schools"]! as! CKRecord.Reference))
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
    
    func fetchFileURLsFor(school: CKRecord.Reference, grid: CKRecord.Reference) {
        //prepare grid query
        let gridPredicate = NSPredicate(format: "recordName==%@", grid.recordID)
        let gridQuery = CKQuery(recordType: "grid", predicate: gridPredicate)
        
        //prepare school query
        let schoolPredicate = NSPredicate(format: "recordName==%@", school.recordID)
        let schoolQuery = CKQuery(recordType: "school", predicate: schoolPredicate)
        
        //query the school URL
        let schoolQueryOperation = CKQueryOperation(query: schoolQuery)
        schoolQueryOperation.recordFetchedBlock = {(record: CKRecord) in
            
        }
        schoolQueryOperation.queryCompletionBlock = {(cursor, err) in
            if err != nil {
                print("queryCompletionBlock error:", err ?? "")
                return
            }
            
            //query the grid URL
            let gridQueryOperation = CKQueryOperation(query: gridQuery)
            gridQueryOperation.recordFetchedBlock = {(record: CKRecord) in
                
            }
            gridQueryOperation.queryCompletionBlock = {(cursor, err) in
                if err != nil {
                    print("queryCompletionBlock error:", err ?? "")
                    return
                }
            }
            
        }
    }
    
    /// This function searches for the URL of a GeoJSON file of a grid refered by a CKRecord.Reference.
    ///
    /// - Parameter grid: the reference of the grid to search for
    func fetchGridFileURL(for grid: CKRecord.Reference) {
        //create the query object
        let predicate = NSPredicate(format: "recordName==%@", grid.recordID)
        let query = CKQuery(recordType: "grid", predicate: predicate)
        
        var fileURL = URL(fileURLWithPath: "")
        
        //fetch the data
        self.publicDB.perform(query, inZoneWith: nil) { results, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.errorUpdating(error as NSError)
                    print("Cloud not query grids \nError: \(error)")
                }
                return
            }
            
            for record in results! {
                fileURL = (record["geojson"]! as CKAsset).fileURL
                break
            }
            
            DispatchQueue.main.async {
                self.gridURL = fileURL
            }
        }
    }
    
    /// This function searches for the URL of a GeoJSON file of a school refered by a CKRecord.Reference.
    ///
    /// - Parameter school: the reference of the school to search for
    func fetchSchoolFileURL(for school: CKRecord.Reference) {
        //create the query object
        let predicate = NSPredicate(format: "recordName==%@", school.recordID)
        let query = CKQuery(recordType: "school", predicate: predicate)
        
        var fileURL = URL(fileURLWithPath: "")
        
        //fetch the data
        self.publicDB.perform(query, inZoneWith: nil) { results, error in
            
            if let error = error {
                DispatchQueue.main.async {
                    self.delegate?.errorUpdating(error as NSError)
                    print("Cloud not query schools \nError: \(error)")
                }
                return
            }
            
            for record in results! {
                fileURL = (record["geojson"]! as CKAsset).fileURL
                break
            }
            
            DispatchQueue.main.async {
                self.schoolURL = fileURL
            }
        }
    }
}
