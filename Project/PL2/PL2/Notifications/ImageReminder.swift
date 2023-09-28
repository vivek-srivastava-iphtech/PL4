//
//  ImageReminder.swift
//  PL2
//
//  Created by IPHTECH 20 on 14/01/20.
//  Copyright © 2020 IPHS Technologies. All rights reserved.
//

import Foundation
import UIKit
class ImageReminder {
    class var sharedInstance : ImageReminder {
        struct Static {
            static let instance: ImageReminder = ImageReminder()
        }
        return Static.instance
    }
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    fileprivate let ITEMS_KEY = "todoItems"
        
    
    func addNotificationItem(_ item: ImageDataItem, timeValue: Int) {
        let content = UNMutableNotificationContent()
        var img = appDelegate.getImage(imgName: item.name!, imageId: item.imageId!,isThumb: false)
        if(img == nil){
           img = self.getImage(name: item.name!)
        }
        
        
        var todoDictionary = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) ?? Dictionary()
        todoDictionary[item.imageId!] = ["imageId": item.imageId!, "category":item.category!, "name": item.name!, "UUID": item.UUID, "level": item.level!, "position": item.position!, "purchase": item.purchase!,"isLocalNotification":true]
        UserDefaults.standard.set(todoDictionary, forKey: ITEMS_KEY)

         let categoryName = item.category!.capitalizingFirstLetter()
         let localizeCategory = NSLocalizedString(categoryName, comment:categoryName)
        
       
        let perfect_time  = NSLocalizedString("It is perfect time to finish your", comment: "")
        
        
        
        content.title = NSLocalizedString("Use the power of now!", comment: "")
        content.body = "\(perfect_time) \(localizeCategory) 😀"
        //"It is perfect time to finish \n your \(item.category!) 😀"
        content.sound = UNNotificationSound.default()
        content.badge = 1
        
        // 2
        content.userInfo = ["category": item.category!, "imageId": item.imageId!,"name": item.name!,"level": item.level!, "position": item.position!, "purchase": item.purchase!,"isLocalNotification":true]
        

        if let attachment = UNNotificationAttachment.create(identifier: item.name!, image: img!, options: .none) {
            content.attachments = [attachment]
        }
        
        let after1Day = Calendar.current.date(byAdding: timeComponent, value: timeValue, to: Date())
        let calendar = Calendar.current
        var comp = calendar.dateComponents([.year,.month,.day,.hour,.minute,.second], from: after1Day!)
        let triggerFirstNotification = UNCalendarNotificationTrigger(dateMatching: comp, repeats: false)
        let requestFirstNotification = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: triggerFirstNotification)
        UNUserNotificationCenter.current().add(requestFirstNotification, withCompletionHandler: nil)

    }
    
    
    func getImage(name: String) -> UIImage {
        var completeImage = UIImage()
        if let image = UIImage(named:name)
        {
            completeImage = image
            return completeImage
        }
        else
        {
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: paths){
                let image = UIImage(contentsOfFile:paths)
                completeImage = image!
                return completeImage
            }
            else
            {
                return completeImage
            }
        }
    }
    
    func  clearNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        if var todoItems = UserDefaults.standard.dictionary(forKey: ITEMS_KEY) {
            todoItems.removeAll()
            UserDefaults.standard.set(todoItems, forKey: ITEMS_KEY)
        }
       
    }
    
    func  clearAllNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
    }

    
}
