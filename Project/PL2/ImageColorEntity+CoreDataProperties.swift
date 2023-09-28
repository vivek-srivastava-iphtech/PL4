//
//  ImageColorEntity+CoreDataProperties.swift
//  
//
//  Created by iPHTech12 on 17/11/2017.
//
//

import Foundation
import CoreData


extension ImageColorEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ImageColorEntity> {
        return NSFetchRequest<ImageColorEntity>(entityName: "ImageColorEntity")
    }

    @NSManaged public var colorData: Data?
    @NSManaged public var imageId: String?
    @NSManaged public var type: String?

}
