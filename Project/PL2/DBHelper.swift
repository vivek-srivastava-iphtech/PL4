//
//  DBHelper.swift
//  PL2
//
//  Created by iPHTech12 on 02/11/2017.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CloudKit

@available(iOS 10.0, *)
class DBHelper {
    
    static let sharedInstance = DBHelper()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    //To Add 2D Array -------- ImageColorEntity -----------
    func insertColorArray(imageId: String, colorArr: [[UIColor]] , type: String ){
        
        //Encode Array in Data Format
        let data = encodeColorArr(colorArr: colorArr)
        let colorObj = ImageColorEntity(context:context)
        colorObj.imageId = imageId
        colorObj.colorData = data
        colorObj.type = type
        saveRecords()
        
        
//        let recordId = CKRecordID(recordName: imageId)
//        let imageColorRecord = CKRecord(recordType: "ImageColorEntity", recordID: recordId)
//        imageColorRecord["colorData"] = data as CKRecordValue
//        imageColorRecord["imageId"] = imageId as NSString
//        imageColorRecord["type"] = type as NSString
  //      let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
//        ckPrivateDatabase.save(imageColorRecord) { (record, error) in
//            if let error = error{
//                print(error.localizedDescription)
//                return
//            }
//            print("Data saved for ImageColorEntity")
//        }
        
        
        // save to iCloud Database
        
        /*let predicate = NSPredicate(format:"imageId == %@",imageId)
        let query = CKQuery(recordType: IMAGE_COLOR_ENTITY, predicate: predicate)
        let recordZoneId = CKRecordZoneID(zoneName: IMAGE_COLOR_ENTITY_ZONE, ownerName: CKCurrentUserDefaultName)
        ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (imageColorEntityRecord, error) in
            if let error = error{
                print("error in myworkentity")
                print(error.localizedDescription)
            } else{
                print("ImageColorEntity Record --> \(imageColorEntityRecord?.count ?? 0)")
                if (imageColorEntityRecord?.count)! == 0{
                    
                    let recordId = CKRecordID(recordName: imageId, zoneID: recordZoneId)
                    
                    let imageColorRecord = CKRecord(recordType: IMAGE_COLOR_ENTITY, recordID: recordId)
                    imageColorRecord["colorData"] = data as NSData
                    imageColorRecord["imageId"] = imageId as NSString
                    imageColorRecord["type"] = type as NSString
                    
                    ckPrivateDatabase.save(imageColorRecord) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("New Record saved for ImageColorEntity")
                    }
                } else{
                    imageColorEntityRecord![0]["colorData"] = data as NSData
                    imageColorEntityRecord![0]["imageId"] = imageId as NSString
                    imageColorEntityRecord![0]["type"] = type as NSString
                    
                    ckPrivateDatabase.save(imageColorEntityRecord![0]) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("Record updated for ImageColorEntity")
                    }
                }
            }
        }*/
        
        
    }
    
    func insertWhiteColorArray(imageId: String, colorArr: [CGPoint] , type: String ){
        
        //Encode Array in Data Format
        let data = NSKeyedArchiver.archivedData(withRootObject: colorArr)
        let colorObj = ImageColorEntity(context:context)
        colorObj.imageId = imageId
        colorObj.colorData = data
        colorObj.type = type
        saveRecords()
    }
    
    func fetchColorArr(imageId: String, type: String) ->[[UIColor]]{
        var colorArr = [[UIColor]]()
        let request = NSFetchRequest<ImageColorEntity>(entityName: IMAGE_COLOR_ENTITY)
        request.predicate = NSPredicate(format: "imageId = %@ AND type = %@",imageId,type)
        do{
            let searchResults = try context.fetch(request)
            
            for task in searchResults {
                
                colorArr = decodeFromData(withData:task.colorData!)
                return colorArr
            }
        }catch {
           // print("Error with request: \(error)")
        }
        
        saveRecords()
        return colorArr
    }
    
    func fetchWhiteColorArr(imageId: String, type: String) ->[CGPoint]{
        var colorArr = [CGPoint]()
        let request = NSFetchRequest<ImageColorEntity>(entityName: IMAGE_COLOR_ENTITY)
        request.predicate = NSPredicate(format: "imageId = %@ AND type = %@",imageId,type)
        do{
            let searchResults = try context.fetch(request)
            
            for task in searchResults {
                
                colorArr = NSKeyedUnarchiver.unarchiveObject(with: task.colorData!) as! [CGPoint]
                return colorArr
            }
        }catch {
           // print("Error with request: \(error)")
        }
        
        saveRecords()
        return colorArr
    }
    
    //End ImageColorEntity
 /*
    func insertTuple(imageId: String , pointColorTuple: [PointAndColor]) -> Void {
        
        //Encode Array in Data Format
        let data = encodePointAndColorTuple(colorTuple: pointColorTuple)
        let drawViewEntityObj = DrawViewEntity(context:context)
        drawViewEntityObj.imageId          = imageId
        drawViewEntityObj.pointColorTouple = data
        saveRecords()
        
        
        
        // save to iCloud Database
        let zone = CKRecordZone(zoneName: "DrawViewEntity_Zone")
        let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
        ckPrivateDatabase.save(zone) { (recordZone, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                print("DrawViewEntity Zone saved succesfully")
                
                
            }
        }
        let predicate = NSPredicate(format:"imageId == %@",imageId)
        let query = CKQuery(recordType: "DrawViewEntity", predicate: predicate)
        let recordZoneId = CKRecordZoneID(zoneName: "DrawViewEntity_Zone", ownerName: CKCurrentUserDefaultName)
        ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (drawViewEntityRecord, error) in
            if let error = error{
                print("error in DrawViewEntity")
                print(error.localizedDescription)
            } else{
                print("DrawViewEntity Record --> \(drawViewEntityRecord?.count ?? 0)")
                if (drawViewEntityRecord?.count)! == 0{
                    
                    let recordId = CKRecordID(recordName: imageId, zoneID: recordZoneId)
                    
                    let drawViewRecord = CKRecord(recordType: "DrawViewEntity", recordID: recordId)
                    drawViewRecord["pointColorTouple"] = data as NSData
                    drawViewRecord["imageId"] = imageId as NSString
                    
                    ckPrivateDatabase.save(drawViewRecord) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("New Record saved for DrawViewEntity")
                    }
                } else{
                    drawViewEntityRecord![0]["pointColorTouple"] = data as NSData
                    drawViewEntityRecord![0]["imageId"] = imageId as NSString
                    
                    ckPrivateDatabase.save(drawViewEntityRecord![0]) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("Record updated for DrawViewEntity")
                    }
                }
            }
        }

    }
    */
    func fetchPointsAndColorTuple(imageId: String, imageName: String, isCallFromHome: Bool) -> [PointAndColor] {
        
        var pointsAndColorTupleArr = [PointAndColor]()
        let request = NSFetchRequest<DrawViewEntity>(entityName: DRAW_VIEW_ENTITY)
//        request.predicate = NSPredicate(format: "imageId = %@",imageId)
        request.predicate = NSPredicate(format: "imageId CONTAINS %@",imageName)

        do{
            let searchResults = try context.fetch(request)
            
            for task in searchResults {
                
                pointsAndColorTupleArr = decodePointAndColorTupleFromData(withData:task.pointColorTouple!)
                return pointsAndColorTupleArr
            }
        }catch {
            print("Error with request: \(error)")
        }
        
        saveRecords()
        return pointsAndColorTupleArr
    }
 /*
    //Captured Points
    func insertCapturedPoint(imageId: String , pointsArr: [CGPoint]) -> Void {
        
        //Encode Array in Data Format
        let data = encodeCapturedPoints(currentPoint: pointsArr)
        let drawViewEntityObj = DrawViewEntity(context:context)
        drawViewEntityObj.imageId          = imageId
        drawViewEntityObj.pointColorTouple = data
        
        saveRecords()
    }
    
    func fetchCapturedPoints(imageId: String) -> [CGPoint] {
        
        var pointsArr = [CGPoint]()
        let request = NSFetchRequest<DrawViewEntity>(entityName: "DrawViewEntity")
        request.predicate = NSPredicate(format: "imageId == %@",imageId)
        do{
            let searchResults = try context.fetch(request)
            
            for task in searchResults {
                
                pointsArr = decodeCapturedPointsFromData(withData: task.pointColorTouple!)
                return pointsArr
            }
        }catch {
            print("Error with request: \(error)")
        }
        
        saveRecords()
        return pointsArr
    }
    
    */
   
    func updateTuple(imageId: String , pointColorTuple: [PointAndColor], imageName: String, isCallFromHome: Bool) {

        let request = NSFetchRequest<DrawViewEntity>(entityName: DRAW_VIEW_ENTITY)
        if isCallFromHome {
            request.predicate = NSPredicate(format: "imageId CONTAINS %@",imageName)
        }
        else {
            request.predicate = NSPredicate(format:"imageId == %@",imageId)
        }

        let data = encodePointAndColorTuple(colorTuple: pointColorTuple)
        
        //updateToupleTOiCloud(imageId: imageId, data: data, predicate: predicate, entityName: DRAW_VIEW_ENTITY, zoneName: DRAW_VIEW_ENTITY_ZONE)
        
        do{
            let searchResults = try context.fetch(request)
            if searchResults.count == 0{
                let drawViewEntityObj = DrawViewEntity(context:context)
                drawViewEntityObj.imageId          = imageId
                drawViewEntityObj.pointColorTouple = data
                drawViewEntityObj.lastUpdatedDate = Date()
            } else{
                searchResults[0].pointColorTouple = data
                searchResults[0].lastUpdatedDate = Date()
            }
            saveRecords()
        }catch {
            print("Error with request: \(error)")
        }
    }
    
    
    func saveToupleData(imageId: String , data: Data, isUploadToiCloud:Bool, completion:(_ isUpdated: Bool) -> ()) {
        let request = NSFetchRequest<DrawViewEntity>(entityName: DRAW_VIEW_ENTITY)
        let predicate = NSPredicate(format:"imageId == %@",imageId)
        request.predicate = predicate
//        if isUploadToiCloud == true{
//             updateToupleTOiCloud(imageId: imageId, data: data, predicate: predicate, entityName: DRAW_VIEW_ENTITY, zoneName: DRAW_VIEW_ENTITY_ZONE)
//        }
        do{
            let searchResults = try context.fetch(request)
            if searchResults.count == 0{
                let drawViewEntityObj = DrawViewEntity(context:context)
                drawViewEntityObj.imageId          = imageId
                drawViewEntityObj.pointColorTouple = data
                drawViewEntityObj.lastUpdatedDate = Date()
                saveRecords()
                completion(false)
            } else{
                searchResults[0].pointColorTouple = data
                searchResults[0].lastUpdatedDate = Date()
                saveRecords()
                completion(true)
            }
            
        }catch {
            print("Error with request: \(error)")
        }
    }
    
    /*func updateToupleTOiCloud(imageId:String, data:Data, predicate:NSPredicate, entityName:String, zoneName:String){
        let query = CKQuery(recordType: entityName, predicate: predicate)
        let recordZoneId = CKRecordZoneID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
        let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
        ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (record, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                if (record?.count) == 0{
                    let recordId = CKRecordID(recordName: imageId, zoneID: recordZoneId)
                    
                    let drawViewRecord = CKRecord(recordType: entityName, recordID: recordId)
                    drawViewRecord["pointColorTouple"] = data as NSData
                    drawViewRecord["imageId"] = imageId as NSString
                    
                    ckPrivateDatabase.save(drawViewRecord) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("New Record saved for \(entityName)")
                    }
                } else{
                    record![0]["pointColorTouple"] = data as NSData
                    record![0]["imageId"] = imageId as NSString
                    ckPrivateDatabase.save(record![0]) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("Record updated for \(entityName)")
                    }
                }
                
            }
        }
    }*/
    
    
    /*func syncDrawViewEntityToiCloud(imageId:String, entityName:String, zoneName:String, completion:@escaping (_ dataSaved:Bool) -> ()){
        let predicate = NSPredicate(format: "imageId == %@",imageId)
        let query = CKQuery(recordType: entityName, predicate: predicate)
        let recordZoneId = CKRecordZoneID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
        let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
        ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (record, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                if (record?.count)! != 0{
                    let toupleData = record![0]["pointColorTouple"] as! Data
                    let modificationDate = (record![0]["modificationDate"])! as! Date
                    let request = NSFetchRequest<DrawViewEntity>(entityName: entityName)
                    request.predicate = predicate
                    do{
                        let searchResults = try self.context.fetch(request)
                        if searchResults.count == 0{
                            self.saveToupleData(imageId: imageId, data: toupleData, isUploadToiCloud: false, completion: { isUpdated in
                                completion(isUpdated)
                            })
                        } else{
                            let lastModificationDateFromLocalDatabase = searchResults[0].lastUpdatedDate
                            if modificationDate > lastModificationDateFromLocalDatabase!{
                                self.saveToupleData(imageId: imageId, data: toupleData, isUploadToiCloud: false, completion: { isUpdated in
                                    completion(isUpdated)
                                })
                            } else{
                                self.saveToupleData(imageId: imageId, data: toupleData, isUploadToiCloud: true, completion: { isUpdated in
                                    completion(isUpdated)
                                })
                            }
                        }
                    }catch {
                        print("Error with request: \(error)")
                    }
                } else{
                    
                }
            }
        }
    }
    */
    
    
    //Lekha Added ======
    //Insert image
    func saveImageInDb(imgData : ImageData, isUploadToiCloud:Bool) {
        
        let request = NSFetchRequest<MyWorkEntity>(entityName: MY_WORK_ENTITY)
        request.predicate = NSPredicate(format: "imageId == %@",imgData.imageId!)
        do{
            let searchResults = try context.fetch(request)
            if searchResults.count == 0
            {
                let task = MyWorkEntity(context:context)
                task.category = imgData.category
                task.imageId = imgData.imageId
                task.level = imgData.level
                task.purchase = Int16(imgData.purchase!)
                task.name = imgData.name
                task.position = Int16(imgData.position!)
                do{
                    try context.save()
                }
                print("saving record for MyWorkEnitity for image ID = \(imgData.imageId!)")
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
            }
            
        }catch {
            print("Error with request: \(error)")
        }
        
       /* if isUploadToiCloud == true{
            // save to iCloud Database
            let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
            let predicate = NSPredicate(format:"imageId == %@",imgData.imageId!)
            let query = CKQuery(recordType: MY_WORK_ENTITY, predicate: predicate)
            let recordZoneId = CKRecordZoneID(zoneName: MY_WORK_ENTITY_ZONE, ownerName: CKCurrentUserDefaultName)
            ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (myRecord, error) in
                if let error = error{
                    print("error in myworkentity")
                    print(error.localizedDescription)
                } else{
                    print("My work Record --> \(myRecord?.count ?? 0)")
                    if (myRecord?.count)! == 0{
                        
                        let recordId = CKRecordID(recordName: imgData.imageId!, zoneID: recordZoneId)
                        
                        let myWorkRecord = CKRecord(recordType: MY_WORK_ENTITY, recordID: recordId)
                        myWorkRecord["category"] = imgData.category! as NSString
                        myWorkRecord["imageId"] = imgData.imageId! as NSString
                        myWorkRecord["level"] = imgData.level! as NSString
                        myWorkRecord["purchase"] = imgData.purchase! as NSNumber
                        myWorkRecord["name"] = imgData.name! as NSString
                        myWorkRecord["position"] = imgData.position! as NSNumber
                        
                        ckPrivateDatabase.save(myWorkRecord) { (record, error) in
                            if let error = error{
                                print(error.localizedDescription)
                                return
                            }
                            print("New Record saved for MyWorkEntity")
                        }
                    }
                }
            }
        }*/
    }


    //MARK:- Delete image Devendra Added
    func deleteImageFromDb(imgData : ImageData, isUploadToiCloud:Bool, imageName: String) {
        let request = NSFetchRequest<MyWorkEntity>(entityName: MY_WORK_ENTITY)
//        request.predicate = NSPredicate(format: "imageId == %@",imgData.imageId!)
        request.predicate = NSPredicate(format: "imageId CONTAINS %@",imageName)
        do{
            let searchResults = try context.fetch(request)
            for object in searchResults {
                context.delete(object)
            }
            print("delete record for MyWorkEnitity for image ID = \(imgData.imageId!)")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()

        }catch {
            print("Delete MyWorkEnitity image,Error with request: \(error)")
        }
    }
    //MARK: Delete Thumbnail Devendra Added
    func deleteThumbInDb(imageId: String?, isUploadToiCloud:Bool, imageName: String) {
        let request = NSFetchRequest<ThumbNailEntity>(entityName: THUMBNAIL_ENTITY)
//        let predicate = NSPredicate(format: "imageId == %@",imageId!)
        let predicate = NSPredicate(format: "imageId CONTAINS %@",imageName)
        request.predicate = predicate
        do{
            let searchResults = try context.fetch(request)
            for object in searchResults {
                context.delete(object)
            }
            print("delete record for Thumbnail for image ID = \(imageId!)")
            (UIApplication.shared.delegate as! AppDelegate).saveContext()

        }catch {
            print("Delete Thumbnail,Error with request: \(error)")
        }
    }


    func getMyWorkImages() -> [ImageData] {
    
        var imgArray = [ImageData]()
        let request = NSFetchRequest<MyWorkEntity>(entityName: MY_WORK_ENTITY)
     
        do{
            let searchResults = try context.fetch(request)
           // print("My Work images result = \(searchResults.count)")

            for task in searchResults {
                let imgData = ImageData()
                imgData.category = task.category
                imgData.imageId = task.imageId
                imgData.level  = task.level
//                Comment by Devendra To D0
//                if task.name  == "em3.png"
//                {
//                    imgData.purchase = Int(2)
//                }
//                else
//                {
                imgData.purchase = Int(task.purchase)
//            }
                imgData.name = task.name
                imgData.position = Int(task.position)
                imgArray.append(imgData)
            }
            
        }catch {
            print("Error with request: \(error)")
        }

        var tempArray = [ImageData]()
        var imageNameArray = [String]()
        for data in imgArray {
            if !imageNameArray.contains(data.name!) {
                tempArray.append(data)
                imageNameArray.append(data.name!)
            }
        }

        print(imageNameArray)

        imgArray = tempArray

        return imgArray
    }
    
    /*func syncMyWorkImagesFromiCloud(completion:@escaping(_ imagesData:[ImageData]) -> ()){
        var imagesData = [ImageData]()
        let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
        let recordZoneId = CKRecordZoneID(zoneName: MY_WORK_ENTITY_ZONE, ownerName: CKCurrentUserDefaultName)
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: MY_WORK_ENTITY, predicate: predicate)
        ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (records, error) in
            print("\niCloud My work images =  \((records?.count)!)")
            DispatchQueue.main.async(execute: {
                if let error = error{
                    print(error.localizedDescription)
                } else{
                    for record in records!{
                        let imageData = ImageData()
                        imageData.category = record["category"] as? String
                        imageData.imageId = record["imageId"] as? String
                        imageData.level = record["level"] as? String
                        imageData.purchase = record["purchase"] as? Int
                        imageData.name = record["name"] as? String
                        imageData.position = record["position"] as? Int
                        self.saveImageInDb(imgData: imageData, isUploadToiCloud: false)
                        imagesData.append(imageData)
                        print("\n\n images data appended for mywork page")
                    }
                    print("\n\n images data for mywork page returned")
                    completion(imagesData)
                }
                
            })
            
        }
    }*/
    
    //Lekha End ======
    
    //Insert image
    func saveThumbInDb(imageId: String?, thumImg: UIImage, isUploadToiCloud:Bool, imageName: String, isCallFromHome: Bool, completion:(_ isUpdated: Bool) -> ()) {
        
        let dataObj = UIImageJPEGRepresentation(thumImg, 0.5)
        
        
        //            let strBase64 = dataObj?.base64EncodedString(options: .lineLength64Characters)
        //            print(strBase64)
        
        let request = NSFetchRequest<ThumbNailEntity>(entityName: THUMBNAIL_ENTITY)
//        let predicate = NSPredicate(format: "imageId == %@",imageId!)
//        request.predicate = predicate
        if isCallFromHome {
            request.predicate = NSPredicate(format: "imageId CONTAINS %@",imageName)
        }
        else {
            request.predicate = NSPredicate(format:"imageId == %@",imageId!)
        }
        

//        if isUploadToiCloud == true{
//            saveThumbnailImageTOiCloud(imageId: imageId!, data: dataObj!, predicate: predicate, entityName: THUMBNAIL_ENTITY, zoneName: THUMBNAIL_ENTITY_ZONE)
//        }
        do{
            let searchResults = try context.fetch(request)
            if searchResults.count == 0
            {
                let task = ThumbNailEntity(context:context)
                task.imageId = imageId
                task.thumb = dataObj
                task.lastUpdatedDate = Date()
                completion(false)
                saveRecords()
            }
            else
            {
                for task in searchResults {
                    task.imageId = imageId
                    task.thumb = dataObj
                    task.lastUpdatedDate = Date()
                    saveRecords()
                    completion(true)
                    break;
                }
            }
            
        }catch {
            print("Error with request: \(error)")
        }
    }
    
    /*func saveThumbnailImageTOiCloud(imageId:String, data:Data, predicate:NSPredicate, entityName:String, zoneName:String){
        let query = CKQuery(recordType: entityName, predicate: predicate)
        let recordZoneId = CKRecordZoneID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
        let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
        ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (record, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                if (record?.count) == 0{
                    let recordId = CKRecordID(recordName: imageId, zoneID: recordZoneId)
                    
                    let drawViewRecord = CKRecord(recordType: entityName, recordID: recordId)
                    drawViewRecord["thumb"] = data as NSData
                    drawViewRecord["imageId"] = imageId as NSString
                    
                    ckPrivateDatabase.save(drawViewRecord) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("New Record saved for \(entityName)")
                    }
                } else{
                    record![0]["thumb"] = data as NSData
                    record![0]["imageId"] = imageId as NSString
                    ckPrivateDatabase.save(record![0]) { (record, error) in
                        if let error = error{
                            print(error.localizedDescription)
                            return
                        }
                        print("Record updated for \(entityName)")
                    }
                }
                
            }
        }
    }*/
    
    
    
    func getThumbImage(imageId: String, imageName: String) -> UIImage? {
        
        let request = NSFetchRequest<ThumbNailEntity>(entityName: THUMBNAIL_ENTITY)
//        let predicate = NSPredicate(format: "imageId == %@",imageId)
        let predicate = NSPredicate(format: "imageId CONTAINS %@",imageName)

        request.predicate = predicate
        do{
            let searchResults = try context.fetch(request)
            if searchResults.count == 0{
                
            } else{
                if searchResults[0].thumb != nil{
                    return UIImage(data:searchResults[0].thumb!)
                }
            }
            
        }catch {
            print("Error with request: \(error)")
        }
        
        return nil
    }
    
    func saveRecords()
    {
        DispatchQueue.main.async {
           (UIApplication.shared.delegate as! AppDelegate).saveContext()
        }
       
    }
    
    //Lekha End ======
    
    /*func syncThumnailImage(imageId: String, entityName:String, zoneName:String, completion:@escaping (_ dataSaved:Bool) -> ()){
        let predicate = NSPredicate(format: "imageId == %@",imageId)
        let query = CKQuery(recordType: entityName, predicate: predicate)
        let recordZoneId = CKRecordZoneID(zoneName: zoneName, ownerName: CKCurrentUserDefaultName)
        let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
        ckPrivateDatabase.perform(query, inZoneWith: recordZoneId) { (record, error) in
            if let error = error{
                print(error.localizedDescription)
            } else{
                if (record?.count)! != 0{
                    let thumb = record![0]["thumb"] as! Data
                    let image = UIImage(data: thumb)
                    let modificationDate = (record![0]["modificationDate"])! as! Date
                    let request = NSFetchRequest<ThumbNailEntity>(entityName: THUMBNAIL_ENTITY)
                    request.predicate = predicate
                    do{
                        let searchResults = try self.context.fetch(request)
                        if searchResults.count == 0{
                            self.saveThumbInDb(imageId: imageId, thumImg: image!, isUploadToiCloud: false ){ isComplete in
                                completion(isComplete)
                            }
                        } else{
                            let lastModificationDateFromLocalDatabase = searchResults[0].lastUpdatedDate
                            if modificationDate > lastModificationDateFromLocalDatabase!{
                                self.saveThumbInDb(imageId: imageId, thumImg: image!, isUploadToiCloud: false){ isComplete in
                                    completion(isComplete)
                                }
                            } else{
                                self.saveThumbInDb(imageId: imageId, thumImg: image!, isUploadToiCloud: true){ isComplete in
                                    completion(isComplete)
                                }
                            }
                        }
                    }catch {
                        print("Error with request: \(error)")
                    }
                    
                } else{
                    
                }
            }
        }
    }*/
}

//MARK:- syncing data with iCloud Database

func syncDataToiCloud(imageId:String){
    
}


//MARK: - Encoding and Decoding
func encodeColorArr(colorArr: [[UIColor]]) -> Data {
    return NSKeyedArchiver.archivedData(withRootObject: colorArr)
}
func decodeFromData(withData data:Data) -> [[UIColor]] {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as! [[UIColor]]
}

func encodeImage(img: UIImage) -> Data {
    return NSKeyedArchiver.archivedData(withRootObject: img)
}
func decodeImage(withData data:Data) -> UIImage {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as! UIImage
}

func encodePointAndColorTuple(colorTuple: [PointAndColor]) -> Data {
    return NSKeyedArchiver.archivedData(withRootObject: colorTuple)
}
func decodePointAndColorTupleFromData(withData data:Data) -> [PointAndColor] {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as! [PointAndColor]
}

func encodeCapturedPoints(currentPoint: [CGPoint]) -> Data {
    return NSKeyedArchiver.archivedData(withRootObject: currentPoint)
}
func decodeCapturedPointsFromData(withData data:Data) -> [CGPoint] {
    return NSKeyedUnarchiver.unarchiveObject(with: data) as! [CGPoint]
}
