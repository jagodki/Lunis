//
//  School+CoreDataProperties.swift
//  Lunis
//
//  Created by Christoph on 18.01.19.
//  Copyright © 2019 jagodki. All rights reserved.
//
//

import Foundation
import CoreData

extension SchoolMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SchoolMO> {
        return NSFetchRequest<SchoolMO>(entityName: "School")
    }

    @NSManaged public var city: String
    @NSManaged public var favorite: Bool
    @NSManaged public var mail: String
    @NSManaged public var name: String
    @NSManaged public var number: String
    @NSManaged public var path: String
    @NSManaged public var phone: String
    @NSManaged public var postalCode: String
    @NSManaged public var schoolSpecialisation: String
    @NSManaged public var schoolType: String
    @NSManaged public var street: String
    @NSManaged public var website: String
    @NSManaged public var wikipedia: String
    @NSManaged public var x: Double
    @NSManaged public var y: Double
    @NSManaged public var administration: AdministrationMO

}
