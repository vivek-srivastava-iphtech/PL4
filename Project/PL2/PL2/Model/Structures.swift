//
//  Structures.swift
//  PL2
//
//  Created by iPHTech8 on 9/22/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import Foundation
import UIKit

struct RGBAColor {
    var red = uint()
    var green = uint()
    var blue = uint()
    var alpha = CGFloat()
}

struct ColorWithNumber {
    var key = UIColor()
    var value = Int()
    var number = Int()
    var isComplete = false
}


extension UIColor {
    
    func rgb() -> Int? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)
            
            //  (Bits 24-31 are alpha, 16-23 are red, 8-15 are green, 0-7 are blue).
            let rgb = (iAlpha << 24) + (iRed << 16) + (iGreen << 8) + iBlue
            return rgb
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}


//Gaurav

class ImageData : NSObject {
    
    var imageId: String?
    var category: String?
    var name: String?
    var level:String?
    var position: Int?
    var purchase: Int?
    var np: Int!
    var n: Int!
    //     var horizontalGrids: Int?
    //     var verticalGrids: Int?
    
}


class ExploreData : NSObject {
    
    var name: String
    var category: String
    var type: String
    var nc: Int!
    init(data:NSDictionary){
        self.name = data.value(forKey: "name") as! String
        self.category = data.value(forKey: "category") as! String
        self.type = data.value(forKey: "type") as! String
        self.nc = data.value(forKey: "nc") != nil ? data.value(forKey: "nc") as! Int : 0
    }
}

class PointAndColor : NSObject,NSCoding{
    
    var points : CGPoint!
    var fillColor : UIColor!
    var coloringDevice : Int!
    var colorID = String(0)
    
    func encode(with aCoder: NSCoder) {
        if let pointsObj = points { aCoder.encode(NSValue(cgPoint: pointsObj), forKey: "points") }
        if let fillColorObj = fillColor { aCoder.encode(fillColorObj, forKey: "fillColor") }
        if let coloringDeviceObj = coloringDevice {
            aCoder.encode(coloringDeviceObj, forKey: "coloringDevice")
        }
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init()
        let value    = aDecoder.decodeObject(forKey: "points") as! NSValue
        self.points  = value.cgPointValue;
        self.fillColor = aDecoder.decodeObject(forKey: "fillColor") as! UIColor
        self.coloringDevice = aDecoder.decodeInteger(forKey: "coloringDevice")
        self.setColorIDVal()
        
    }

    convenience init(points: CGPoint, fillColor: UIColor, coloringDevice: Int) {
        self.init()
        self.points    = points
        self.fillColor = fillColor
        self.coloringDevice = coloringDevice
        self.setColorIDVal()
    }
    
    func setColorIDVal()
    {
        self.colorID = String(self.fillColor.rgb()!)
    }
    
}

struct ImageDataItem {
    var imageId: String?
    var category: String?
    var name: String?
    var UUID: String
    var level:String?
    var position: Int?
    var purchase: Int?
    init(imageId: String, category: String,name: String, UUID: String, level: String, position: Int, purchase: Int) {
        self.imageId = imageId
        self.category = category
        self.name = name
        self.UUID = UUID
        self.level = level
        self.position = position
        self.purchase = purchase
    }
}

//Shoaib
class TutorialData : NSObject {
    var image: String!
    var title: String!
    var isIpad: Bool!
}
//End

//Saddam
class CategoryStringModel: NSObject {

    var categoryName: String
    var categoryImages: [String]
    var categoryImagesId: [String]
    
    init(categoryName: String, categoryImages: [String], categoryImagesId: [String]) {
        self.categoryName = categoryName
        self.categoryImages = categoryImages
        self.categoryImagesId = categoryImagesId

    }
}
//End
