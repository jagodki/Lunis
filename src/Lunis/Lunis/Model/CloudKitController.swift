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
    var ckDelegate: CloudKitDelegate?
    var downloadDelegate: DownloadDelegate?
    var cloudKitAdministrations: [CloudKitAdministrationSection] = []
    var updateAdministration: CloudKitAdministrationRow?
    var schoolURL: URL!
    var gridURL: URL!
    var mapDelegate: MapDelegate!
    
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
                    self.ckDelegate?.errorUpdating(error as NSError)
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
                self.ckDelegate?.updateTableData(with: self.cloudKitAdministrations)
                self.ckDelegate?.modelUpdated()
            }
            
        }
    }
    
    /// This function fetches the URLs for the given references.
    /// The function can also start a download routing, if the correponding parameters are properly filled.
    /// Never set informViaDelegation and update both on true (update will not be recognized in this case).
    ///
    /// - Parameters:
    ///   - school: the reference of the school dataset
    ///   - grid: the reference of the grid dataset
    ///   - informViaDelegation: starts the download of the data of true
    ///   - update: starts the update of the datasets if true
    ///   - localAdministrations: an array of all administrations on the device
    ///   - index: an index value for getting an object from the localAdministrations array
    func fetchFileURLsFor(school: CKRecord.Reference, grid: CKRecord.Reference, informViaDelegation: Bool = true, update: Bool = false, localAdministrations: [Administration] = [], atIndex index: Int = -99) {
        //prepare grid query
        let gridPredicate = NSPredicate(format: "recordID==%@", grid.recordID)
        let gridQuery = CKQuery(recordType: "grid", predicate: gridPredicate)
        
        //prepare school query
        let schoolPredicate = NSPredicate(format: "recordID==%@", school.recordID)
        let schoolQuery = CKQuery(recordType: "school", predicate: schoolPredicate)
        
        //query the school URL
        let schoolQueryOperation = CKQueryOperation(query: schoolQuery)
        schoolQueryOperation.recordFetchedBlock = {(record: CKRecord) in
            self.schoolURL = (record["geojson"]! as CKAsset).fileURL
        }
        schoolQueryOperation.queryCompletionBlock = {(cursor, err) in
            if err != nil {
                print("queryCompletionBlock for schools error:", err ?? "")
                
                let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the schools; please try again: \(err!.localizedDescription)", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                
                guard let currentViewController = UIApplication.shared.keyWindow?.rootViewController else {
                    print("No root controller")
                    return
                }
                currentViewController.present(ac, animated: true)
                return
            }
            
            //query the grid URL
            let gridQueryOperation = CKQueryOperation(query: gridQuery)
            gridQueryOperation.recordFetchedBlock = {(record: CKRecord) in
                self.gridURL = (record["geojson"]! as CKAsset).fileURL
            }
            gridQueryOperation.queryCompletionBlock = {(cursor, err) in
                DispatchQueue.main.async {
                    if err != nil {
                        print("queryCompletionBlock for the grid error:", err ?? "")
                        
                        let ac = UIAlertController(title: "Fetch failed", message: "There was a problem fetching the grid; please try again: \(err!.localizedDescription)", preferredStyle: .alert)
                        ac.addAction(UIAlertAction(title: "OK", style: .default))
                        
                        guard let currentViewController = UIApplication.shared.keyWindow?.rootViewController else {
                            print("No root controller")
                            return
                        }
                        currentViewController.present(ac, animated: true)
                        return
                    }
                    
                    //handling of the query result
                    
                    if informViaDelegation {
                        //call the delegate for downloading the data, e.g. from the DownloadDetailView
                        self.downloadDelegate!.downloadData(schoolURL: self.schoolURL, gridURL: self.gridURL)
                    } else if update && index != -99 && localAdministrations.count != 0 {
                        //update an exisitng dataset in CoreData
                        (UIApplication.shared.delegate as! AppDelegate).dataController.delete(by: localAdministrations[index].objectID)
                        (UIApplication.shared.delegate as! AppDelegate).dataController.downloadData(administration: self.updateAdministration!, schoolFileURL: self.schoolURL, gridFileURL: self.gridURL)
                        self.updateAdministration = nil
                        
                        //check, whether more data sets should be checked for updates
                        self.updateMoreData(index: index, localAdministrations: localAdministrations)
                    }
                    
                }
                
            }
            
            self.publicDB.add(gridQueryOperation)
        }
        
        self.publicDB.add(schoolQueryOperation)
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
                    self.ckDelegate?.errorUpdating(error as NSError)
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
                    self.ckDelegate?.errorUpdating(error as NSError)
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
    
    /// This function updates one administration and all related objects.
    ///
    /// - Parameters:
    ///   - localAdministrations: an array of all administrations on the device
    ///   - index: the index to get on administration from the array above
    func update(localAdministrations: [Administration], at index: Int = 0) {
        
        //init the admin query
        let adminPredicate = NSPredicate(format: "country==%@ AND region==%@ AND city==%@ AND centroid==%@ AND modificationDate>%@", argumentArray: [localAdministrations[index].country!, localAdministrations[index].region!, localAdministrations[index].city!, CLLocation(latitude: localAdministrations[index].y, longitude: localAdministrations[index].x), localAdministrations[index].lastUpdate! as CVarArg])
        let adminQuery = CKQuery(recordType: "administration", predicate: adminPredicate)
        let adminQueryOperation = CKQueryOperation(query: adminQuery)
        
        //query the administration
        adminQueryOperation.recordFetchedBlock = {(record: CKRecord) in
            self.updateAdministration = CloudKitAdministrationRow(city: record["city"]!, region: record["region"]!, centroid: (record["centroid"]! as! CLLocation).coordinate, countOfSchools: record["countOfSchools"]! as! Int, source: record["source"]!, lastUpdate: record.modificationDate!, geojson: record["geojson"]! as! CKAsset, recordID: record.recordID, gridReference: record["grid"]! as! CKRecord.Reference, schoolReference: record["schools"]! as! CKRecord.Reference)
        }
        adminQueryOperation.queryCompletionBlock = {(cursor, err) in
            if err != nil {
                print("queryCompletionBlock for administrations error:", err ?? "")
                return
            }
            
            //query the file URLs and update a data set
            if self.updateAdministration != nil {
                self.fetchFileURLsFor(school: self.updateAdministration!.schoolReference, grid: self.updateAdministration!.gridReference, informViaDelegation: false, update: true, localAdministrations: localAdministrations, atIndex: index)
            } else {
                self.updateMoreData(index: index, localAdministrations: localAdministrations)
            }
            
        }
        
        self.publicDB.add(adminQueryOperation)
        
    }
    
    ///This function checks, whether more datasets could be updated or not. If not, all map objects will be reloaded.
    ///
    /// - Parameters:
    ///   - index: the index to get on administration from the array (second parameter)
    ///   - localAdministrations: an array of all administrations on the device
    private func updateMoreData(index: Int, localAdministrations: [Administration]) {
        if index == (localAdministrations.count - 1) {
            self.mapDelegate.loadMapObjects()
        } else {
            self.update(localAdministrations: localAdministrations, at: (index + 1))
        }
    }
}
