//
//  AppDelegate.swift
//  PL2
//
//  Created by iPHTech8 on 9/19/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit
import CoreData
import FirebaseAnalytics
import CloudKit
import FirebaseCrashlytics
import GoogleMobileAds

import UserNotifications
import FirebaseInstallations
import FirebaseMessaging
import FirebaseDynamicLinks
import FBSDKCoreKit
import FirebaseCore
import FirebasePerformance

import SwiftyStoreKit
//import AppLovinSDK
import AppLovinSDK
import AdColonyAdapter
import FBAudienceNetwork

import AppTrackingTransparency
import AdSupport

// Mark : For Register AppLovin
//import AppLovinSDKc

enum PurchasType {
    case kPurchasTypeNone
    case kPurchaseTypeNonConsumable
    case kPurchaseTypeSubscribe
    case kPurchaseTypeWeekSubscription
    case kPurchaseTypeMonthSubscription
    case kPurchaseTypeYearSubscription
}

enum LayoutType {
    case kPhonePortrait
    case kPhoneLandscape
    case kPadPortrait
    case kPadLandscape
    
}
// added comint for testing
//let LAUNCH_COUNT = "LaunchCount"
private var windowPopup: UIWindow!
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UITabBarControllerDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    var window: UIWindow?
    let convert = ConvertImageToGreyScale()
    let non_consumable_purchase = "NON_CONSUMABLE_PURCHASE"
    let subscription_purchase = "SUBSCRIPTION_PURCHASE"
    let expiration_date = "EXPIRATION_DATE"
    let is_expired = "IS_EXPIRED"
    var isReloadNeeded = true
    var isLastPortrait = false
    let imagesNeedsSync = NSMutableArray()
    
    var isNotificationViewVisible = 0
    var notificationAskView : UIView!
    let notification_enabled = "NOTIFICATION_ENABLED" //1-Yes, 2-Cancelled, 3-Maybe Later
    var counter: Int = 0
    var timerSession : Timer?
    var pagesVC: PagesVC!
    var sessionCountTime = 60.0  //60.0  //1 min
    var imageDataNotification : ImageData!
    var selectedImageData : ImageData!
    // var isNotificationTap : Bool = false
    var currentWindowString = "comp_win_2"
    var adTrackingPromptValue = -1
    var homeVC: HomeVC!
    var exploreVC: ExploreViewController!
    var imagesCategoryArray = [String]()
    let hint_count = "HINT_COUNT"
    var isReloadExploreNeeded = true
    var sessionImageArray = [String]()
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        
        application.applicationIconBadgeNumber = 0
        application.isStatusBarHidden = true
        let currentLaunch = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        UserDefaults.standard.set(currentLaunch+1, forKey: LAUNCH_COUNT)
        UserDefaults.standard.set(true, forKey: SHOW_SUBSCRIPTION)
        
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            print("PORTRAIT FIRST")
            self.isLastPortrait = true
        }
        let appTracking = UserDefaults.standard.string(forKey: APP_TRACKING)
        if appTracking != nil {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] status in
                if status == .authorized{
                    FBAdSettings.setAdvertiserTrackingEnabled(true)
                    FBSDKCoreKit.Settings.setAdvertiserTrackingEnabled(true)
                    FBSDKCoreKit.Settings.isAdvertiserIDCollectionEnabled = true
                    print("FacebookAdvertiserIDCollectionEnabled")
                } else if status == .denied || status == .restricted{
                    FBAdSettings.setAdvertiserTrackingEnabled(false)
                    print("FacebookAdvertiserIDCollectionDisabled")
                }
            }
        }
        }
        print(appTracking)
        /*if UI_USER_INTERFACE_IDIOM() == .pad{
         UIApplication.shared.isStatusBarHidden = false
         }
         else{
         UIApplication.shared.isStatusBarHidden = true
         }*/
        // Override point for customization after application launch.
        
        //Todo
        // If counter no nil in user defaults
        // set 0
        
        // Remove all UserDefaults Data
        // UserDefaults.standard.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
        
        sleep(1)
        
        //FIREBASE PUSH NOTIFICATION REGISTRATION
        // Use Firebase library to configure APIs
        //^https://mybrand\.com/.*$
        // Mark : For Register AppLovin
        // ALSdk.initializeSdk()
        
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        
        // Get the FCM registration token
        Messaging.messaging().token { token, error in
          if let error = error {
            print("Error fetching FCM registration token: \(error.localizedDescription)")
          } else if let token = token {
            print("FCM registration token: \(token)")
            // Do something with the token, such as send it to your server
          }
        }
        
        // Get the Firebase installation ID
        Installations.installations().installationID { result, error in
          if let error = error {
            print("Error fetching Firebase installation ID: \(error)")
          } else if let result = result {
            let installationID = result
            print("Firebase installation ID: \(installationID)")
            // Do something with the installation ID, such as send it to your server
          }
        }
        
        // GADMobileAds.configure(withApplicationID: "ca-app-pub-7682495659460581~6281920678")
        if (UserDefaults.standard.object(forKey: "WEEKLY_PRICE") == nil)
        {
            self.getProductDetail()
        }
        else if (UserDefaults.standard.object(forKey: "Paint_Buckets_30") == nil)
        {
            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
            if !(((self.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || ((self.purchaseType() == .kPurchaseTypeNonConsumable)))
            {
                self.getProductDetail()
            }
        }
        
        
        self.addDefaultCount()
        self.SaveTimeSession()
        self.CheckFirstImageCompleted()
        
        // Enable uploading changed local data to CoreData
        //        CloudCore.observeCoreDataChanges(persistentContainer: persistentContainer, errorDelegate: self)
        
        // Sync on startup if push notifications is missed, disabled etc
        //self.saveRecordsToCloud()
        //self.saveZones()
        self.fetchPlistFile() // To Do For testing
        self.fetchExplorePlistFile()
        //self.syncDataFromToiCloud()
        //Crash Report on Debug Mode To Do Devendra
        
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
        
        //Devendra Added
        self.setupIAP() //SwiftyStoreKit.completeTransactions() should be called once when the app launches.
        //For test to avoid above message.
        
        
        IAPViewController.shared.verifySubscriptions([.pl2sp,.pl2wk, .pl2mo, .pl2mods, .pl2yr])
        //
        // self.checkForRemoteNotificationIsEnabled()
        // number of completions per session for Reward_w2
        UserDefaults.standard.set(8, forKey: SESSION_LIMIT)
        //        self.isReadytoQuit = false
        // UserDefaults.standard.set(false, forKey: SHOW_TERMPOPUP)
        
        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        let isShowSubs = UserDefaults.standard.bool(forKey: SHOW_SUBSCRIPTION)
        if (launchCount >= 2 && isShowSubs == true) {
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                if(isExpired == "YES" || isExpired == nil){
                    //  UserDefaults.standard.set(false, forKey: SHOW_SUBSCRIPTION)
                }else
                {
                    self.checkForRemoteNotificationIsEnabled()
                }
            }
            
        }
        else if(currentLaunch == 0)
        {
            UserDefaults.standard.setValue(true,forKey: isSoundEnabled)
            if let tabBarController = self.window!.rootViewController as? UITabBarController {
                tabBarController.selectedIndex = 1
            }
            
            if #available(iOS 14.0, *) {
                
            }
            else {
                self.ShowComplianceWindow1()
            }
        }
        else if (launchCount >= 2)
        {
            self.checkForRemoteNotificationIsEnabled()
        }
        
        // shoaib
        UNUserNotificationCenter.current().delegate = self
        
        // Need to Comment Line below to track
        // Task 193 Add custom even to track when user renews subscriptions (weekly, monthly, yearly)
        Analytics.setAnalyticsCollectionEnabled(false) // Disable Analytics data collection
        
        getExploreDataFromImagesCategory()
        sessionImageArray = []
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        let ads = GADMobileAds.sharedInstance()
            ads.start { status in
              // Optional: Log each adapter's initialization latency.
              let adapterStatuses = status.adapterStatusesByClassName
              for adapter in adapterStatuses {
                let adapterStatus = adapter.value
                NSLog("Adapter Name: %@, Description: %@, Latency: %f", adapter.key,
                adapterStatus.description, adapterStatus.latency)
              }

              // Start loading ads here...
            }
        
        // Ad Colony
        let appOptions = GADMediationAdapterAdColony.appOptions
        appOptions?.setPrivacyFrameworkOfType(ADC_CCPA, isRequired: true)
        appOptions?.setPrivacyConsentString("1", forType: ADC_CCPA)
        
        let request = GADRequest()
        let extras = GADMAdapterAdColonyExtras()
        extras.showPrePopup = true
        extras.showPostPopup = true
        request.register(extras)
        
        // App Lovin
        ALPrivacySettings.setHasUserConsent(true)
        ALPrivacySettings.setIsAgeRestrictedUser(true)
        ALPrivacySettings.setDoNotSell(true)
        
        // FB Advertising tracking enabled
        if #available(iOS 14.5, *) {
        // Do nothing

        } else {
            FBAdSettings.setAdvertiserTrackingEnabled(true)

        }

        return true
        
    }
    
    
    func showAdTrackingPrompt(isNeedToShowSubscription: String) {
        
        let alertController = UIAlertController (title: NSLocalizedString("Welcome", comment: ""), message: NSLocalizedString("Our app serves ads to help us\nprovide some content for free.\nIf you allow tracking, you\nwill see more personalized ads\ninstead of boring ads. Please tap\n“Allow for Tracking” in next window.", comment: ""), preferredStyle: .alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default) { (UIAlertAction) in
            self.okTappedHandler(isNeedToShowSubscription: isNeedToShowSubscription)
        }
        alertController.addAction(okAction)
        self.logEvent(name: "Track_win", category: "App Tracking Prompt", action: "App Tracking Transparency Prompt display")
        alertController.present(animated: true, completion: nil)
        
    }
    
    func okTappedHandler(isNeedToShowSubscription: String = "0") {
        
        if #available(iOS 14, *) {
            UserDefaults.standard.setValue(true, forKey: isAdTrackingPromptAuthorization)
            
            if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                
                ATTrackingManager.requestTrackingAuthorization(completionHandler: { status in
                    
                    // Tracking authorization completed. Start loading ads here.
                    // loadAd()
                    if status == .authorized {
                        FBAdSettings.setAdvertiserTrackingEnabled(true)
                        self.logEvent(name: "Track_allow", category: "App Tracking Prompt", action: "App Tracking Transparency Prompt allow click")
                        UserDefaults.standard.set("App Tracking Transparency allowed", forKey: APP_TRACKING)
                    }
                    else if status == .denied {
                        FBAdSettings.setAdvertiserTrackingEnabled(false)
                        self.logEvent(name: "Track_no", category: "App Tracking Prompt", action: "App Tracking Transparency Prompt Ask App Not to Track click")
                        UserDefaults.standard.set("App Tracking Transparency Denied", forKey: APP_TRACKING)
                    }
                    if(self.pagesVC != nil){
//                        self.pagesVC.loadAdAfterTrackingWindow()
                    }
                    let currentLaunch = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
                    let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType)
                    
                    if detectAppTypeValue == "New" {
                        if currentLaunch == 1 {
                            DispatchQueue.main.async {
                                if self.pagesVC != nil {
                                    self.pagesVC.showGifTutorialVC()
                                }
                            }
                        }
                    }
                    else{
                        if (UserDefaults.standard.value(forKey:tutKeyPageVC) == nil){
                            UserDefaults.standard.set("yes", forKey: tutKeyPageVC)
                            UserDefaults.standard.synchronize()
                        }
                    }
                    //                    else if detectAppTypeValue == "Old" {
                    //                        DispatchQueue.main.async {
                    //                            self.checkForRemoteNotificationIsEnabled()
                    //                        }
                    //                    }
                    if isNeedToShowSubscription == "1" {
                        DispatchQueue.main.async {
                            if(self.pagesVC != nil){
                                self.pagesVC.showGiftScreen()
                            }
                        }
                    }
                })
            }
        } else {
            //Handle false case
        }
        
    }
    
    func ShowComplianceWindow1() {
        
        self.logEvent(name: "Compliance_View", category: "compliance", action: "views compliance window")
        self.logEvent(name: "comp_win", category: "compliance", action: "comp_w_1")
        
        let alertController = UIAlertController (title: NSLocalizedString("Welcome", comment: ""), message: NSLocalizedString("By tapping Continue, you are confirming that you reviewed and accepted our Terms Of Use and Privacy Policy.", comment: ""), preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: acceptHandler)
        alertController.addAction(acceptAction)
        let moreInfoAction = UIAlertAction(title: NSLocalizedString("More Info", comment: ""), style: .cancel, handler: viewMoreHandler)
        alertController.addAction(moreInfoAction)
        // let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        // alertWindow.rootViewController = UIViewController()
        //alertWindow.windowLevel = UIWindowLevelAlert + 1;
        // alertWindow.makeKeyAndVisible()
        // alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        
        // let alert = UIAlertController(title: "Title", message: "Message", preferredStyle: .alert)
        // alert.addAction(UIAlertAction(title: "Button", style: .cancel))
        alertController.preferredAction = acceptAction
        alertController.present(animated: true, completion: nil)
    }
    
    func acceptHandler(alert: UIAlertAction!) {
        Settings.isAutoLogAppEventsEnabled = true
        Settings.isAdvertiserIDCollectionEnabled = true

        _ = GADRequest()
        // self.checkForRemoteNotificationIsEnabled()
        
        self.logEvent(name: "Accept", category: "compliance", action: "taps Accept button")
        self.logEvent(name: "comp_accept", category: "compliance", action: "comp_w_1")
        UserDefaults.standard.set("0", forKey: isKillByForce)
        UserDefaults.standard.setValue(true, forKey: isComplianceDone)
        UserDefaults.standard.set(false, forKey: IS_MOREINFO)
        DispatchQueue.main.async {
            if self.pagesVC != nil {
                self.pagesVC.showGifTutorialVC()
            }
        }
    }
    
    func viewMoreHandler(alert: UIAlertAction!) {
        self.logEvent(name: "More_Info", category: "compliance", action: "taps More info button")
        
        UserDefaults.standard.set(true, forKey: IS_MOREINFO)
        if let url = URL(string: "http://www.pixelcolorapp.com/privacy-policy/"),
           UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //Calling on PagesVC.
    func showComplianceWindow() {
        
        let isComplianceDoneValue = UserDefaults.standard.bool(forKey: isComplianceDone)
        let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType)
        
        if !isComplianceDoneValue && detectAppTypeValue == "New" {
            if #available(iOS 14, *) {
                if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                    currentWindowString = "comp_win_2"
                    print("trackingAuthorizationStatus notDetermined")
                }else if ATTrackingManager.trackingAuthorizationStatus == .restricted {
                    currentWindowString = "comp_win_1"
                    print("trackingAuthorizationStatus restricted")
                }else if ATTrackingManager.trackingAuthorizationStatus == .denied {
                    currentWindowString = "comp_win_1"
                    print("trackingAuthorizationStatus denied")
                }
            }else {
                currentWindowString = "comp_win_1"
            }
            if currentWindowString == "comp_win_1" {
                UserDefaults.standard.set("comp_win_1", forKey: displayComplianceWindow)
                ShowComplianceWindow1()
            }else if currentWindowString == "comp_win_2" {
                UserDefaults.standard.set("comp_win_2", forKey: displayComplianceWindow)
                ShowComplianceWindow2()
            }
        }
        
    }
    
    func ShowComplianceWindow2() {
        
        self.logEvent(name: "Comp_2_win", category: "compliance 2", action: "Compliance window 2 display")
        self.logEvent(name: "comp_win", category: "compliance 2", action: "comp_win_2")
        
        let alertController = UIAlertController (title: NSLocalizedString("Welcome", comment: ""), message: NSLocalizedString("Our app serves ads to help us\n provide some content for free.\nIf you allow tracking, you\nwill see more personalized ads\ninstead of boring ads. Please tap\n“Allow for Tracking” in next window.\n\nBy tapping Continue, you are\nconfirming that you reviewed and\naccepted our Terms Of Use and\nPrivacy Policy.", comment: ""), preferredStyle: .alert)
        let acceptAction = UIAlertAction(title: NSLocalizedString("Continue", comment: ""), style: .default, handler: acceptHandler2)
        alertController.addAction(acceptAction)
        let moreInfoAction = UIAlertAction(title: NSLocalizedString("More Info", comment: ""), style: .cancel, handler: viewMoreHandler2)
        alertController.addAction(moreInfoAction)
        alertController.preferredAction = acceptAction
        self.window?.rootViewController?.present(alertController, animated: true, completion: nil)
        
    }
    
    func acceptHandler2(alert: UIAlertAction!) {
        Settings.isAutoLogAppEventsEnabled = true
        Settings.isAdvertiserIDCollectionEnabled = true
        _ = GADRequest()
        
        self.logEvent(name: "Comp_2_Accept", category: "compliance 2", action: "Compliance 2  Accept tap")
        self.logEvent(name: "comp_accept", category: "compliance 2", action: "comp_w_2")
        UserDefaults.standard.set("0", forKey: isKillByForce)
        UserDefaults.standard.setValue(true, forKey: isComplianceDone)
        UserDefaults.standard.set(false, forKey: IS_MOREINFO)
        okTappedHandler() //(Done)
        
    }
    
    func viewMoreHandler2(alert: UIAlertAction!) {
        
        self.logEvent(name: "Comp_2_More", category: "compliance 2", action: "Compliance 2 More info tap")
        
        UserDefaults.standard.set(true, forKey: IS_MOREINFO)
        if let url = URL(string: "http://www.pixelcolorapp.com/privacy-policy/"),
           UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    
    func isCompletedImage(imageId: String, imageName: String) -> Bool {
        var completedID = getCompletedImagesIDArray()
        let dataSource = completedID
        let searchString = imageName
        let predicate = NSPredicate(format: "SELF contains %@", searchString)
        let searchDataSource = dataSource.filter { predicate.evaluate(with: $0) }
        
        if searchDataSource.count > 0{//completedID.contains(imageId) {
            return true
        }
        else {
            return false
        }
        
    }
    
    
    
    func addDefaultCount()
    {
        let defaults = UserDefaults.standard
        let currentAppVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let previousVersion = defaults.string(forKey: "appVersion")
        if previousVersion == nil {
            // first launch
            UserDefaults.standard.set(20, forKey: "HINT_COUNT")
            UserDefaults.standard.set(30, forKey: "PAINT_COUNT")
            UserDefaults.standard.set(30, forKey: "AUTOMOVE_COUNT")
            defaults.set(currentAppVersion, forKey: "appVersion")
            defaults.set("0", forKey: "feedbackOrRateTapped")
            defaults.synchronize()
        } else if previousVersion == currentAppVersion {
            // same version
            // UserDefaults.standard.set(100, forKey: "PAINT_COUNT")
        } else {
            // other version
            //UserDefaults.standard.set(10, forKey: "PAINT_COUNT")
            // defaults.set(currentAppVersion, forKey: "appVersion")
            // defaults.synchronize()
            defaults.set("0", forKey: "feedbackOrRateTapped")
        }
    }
    
    func getLayoutType()->LayoutType
    {
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            
            if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight)
            {
                return .kPadLandscape
            }
            else
            {
                return .kPadPortrait
            }
            
        }
        else
        {
            
            if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight)
            {
                return .kPhoneLandscape
            }
            else
            {
                return .kPhonePortrait
            }
        }
        
        return .kPhonePortrait
    }
    
    func setupIAP() {
        
        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                case .failed, .purchasing, .deferred:
                    print("DO NOTHING")
                    break // do nothing
                }
            }
        }
        
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.flatMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    
    func SaveTimeSession()
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        let result = formatter.string(from: date)
        if UserDefaults.standard.value(forKey: "current_date_string") != nil{
            let prevDateString = UserDefaults.standard.value(forKey: "current_date_string") as? String
            if prevDateString != result
            {
                UserDefaults.standard.set(result, forKey: "current_date_string")
                UserDefaults.standard.set(0, forKey: "sessionTime")
                UserDefaults.standard.synchronize()
                
                timerSession = Timer.scheduledTimer(timeInterval: sessionCountTime, target: self, selector: #selector(self.UpdateCounter), userInfo: nil, repeats: true)
            }
            else{
                timerSession = Timer.scheduledTimer(timeInterval: sessionCountTime, target: self, selector: #selector(self.UpdateCounter), userInfo: nil, repeats: true)
            }
            
        }
        else
        {
            UserDefaults.standard.set(0, forKey: "sessionTime")
            UserDefaults.standard.synchronize()
            
            timerSession = Timer.scheduledTimer(timeInterval: sessionCountTime, target: self, selector: #selector(self.UpdateCounter), userInfo: nil, repeats: true)
            UserDefaults.standard.set(result, forKey: "current_date_string")
            UserDefaults.standard.synchronize()
        }
        
    }
    
    
    func CheckFirstImageCompleted()
    {
        let completedID = getCompletedImagesIDArray()
        // first default tutrial image will not consider
        if(completedID.count>1){
            UserDefaults.standard.set("yes", forKey: "is_first_image_completed")
            UserDefaults.standard.synchronize()
        }
    }
    
    @objc func UpdateCounter()
    {
        //        UserDefaults.standard.set(2, forKey: "sessionTime")
        //        UserDefaults.standard.synchronize()
        
        if (UserDefaults.standard.object(forKey: "sessionTime") != nil)
        {
            counter = (UserDefaults.standard.object(forKey: "sessionTime") as! Int)
        }
        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        if(launchCount < 2){
            counter = 0
            UserDefaults.standard.set(counter, forKey: "sessionTime")
            UserDefaults.standard.synchronize()
        }
        else
        {
            counter = counter+1
            UserDefaults.standard.set(counter, forKey: "sessionTime")
            UserDefaults.standard.synchronize()
        }
        print("sessionTime:- \(counter)")
        
    }
    
    
    //    deinit {
    //         NotificationCenter.default.removeObserver(self)
    //         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
    //         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    //     }
    
    /*func saveZones(){
     let zone1 = CKRecordZone(zoneName: DRAW_VIEW_ENTITY_ZONE)
     let zone2 = CKRecordZone(zoneName: IMAGE_COLOR_ENTITY_ZONE)
     let zone3 = CKRecordZone(zoneName: MY_WORK_ENTITY_ZONE)
     let zone4 = CKRecordZone(zoneName: THUMBNAIL_ENTITY_ZONE)
     let ckPrivateDatabase = CKContainer.default().privateCloudDatabase
     let zones = [zone1,zone2,zone3,zone4]
     for zone in zones{
     ckPrivateDatabase.save(zone) { (recordZone, error) in
     if let error = error{
     print(error.localizedDescription)
     } else{
     print("Zones saved succesfully")
     }
     }
     }
     }*/
    
    
    /*func syncDataFromToiCloud(){
     let dbHelper = DBHelper()
     if let path = Bundle.main.path(forResource: "imagesproperty", ofType: "plist")
     {
     if let array = NSArray(contentsOfFile: path) as? [[String: Any]]
     {
     for arr in array
     {
     let imageDict =  arr as NSDictionary
     var level :String = ""
     let name      =     imageDict.value(forKey: "name") as! String
     let gameLevel =     imageDict.value(forKey: "level")
     if let levels = gameLevel {
     level     =     String(describing:levels )
     }
     let category  =  imageDict.value(forKey: "category") as! String
     let imageId   =     category+"_"+level+"_"+name
     
     /*dbHelper.syncThumnailImage(imageId: imageId, entityName: THUMBNAIL_ENTITY, zoneName: THUMBNAIL_ENTITY_ZONE, completion: { isUpdated in
      NotificationCenter.default.post(name: NSNotification.Name("load"), object: nil)
      print("\n\n---->  Thumbnail Synced for image ID = \(imageId)\n\n")
      })*/
     
     /*dbHelper.syncDrawViewEntityToiCloud(imageId: imageId, entityName: DRAW_VIEW_ENTITY, zoneName: DRAW_VIEW_ENTITY_ZONE, completion: { _ in
      print("\n\n ---->  Draw View touples Synced for image ID = \(imageId)\n\n")
      })*/
     }
     
     }
     
     }
     
     /*dbHelper.syncMyWorkImagesFromiCloud { _ in
      NotificationCenter.default.post(name: NSNotification.Name("myWorkSynced"), object: nil)
      print("\n\n ----> MyWork page synced\n\n")
      }*/
     }*/
    
    // commente by shoaib
    //    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    //        // Check if it CloudKit's and CloudCore notification
    //        //        if CloudCore.isCloudCoreNotification(withUserInfo: userInfo) {
    //        //            // Fetch changed data from iCloud
    //        //            CloudCore.fetchAndSave(using: userInfo, container: self.persistentContainer, error: nil, completion: { (fetchResult) in
    //        //                completionHandler(fetchResult.uiBackgroundFetchResult)
    //        //            })
    //        //        }
    //    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        if let incomingURL = userActivity.webpageURL {
            
            
            
            // NOTE :-  After Performance package below deep link not working
            
            // let handleLink = DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL, completion: { (dynamicLink, error) in
            //                if let dynamicLink = dynamicLink, let _ = dynamicLink.url
            //                {
            //                    print("Your Dynamic Link parameter: \(dynamicLink)")
            //                    self.handleDynamicLink(dynamicLink.url! as NSURL)
            //                } else {
            //                    print("Your Dynamic Link parameter Error")
            //                }
            //            })
            //            return handleLink
            
            // Added New Code for it
            
            URLSession.shared.dataTask(with: incomingURL) { (data, response, error) in
                
                if let actualURL = response?.url {
                    
                    DispatchQueue.main.async {
                        print("dLink : \(actualURL)")
                        print("Your Dynamic Link parameter: \(actualURL)")
                        self.handleDynamicLink(actualURL as NSURL)
                        
                    }
                }
            }.resume()
        }
        return false
    }
    
    
    func getParameterFrom(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func handleDynamicLink(_ dynamicLink: NSURL) {
        print("Your Dynamic Link parameter: \(dynamicLink)")
        
        var parameters: [String: String] = [:]
        if let urlComponents = URLComponents(string: dynamicLink.absoluteString!)?.queryItems {
            // return queryItems.first(where: { $0.name == param })?.value
            urlComponents.forEach { item in
                parameters[item.name] = item.value
                
                
                // URLComponents(url: dynamicLink as URL, resolvingAgainstBaseURL: false)?.queryItems?.forEach {
                // parameters[$0.name] = $0.value
                if(item.name == "plist")
                {
                    var array = UserDefaults.standard.stringArray(forKey: BONUS_NOT_CLAIMED) ?? [String]()
                    array.append(item.value!)
                    UserDefaults.standard.set(array, forKey: BONUS_NOT_CLAIMED)
                    if self.pagesVC != nil {
                        self.pagesVC.showClaimPopup()
                    }
                }
                if(item.name == "boost"){
                    
                    let deviceID = UIDevice.current.identifierForVendor!.uuidString
                    let value =  item.value!
                    if(value.split(separator: "_")[1] != deviceID )
                    {
                        var array = UserDefaults.standard.stringArray(forKey: BOOSTER_CLAIMED) ?? [String]()
                        if(!array.contains(value)){
                            
                            if(isBoosterReceived())// check max limit of receiving link
                            {   array.append(value)
                                UserDefaults.standard.set(array, forKey: BOOSTER_CLAIMED)
                                let paintCount =  UserDefaults.standard.integer(forKey: "PAINT_COUNT")
                                UserDefaults.standard.set(paintCount + boosterTool, forKey: "PAINT_COUNT")
                                
                                let alert = UIAlertController(title: NSLocalizedString("You have received a booster pack", comment:""), message: NSLocalizedString("", comment:""), preferredStyle: .alert)
                                
                                let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                                    
                                    self.logEvent(name: "booster_r", category: "booster", action: "Booster Received")
                                    
                                    if let rootViewController = UIApplication.topViewController() {
                                        if rootViewController is HomeVC
                                        {
                                            if rootViewController is HomeVC{
                                                self.homeVC = (rootViewController as! HomeVC)
                                                if self.homeVC != nil {
                                                    self.homeVC.setPaintCount()
                                                }
                                            }
                                            
                                        }
                                    }
                                    
                                }
                                alert.addAction(okayAction)
                                //present(alert, animated: true, completion: nil)
                                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                            else {
                                let alert = UIAlertController(title: NSLocalizedString("You have reached your daily limit", comment:""), message: NSLocalizedString("", comment:""), preferredStyle: .alert)
                                
                                let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                                    self.logEvent(name: "booster_r_limit", category: "booster", action: "Booster daily limit")
                                    
                                    
                                }
                                alert.addAction(okayAction)
                                //present(alert, animated: true, completion: nil)
                                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
                            }
                        }
                    }
                    else {
                        print("Same shared user")
                    }
                }
                
                // Update Version //
                if(item.name == "BundleVersion")
                {
                    if(getAppInfo() != item.value){
                        self.showUpdateApp()
                    }
                }
                // }
                
            }
        }
    }
    
    
    func getBoosterCompareValue(previousDisplayDate: Date, nowDate: Date) -> Int {
        
        var compValue = -1
        
        if boosterTimeComponent == .second {
            if let comp = Calendar.current.dateComponents([boosterTimeComponent], from: previousDisplayDate, to: nowDate).second {
                compValue = comp
            }
        }
        else if boosterTimeComponent == .minute {
            if let comp = Calendar.current.dateComponents([boosterTimeComponent], from: previousDisplayDate, to: nowDate).minute {
                compValue = comp
            }
        }
        else if boosterTimeComponent == .hour {
            if let comp = Calendar.current.dateComponents([boosterTimeComponent], from: previousDisplayDate, to: nowDate).hour {
                compValue = comp
            }
        }
        else if boosterTimeComponent == .day {
            if let comp = Calendar.current.dateComponents([boosterTimeComponent], from: previousDisplayDate, to: nowDate).day {
                compValue = comp
            }
        }
        
        return compValue
        
    }
    
    
    
    func isBoosterReceived() -> Bool
    {
        
        let date =  Calendar.current.date(byAdding: .day, value: 1, to: Date())
        let formatter = DateFormatter()
        formatter.timeZone = .current
        formatter.locale = .current
        formatter.dateFormat = "dd-MM-yyyy"
        let nowTimeString = formatter.string(from: date!)
        let prevShareCount = Int(UserDefaults.standard.value(forKey: previousBoostRecevingCount) as? Int ?? 0)
        
        if UserDefaults.standard.value(forKey: boosterReceivingDate) != nil{
            let prevDateString = UserDefaults.standard.value(forKey: boosterReceivingDate) as? String
            if prevDateString != nowTimeString
            {
                UserDefaults.standard.set(1,forKey: previousBoostRecevingCount)
                UserDefaults.standard.set("\(nowTimeString)", forKey: boosterReceivingDate)
                return true
            }
            if prevShareCount >= maxBoosterReceivingCount {
                
                return false
            }
            else {
                UserDefaults.standard.set(prevShareCount+1,forKey: previousBoostRecevingCount)
                UserDefaults.standard.set("\(nowTimeString)", forKey: boosterReceivingDate)
                return true
            }
        }
        else
        {
            UserDefaults.standard.set(1,forKey: previousBoostRecevingCount)
            UserDefaults.standard.set("\(nowTimeString)", forKey: boosterReceivingDate)
            return true
        }
        
        
        //        let prevShareCount = Int(UserDefaults.standard.value(forKey: previousBoostRecevingCount) as? Int ?? 0)
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        //        let nowTimeString = formatter.string(from: Date())
        //
        //        if let displayTimeValue = UserDefaults.standard.string(forKey: boosterReceivingDate) {
        //
        //            let previousDisplayDate = formatter.date(from: displayTimeValue)
        //            let nowDate = formatter.date(from: nowTimeString)
        //
        //            let compValue = getBoosterCompareValue(previousDisplayDate: previousDisplayDate!, nowDate: nowDate!)
        //            if compValue <= boosterTimeDelayValue && prevShareCount < maxBoosterReceivingCount{
        //
        //                UserDefaults.standard.set(prevShareCount+1,forKey: previousBoostRecevingCount)
        //                UserDefaults.standard.set("\(nowTimeString)", forKey: boosterReceivingDate)
        //                return true
        //            }
        //            if compValue <= boosterTimeDelayValue && prevShareCount >= maxBoosterReceivingCount {
        //
        //                return false
        //            }
        //            else {
        //                UserDefaults.standard.set(1,forKey: previousBoostRecevingCount)
        //                UserDefaults.standard.set("\(nowTimeString)", forKey: boosterReceivingDate)
        //                return true
        //            }
        //
        //        }
        //        else{
        //            UserDefaults.standard.set(1,forKey: previousBoostRecevingCount)
        //            UserDefaults.standard.set("\(nowTimeString)", forKey: boosterReceivingDate)
        //            return true
        //        }
    }
    
    
    func getAppInfo()->String {
        let dictionary = Bundle.main.infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        //let build = dictionary["CFBundleVersion"] as! String
        return version //+ "(" + build + ")"
    }
    
    
    //    @available(iOS 9.0, *)
    //    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
    //        return application(app, open: url,
    //                           sourceApplication: options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String,
    //                           annotation: "")
    //    }
    //
    //    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
    //        if let dynamicLink = DynamicLinks.dynamicLinks()!.dynamicLink(fromCustomSchemeURL: url) {
    //            // Handle the deep link. For example, show the deep-linked content or
    //            // apply a promotional offer to the user's account.
    //            // ...
    //            return true
    //        }
    //        return false
    //    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        // Save tokens on exit used to differential sync
        // CloudCore.tokens.saveToUserDefaults()
        
        
        
        
        //         var homeVC: HomeVC!
        //
        //        if(homeVC != nil)
        //        {
        //            homeVC.saveThumbnailAndPointsColor()
        //        }
        backgroundOrientation = false
        print("Enter Background")
        DispatchQueue.global(qos: .background).async {
            self.fetchPlistFile()
            self.fetchExplorePlistFile()
        }
        
        self.stopTimerSession()
        
        
        //        UserDefaults.standard.set(nil, forKey: "sessionTime")
        //        UserDefaults.standard.synchronize()
        
        /*        if UIApplication.shared.applicationState != .active
         {
         self.isReadytoQuit = true
         quitTimer = Timer.scheduledTimer(timeInterval: 900.0, target: self, selector: #selector(quitApp), userInfo: nil, repeats: false)
         }*/
        
        //call thumbnail & Point color saving function
        //        DispatchQueue.main.async {
        //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Reminder_For_InComplete_Image"), object: nil)
        //        }
        
        // Notification at Background
        // self.setInCompleteImageReminder()
    }
    
    func stopTimerSession() {
        if timerSession != nil {
            timerSession!.invalidate()
            timerSession = nil
        }
    }
    
    /*
     
     @objc func quitApp()
     {
     if self.isReadytoQuit
     {
     exit(0)
     }
     }*/
    
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        backgroundOrientation = false
        let defaults = UserDefaults.standard
        if defaults.data(forKey: "pointAndColorArr") != nil
        {
            let outData = defaults.data(forKey: "pointAndColorArr")
            let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!)as![PointAndColor]
            if #available(iOS 10.0, *) {
                
                DBHelper.sharedInstance.updateTuple(imageId: defaults.string(forKey: "imageId")!, pointColorTuple: dict, imageName: defaults.string(forKey: "name")!, isCallFromHome: false)
                
            } else {
                // Fallback on earlier versions
            }
            UserDefaults.standard.set(nil, forKey: "pointAndColorArr")
            defaults.synchronize()
        }
        print("ENTER_FOREGROUND")
        self.isReloadNeeded = true
        //        self.isReadytoQuit = false
        DispatchQueue.global(qos: .background).async {
            self.fetchPlistFile()
            self.fetchExplorePlistFile()
        }
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is PagesVC
            {
                if backgroundOrientation{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sync_images_new_popular"), object: nil)
                }
                }
            }
            else  if rootViewController is NewsVC{
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "checkNotificationStatus"), object: nil)
                }
                
            }
        }
        self.checkPushNotification {  (isEnable) in
            print(isEnable)
        }
        self.checkForPurchaseStatus()
        self.SaveTimeSession()
        let isMoreInfo = UserDefaults.standard.bool(forKey: IS_MOREINFO)
        let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType)
        if(isMoreInfo != nil && isMoreInfo == true)
        {
            UserDefaults.standard.set(false, forKey: IS_MOREINFO)
            
            if detectAppTypeValue == "New" {
                
                let visibleComplianceWindow = UserDefaults.standard.string(forKey: displayComplianceWindow)
                
                if visibleComplianceWindow == "comp_win_2" {
                    ShowComplianceWindow2()
                }
                else {
                    ShowComplianceWindow1()
                }
            }
        }
        
        
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        //   AppEvents.logEvent(<#T##eventName: AppEvents.Name##AppEvents.Name#>)
        // AppEventsLogger.activate(application)
        //        self.isReadytoQuit = false
        
        
        //        if UserDefaults.standard.value(forKey: "isFirstSession") == nil {
        
        
        application.applicationIconBadgeNumber = 0  // Remove Badge from app_Icon
        DispatchQueue.main.async {
            ImageReminder.sharedInstance.clearAllNotification()
        }
        let defaults = UserDefaults.standard
        if defaults.data(forKey: "pointAndColorArr") != nil
        {
            let outData = defaults.data(forKey: "pointAndColorArr")
            let dict = NSKeyedUnarchiver.unarchiveObject(with: outData!)as![PointAndColor]
            if #available(iOS 10.0, *) {
                
                DBHelper.sharedInstance.updateTuple(imageId: defaults.string(forKey: "imageId")!, pointColorTuple: dict, imageName: defaults.string(forKey: "name")!, isCallFromHome: false)
                
            } else {
                // Fallback on earlier versions
            }
            UserDefaults.standard.set(nil, forKey: "pointAndColorArr")
            defaults.synchronize()
        }
        
        AppEvents.activateApp()
        print("BECOME_ACTIVE")
        DispatchQueue.global(qos: .background).async {
            
            self.fetchPlistFile()
            self.fetchExplorePlistFile()
        }
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is PagesVC
            {
               if backgroundOrientation {
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "sync_images_new_popular"), object: nil)
                }
               }
            }
        }
        //        // To refresh pagesVC...Abhishek
        //        if (self.isReloadNeeded == true){
        //            self.refreshPagesVCView ()
        //        }
        
        
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        //        self.isReadytoQuit = false
        
        UserDefaults.standard.set(0, forKey: "sessionTime")
        UserDefaults.standard.synchronize()
        self.stopTimerSession()
        self.saveContext()
        //        DispatchQueue.main.async {
        //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "Reminder_For_InComplete_Image"), object: nil)
        //        }
        
        self.setInCompleteImageReminder()
    }
    
    // MARK: - Core Data stack
    
    @available(iOS 10.0, *)
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PL2")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if #available(iOS 10.0, *) {
            let context = persistentContainer.viewContext
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    // let nserror = error as NSError
                    // fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
                }
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    func getDirectoryPath() -> String {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
    func getImage(imgName: String?, imageId: String, isThumb:Bool = true) -> UIImage?{
        
        let imgN = "t_"+imgName!
        //        if(isThumb == false)
        //        {
        //            imgN = imgName!
        //        }
        let dirImgN = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgN)
        // let dirImgName = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName!)
        /*
         let fileManager = FileManager.default
         let imagePAth = (self.getDirectoryPath() as NSString).appendingPathComponent(imgN)
         if fileManager.fileExists(atPath: imagePAth){
         return UIImage(contentsOfFile: imagePAth)!
         }else{*/
        
        var shouldLoadFromasset = true
        
        if #available(iOS 10.0, *) {
            let dbHelper = DBHelper.sharedInstance
            if let img = dbHelper.getThumbImage(imageId: imageId, imageName: imgName!){
                shouldLoadFromasset = false
                return img
            }
            
        } else {
            // Fallback on earlier versions
        }
        
        if(shouldLoadFromasset)
        {
            //var img = UIImage()
            if FileManager.default.fileExists(atPath: dirImgN){
                
                return UIImage(contentsOfFile:dirImgN)!
                
            }
            else if let img = UIImage(named: imgN){
                return convert.convertImageToGrayScale(image:img)
            }
            else if let img = UIImage(named: imgName!){
                return convert.convertImageToGrayScale(image:img)
            }
            else
            {
                return nil
            }
            
        }
        
    }
    
    
    
    func getExploreImage(imgName: String) -> UIImage?{
        let dirImgN = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName)
        if FileManager.default.fileExists(atPath: dirImgN){
            
            return UIImage(contentsOfFile:dirImgN)!
            
        }
        else if let img = UIImage(named: imgName){
            return img
        }
        else
        {
            return nil
        }
    }
    
    
    func purchaseType() -> PurchasType{
        if let _ = UserDefaults.standard.value(forKey: subscription_purchase){
            return PurchasType.kPurchaseTypeWeekSubscription
        }
        else if let _ = UserDefaults.standard.value(forKey: non_consumable_purchase){
            return PurchasType.kPurchaseTypeNonConsumable
        }
        return PurchasType.kPurchasTypeNone
    }
    
    func savePurchase(purchaseType:PurchasType){
        switch purchaseType {
        case PurchasType.kPurchaseTypeNonConsumable:
            UserDefaults.standard.set("YES", forKey: non_consumable_purchase)
            break;
        case PurchasType.kPurchaseTypeWeekSubscription:
            self.handleSubscription(type:1)
            break;
        case PurchasType.kPurchaseTypeMonthSubscription:
            self.handleSubscription(type:2)
            break;
        case PurchasType.kPurchaseTypeYearSubscription:
            self.handleSubscription(type:3)
            break;
        default:
            print("error")
        }
        UserDefaults.standard.synchronize()
    }
    
    
    func handleSubscription(type: Int)
    {
        UserDefaults.standard.set("YES", forKey: subscription_purchase)
        UserDefaults.standard.set("NO", forKey: is_expired)
    }
    
    //MARK: Auto Renew Purchase
    func checkForPurchaseStatus()
    {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
            IAPViewController.shared.verifySubscriptions([.pl2sp,.pl2wk, .pl2mo, .pl2mods, .pl2yr])
        }
        /*
         if (UserDefaults.standard.object(forKey: "EXPIRE_INTENT") != nil)
         {
         let expirationIntent = UserDefaults.standard.integer(forKey: "EXPIRE_INTENT")
         print("EXPIRATION INTENT==",expirationIntent)
         if expirationIntent != 1
         {
         if (UserDefaults.standard.object(forKey: subscription_purchase) != nil)
         {
         let date = Date()
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd hh:mm:ss a"//yyyy-MM-dd HH:mm:ss VV
         //formatter.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale!
         
         let currentDateString = formatter.string(from: date)
         if (UserDefaults.standard.object(forKey: expiration_date) != nil)
         {
         let expirationDateString = UserDefaults.standard.value(forKey: expiration_date) as! String
         print("Current Date String==\(currentDateString),Expiration Date String==\(expirationDateString)")
         
         let currentDate = formatter.date(from: currentDateString)!
         let expirationDate = formatter.date(from: expirationDateString)!
         print("Current Date==\(currentDate),Expiration Date==\(expirationDate)")
         
         if currentDate > expirationDate
         {
         print("Expired")
         UserDefaults.standard.removeObject(forKey: expiration_date)
         UserDefaults.standard.set("YES", forKey: is_expired)
         IAPHandler.shared.receiptValidation()
         }
         else if currentDate < expirationDate
         {
         print("Subscription running")
         IAPHandler.shared.receiptValidation()
         }
         else
         {
         print("Equal dates")
         }
         }
         }
         }
         }
         */
    }
    
    //MARK: GET PODUCT DETAIL
    func getProductDetail()
    {
        UserDefaults.standard.set("YES", forKey: "FETCH_PRODUCT_ONLY")
        IAPHandler.shared.fetchAvailableProducts()
    }
    
    //MARK: Firebase Analytics Logs
    
    func logEvent(name:String, category:String, action:String)
    {
        print(name, category, action)
        Analytics.logEvent(name, parameters: [
            "category": category as String,
            "action": action as String
        ])
        
    }
    
    
    
    
    
    
    
    func logScreen(name:String)
    {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: name])
    }
    
    
    //MARK: - CloudCoreErrorDelegate Methods
    
    func cloudCore(saveToCloudDidFailed error: Error){
        
    }
    
    func saveRecordsToCloud(){
        
        //        CloudCore.fetchAndSave(container: self.persistentContainer, error: { (error) in
        //            print(error)
        //        }) {
        //
        //        }
    }
    
    func serverPlistPath() -> String? {
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("ImagesProperty.plist")
        return paths
        
    }
    
    func fetchPlistFile()
    {
        let recordID = CKRecordID(recordName:"plist")
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            
            let fileData = record.object(forKey: "data") as! Data
            
            // print("The user record is: \(fileData)")
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("ImagesProperty.plist")
            
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: paths){
                do {
                    try fileManager.removeItem(atPath:paths)
                }
                catch let error as NSError {
                    // print("Ooops! Something went wrong: \(error)")
                    self.logEvent(name: "Error_plist", category: "appdelegate", action: "error_dl")
                }
            }
            
            fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            self.isReloadNeeded = true
            //print("The user record is: \(record)")
            
            print("self.isReloadNeeded = true")
        }
        
    }
    
    func serverExplorePlistPath() -> String? {
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("explore.plist")
        return paths
    }
    
    func fetchExplorePlistFile()
    {
        let recordID = CKRecordID(recordName:"explore")
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            let fileData = record.object(forKey: "data") as! Data
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("explore.plist")
            print(paths)
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: paths){
                do {
                    try fileManager.removeItem(atPath:paths)
                }
                catch let error as NSError {
                    print("Ooops! Something went wrong: \(error)")
                }
            }
            fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            DispatchQueue.main.async {
                self.isReloadExploreNeeded = true
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_explore"), object: nil)
            }
        }
        
    }
    
    func ServerBounsPlistPath(fileName:String) -> String? {
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fileName+".plist")
        return paths
        
    }
    
    func fetchBonusPlistFile(fileName:String, completion: @escaping (Bool,String) -> ()) {
        
        
        let fName = fileName+".plist" //ToDo
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(fName)
        
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: paths){
            completion(true,"success")
            return;
        }
        
        let recordID = CKRecordID(recordName:fileName)
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                var bonusPendingArray = UserDefaults.standard.stringArray(forKey: BONUS_NOT_CLAIMED) ?? [String]()
                bonusPendingArray.remove(at:0)
                UserDefaults.standard.set(bonusPendingArray, forKey: BONUS_NOT_CLAIMED)
                
                completion(false,error!.localizedDescription)
                return
                
            }
            
            let fileData = record.object(forKey: "data") as! Data
            
            //print("The user record is: \(fileData)")
            
            fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            completion(true,"success")
            self.isReloadNeeded = true
        }
        
    }
    
    
    func fetchFile(name:NSString)
    {
        
        let recordID = CKRecordID(recordName:name.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            
            let fileData = record.object(forKey: "data") as! Data
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name as String)
            
            let fileManager = FileManager.default
            
            if !fileManager.fileExists(atPath: paths){
                fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            }
            
            //print("The user record is: \(record)")
        }
        
    }
    
    //MARK: Tab Bar Controller delegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController)
    {
        if viewController.isKind(of: UINavigationController.self)
        {
            let navController = viewController as! UINavigationController
            if navController.viewControllers[0].isKind(of: PagesVC.self)
            {
                self.logEvent(name: "navigation_pages", category: "Navigation", action: "Pages Button")
            }
            else if navController.viewControllers[0].isKind(of: MyWorkVC.self)
            {
                self.logEvent(name: "navigation_mywork", category: "Navigation", action: "My Work Button")
            }
            else if navController.viewControllers[0].isKind(of: NewsVC.self)
            {
                self.logEvent(name: "navigation_news", category: "Navigation", action: "News Button")
            }
            else if navController.viewControllers[0].isKind(of: ExploreViewController.self)
            {
                self.logEvent(name: "navigation_news", category: "Navigation", action: "News Button")
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_explore"), object: nil)
            }
        }
        else if viewController.isKind(of: SettingsViewController.self)
        {
            self.logEvent(name: "navigation_settings", category: "Navigation", action: "Settings Button")
        }
        
        //        if viewController.isKind(of: ExploreViewController.self)
        //        {
        //
        //            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_explore"), object: nil)
        //        }
    }
    
    //MARK:- FIREBASE NOTIFICATION REGISTRATION
    func registrationForPushNotification(application:UIApplication)
    {
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            //            UNUserNotificationCenter.current().requestAuthorization(
            //                options: authOptions,
            //                completionHandler: {_, _ in })
            
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions) { (_, _) in
                    
                    if #available(iOS 10.0, *) {
                        UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                            
                            switch setttings.authorizationStatus{
                            case .authorized:
                                let notiStaus = UserDefaults.standard.integer(forKey: notificationStatus)
                                print("enabled notification setting :- \(notiStaus)")
                                if(notiStaus == 2 || notiStaus == 0){
                                    self.logEvent(name: "note_enable", category: " notification", action: " notification enable")
                                    UserDefaults.standard.setValue(1,forKey: notificationStatus)
                                    UserDefaults.standard.synchronize()
                                }
                                if let rootViewController = UIApplication.topViewController() {
                                    if rootViewController is ExploreViewController{
                                        self.exploreVC = (rootViewController as! ExploreViewController)
                                        if self.exploreVC != nil {
                                            self.exploreVC.showNewPaintBucketInfoPopup()
                                        }
                                    }
                                    
                                }
                            case .denied:
                                let notiStaus = UserDefaults.standard.integer(forKey: notificationStatus)
                                print("setting has been disabled :- \(notiStaus)")
                                if(notiStaus == 1 || notiStaus == 0){
                                    self.logEvent(name: "note_disable", category: " notification", action: " notification disable")
                                    UserDefaults.standard.setValue(2,forKey: notificationStatus)
                                    UserDefaults.standard.synchronize()
                                }
                                if let rootViewController = UIApplication.topViewController() {
                                    if rootViewController is ExploreViewController{
                                        self.exploreVC = (rootViewController as! ExploreViewController)
                                        if self.exploreVC != nil {
                                            self.exploreVC.showNewPaintBucketInfoPopup()
                                        }
                                    }
                                    
                                }
                            case .notDetermined:
                                print("Notification authorizationStatus notDetermined")
                            case .provisional:
                                print("Notification authorizationStatus provisional")
                            case .ephemeral:
                                print("Notification authorizationStatus ephemeral")
                            }
                        }
                    } else {
                        
                        let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
                        if isNotificationEnabled == true{
                            print("enabled notification setting")
                            
                            if(self.pagesVC != nil){
                                self.pagesVC.showNewPaintBucketInfoPopup()
                            }
                        }else{
                            print("setting has been disabled")
                            if(self.pagesVC != nil){
                                self.pagesVC.showNewPaintBucketInfoPopup()
                            }
                        }
                    }
                }
            // For iOS 10 data message (sent via FCM
            Messaging.messaging().delegate = self
        } else {
            let settings: UIUserNotificationSettings =
            UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        application.registerForRemoteNotifications()
    }
    
    func checkPushNotification(checkNotificationStatus isEnable : ((Bool)->())? = nil){
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().getNotificationSettings(){ (setttings) in
                
                switch setttings.authorizationStatus{
                case .authorized:
                    
                    let notiStaus = UserDefaults.standard.integer(forKey: notificationStatus)
                    print("enabled notification setting :- \(notiStaus)")
                    if(notiStaus == 2 || notiStaus == 0){
                        self.logEvent(name: "note_enable", category: " notification", action: " notification enable")
                        UserDefaults.standard.setValue(1,forKey: notificationStatus)
                        UserDefaults.standard.synchronize()
                    }
                    
                    isEnable?(true)
                case .denied:
                    let notiStaus = UserDefaults.standard.integer(forKey: notificationStatus)
                    print("setting has been disabled :- \(notiStaus)")
                    if(notiStaus == 1 || notiStaus == 0){
                        self.logEvent(name: "note_disable", category: " notification", action: " notification disable")
                        UserDefaults.standard.setValue(2,forKey: notificationStatus)
                        UserDefaults.standard.synchronize()
                    }
                    
                    isEnable?(false)
                case .notDetermined:
                    
                    print("something vital went wrong here")
                    isEnable?(false)
                case .provisional:
                    isEnable?(false)
                    
                case .ephemeral:
                    isEnable?(false)
                    
                }
            }
        } else {
            
            let isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
            if isNotificationEnabled == true{
                
                print("enabled notification setting")
                isEnable?(true)
                
            }else{
                
                print("setting has been disabled")
                isEnable?(false)
            }
        }
    }
    
    
    
    
    // The callback to handle data message received via FCM for devices running iOS 10 or above.
    //    func application(received remoteMessage: MessagingRemoteMessage) {
    //        print(remoteMessage.appData)
    //    }
    
    //MARK: Rotation Allow on Specific Controller
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        let userInterface = UIDevice.current.userInterfaceIdiom
        
        if(userInterface == .pad)
        {
            return UIInterfaceOrientationMask.all
        }
        else
        {
            return UIInterfaceOrientationMask.portrait
        }
        
    }
    
    func isLandscapeByMe() -> Bool
    {
        if UIApplication.shared.statusBarOrientation == .landscapeLeft || UIApplication.shared.statusBarOrientation == .landscapeRight || UIApplication.shared.statusBarOrientation.isLandscape
        {
            return true
        }
        else
        {
            return false
        }
    }
    //MARK: Rotation Detection Method
    @objc func rotated() {
        
        let interfaceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        if UIDeviceOrientationIsLandscape(interfaceOrientation)
        {
            if (UserDefaults.standard.value(forKey: "LAST_ORIENTATION") != nil)
            {
                let intOrintation = UserDefaults.standard.value(forKey: "LAST_ORIENTATION") as! Int
                if intOrintation != 1
                {
                    print("Landscape")
                    self.refreshOrintationView()
                }
            }
            else
            {
                print(" Else Landscape")
                self.refreshOrintationView()
            }
            UserDefaults.standard.set(1, forKey: "LAST_ORIENTATION")
            UserDefaults.standard.synchronize()
        }
        else if UIDeviceOrientationIsPortrait(interfaceOrientation)
        {
            if (UserDefaults.standard.value(forKey: "LAST_ORIENTATION") != nil)
            {
                let intOrintation = UserDefaults.standard.value(forKey: "LAST_ORIENTATION") as! Int
                if intOrintation != 2
                {
                    print("Portrait")
                    self.refreshOrintationView()
                }
            }
            else
            {
                print(" Else Portrait")
                self.refreshOrintationView()
            }
            UserDefaults.standard.set(2, forKey: "LAST_ORIENTATION")
            UserDefaults.standard.synchronize()
        }
    }
    
    //    //MARK: Reload PagesVC when plist size changed...Abhishek
    //    func  refreshPagesVCView()
    //    {
    //        if let rootViewController = UIApplication.topViewController() {
    //            if rootViewController is PagesVC
    //            {
    //                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "reload_change_pages"), object: nil)
    //            }
    //        }
    //
    //    }
    
    //MARK: Rotation Detection Method
    func  refreshOrintationView()
    {
        
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is PagesVC
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_pages"), object: nil)
            }
            else if rootViewController is MyWorkVC
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myWorkSynced"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_pages"), object: nil)
            }
            else if rootViewController is GifTutorialVC//TutorialViewController
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "totorial_refresh"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_pages"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myWorkSynced"), object: nil)
            }
            else if rootViewController is ExploreViewController
            {
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_explore"), object: nil)
            }
            else if rootViewController is PlayVideoVC
            {
                
                // NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_explore"), object: nil)
            }
            
            else
            {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "pagesView_Initilaize"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_pages"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orientation_change_homevc"), object: nil)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "myWorkSynced"), object: nil)
            }
        }
    }
    
    //MARK:- Check Notifiucation Enabled or Not
    func checkForRemoteNotificationIsEnabled()
    {
        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        if isRegisteredForRemoteNotifications
        {
            // User is registered for notification
            if let rootViewController = UIApplication.topViewController() {
                if rootViewController is ExploreViewController
                {
                    self.exploreVC = (rootViewController as! ExploreViewController)
                    if( self.exploreVC != nil){
                        self.exploreVC.exploreCollectionView.isUserInteractionEnabled = false
                        self.exploreVC.showNewPaintBucketInfoPopup()
                        
                    }
                }
            }
            else if(pagesVC != nil){
                self.pagesVC.showNewPaintBucketInfoPopup()
            }
        }
        else
        {
            // Show alert user is not registered for notification
            let notificationEnabled = UserDefaults.standard.integer(forKey: notification_enabled)
            if notificationEnabled == 3
            {
                let dateLater = UserDefaults.standard.object(forKey: "LimitReachedOnDate") as? NSDate ?? NSDate.distantFuture as NSDate
                let dateCurrent = Date() //Calendar.current.date(byAdding: .day, value: 7, to: Date())
                let diffInDays = Calendar.current.dateComponents([.day], from: dateLater as Date as Date, to: dateCurrent).day
                if diffInDays == 3
                {
                    self.askForNotificationView()
                }
                else {
                    if let rootViewController = UIApplication.topViewController() {
                        if rootViewController is ExploreViewController
                        {
                            self.exploreVC = (rootViewController as! ExploreViewController)
                            if( self.exploreVC != nil){
                                self.exploreVC.exploreCollectionView.isUserInteractionEnabled = false
                                self.exploreVC.showNewPaintBucketInfoPopup()
                                
                            }
                        }
                    }
                    //                    if(pagesVC != nil){
                    //                        self.pagesVC.showNewPaintBucketInfoPopup()
                    //                    }
                    
                }
            }
            else if notificationEnabled == 2
            {
                self.askForNotificationView()
            }
            else if notificationEnabled == 0
            {
                self.askForNotificationView()
            }
            else {
                if let rootViewController = UIApplication.topViewController() {
                    if rootViewController is ExploreViewController
                    {
                        self.exploreVC = (rootViewController as! ExploreViewController)
                        if( self.exploreVC != nil){
                            self.exploreVC.exploreCollectionView.isUserInteractionEnabled = false
                            self.exploreVC.showNewPaintBucketInfoPopup()
                        }
                    }
                }
                
                //                if(pagesVC != nil){
                //                    self.pagesVC.showNewPaintBucketInfoPopup()
                //                }
            }
        }
    }
    
    
    
    
    //MARK:- Notification Ask View
    func askForNotificationView()
    {
        if isNotificationViewVisible == 0
        {
            if let rootViewController = UIApplication.topViewController() {
                if rootViewController is ExploreViewController
                {
                    self.exploreVC = (rootViewController as! ExploreViewController)
                    if( self.exploreVC != nil){
                        self.exploreVC.exploreCollectionView.isUserInteractionEnabled = false
                    }
                }
            }
            self.logEvent(name: "Notification_Window", category: "Notification", action: "ask For Notification")
            isNotificationViewVisible = 1
            let screenSize: CGRect = UIScreen.main.bounds
            self.notificationAskView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
            self.notificationAskView.backgroundColor = UIColor.clear
            self.notificationAskView.alpha = 1.0
            self.window?.rootViewController?.view.addSubview(self.notificationAskView)
            
            var width_white : CGFloat = 300
            var height_white : CGFloat = 431
            let offset : CGFloat = 10
            var fontSizeWithBold : UIFont = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight(rawValue: 0.7))
            var fontSizeWithNormalBold : UIFont = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight(rawValue: 0.7))
            var fontSizeWithNormal : UIFont = UIFont.systemFont(ofSize: 12.0)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                width_white = 500
                height_white = 718
                fontSizeWithBold = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight(rawValue: 0.7))
                fontSizeWithNormalBold = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight(rawValue: 0.7))
                fontSizeWithNormal = UIFont.systemFont(ofSize: 20.0)
                if (self.window?.frame.width)! > (self.window?.frame.height)!{
                    width_white = height_white/1.436
                    height_white = (self.window?.frame.height)! * 0.75
                }
                
            }
            let x_white : CGFloat = (screenSize.width - width_white) / 2
            let y_white : CGFloat = (screenSize.height - height_white) / 2
            
            let whiteRect = CGRect(x: x_white, y: y_white, width: width_white, height: height_white)
            var crossButtonRect = CGRect(x: offset, y: offset, width: offset*3, height: offset*3)
            var tipsLblRect = CGRect(x: 0, y: (height_white - offset) / 2, width: width_white, height: offset*7)
            var yesButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 55, width: width_white - (offset*8), height: offset*6)
            var laterButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 125, width: width_white - (offset*8), height: offset*6)
            var imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                crossButtonRect = CGRect(x: offset, y: offset, width: offset*4, height: offset*4)
                tipsLblRect = CGRect(x: 0, y: height_white / 2, width: width_white, height: offset*9)
                yesButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 95, width: width_white - (offset*14), height: offset*9)
                laterButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 205, width: width_white - (offset*14), height: offset*9)
                imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
                
                if (self.window?.frame.width)! > (self.window?.frame.height)!{
                    print("landscape")
                    crossButtonRect = CGRect(x: offset*6, y: offset, width: offset*4, height: offset*4)
                    
                    yesButtonRect = CGRect(x: offset*7, y: (height_white * 0.62), width: width_white - (offset*14), height: offset*9)
                    laterButtonRect = CGRect(x: offset*7, y: (height_white * 0.78), width: width_white - (offset*14), height: offset*9)
                }
                
                
            }
            
            //TransParent View
            let blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            blackView.backgroundColor = UIColor.black
            blackView.alpha = 0.3
            self.notificationAskView.addSubview(blackView)
            
            //WhiteView
            let whiteView = UIView(frame: whiteRect)
            self.notificationAskView.addSubview(whiteView)
            self.notificationAskView.bringSubview(toFront: whiteView)
            
            //BackgroundImage
            var bgImage: UIImage!
            var notificationTextString: String!
            
            bgImage = UIImage(named: "note1_iphone")
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                bgImage = UIImage(named: "note1_ipad_v")
            }
            notificationTextString = NSLocalizedString("Do you want to get notified\nwhen there are new pictures ready?", comment: "")
            
            let tipsImageView = UIImageView(frame: imageRect)
            tipsImageView.image = bgImage
            tipsImageView.contentMode = .scaleAspectFit
            whiteView.addSubview(tipsImageView)
            
            //CancelButton
            let crossButton = UIButton(frame: crossButtonRect)
            crossButton.setImage(UIImage(named: "cancel_subs"), for: UIControlState.normal)
            crossButton.addTarget(self, action:#selector(self.removeNotificationView), for: .touchUpInside)
            whiteView.addSubview(crossButton)
            whiteView.bringSubview(toFront: crossButton)
            //TextLabel
            let alertLabel = UILabel(frame: tipsLblRect)
            alertLabel.text = notificationTextString
            alertLabel.textAlignment = NSTextAlignment.center
            alertLabel.textColor = UIColor.black
            alertLabel.numberOfLines = 3
            alertLabel.font = fontSizeWithNormal
            whiteView.addSubview(alertLabel)
            
            //YES button
            let yesButton = UIButton(frame: yesButtonRect)
            yesButton.setTitle(NSLocalizedString("YES", comment: ""), for: UIControlState.normal)
            yesButton.setTitleColor(UIColor.white, for: UIControlState.normal)
            yesButton.titleLabel?.numberOfLines = 1
            yesButton.titleLabel?.textAlignment  = NSTextAlignment.center
            yesButton.titleLabel?.font =  fontSizeWithBold
            yesButton.addTarget(self, action:#selector(yesButtonClicked), for: .touchUpInside)
            whiteView.addSubview(yesButton)
            
            //Later Button
            let laterButton = UIButton(frame: laterButtonRect)
            laterButton.setTitle(NSLocalizedString("Maybe Later", comment: ""), for: UIControlState.normal)
            laterButton.setTitleColor(UIColor.gray, for: UIControlState.normal)
            laterButton.titleLabel?.numberOfLines = 1
            laterButton.titleLabel?.textAlignment  = NSTextAlignment.center
            laterButton.titleLabel?.font =  fontSizeWithNormalBold
            laterButton.addTarget(self, action:#selector(laterButtonClicked), for: .touchUpInside)
            whiteView.addSubview(laterButton)
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                self.notificationAskView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            }, completion:  nil)
        }
    }
    
    //MARK:- Cacncelled Clicked Notification Ask View
    @objc func removeNotificationView()
    {
        print("CANCELLED CLICKED")
        UserDefaults.standard.set(NSDate(), forKey: "LimitReachedOnDate")
        UserDefaults.standard.set(2, forKey: self.notification_enabled)
        self.removeView()
        
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ExploreViewController
            {
                self.exploreVC = (rootViewController as! ExploreViewController)
                if( self.exploreVC != nil){
                    self.exploreVC.showNewPaintBucketInfoPopup()
                }
            }
        }
    }
    
    
    
    //MARK:- Remove Notification Ask View
    func askForNotificationViewChangeOrientation()
    {
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
            let screenSize: CGRect = UIScreen.main.bounds
            self.notificationAskView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        }, completion: { (finished: Bool) in
            self.isNotificationViewVisible = 0
            self.notificationAskView.removeFromSuperview()
            self.askForNotificationView()
        })
    }
    
    
    //MARK:- Remove Notification Ask View
    func removeView()
    {
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ExploreViewController
            {
                self.exploreVC = (rootViewController as! ExploreViewController)
                if( self.exploreVC != nil){
                    self.exploreVC.exploreCollectionView.isUserInteractionEnabled = true
                    
                    
                }
            }
        }
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
            let screenSize: CGRect = UIScreen.main.bounds
            self.notificationAskView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        }, completion: { (finished: Bool) in
            self.isNotificationViewVisible = 0
            self.notificationAskView.removeFromSuperview()
        })
    }
    
    //MARK:- YES button Clicked
    @objc func yesButtonClicked()
    {
        
        self.logEvent(name: "Note_YES", category: "Notification", action: "Yes Button")
        UserDefaults.standard.set(1, forKey: notification_enabled)
        self.removeView()
        UserDefaults.standard.set(true, forKey: isPermissionCodeExecute)
        self.registrationForPushNotification(application: UIApplication.shared)
        
        //        if self.pagesVC != nil {
        //            self.pagesVC.showGifTutorialVC()
        //        }
    }
    
    //MARK:- Later button Clicked
    @objc func laterButtonClicked()
    {
        self.logEvent(name: "Note_LATER", category: "Notification", action: "Later Button")
        UserDefaults.standard.set(NSDate(), forKey: "LimitReachedOnDate")
        UserDefaults.standard.set(3, forKey: notification_enabled)
        self.removeView()
        
        if let rootViewController = UIApplication.topViewController() {
            if rootViewController is ExploreViewController
            {
                self.exploreVC = (rootViewController as! ExploreViewController)
                if( self.exploreVC != nil){
                    self.exploreVC.showNewPaintBucketInfoPopup()
                }
            }
        }
        
    }
    
    func CheckisFirstSession()
    {
        let defaults = UserDefaults.standard
        if defaults.value(forKey: "isFirstSession") == nil{
            defaults.set(true, forKey: "isFirstSession")
        }
        else{
            defaults.set(false, forKey: "isFirstSession")
            
        }
        defaults.synchronize()
    }
    
    
    
    // Get FCM registration token
    //    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    //        //let newToken = InstanceID.instanceID().token()
    //        // print("Device Token : "+newToken!)
    //    }
    
    
    
    
    func showUpdateApp() {
        let alertController = UIAlertController (title: "PixelColor Update", message: "A newer version of the app is available. Would you like to upgrade?", preferredStyle: .alert)
        let firstAction = UIAlertAction(title: "Update", style: .default, handler: UpgradeHandler)
        alertController.addAction(firstAction)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1;
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertController, animated: true, completion: nil)
        
    }
    func UpgradeHandler(alert: UIAlertAction!) {
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1277229792"),
           UIApplication.shared.canOpenURL(url)
        {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    //NSLocalizedString("copied", comment: "")
    
    // to do Handel notification when Tapped
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        
        // Notification tapped shoaib
        let userInfo = response.notification.request.content.userInfo
        print(userInfo)
        
        let imageData = ImageData()
        if let isLocalNotification = userInfo["isLocalNotification"] {
            
            if let categoryID = userInfo["category"] {
                imageData.category = categoryID as? String
            }
            if let imageId = userInfo["imageId"] {
                imageData.imageId = imageId as? String
            }
            if let name = userInfo["name"] {
                imageData.name = name as? String
                
            }
            if let level = userInfo["level"] {
                imageData.level = level as? String
                
            }
            if let position = userInfo["position"] {
                imageData.position = position as? Int
                
            }
            if let purchase = userInfo["purchase"] {
                imageData.purchase = purchase as? Int
                
            }
            imageDataNotification = imageData
            isNotificationTap = true
            UserDefaults.standard.set(true, forKey: SHOW_SUBSCRIPTION)
            let tabBarController = window?.rootViewController as! UITabBarController
            tabBarController.selectedIndex = 0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(2)) {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load_home_page"), object: imageData)
            }
            
        }
        
        
        completionHandler()
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        //displaying the ios local notification when app is in foreground
        completionHandler([.alert, .badge, .sound])
    }
    
    func setInCompleteImageReminder()
    {
        // Mystery Window issue after notifications
        // let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        // if isRegisteredForRemoteNotifications {
        
        var completedID = [String]()
        let defaults = UserDefaults.standard
        
        if defaults.array(forKey: "mywork_completed_id") != nil {
            completedID = (defaults.array(forKey: "mywork_completed_id")  as? [String])!
        }
        
        let dbHelper = DBHelper.sharedInstance
        var imageArrayTemp = dbHelper.getMyWorkImages()
        var tempImageData = [ImageData]()
        
        //Remove Complete Data.
        for imageDataTemp in imageArrayTemp
        {
            if (!completedID.contains(imageDataTemp.imageId!))
            {
                tempImageData.append(imageDataTemp)
            }
        }
        imageArrayTemp = tempImageData
        tempImageData.removeAll()
        //End
        
        var assignNotiCount = 1
        var imageDataItemObject = [ImageDataItem]()
        var imageDataItemId = [String]()
        var doneString = UserDefaults.standard.string(forKey: "doneNotificationString") ?? ""
        
        var doneStringArray = [String]()
        if doneString != "" {
            doneStringArray = self.stringToStringArray(value: doneString)
        }
        if imageArrayTemp.count > 0 {
            for index in 0...imageArrayTemp.count-1 {
                if assignNotiCount <= MAX_NOTIFICATION_COUNT {
                    if !(doneString.contains(imageArrayTemp[index].imageId!)) {
                        imageDataItemObject.append(ImageDataItem(imageId: imageArrayTemp[index].imageId!, category: imageArrayTemp[index].category!,name: imageArrayTemp[index].name!, UUID: UUID().uuidString, level: imageArrayTemp[index].level!, position: imageArrayTemp[index].position!, purchase: imageArrayTemp[index].purchase!))
                        imageDataItemId.append(imageArrayTemp[index].imageId!)
                        doneStringArray.append(imageArrayTemp[index].imageId!)
                        assignNotiCount += 1
                    }
                }
            }
        }
        
        print(imageDataItemObject.count)
        if imageDataItemObject.count < MAX_NOTIFICATION_COUNT {
            
            UserDefaults.standard.set("", forKey: "doneNotificationString")
            doneStringArray = imageDataItemId
            doneString = self.stringArrayToString(value: imageDataItemId)
            if imageArrayTemp.count > 0 {
                for index in 0...imageArrayTemp.count-1 {
                    if assignNotiCount <= MAX_NOTIFICATION_COUNT {
                        if !(doneString.contains(imageArrayTemp[index].imageId!)) {
                            imageDataItemObject.append(ImageDataItem(imageId: imageArrayTemp[index].imageId!, category: imageArrayTemp[index].category!,name: imageArrayTemp[index].name!, UUID: UUID().uuidString, level: imageArrayTemp[index].level!, position: imageArrayTemp[index].position!, purchase: imageArrayTemp[index].purchase!))
                            imageDataItemId.append(imageArrayTemp[index].imageId!)
                            doneStringArray.append(imageArrayTemp[index].imageId!)
                            assignNotiCount += 1
                        }
                    }
                }
            }
        }
        
        let saveString = self.stringArrayToString(value: doneStringArray)
        UserDefaults.standard.set(saveString, forKey: "doneNotificationString")
        print("Save string : \(saveString)")
        print(imageDataItemObject)
        
        var timeDelay = timeDelayValue
        for sendObject in imageDataItemObject {
            ImageReminder.sharedInstance.addNotificationItem(sendObject, timeValue: timeDelay)
            timeDelay += timeDelayValue
        }
        
        // }
    }
    
    func stringArrayToString(value:[String]) -> String{
        return value.joined(separator: ",")
    }
    
    func stringToStringArray(value:String) -> [String]{
        return value.components(separatedBy: ",")
    }
    
    
    
    //    func application(_ application: UIApplication, continue userActivity: NSUserActivity,
    //                     restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
    //      let handled = DynamicLinks.dynamicLinks().handleUniversalLink(userActivity.webpageURL!) { (dynamiclink, error) in
    //        // ...
    //      }
    //
    //      return handled
    //    }
    
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool {
        return application(app, open: url,
                           sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                           annotation: "")
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        print(url)
        if DynamicLinks.dynamicLinks().dynamicLink(fromCustomSchemeURL: url) != nil {
            
            print(url)
            // Handle the deep link. For example, show the deep-linked content or
            // apply a promotional offer to the user's account.
            // ...
            return true
        }
        return false
    }
    
    
    //MARK:- getCategoryFromProperityList
    func getExploreDataFromImagesCategory() {
        imagesCategoryArray.removeAll()
        if let path = Bundle.main.path(forResource: "ImagesCategory", ofType: "plist") {
            if let array = NSArray(contentsOfFile: path) as? [String]
            {
                imagesCategoryArray = array
            }
        }
    }
    
    //MARK:- getExploreImages
    func getExploreImages(name:String){
        
        let thumName = NSString(format:"%@",name)
        let recordID = CKRecordID(recordName:thumName.deletingPathExtension)
        
        let fileManager = FileManager.default
        let pathsForTImages = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(thumName as String)
        
        if !fileManager.fileExists(atPath: pathsForTImages) {
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
                guard let record = record, error == nil else {
                    return
                }
                if let fileData = record.object(forKey: "data") as? Data {
                    //                    print("Download _t image name : \(name) from server complete")
                    fileManager.createFile(atPath: pathsForTImages, contents: fileData, attributes: nil)
                }
            }
        }
        
        let recordID2 = CKRecordID(recordName:thumName.deletingPathExtension)
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name as String)
        if !fileManager.fileExists(atPath: paths){
            CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID2) { record, error in
                guard let record = record, error == nil else {
                    return
                }
                let fileData = record.object(forKey: "data") as! Data
                if !fileManager.fileExists(atPath: paths){
                    //                    print("Download image name : \(name) from server complete")
                    fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
                }
            }
        }
        
    }
    
}




extension UIApplication {
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        
        if let tab = base as? UITabBarController {
            let moreNavigationController = tab.moreNavigationController
            
            if let top = moreNavigationController.topViewController, top.view.window != nil {
                return topViewController(base: top)
            } else if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
}

// Manage Window Popup for OS 13.1.3 on app launch
extension UIAlertController {
    func present(animated: Bool, completion: (() -> Void)?) {
        windowPopup = UIWindow(frame: UIScreen.main.bounds)
        windowPopup.rootViewController = UIViewController()
        windowPopup.windowLevel = 2000.0
        windowPopup.makeKeyAndVisible()
        windowPopup.rootViewController?.present(self, animated: animated, completion: completion)
        
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        windowPopup = nil
    }
}

