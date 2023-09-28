//
//  IAPViewController.swift
//  PL2
//
//  Created by iPHTech2 on 24/05/18.
//  Copyright © 2018 IPHS Technologies. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
import FBSDKCoreKit

enum RegisteredPurchase: String
{
    case pl2sp
    case pl2wk
    case pl2mo
    case pl2yr
    case pl2mods
}

class IAPViewController: UIViewController {
    
    static let shared = IAPViewController()
    let appBundleId = "com.moomoolab"
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    
    func verifyReceipt(completion: @escaping (VerifyReceiptResult) -> Void) {
        
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "41d0f1f21d1a4e51a9811b08cf282e53")
        SwiftyStoreKit.verifyReceipt(using: appleValidator, completion: completion)
    }
    
    
    func verifySubscriptions(_ purchases: Set<RegisteredPurchase>) {
        NetworkActivityIndicatorManager.networkOperationStarted()
        verifyReceipt { result in
            NetworkActivityIndicatorManager.networkOperationFinished()
            switch result {
            case .success(let receipt):
                let productIds = Set(purchases.map { self.appBundleId + "." + $0.rawValue })
                let purchaseResult = SwiftyStoreKit.verifySubscriptions(productIds: productIds, inReceipt: receipt)
                let resultString = self.responseVerifySubscriptions(purchaseResult, productIds: productIds)
                print(resultString)
            case .error:
                let errorString = self.responseForVerifyReceipt(result)
                print(errorString)
            }
        }
    }
}

// MARK: User facing response
extension IAPViewController {
    
    fileprivate func writeAutoRenewalLogs(_ subscriptionType: String) {
        if(subscriptionType == "Weekly"){
            self.appDelegate.logEvent(name: "weekly_subscription_auto_complete", category: "Subscription", action: "Auto Restore")
            self.appDelegate.logEvent(name: "subscription_renew", category: "Subscription", action: "weekly")
        }
        if(subscriptionType == "Monthly"){
            self.appDelegate.logEvent(name: "Monthly_subscription_auto_complete", category: "Subscription", action: "Auto Restore")
            self.appDelegate.logEvent(name: "subscription_renew", category: "Subscription", action: "monthly")
        }
        if(subscriptionType == "Yearly"){
            self.appDelegate.logEvent(name: "Yearly_subscription_auto_complete", category: "Subscription", action: "Auto Restore")
            self.appDelegate.logEvent(name: "subscription_renew", category: "Subscription", action: "yearly")
        }
    }
    
    func responseVerifySubscriptions(_ result: VerifySubscriptionResult, productIds: Set<String>) -> String {
        switch result {
        case .purchased(let expiryDate, let items):
            //            print("\(productIds) IS VALID UNTILL \(expiryDate)\n\(items)\n")
            
            ///Devendra to do
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
            let ExpirationDateString = formatter.string(from: expiryDate)
            //print("EXPIRED DEV DATE::\(ExpirationDateString)")
            UserDefaults.standard.set("NO", forKey: "IS_EXPIRED")
            UserDefaults.standard.set(0, forKey: "EXPIRE_INTENT")
            UserDefaults.standard.set("YES", forKey: "SUBSCRIPTION_PURCHASE")
            
            if let mostRecent = items.first {
                let cancelDate = mostRecent.cancellationDate
                if cancelDate != nil
                {
                    UserDefaults.standard.set("YES", forKey: "IS_EXPIRED")
                    UserDefaults.standard.set(1, forKey: "EXPIRE_INTENT")
                    UserDefaults.standard.synchronize()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
                    }
                }
                else {
                    
                    var subscriptionType = ""
                    let productId = mostRecent.productId
                    if productId != nil {
                        if productId == "com.moomoolab.pl2wk" {
                            subscriptionType = "Weekly"
                            let saveExpireDateString = UserDefaults.standard.string(forKey: expirationTimeKey)
                            //When user subscribes to weekly subscription the first time with 3 day trial // shoaib
                            if saveExpireDateString == nil && items.count == 1 {
                                self.appDelegate.logEvent(name: "Weekly_first_sub", category: "Subscription", action: "weekly subscription first time")
                                AppEvents.logEvent(AppEvents.Name("Weekly_first_sub"))
                            }
                        }
                        else if (productId == "com.moomoolab.pl2mo" || productId == "com.moomoolab.pl2mods") {
                            subscriptionType = "Monthly"
                        }
                        else if productId == "com.moomoolab.pl2yr" {
                            subscriptionType = "Yearly"
                        }
                    }
                    
                    let saveExpireDateString = UserDefaults.standard.string(forKey: expirationTimeKey)
                    if saveExpireDateString == nil && items.count >= 1 {
                        UserDefaults.standard.set("\(ExpirationDateString)", forKey: expirationTimeKey)
                    }
                    else {
                        let getDateString = UserDefaults.standard.string(forKey: expirationTimeKey)
                        let previousDate = formatter.date(from: getDateString!)
                        let currentDate = formatter.date(from: ExpirationDateString)
                        if previousDate != nil && currentDate != nil {
                            if currentDate?.compare(previousDate!) == .orderedDescending {
                                UserDefaults.standard.set("\(currentDate)", forKey: expirationTimeKey)
                                self.writeAutoRenewalLogs(subscriptionType)
                            }
                        }
                    }
                    
                }
                
            }
            
            UserDefaults.standard.synchronize()
            if backgroundOrientation {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
            }
            }
            backgroundOrientation = true
            //End
            
            return "SUBSCRIPTION RUNNING"
            
        case .expired(let expiryDate, let items):
            //            print("\(productIds) IS EXPIRED SINCE \(expiryDate)\n\(items)\n")
            ///Devendra to do
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"
            let ExpirationDateString = formatter.string(from: expiryDate)
            let currentDate = formatter.date(from: ExpirationDateString)
            UserDefaults.standard.set("\(currentDate)", forKey: expirationTimeKey)
            
            UserDefaults.standard.set("YES", forKey: "IS_EXPIRED")
            UserDefaults.standard.set(1, forKey: "EXPIRE_INTENT")
            UserDefaults.standard.synchronize()
            if backgroundOrientation {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
            }
            }
            backgroundOrientation = true
            //End
            return "SUBSCRIPTION EXPIRED"
        case .notPurchased:
            //print("\(productIds) HAS NEVER BEEN PURCHASED")
            return "SUBSCRIPTION NEVER PURCHASED"
        }
    }
    
    func responseForVerifyReceipt(_ result: VerifyReceiptResult) -> String {
        
        switch result {
        case .success(let receipt):
            //print("Verify receipt Success: \(receipt)")
            return "RECEIPT VERIFIED"
        case .error(let error):
            //print("Verify receipt Failed: \(error)")
            switch error {
            case .noReceiptData:
                return "NO RECEIPT DATA TRY AGAIN."
            case .networkError(let error):
                return "Network error while verifying receipt: \(error)"
            default:
                return "Receipt verification failed: \(error)"
            }
        }
    }
}

