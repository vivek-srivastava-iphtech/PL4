//
//  DrawViewEntity+CoreDataProperties.swift
//  
//
//  Created by iPHTech12 on 17/11/2017.
//
//

import Foundation
import CoreData


extension DrawViewEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DrawViewEntity> {
        return NSFetchRequest<DrawViewEntity>(entityName: "DrawViewEntity")
    }

    @NSManaged public var imageId: String?
    @NSManaged public var pointColorTouple: Data?

}
