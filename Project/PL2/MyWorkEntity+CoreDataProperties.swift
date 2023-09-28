//
//  MyWorkEntity+CoreDataProperties.swift
//  
//
//  Created by iPHTech12 on 17/11/2017.
//
//

import Foundation
import CoreData


extension MyWorkEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MyWorkEntity> {
        return NSFetchRequest<MyWorkEntity>(entityName: "MyWorkEntity")
    }

    @NSManaged public var category: String?
    @NSManaged public var position: Int16
    @NSManaged public var level: String?
    @NSManaged public var free: Bool
    @NSManaged public var name: String?
    @NSManaged public var imageId: String?

}
