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
    
    //var managedObjectContext: NSManagedObjectContext!
    
    override init() {
        super.init()
        let persistentContainer = NSPersistentContainer(name: "lunis")
        persistentContainer.loadPersistentStores() { (description, error) in
            if let error = error {
                fatalError("Failed to load Core Data stack: \(error)")
            }
        }
        
        //init the managed object context for connecting to core data
//        guard let appDelegate =
//            UIApplication.shared.delegate as? AppDelegate else {
//                return
////        }
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        self.managedObjectContext  = appDelegate.persistentContainer.viewContext
        
        
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
    
    func initData() {
        let administration1 = NSEntityDescription.insertNewObject(forEntityName: "Administration", into: managedObjectContext) as! AdministrationMO
        let administration2 = NSEntityDescription.insertNewObject(forEntityName: "Administration", into: managedObjectContext) as! AdministrationMO
        let school1 = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext) as! SchoolMO
        let school2 = NSEntityDescription.insertNewObject(forEntityName: "School", into: managedObjectContext) as! SchoolMO
        
        administration1.city = "Radebeul"
        administration1.region = "Sachsen"
        administration1.country = "Deutschland"
        administration1.path = ""
        administration1.lastUpdate = NSDate()
        administration1.x = 51.110218
        administration1.y = 13.641750
        
        administration2.city = "Meißen"
        administration2.region = "Sachsen"
        administration2.country = "Deutschland"
        administration2.path = ""
        administration2.lastUpdate = NSDate()
        administration2.x = 51.166734
        administration2.y = 13.473048
        
        school1.name = "Lößnitzgymnasium"
        school1.city = "Radebeul"
        school1.mail = "info@test.xyz"
        school1.favorite = true
        school1.street = "Steinbachstraße"
        school1.number = "21"
        school1.path = ""
        school1.phone = "0351/12345678"
        school1.postalCode = "01445"
        school1.schoolSpecialisation = "sprachlich, künstlerich"
        school1.schoolType = "Gymnasium"
        school1.website = "https://www.loessnitzgymnasium-radebeul.de"
        school1.wikipedia = "https://de.wikipedia.org/wiki/L%C3%B6%C3%9Fnitzgymnasium"
        school1.x = 51.104209
        school1.y = 13.659038
        school1.administration = administration1
        
        school2.name = "Sächsisches Landesgymnasium Sankt Afra"
        school2.city = "Meißen"
        school2.mail = "info@test.xyz"
        school2.favorite = false
        school2.street = "Freiheit"
        school2.number = "13"
        school2.path = ""
        school2.phone = "03521/87654321"
        school2.postalCode = "01662"
        school2.schoolSpecialisation = "sprachlich, künstlerich, naturwissenschaftlich"
        school2.schoolType = "Grundschule"
        school2.website = "http://www.sankt-afra.de/"
        school2.wikipedia = "https://de.wikipedia.org/wiki/S%C3%A4chsisches_Landesgymnasium_Sankt_Afra"
        school2.x = 51.163543
        school2.y = 13.467966
        school2.administration = administration2
        
        administration1.addToSchools(school1)
        administration2.addToSchools(school2)
        
        self.saveData()
    }
    
    /// This function fetches datasets from the administration entity.
    ///
    /// - Parameter request: a String representing the request for filtering, sorting etc. the fetch
    /// - Returns: an array of AdministrationMO-objects as the result of the fetch
    func fetchAdministations(request: String = "") -> [AdministrationMO] {
        //create the fetch request
        let administrationFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Administration")
        var administrationData: [AdministrationMO] = [AdministrationMO]()
        
        //fetch the data
        do {
            administrationData = try self.managedObjectContext.fetch(administrationFetch) as! [AdministrationMO]
        } catch {
            fatalError("Failed to fetch administrations: \(error)")
        }
        return administrationData
    }
    
    /// This function fetches datasets from the school entity.
    ///
    /// - Parameter request: a String representing the request for filtering, sorting etc. the fetch
    /// - Returns: an array of SchoolMO-objects as the result of the fetch
    func fetchSchools(request: String = "") -> [SchoolMO] {
        //create the fetch request
        let schoolFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "School")
        var schoolData: [SchoolMO] = [SchoolMO]()
        
        //fetch the data
        do {
            schoolData = try self.managedObjectContext.fetch(schoolFetch) as! [SchoolMO]
        } catch {
            fatalError("Failed to fetch schools: \(error)")
        }
        return schoolData
    }
    
    
    /// This function fetches datasets from the administration entity.
    ///
    /// - Parameters:
    ///   - request: a filter argument to reduce the result
    ///   - groupedBy: a group argument to create sections
    ///   - orderedBy: the name of the attribute, which should be used for order the results
    ///   - orderedAscending: a boolean value to indicate, whether the results should be ordered ascending or descening
    /// - Returns: a result controller with objects of type AdministrationMO into it
    func fetchAdministations(request: String = "", groupedBy: String = "", orderedBy: String = "", orderedAscending: Bool = false) -> NSFetchedResultsController<AdministrationMO> {
        //create fetch request and a result controller
        var resultsController = NSFetchedResultsController<AdministrationMO>()
        let fetch = NSFetchRequest<AdministrationMO>(entityName: "Administration")
        
        //sort the result
        if orderedBy != "" {
            let sort = NSSortDescriptor(key: orderedBy, ascending: orderedAscending)
            fetch.sortDescriptors = [sort]
        }
        
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
            fatalError("Failed to fetch grouped administrations: \(error)")
        }
        
        return resultsController
    }
    
    /// This function fetches datasets from the school entity.
    ///
    /// - Parameters:
    ///   - request: a filter argument to reduce the result
    ///   - groupedBy: a group argument to create sections
    ///   - orderedBy: the name of the attribute, which should be used for order the results
    ///   - orderedAscending: a boolean value to indicate, whether the results should be ordered ascending or descening
    /// - Returns: a result controller with objects of type SchoolMO into it
    func fetchSchools(request: String = "", groupedBy: String = "", orderedBy: String = "", orderedAscending: Bool = false) -> NSFetchedResultsController<SchoolMO> {
        //create fetch request and a result controller
        var resultsController = NSFetchedResultsController<SchoolMO>()
        let fetch = NSFetchRequest<SchoolMO>(entityName: "School")
        
        //sort the result
        if orderedBy != "" {
            let sort = NSSortDescriptor(key: orderedBy, ascending: orderedAscending)
            fetch.sortDescriptors = [sort]
        }
        
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
            fatalError("Failed to fetch grouped administrations: \(error)")
        }
        
        return resultsController
    }
    
    /// This function deletes an object from core data.
    ///
    /// - Parameter objectID: the id of the object, which should be deleted
    func delete(by objectID: NSManagedObjectID) {
        let managedObject = self.managedObjectContext.object(with: objectID)
        self.managedObjectContext.delete(managedObject)
    }
    
}
