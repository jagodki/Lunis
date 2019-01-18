//
//  Administration+CoreDataProperties.swift
//  Lunis
//
//  Created by Christoph on 18.01.19.
//  Copyright © 2019 jagodki. All rights reserved.
//
//

import Foundation
import CoreData


extension AdministrationMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<AdministrationMO> {
        return NSFetchRequest<AdministrationMO>(entityName: "Administration")
    }

    @NSManaged public var city: String
    @NSManaged public var country: String
    @NSManaged public var lastUpdate: NSDate
    @NSManaged public var path: String
    @NSManaged public var region: String
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var schools: NSSet

}

// MARK: Generated accessors for schools
extension AdministrationMO {

    @objc(addSchoolsObject:)
    @NSManaged public func addToSchools(_ value: SchoolMO)

    @objc(removeSchoolsObject:)
    @NSManaged public func removeFromSchools(_ value: SchoolMO)

    @objc(addSchools:)
    @NSManaged public func addToSchools(_ values: NSSet)

    @objc(removeSchools:)
    @NSManaged public func removeFromSchools(_ values: NSSet)

}
