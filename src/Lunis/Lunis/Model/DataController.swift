//
//  DataController.swift
//  Lunis
//
//  Created by Christoph on 17.01.19.
//  Copyright © 2019 jagodki. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {
    
    enum entityType {
        case administration
        case school
    }
    
    var filter: [String: String]! = ["Country":"All",
                                     "District":"All",
                                     "City":"All",
                                     "School Type":"All",
                                     "School Profile":"All",
                                     "Agency":"All"]
    
    let decoder: Decoder = Decoder()
    
    override init() {
        super.init()
        let persistentContainer = NSPersistentContainer(name: "lunis")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        //remove data
        self.removeAllData()
        
        //insert test data
        if self.fetchAdministations(request: "").count == 0 {
            self.initData()
        }
    }
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "lunis")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        return self.persistentContainer.viewContext
    }()
    
    /// This function stores the current managed objects into core data.
    func saveData() {
        if self.managedObjectContext.hasChanges {
            do {
                try self.managedObjectContext.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func removeAllData() {
        let schools = self.fetchSchools()
        for school in schools {
            self.delete(by: school.objectID)
        }
        
        let admins = self.fetchAdministations()
        for admin in admins {
            self.delete(by: admin.objectID)
        }
        
        let boundaries = (self.fetchData(from: "Boundary", orderedBy: ["administration"]) as! NSFetchedResultsController<Boundary>).fetchedObjects
        for boundary in boundaries! {
            self.delete(by: boundary.objectID)
        }
        
        let points = (self.fetchData(from: "Point", orderedBy: ["x"]) as! NSFetchedResultsController<Point>).fetchedObjects
        for point in points! {
            self.delete(by: point.objectID)
        }
        
        let cells = (self.fetchData(from: "Cell", orderedBy: ["boundary"]) as! NSFetchedResultsController<Cell>).fetchedObjects
        for cell in cells! {
            self.delete(by: cell.objectID)
        }
        
        let grids = (self.fetchData(from: "Grid", orderedBy: ["administration"]) as! NSFetchedResultsController<Grid>).fetchedObjects
        for grid in grids! {
            self.delete(by: grid.objectID)
        }
        
        let cellValues = (self.fetchData(from: "CellValue", orderedBy: ["schoolName"]) as! NSFetchedResultsController<CellValue>).fetchedObjects
        for cellValue in cellValues! {
            self.delete(by: cellValue.objectID)
        }
    }
    
    private func initData() {
        let administration1 = NSEntityDescription.insertNewObject(forEntityName: "Administration", into: managedObjectContext) as! Administration
        let administration2 = NSEntityDescription.insertNewObject(forEntityName: "Administration", into: managedObjectContext) as! Administration
        let school1 = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext) as! School
        let school2 = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext) as! School
        let boundaryAdmin1 = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
        let boundaryAdmin2 = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
        let grid = NSEntityDescription.insertNewObject(forEntityName: "Grid", into: managedObjectContext) as! Grid
        let cell1 = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: managedObjectContext) as! Cell
        let cell2 = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: managedObjectContext) as! Cell
        let cell3 = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: managedObjectContext) as! Cell
        let cell4 = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: managedObjectContext) as! Cell
        let cellValue11 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellValue12 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellValue21 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellValue22 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellValue31 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellValue32 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellValue41 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellValue42 = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
        let cellBoundary1 = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
        let cellBoundary2 = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
        let cellBoundary3 = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
        let cellBoundary4 = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
        let pointAdmin11 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointAdmin12 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointAdmin13 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointAdmin21 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointAdmin22 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointAdmin23 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid11 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid12 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid13 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid14 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid21 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid22 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid23 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid24 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid31 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid32 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid33 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid34 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid41 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid42 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid43 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        let pointGrid44 = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
        
        pointAdmin11.x = 13.6239115
        pointAdmin11.y = 51.1483503
        pointAdmin11.boundary = boundaryAdmin1
        pointAdmin12.x = 13.6747015
        pointAdmin12.y = 51.0966393
        pointAdmin12.boundary = boundaryAdmin1
        pointAdmin13.x = 13.5829519
        pointAdmin13.y = 51.0972272
        pointAdmin13.boundary = boundaryAdmin1
        
        pointAdmin21.x = 13.4757633
        pointAdmin21.y = 51.1879868
        pointAdmin21.boundary = boundaryAdmin2
        pointAdmin22.x = 13.5213184
        pointAdmin22.y = 51.1391547
        pointAdmin22.boundary = boundaryAdmin2
        pointAdmin23.x = 13.4340232
        pointAdmin23.y = 51.1390139
        pointAdmin23.boundary = boundaryAdmin2
        
        pointGrid11.x = 13.6611497
        pointGrid11.y = 51.1069835
        pointGrid11.boundary = cellBoundary1
        pointGrid12.x = 13.6609024
        pointGrid12.y = 51.0878690
        pointGrid12.boundary = cellBoundary1
        pointGrid13.x = 13.6304652
        pointGrid13.y = 51.0880243
        pointGrid13.boundary = cellBoundary1
        pointGrid14.x = 13.6307125
        pointGrid14.y = 51.1071388
        pointGrid14.boundary = cellBoundary1
        
        pointGrid21.x = 13.6311666
        pointGrid21.y = 51.1264104
        pointGrid21.boundary = cellBoundary2
        pointGrid22.x = 13.6307125
        pointGrid22.y = 51.1071388
        pointGrid22.boundary = cellBoundary2
        pointGrid23.x = 13.5999737
        pointGrid23.y = 51.1073931
        pointGrid23.boundary = cellBoundary2
        pointGrid24.x = 13.6004226
        pointGrid24.y = 51.1266921
        pointGrid24.boundary = cellBoundary2
        
        pointGrid31.x = 13.6611497
        pointGrid31.y = 51.1264104
        pointGrid31.boundary = cellBoundary3
        pointGrid32.x = 13.6611497
        pointGrid32.y = 51.1069835
        pointGrid32.boundary = cellBoundary3
        pointGrid33.x = 13.6307125
        pointGrid33.y = 51.1071388
        pointGrid33.boundary = cellBoundary3
        pointGrid34.x = 13.6311666
        pointGrid34.y = 51.1264104
        pointGrid34.boundary = cellBoundary3
        
        pointGrid41.x = 13.6307125
        pointGrid41.y = 51.1071388
        pointGrid41.boundary = cellBoundary4
        pointGrid42.x = 13.6304652
        pointGrid42.y = 51.0880243
        pointGrid42.boundary = cellBoundary4
        pointGrid43.x = 13.5999737
        pointGrid43.y = 51.0880243
        pointGrid43.boundary = cellBoundary4
        pointGrid44.x = 13.5999737
        pointGrid44.y = 51.1073931
        pointGrid44.boundary = cellBoundary4
        
        cellBoundary1.addToPoints(pointGrid11)
        cellBoundary1.addToPoints(pointGrid12)
        cellBoundary1.addToPoints(pointGrid13)
        cellBoundary1.addToPoints(pointGrid14)
        cellBoundary1.cell = cell1
        
        cellBoundary2.addToPoints(pointGrid21)
        cellBoundary2.addToPoints(pointGrid22)
        cellBoundary2.addToPoints(pointGrid23)
        cellBoundary2.addToPoints(pointGrid24)
        cellBoundary2.cell = cell2
        
        cellBoundary3.addToPoints(pointGrid31)
        cellBoundary3.addToPoints(pointGrid32)
        cellBoundary3.addToPoints(pointGrid33)
        cellBoundary3.addToPoints(pointGrid34)
        cellBoundary3.cell = cell3
        
        cellBoundary4.addToPoints(pointGrid41)
        cellBoundary4.addToPoints(pointGrid42)
        cellBoundary4.addToPoints(pointGrid43)
        cellBoundary4.addToPoints(pointGrid44)
        cellBoundary4.cell = cell4
        
        cellValue11.localSchoolID = Int64(1)
        cellValue11.value = 1
        cellValue11.cell = cell1
        
        cellValue21.localSchoolID = Int64(1)
        cellValue21.value = 5
        cellValue21.cell = cell2
        
        cellValue31.localSchoolID = Int64(1)
        cellValue31.value = 8
        cellValue31.cell = cell3
        
        cellValue41.localSchoolID = Int64(1)
        cellValue41.value = 9
        cellValue41.cell = cell4
        
        cellValue12.localSchoolID = Int64(2)
        cellValue12.value = 2
        cellValue12.cell = cell1
        
        cellValue22.localSchoolID = Int64(2)
        cellValue22.value = 3
        cellValue22.cell = cell2
        
        cellValue32.localSchoolID = Int64(2)
        cellValue32.value = 5
        cellValue32.cell = cell3
        
        cellValue42.localSchoolID = Int64(2)
        cellValue42.value = 10
        cellValue42.cell = cell4
        
        cell1.addToCellValues(cellValue11)
        cell1.addToCellValues(cellValue12)
        cell1.grid = grid
        
        cell2.addToCellValues(cellValue21)
        cell2.addToCellValues(cellValue22)
        cell2.grid = grid
        
        cell3.addToCellValues(cellValue31)
        cell3.addToCellValues(cellValue32)
        cell3.grid = grid
        
        cell4.addToCellValues(cellValue41)
        cell4.addToCellValues(cellValue42)
        cell4.grid = grid
        
        grid.addToCells(cell1)
        grid.addToCells(cell2)
        grid.addToCells(cell3)
        grid.addToCells(cell4)
        grid.administration = administration1
        grid.administration = administration2
        
        boundaryAdmin1.addToPoints(pointAdmin11)
        boundaryAdmin1.addToPoints(pointAdmin12)
        boundaryAdmin1.addToPoints(pointAdmin13)
        
        boundaryAdmin2.addToPoints(pointAdmin21)
        boundaryAdmin2.addToPoints(pointAdmin22)
        boundaryAdmin2.addToPoints(pointAdmin23)
        
        administration1.city = "Radebeul"
        administration1.region = "Sachsen"
        administration1.country = "Deutschland"
        administration1.lastUpdate = Date()
        administration1.x = 13.641750
        administration1.y = 51.110218
        administration1.boundary = boundaryAdmin1
        administration1.grid = grid
        
        administration2.city = "Meißen"
        administration2.region = "Sachsen"
        administration2.country = "Deutschland"
        administration2.lastUpdate = Date()
        administration2.x = 13.473048
        administration2.y = 51.166734
        administration2.boundary = boundaryAdmin2
        //administration2.grid = grid
        
        school1.schoolName = "Lößnitzgymnasium"
        school1.city = "Radebeul"
        school1.agency = "Stadt Radebeul"
        school1.localID = 1
        school1.mail = "info@test.xyz"
        school1.favorite = true
        school1.street = "Steinbachstraße"
        school1.number = "21"
        school1.phone = "0351/12345678"
        school1.postalCode = "01445"
        school1.schoolSpecialisation = "sprachlich, künstlerich"
        school1.schoolType = "Gymnasium"
        school1.website = "https://www.loessnitzgymnasium-radebeul.de"
        school1.wikipedia = "https://de.wikipedia.org/wiki/L%C3%B6%C3%9Fnitzgymnasium"
        school1.x = 13.659038
        school1.y = 51.104209
        school1.administration = administration1
        
        school2.schoolName = "Sächsisches Landesgymnasium Sankt Afra"
        school2.city = "Meißen"
        school2.agency = "Freistaat Sachsen"
        school2.localID = 2
        school2.mail = "info@test.xyz"
        school2.favorite = false
        school2.street = "Freiheit"
        school2.number = "13"
        school2.phone = "03521/87654321"
        school2.postalCode = "01662"
        school2.schoolSpecialisation = "sprachlich, künstlerich, naturwissenschaftlich"
        school2.schoolType = "Grundschule"
        school2.website = "http://www.sankt-afra.de/"
        school2.wikipedia = "https://de.wikipedia.org/wiki/S%C3%A4chsisches_Landesgymnasium_Sankt_Afra"
        school2.x = 13.467966
        school2.y = 51.163543
        school2.administration = administration1
        
        administration1.addToSchools(school1)
        administration1.addToSchools(school2)
        //administration2.addToSchools(school2)
        
        self.saveData()
    }
    
    /// This function fetches datasets from the administration entity.
    ///
    /// - Parameter request: a String representing the request for filtering, sorting etc. the fetch
    /// - Returns: an array of Administration-objects as the result of the fetch
    func fetchAdministations(request: String = "") -> [Administration] {
        //create the fetch request
        let administrationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Administration")
        var administrationData: [Administration] = [Administration]()
        
        //fetch the data
        do {
            administrationData = try self.managedObjectContext.fetch(administrationFetch) as! [Administration]
        } catch {
            fatalError("Failed to fetch administrations: \(error)")
        }
        return administrationData
    }
    
    /// This function fetches datasets from the school entity.
    ///
    /// - Parameter request: a String representing the request for filtering, sorting etc. the fetch
    /// - Returns: an array of School-objects as the result of the fetch
    func fetchSchools(request: String = "") -> [School] {
        //create the fetch request
        let schoolFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "School")
        var schoolData: [School] = [School]()
        
        //fetch the data
        do {
            schoolData = try self.managedObjectContext.fetch(schoolFetch) as! [School]
        } catch {
            fatalError("Failed to fetch schools: \(error)")
        }
        return schoolData
    }
    
    /// This function fetches datasets from the school entity.
    ///
    /// - Parameters:
    ///   - filter: a boolean value to indicate, whether the filter settings of this class will be used to create a request
    ///   - groupedBy: a group argument to create sections
    ///   - orderedBy: the names of the attributes, which should be used for order the results
    ///   - orderedAscending: a boolean value to indicate, whether the results should be ordered ascending or descening
    /// - Returns: a result controller with objects of type Administration into it
    func fetchSchools(filter: Bool, groupedBy: String = "", orderedBy: [String], orderedAscending: Bool = false) -> NSFetchedResultsController<School> {
        //create the filter request
        var request = ""
        if filter {
            request = self.createFilterRequest()
        }
        
        //fetch data
        let resultsController = self.fetchData(from: "School", request: request, groupedBy: groupedBy, orderedBy: orderedBy, orderedAscending: orderedAscending) as! NSFetchedResultsController<School>
        return resultsController
    }
    
    /// This function creates a request string from the filter settings of this class.
    ///
    /// - Returns: a string, which can be used as a core data request
    private func createFilterRequest() -> String {
        var request = ""
        
        if self.filter["Country"] != "All" {
            if request == "" {
                request.append("ANY administration.country CONTAINS \"" + self.filter["Country"]! + "\"")
            } else {
                request.append("AND ANY administration.country CONTAINS \"" + self.filter["Country"]! + "\"")
            }
        }
        if self.filter["District"] != "All" {
            if request == "" {
                request.append("ANY administration.region CONTAINS \"" + self.filter["District"]! + "\"")
            } else {
                request.append("AND ANY administration.region CONTAINS \"" + self.filter["District"]! + "\"")
            }
        }
        if self.filter["City"] != "All" {
            if request == "" {
                request.append("city CONTAINS \"" + self.filter["City"]! + "\"")
            } else {
                request.append("AND city CONTAINS \"" + self.filter["City"]! + "\"")
            }
        }
        if self.filter["School Type"] != "All" {
            if request == "" {
                request.append("schoolType CONTAINS \"" + self.filter["School Type"]! + "\"")
            } else {
                request.append("AND schoolType CONTAINS \"" + self.filter["School Type"]! + "\"")
            }
        }
        if self.filter["Agency"] != "All" {
            if request == "" {
                request.append("agency CONTAINS \"" + self.filter["Agency"]! + "\"")
            } else {
                request.append("AND agency CONTAINS \"" + self.filter["Agency"]! + "\"")
            }
        }
        
        return request
    }
    
    /// This function fetches datasets from the administration entity.
    ///
    /// - Parameters:
    ///   - request: a filter argument to reduce the result
    ///   - groupedBy: a group argument to create sections
    ///   - orderedBy: the names of the attributes, which should be used for order the results
    ///   - orderedAscending: a boolean value to indicate, whether the results should be ordered ascending or descening
    /// - Returns: a result controller with objects of type Administration into it
    func fetchAdministations(request: String = "", groupedBy: String = "", orderedBy: [String], orderedAscending: Bool = false) -> NSFetchedResultsController<Administration> {
        let resultsController: NSFetchedResultsController<Administration>
        
        if orderedBy.count == 0 {
            resultsController = self.fetchData(from: "Administration", request: request, groupedBy: groupedBy, orderedBy: ["country"], orderedAscending: orderedAscending) as! NSFetchedResultsController<Administration>
        } else {
            resultsController = self.fetchData(from: "Administration", request: request, groupedBy: groupedBy, orderedBy: orderedBy, orderedAscending: orderedAscending) as! NSFetchedResultsController<Administration>
        }
        
        return resultsController
    }
    
    /// This function fetches datasets from the school entity.
    ///
    /// - Parameters:
    ///   - request: a filter argument to reduce the result
    ///   - groupedBy: a group argument to create sections
    ///   - orderedBy: the names of the attributes, which should be used for order the results
    ///   - orderedAscending: a boolean value to indicate, whether the results should be ordered ascending or descening
    /// - Returns: a result controller with objects of type School into it
    func fetchSchools(request: String = "", groupedBy: String = "", orderedBy: [String], orderedAscending: Bool = false) -> NSFetchedResultsController<School> {
        let resultsController: NSFetchedResultsController<School>
        
        if orderedBy.count == 0 {
            resultsController = self.fetchData(from: "School", request: request, groupedBy: groupedBy, orderedBy: ["name"], orderedAscending: orderedAscending) as! NSFetchedResultsController<School>
        } else {
            resultsController = self.fetchData(from: "School", request: request, groupedBy: groupedBy, orderedBy: orderedBy, orderedAscending: orderedAscending) as! NSFetchedResultsController<School>
        }
        
        return resultsController
    }
    
    /// This function fetches datasets from any entity.
    ///
    /// - Parameters:
    ///   - entity: the name of the entity fetching data from
    ///   - request: a filter argument to reduce the result
    ///   - groupedBy: a group argument to create sections
    ///   - orderedBy: the names of the attributes, which should be used for order the results
    ///   - orderedAscending: a boolean value to indicate, whether the results should be ordered ascending or descening
    /// - Returns: a result controller with objects of given entity
    private func fetchData(from entity: String, request: String = "", groupedBy: String = "", orderedBy: [String], orderedAscending: Bool = false) -> NSFetchedResultsController<NSFetchRequestResult> {
        //create fetch request and a result controller
        var resultsController = NSFetchedResultsController<NSFetchRequestResult>()
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        //sort the result
        var sortDesc: [NSSortDescriptor] = []
        for attr in orderedBy {
            sortDesc.append(NSSortDescriptor(key: attr, ascending: orderedAscending))
        }
        fetch.sortDescriptors = sortDesc
//        if orderedBy != "" {
//            let sort = NSSortDescriptor(key: orderedBy, ascending: orderedAscending)
//            fetch.sortDescriptors = [sort]
//        }
        
        //filter the result
        if request != "" {
            fetch.predicate = NSPredicate(format: request)
        }
        
        //group the result
        if groupedBy != "" {
            resultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: groupedBy, cacheName: nil)
        } else {
            resultsController = NSFetchedResultsController(fetchRequest: fetch, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)
        }
        
        //fetch the data
        do {
            try resultsController.performFetch()
        } catch {
            fatalError("Failed to fetch data: \(error)")
        }
        
        return resultsController
    }
    
    /// This function deletes an object from core data.
    ///
    /// - Parameter objectID: the id of the object, which should be deleted
    func delete(by objectID: NSManagedObjectID) {
        let managedObject = self.managedObjectContext.object(with: objectID)
        self.managedObjectContext.delete(managedObject)
        self.saveData()
    }
    
    /// This function extracts all unique values from Core Data and returns them as an array.
    ///
    /// - Parameters:
    ///   - attribute: the name of the attribute for which the unique values are required
    ///   - entity: the name of the entity for which the unique values are required
    /// - Returns: an array of Strings containing the unique values
    func distinctValues(for attribute: String, in entity: String) -> [String] {
        //init the fetch request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        
        fetchRequest.resultType = NSFetchRequestResultType.dictionaryResultType
        fetchRequest.propertiesToFetch = [attribute]
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.returnsDistinctResults = true
        
        //fetch data and return it
        var result: [String] = []
        var fetchResult: NSArray
        do {
            fetchResult = try self.managedObjectContext.fetch(fetchRequest) as NSArray
        } catch {
            fatalError("Failed to fetch distinct values: \(error)")
        }
        for entry in fetchResult {
            let entryDictionary = entry as! NSDictionary
            result.append(entryDictionary.object(forKey: attribute) as! String)
        }
        return result
    }
    
    func downloadData(administration: CloudKitAdministrationRow, schoolFileURL: URL, gridFileURL: URL) {
        
        //init the new administration object
        let localAdministration: Administration = self.create(administration: administration)
        
        //init the schools
        let schools: [School] = self.create(schools: schoolFileURL)
        for school in schools {
            localAdministration.addToSchools(school)
            school.administration = localAdministration
        }
        
        //init the grid
        let grid: Grid = self.create(grid: gridFileURL)
        localAdministration.grid = grid
        grid.administration = localAdministration
        
        //store the administration in CoreData
        self.saveData()
        
    }
    
    private func create(administration: CloudKitAdministrationRow) -> Administration {
        //init the new administration object with information directly from CloudKit
        let localAdministration = NSEntityDescription.insertNewObject(forEntityName: "Administration", into: managedObjectContext) as! Administration
        localAdministration.city = administration.city
        localAdministration.region = administration.region
        localAdministration.lastUpdate = administration.lastUpdate
        localAdministration.x = administration.centroid.longitude
        localAdministration.y = administration.centroid.latitude
        
        //add information about the country from the GeoJSON-file
        let administrationFile: AdministrationFile = self.decoder.parseAdministrationFile(from: administration.geojson.fileURL)!
        localAdministration.country = administrationFile.features[0].properties.country
        
        //add the boundary to the administration
        let administrationBoundary = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
        for coordinates in administrationFile.features[0].geometry.coordinates[0] {
            let point = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
            point.x = coordinates[0]
            point.y = coordinates[1]
            administrationBoundary.addToPoints(point)
            point.boundary = administrationBoundary
        }
        localAdministration.boundary = administrationBoundary
        administrationBoundary.administration = localAdministration
        
        return localAdministration
    }
    
    private func create(schools fileURL: URL) -> [School] {
        //create the result variable
        var schools: [School] = []
        
        //parse the GeoJSON file
        let schoolFile: SchoolFile = self.decoder.parseSchoolFile(from: fileURL)!
        
        //iterate over all features and create the school objects
        for feature in schoolFile.features {
            let school = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext) as! School
            
            school.localID = Int64(feature.properties.id)
            school.schoolName = feature.properties.name
            school.city = feature.properties.school_address.components(separatedBy: "/")[3]
            school.mail = feature.properties.mail
            school.favorite = false
            school.street = feature.properties.school_address.components(separatedBy: "/")[0]
            school.number = feature.properties.school_address.components(separatedBy: "/")[1]
            school.phone = feature.properties.phone
            school.postalCode = feature.properties.school_address.components(separatedBy: "/")[2]
            school.schoolSpecialisation = feature.properties.school_specialisations
            school.schoolType = feature.properties.school_type
            school.website = feature.properties.website
            school.wikipedia = feature.properties.wikipedia
            school.x = feature.geometry.coordinates[0]
            school.y = feature.geometry.coordinates[1]
            
            schools.append(school)
        }
        
        return schools
    }
    
    private func create(grid fileURL: URL) -> Grid {
        //create a new Grid object
        let localGrid: Grid = NSEntityDescription.insertNewObject(forEntityName: "Grid", into: managedObjectContext) as! Grid
        
        //parse the GeoJSON file
        let gridFile: GridFile = self.decoder.parseGridFile(from: fileURL)!
        
        //iterate over all features
        for feature in gridFile.features {
            //create a new cell for the grid
            let cell = NSEntityDescription.insertNewObject(forEntityName: "Cell", into: managedObjectContext) as! Cell
            
            //create the cell values for this cell
            for (index, value) in feature.properties.cellValues.enumerated() {
                let cellValue = NSEntityDescription.insertNewObject(forEntityName: "CellValue", into: managedObjectContext) as! CellValue
                cellValue.value = value as? NSDecimalNumber
                cellValue.localSchoolID = Int64(feature.properties.schoolIDs[index].components(separatedBy: "_")[2])!
                cellValue.cell = cell
                cell.addToCellValues(cellValue)
            }
            
            //create the boundary for this cell
            let boundary = NSEntityDescription.insertNewObject(forEntityName: "Boundary", into: managedObjectContext) as! Boundary
            for coordinates in feature.geometry.coordinates[0] {
                let point = NSEntityDescription.insertNewObject(forEntityName: "Point", into: managedObjectContext) as! Point
                point.x = coordinates[0]
                point.y = coordinates[1]
                boundary.addToPoints(point)
                point.boundary = boundary
            }
            boundary.cell = cell
            cell.boundary = boundary
            
            //add the cell to the grid
            localGrid.addToCells(cell)
            cell.grid = localGrid
        }
        
        return localGrid
    }
    
}
