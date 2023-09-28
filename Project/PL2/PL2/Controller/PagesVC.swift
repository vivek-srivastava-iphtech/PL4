//
//  PagesVC.swift
//
//  PL2
//  Created by iPHTech12 on 17/11/2017.
//


import UIKit
import WebKit
import SVProgressHUD
import GoogleMobileAds
import SystemConfiguration
import FBSDKCoreKit
import iAd
import AdSupport
import FirebaseRemoteConfig
import CloudKit
import AppTrackingTransparency

enum kCollectionViewType {
    case kCollectionViewIntial
    case kCollectionViewLeft
    case kCollectionViewRight
}

enum kViewMode {
    case kViewInitial
    case kViewModeClaim
}



class PagesVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, UIWebViewDelegate, UICollectionViewDelegateFlowLayout, PagesViewDelegate,CongratulationVCDelegate,NoConnectionVCDelegate, UIScrollViewDelegate, DailyGiftViewControllerDelegate, RewardedAdHelperDelegate, InterstitialAdHelperDelegate  {
    
    var categoriesArray = [String]()
    var sourceDict = [String: [ImageData]]()
    var currentSourceDict = [String: [ImageData]]()
    var currentLevelsArray = [String]()
  
    
    var index = Int()
    var selectedCategoryIndex = 0
    var prevSelectedIndex = 0
    
    var isHelpViewVisible = 0
    var isSubscriptionViewVisible = 0
    
    var dullView = UIView()
    var loadLaunchView : UIView!
    let tagVal = 100
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var iapView : UIView!
    var iapSubscriptionView : UIView!
    var helpView : UIView!
    var timerReceipt : Timer?
    
    let STARTER_PRODUCT_ID = "com.moomoolab.pl2sp"
    let WEEK_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2wk"
    var MONTH_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2mo"
    let YEAR_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2yr"
    
    
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var categoryCollectionViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageViewBottom: NSLayoutConstraint!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var unlockImageLabeliPad: UILabel!
    @IBOutlet weak var unlockImageLabeliPhone: UILabel!
    @IBOutlet weak var freeTrailButton: UIButton!
    @IBOutlet weak var freeTrailButtoniPad: UIButton!
    @IBOutlet weak var middleView: UIView!
    
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var topCollectionView: UICollectionView!
    @IBOutlet weak var currentPage: UIPageControl!
    @IBOutlet weak var topDisplayViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var topDisplayView: UIView!
    @IBOutlet weak var middleViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topDisplayViewHeightConstraint: NSLayoutConstraint!
    
    
    let appdel = UIApplication.shared.delegate as! AppDelegate
    
    let TEST_UNIT_ID = "ca-app-pub-3940256099942544/1712485313"
    let REWARDED_AD_ID = "ca-app-pub-7682495659460581/8735943137"

    //MARK: Reward Ad Helper
    private var rewardedAdHelper = RewardedAdHelper()
    
    //MARK: Inhetitance Ad Helper
    private var interstitialAdHelper = InterstitialAdHelper()
    // Replace this with new Add-Id
    let INTERSTITIAL_AD_ID = "ca-app-pub-7682495659460581/2271863322"
    
    //NEW:"ca-app-pub-7682495659460581~6281920678"
    //OLD:"ca-app-pub-7682495659460581/4701355397"
    fileprivate var rewardBasedVideo: GADRewardedAd?
    
    var adRequestInProgress = false
    var shouldShowRewardedVideo = false
    var currentDate :Date!
    var _imageData : ImageData!
    var subscriptionVC: SubscriptionVC?
    var congratulationVC: CongratulationsVC!
    var noConnectionVC: NoConnectionVC!
    let npCategory: String! = "New"
    let bonusCategory: String! = "Bonus"
    let pCategory: String! = "Popular"
    var isClaimClicked = false;
    var tipsView : UIView!
    var isHintPaintVisible = 0
    var isreward :Bool = true;
    var bonusArray = UserDefaults.standard.stringArray(forKey: BONUS) ?? [String]()
    var isSubscriptionVC :Bool = false
    var isSubscriptionMode :Bool = false
    var launchSubscriptionType:Int = 0 // 1 Launch, 2 Banner, 3 LockThumb
    //  var interstitialFB:ADInterstitialAd!
    var imageViewHeightValue = 50
    var imageDataTutorial : ImageData!
    var isVideoViewOpen = false
    
    var mode = 0
    var topCollectionLabel = ["Pink","Art", "Wonderland", "Desserts", "Hearts", "Wreaths", "Zen Garden"]
    let topWindowsCategoryArray = ["Pink","art" , "Wonderland", "Desserts", "hearts", "Wreaths", "Zen Garden"]
    var isTopShowOrNot = false
    
    var topCollectionScrollIndexValue = [Int]()
    var topDisplayViewHeightValue = -1
    
    var remoteConfig: RemoteConfig!
    var isAppJustLunch = "YES"

    var isTopScrollVisible = false
    //imageId = category + level + name
    
    var selectedPurchaseType = 1 // 0 weekly,1 Monthly,2 yearly
        var monthSubsView:UIView?
        var weekSubsView:UIView?
        var yearSubsView:UIView?
    
    //MARK: -Initial
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //     var IDFA = UUID()
        //     if ASIdentifierManager.shared().isAdvertisingTrackingEnabled {
        //     IDFA = ASIdentifierManager.shared().advertisingIdentifier
        //     }
        
        indicator.startAnimating()
        indicator.transform = CGAffineTransform(scaleX: 2, y: 2)
        let currentLaunch = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        let detectAppVersionValue = UserDefaults.standard.bool(forKey: detectAppVersion)
        if detectAppVersionValue == false && currentLaunch == 1 {
            UserDefaults.standard.set(true, forKey: detectAppVersion)
            UserDefaults.standard.set("New", forKey: detectAppType)
            UserDefaults.standard.set(true, forKey:"isNewPaintBucketInfoShow")
        }
        else if detectAppVersionValue == false && currentLaunch > 1 {
            UserDefaults.standard.set(true, forKey: detectAppVersion)
            UserDefaults.standard.set("Old", forKey: detectAppType)
            UserDefaults.standard.set(true, forKey:"isNewPaintBucketInfoShow")
        }
        
        
        //MARK: Fetch rewardTime, reward_tools, interstitialTime, reminder_time, reminder_time1 and  current_tool_window values.
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        if(currentLaunch == 1){
            fetchConfig()
        }
        // self.checkForTheLaunchCounter()
        
        getSearchAdsInfo()
        
        // shoaib Interstitial ads 12 Dec //
        // let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        //if(isExpired == "YES" || isExpired == nil){
        
        
        //}
        
        index = 0
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.logEvent(name: "navigation_pages", category: "Navigation", action: "Pages Button")
        
        //        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        //        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        //        self.view.addGestureRecognizer(swipeRight)
        //        self.appdel.pagesVC = self
        //        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(respondToSwipeGesture))
        //        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        //        self.view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.middleView.addGestureRecognizer(swipeRight)
        self.appdel.pagesVC = self
        let swipeLeft = UISwipeGestureRecognizer(target: self, action:  #selector(respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.middleView.addGestureRecognizer(swipeLeft)
        
        self.categoryCollectionView.delegate   = self
        self.categoryCollectionView.dataSource = self
        
        self.categoryCollectionView.contentInset = UIEdgeInsets.zero
        self.categoryCollectionView.register(UINib(nibName: "CategoryCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "catecell")
        
        self.categoryCollectionView.layoutIfNeeded()
        self.reloadView()
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadIAP(notification:)), name: NSNotification.Name(rawValue: "orientation_change_pages"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncImages(notification:)), name: NSNotification.Name(rawValue: "sync_images_new_popular"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(changeSlectedCategoryIndex(notification:)), name: NSNotification.Name(rawValue: "show_selected_category"), object: nil)
        
        //Reload pages when plist change into appdelegate...Abhishek
        //        NotificationCenter.default.addObserver(self, selector: #selector(reload(notification:)), name: NSNotification.Name(rawValue: "reload_change_pages"), object: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(redirectToHome(notification:)), name: NSNotification.Name(rawValue: "load_home_page"), object: nil)
        // NotificationCenter.default.addObserver(self, selector: #selector(setReminderForInCompleteImage), name: NSNotification.Name(rawValue: "Reminder_For_InComplete_Image"), object: nil)
        
        if (appDelegate.isReloadNeeded){
            
            self.reloadView()
        }
        
        //Start downloading first.
        timerForInitialDelay?.invalidate()
        timerForInitialDelay = nil
        timerForInitialDelay = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.performFetch), userInfo:nil, repeats:false)
        
        if let pagesView = self.view.viewWithTag(selectedCategoryIndex+tagVal) as? PagesView {
            pagesView.collectionView?.reloadData()
        }
        
        
        // let autoLogAppEventsEnabled = FBSDKSettings.autoLogAppEventsEnabled()
        // print(autoLogAppEventsEnabled)
        
        self.imageView.isHidden = true
        
        self.setStatusBarColor(color: #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            
            let layout: UICollectionViewFlowLayout = topCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
            layout.minimumLineSpacing = 9
            layout.minimumInteritemSpacing = 0
            
            // self.topDisplayViewHeightConstraint.constant = 228.352
            self.topDisplayViewHeightConstraint.constant = 0
            categoryCollectionViewHeight.constant = 50
            
        }
        else {
            let layout: UICollectionViewFlowLayout = topCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.sectionInset = UIEdgeInsets(top: 0, left: 6, bottom: 0, right: 6)
            layout.minimumLineSpacing = 15
            layout.minimumInteritemSpacing = 0
            
            //            if self.view.frame.height > self.view.frame.width {
            //                self.topDisplayViewHeightConstraint.constant = self.view.frame.height * 0.223
            //            }
            //            else {
            //                self.topDisplayViewHeightConstraint.constant = self.view.frame.width * 0.223
            //            }
            
            let deviceType = UIDevice.current.deviceType
            
            if deviceType == .iPhones_5_5s_5c_SE {
                // topDisplayViewHeightConstraint.constant = 126.664
                topDisplayViewHeightConstraint.constant = 0
            }
            else {
                //topDisplayViewHeightConstraint.constant = 148.741
                topDisplayViewHeightConstraint.constant = 0
            }
            categoryCollectionViewHeight.constant = 42
            
        }
        
        
        headerViewMinHeight = -(self.topDisplayViewHeightConstraint.constant+8)
        
        let unlockAllPictureString = NSLocalizedString("UNLOCK ALL PICTURES", comment: "")
        unlockImageLabeliPhone.text = unlockAllPictureString
        unlockImageLabeliPhone.adjustsFontSizeToFitWidth = true
        unlockImageLabeliPad.text = unlockAllPictureString
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            freeTrailButton.setTitle(NSLocalizedString("Begin Now", comment: ""), for: UIControlState.normal)
            freeTrailButtoniPad.setTitle(NSLocalizedString("Begin Now", comment: ""), for: UIControlState.normal)
        }
        else{
            freeTrailButton.setTitle(NSLocalizedString("FREE TRIAL", comment: ""), for: UIControlState.normal)
            freeTrailButtoniPad.setTitle(NSLocalizedString("FREE TRIAL", comment: ""), for: UIControlState.normal)
        }
        unlockImageLabeliPad.adjustsFontSizeToFitWidth = true
        
        freeTrailButton.titleLabel!.adjustsFontSizeToFitWidth = true
        freeTrailButtoniPad.titleLabel!.adjustsFontSizeToFitWidth = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(rewardBasedVideoAdWillLeaveApplication), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillResignActive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appBecomesActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        
        let isAdTrackingPromptAuthorizationValue = UserDefaults.standard.bool(forKey: isAdTrackingPromptAuthorization)
        
        if #available(iOS 14.0, *) {
            if let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType) {
                if detectAppTypeValue == "New" && !isAdTrackingPromptAuthorizationValue {
                    
                    timerForComplianceWindowFetch?.invalidate()
                    timerForComplianceWindowFetch = nil
                    timerForComplianceWindowFetch = Timer.scheduledTimer(timeInterval: 5.0, target:self, selector:#selector(loadWithOutLiveValues), userInfo:nil, repeats:false)
                    
                }
            }
        }
        
        
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    func dismissRewardedAd() {
    }
    
    func dismissIntersialAd() {
        
    }
    
    func showReward(rewardAmount: String, status: String) {
        if status == "Success" {
            print("Reward ad received for Pages Screen")
            print("Pages VC - RewardAD ID : \(PAGES_MY_WORK_REWARD_Id)")

            
        }
        else {
            print("Please try Again PG RW!")
            self.appDelegate.logEvent(name: "No_Reward_PG", category: "Ads", action: "PG")
//            let callActionHandler = { (action:UIAlertAction!) -> Void in
//              //  self.backToView(
//            }
//            let alertController = UIAlertController(title: "Please try Again PV RW!", message: nil, preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
//            alertController.addAction(defaultAction)
//            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    func showInterstitialMessage(message: String, status: String) {
        if status == "Success" {
            print("Intersial ad received for Pages Screen")
            print("Pages VC - IntersialAD ID : \(INTERSIAL_AD_Unit_Id)")

        }
        else {
            print("Please try Again PG IT!")
            self.appDelegate.logEvent(name: "No_IT_PG", category: "Ads", action: "PG")
//            let callActionHandler = { (action:UIAlertAction!) -> Void in
//              //  self.backToView()
//            }
//            let alertController = UIAlertController(title: "Please try Again PV IT!", message: nil, preferredStyle: .alert)
//            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
//            alertController.addAction(defaultAction)
//            self.present(alertController, animated: true, completion:nil)
        }
    }

    
    
    var isNedToComplianceShow = "0"

    @objc func loadWithOutLiveValues() {
        
        timerForComplianceWindowFetch?.invalidate()
        timerForComplianceWindowFetch = nil

        if(self.loadLaunchView != nil){
            self.loadLaunchView.removeFromSuperview()
        }

        if isNedToComplianceShow == "0" {
            isNedToComplianceShow = "1"
            appdel.showComplianceWindow()
        }
    }


    deinit {
         NotificationCenter.default.removeObserver(self)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
         NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
     }
     
     @objc func appBecomesActive() {
         
         if isTopScrolllingApplied == false {
             
             if let rootViewController = UIApplication.topViewController() {
                 if rootViewController is PagesVC
                 {
                     applyTopViewScrolling()
                 }
             }
         }
         
     }
     
     @objc func appWillResignActive() {
         removeTopViewScrolling()
     }
    
    //    // method to reload from appdelegate ....abhishek
    //    @objc func reload(notification: NSNotification) {
    //
    //        self.reloadView()
    //    }
    //
    
    //    @objc func setReminderForInCompleteImage(notification: NSNotification){
    //        DispatchQueue.main.async {
    //            self.setInCompleteImageReminder()
    //        }
    //
    //    }
    
    @objc func updateFrame() {
       
        var image = UIImage(named: "page_sub1-iphone")
        if UIDevice.current.userInterfaceIdiom == .pad {
            self.unlockImageLabeliPad.isHidden = false
            self.unlockImageLabeliPhone.isHidden = true
           
            self.freeTrailButtoniPad.isHidden = false
            self.freeTrailButton.isHidden = true
            
            if UIDevice.current.orientation.isLandscape {
                image = UIImage(named: "page_sub1-ipadh")
                self.unlockImageLabeliPad.font = UIFont.systemFont(ofSize: CGFloat(26), weight: .semibold)
            }
            else {
                image = UIImage(named: "page_sub1-ipadv")
                self.unlockImageLabeliPad.font = UIFont.systemFont(ofSize: CGFloat(24), weight: .semibold)
            }
        }
        else {
            self.unlockImageLabeliPad.isHidden = true
            self.unlockImageLabeliPhone.isHidden = false
            
            self.freeTrailButtoniPad.isHidden = true
            self.freeTrailButton.isHidden = false
        }
        let ratio = image!.size.width / image!.size.height
        let newHeight = self.view.frame.width / ratio
        self.imageViewHeight.constant = newHeight
        self.imageView.image = image
        self.imageViewHeightValue = Int(newHeight)
        self.imageViewBottom.constant = CGFloat(-newHeight)
        
    }

//    @objc func redirectToHome(notification: NSNotification){
//        if(appDelegate.imageDataNotification != nil){
//            self.appDelegate.logEvent(name: "Launch_app_notification", category: "Notification", action: "Tapping the Notification")
//            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//            vc.imageData = appDelegate.imageDataNotification
//            self.navigationController?.pushViewController(vc, animated: true);
//        }
//
//    }
    
    override func viewDidDisappear(_ animated: Bool) {
        appDelegate.imageDataNotification =  nil
        hideBottomImage()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateFrame()
        self.imageView.isHidden = false
        let topDisplayViewHeight = self.topDisplayView.frame.height
        self.topDisplayViewHeightValue = Int(topDisplayViewHeight)
        self.freeTrailButtoniPad.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        self.freeTrailButton.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        
    }
    
   
    
    var topTimer: Timer?
    var isTopScrolllingApplied = false
    var topCounter = 0
    
    var timer: Timer?
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        timer?.invalidate()
        timer = nil
        if(appDelegate.pagesVC != nil){
        timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateFrame), userInfo:nil, repeats:false)
        }
        
    }
    
    @objc func loadIAP(notification: NSNotification) {
        if isSubscriptionViewVisible == 1
        {
            self.iapSubscriptionView.removeFromSuperview()
            self.addIAPSubscriptionView()
        }
        
        if (isHintPaintVisible == 1 && self.tipsView != nil)
        {
            self.tipsView.removeFromSuperview()
            self.isHintPaintVisible = 0
            self.addNoInternetView()
        }
        
        if(appDelegate.isNotificationViewVisible == 1)
        {
            appDelegate.askForNotificationViewChangeOrientation()
        }
        
        if isPaintBucketDisplay == true {

            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                {
                    let screenSize: CGRect = UIScreen.main.bounds
                    self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
            }, completion: { (finished: Bool) in
                self.tipsView.removeFromSuperview()
                self.showNewPaintBucketInfoPopup()
            })

        }
        
        if let pagesView = self.view.viewWithTag(selectedCategoryIndex+tagVal) as? PagesView {
            // to do bottom white space Shoaib // note always showing from top
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now())
            {
                // self.reloadView()
                self.reloadInitilaViewOnForeground(kType: kCollectionViewType.kCollectionViewIntial)
                // pagesView.collectionView?.reloadData()
                
            }
        }
        self.topCollectionView.reloadData()
        let topDisplayViewHeight = self.topDisplayView.frame.height
        self.topDisplayViewHeightValue = Int(topDisplayViewHeight)
        
        self.middleViewBottomConstraint.constant = -topDisplayViewHeight
        
        
        print("loadIAP shoaib")
    }
    //search ads
    func getSearchAdsInfo(){
        ADClient.shared().requestAttributionDetails({ (attributionDetails, error) in
            if error == nil {
                for (_, adDictionary) in attributionDetails! {
                    let attribution = adDictionary as? Dictionary<AnyHashable, Any>;
                    let params = [
                        "appID": "self.appData.appID",
                        "iadAdgroupId": attribution?["iad-adgroup-id"] as? String as Any,
                        "iadAdgroupName": attribution?["iad-adgroup-name"] as? String as Any,
                        "iadAttribution": attribution?["iad-attribution"] as? String  as Any,
                        "iadCampaignId": attribution?["iad-campaign-id"] as? String as Any,
                        "iadCampaignName": attribution?["iad-campaign-name"] as? String as Any,
                        "iadClickDate": attribution?["iad-click-date"] as? String as Any,
                        "iadConversionDate": attribution?["iad-conversion-date"] as? String as Any,
                        "iadCreativeId": attribution?["iad-creative-id"] as? String as Any,
                        "iadCreativeName": attribution?["iad-creative-name"] as? String as Any,
                        "iadKeyword": attribution?["iad-keyword"] as? String as Any,
                        "iadLineitemId": attribution?["iad-lineitem-id"] as? String as Any,
                        "iadLineitemName": attribution?["iad-lineitem-name"] as? String as Any,
                        "iadOrgName": attribution?["iad-org-name"] as? String as Any
                        
                    ]
                    print(params)
                }
            }
        })
    }
    
    //Mark: Sync New & Popular Images
    @objc func syncImages(notification: NSNotification) {
        if selectedCategoryIndex == 0
        {
            self.reloadView()
            reloadInitilaViewOnForeground(kType: kCollectionViewType.kCollectionViewIntial)
        }
    }
//    // check second lanunch
//    func checkForTheLaunchCounter() {
//
//        self.loadLaunchView = UIView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height))
//        self.loadLaunchView.backgroundColor = .white
//        let logo = UIImageView(frame: CGRect(x:0,y:0,width:self.loadLaunchView.frame.size.width,height:self.loadLaunchView.frame.size.height))
//        logo.image = self.launchImage()
//        self.loadLaunchView.addSubview(logo)
//        UIApplication.shared.keyWindow?.insertSubview(self.loadLaunchView!, at: self.view.subviews.count)
//
//        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
//        let isShowSubs = UserDefaults.standard.bool(forKey: SHOW_SUBSCRIPTION)
//
//        let isAdTrackingPromptAuthorizationValue = UserDefaults.standard.bool(forKey: isAdTrackingPromptAuthorization)
//        let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType)
//        let isKillByForceKey = UserDefaults.standard.string(forKey: isKillByForce)
//        let isComplianceDoneValue = UserDefaults.standard.bool(forKey: isComplianceDone)
//
//        if (launchCount >= 2 && isShowSubs == true) {
//
//            if #available(iOS 14.0, *) {
//                if (detectAppTypeValue == "New" || detectAppTypeValue == "Old" ) && isAdTrackingPromptAuthorizationValue {
//
//                    if isKillByForceKey == "1" {
//                        self.showComplianceWindowForQuitReason()
//                    }
//                    else {
//                        showSubscriptionView()
//                    }
//                }
//                else if (detectAppTypeValue == "New" || detectAppTypeValue == "Old" ) && !isAdTrackingPromptAuthorizationValue {
//
//                    if isKillByForceKey == "1" {
//                        self.showComplianceWindowForQuitReason()
//                    }
//                    else if !isComplianceDoneValue && detectAppTypeValue == "New" {
////                        self.loadWithOutLiveValues()
//                    }
//                    else {
//                        if(self.loadLaunchView != nil){
//                            self.loadLaunchView.removeFromSuperview()
//                        }
//                        showSubscriptionView()
//                    }
//                }
//            }
//            else {
//
//                if isKillByForceKey == "1" {
//
//                    self.loadLaunchView.removeFromSuperview()
//                    appdel.ShowComplianceWindow1()
//                }
//                else if !isComplianceDoneValue && detectAppTypeValue == "New" {
////                    self.loadWithOutLiveValues()
//                }
//                else {
//                    showSubscriptionView()
//                }
//
//            }
//
//        } else {
//
//            if #available(iOS 14.0, *) {
//                if (detectAppTypeValue == "New" || detectAppTypeValue == "Old" ) && isAdTrackingPromptAuthorizationValue {
//                    if(self.loadLaunchView != nil){
//                        self.loadLaunchView.removeFromSuperview()
//                    }
//                }
//                else if launchCount >= 2 {
//                    if(self.loadLaunchView != nil){
//                        self.loadLaunchView.removeFromSuperview()
//                    }
//                }
//            }
//            else {
//                if(self.loadLaunchView != nil){
//                    self.loadLaunchView.removeFromSuperview()
//                }
//            }
//        }
//    }
    
    
    func showComplianceWindowForQuitReason() {

        self.loadLaunchView.removeFromSuperview()

        let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType)
        if detectAppTypeValue == "Old" {
            appdel.currentWindowString = "comp_win_1"
        }
        else if detectAppTypeValue == "New" {
            //Eliminate fetching compliance_window value from remote config, the default will be used for "New" that is "com_win_2"
        }

        if appdel.currentWindowString == "comp_win_1" {
            appdel.ShowComplianceWindow1()
        }
        else if appdel.currentWindowString == "comp_win_2" {
            appdel.ShowComplianceWindow2()
        }
    }

//    func showSubscriptionView() {
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//            self.isSubscriptionVC = true
//            self.launchSubscriptionType = 1
//            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
//            if(isExpired == "YES" || isExpired == nil){
//                UserDefaults.standard.set(false, forKey: SHOW_SUBSCRIPTION)
//                self.appDelegate.logEvent(name: "Launch_Subscription_window", category: "Subscription", action: "Free Trial Button")
//                self.subscriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionVC") as? SubscriptionVC
//                self.subscriptionVC?.loadViewIfNeeded()
//                self.isSubscriptionMode = true
//                self.addIAPSubscriptionView(mode: 1)
//            }
//            else
//            {
//                if(self.loadLaunchView != nil)
//                {
//                    self.loadLaunchView.removeFromSuperview()
//                    if(self.appDelegate.imageDataNotification != nil){
//                        DispatchQueue.main.async {
//                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//                            vc.imageData = self.appDelegate.imageDataNotification
//                            self.navigationController?.pushViewController(vc, animated: true)
//                            //self.appDelegate.imageDataNotification = nil // need to check
//                        }
//                    }
//                }
//            }
//        }
//
//
//
//    }
//
    
    func isICloudContainerAvailable()->Bool {
        if let currentToken = FileManager.default.ubiquityIdentityToken {
            return true
        }
        else {
            return false
        }
    }
    
    func reloadInitilaViewOnForeground(kType:kCollectionViewType)
    {
        
        let topDisplayViewHeight = self.topDisplayView.frame.height
        
        self.middleViewBottomConstraint.constant = -topDisplayViewHeight
        
        reloadCurrentData(categoryName: categoriesArray[selectedCategoryIndex])
        
        let pagesView = PagesView()
        //        pagesView.bounds = middleView.bounds
        pagesView.bounds = CGRect(x: middleView.bounds.minX, y: middleView.bounds.minY, width: middleView.bounds.width, height: middleView.bounds.height + topDisplayViewTopConstraint.constant)
        pagesView.frame.origin.x = 0.0
        pagesView.frame.origin.y = 0.0
        pagesView.alpha = 0.0
        pagesView.currentLevelsArray = self.currentLevelsArray
        pagesView.currentSourceDict = self.currentSourceDict
        pagesView.tag = tagVal + selectedCategoryIndex
        pagesView.initializeView()
        pagesView.delegate = self
        let previousPagesView = self.view.viewWithTag(tagVal+selectedCategoryIndex)
        if (previousPagesView != nil){
            previousPagesView?.removeFromSuperview()
        }
        middleView.addSubview(pagesView)
        pagesView.alpha = 1.0
        middleView.layoutIfNeeded()
       
    }
    
    //Mark: Receipt Update Method
    @objc func update()
    {
        if (UserDefaults.standard.object(forKey: "FIRST_RECEIPT") == nil)
        {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                IAPHandler.shared.receiptValidation()
                SVProgressHUD.dismiss()
            }
  
        }
        else
        {
            SVProgressHUD.dismiss()
            timerReceipt?.invalidate()
            timerReceipt = nil
        }
    }
    
    func reloadView(viewMode:kViewMode = .kViewInitial) {
        appDelegate.isReloadNeeded = false;
        //Parse the Asset Plist
        sourceDict.removeAll()
        categoriesArray.removeAll()
        //Parse the Server Plist
       
        if let path = appDelegate.serverPlistPath()
        {
            if let array = NSArray(contentsOfFile: path) as? [[String: Any]]
            {
                
                for arr in array {
                    let dict =  arr as NSDictionary
                    
                    
                    //Level 2 image logic.
                    //                    let categoryName  =  dict.value(forKey: "category") as! String
                    //                    let imageName      =     dict.value(forKey: "name") as! String
                    //
                    //                    var level :String = ""
                    //                    let gameLevel =     dict.value(forKey: "level")
                    //                    if let levels = gameLevel {
                    //                        level     =     String(describing:levels )
                    //                    }
                    //                    let imageId = categoryName+"_"+level+"_"+imageName
                    //
                    //                    let levelValue = dict.value(forKey: "level") as! Int
                    //                    if levelValue == 2 {
                    //                        if appDelegate.getImage(imgName: imageName, imageId: imageId) != nil {
                    //
                    //                        }
                    //                        else {
                    //                            print("Download image name : \(imageName) from server")
                    //                            DispatchQueue.global(qos: .background).async {
                    //                                self.loadServerImageFirst(name: "\(imageName)" as NSString)
                    //                            }
                    //                        }
                    //                    }
                    
                    self.getCategoryName(imageDict: dict)
                }
                
                let filteredNpItems = array.filter { $0["np"] != nil }
                let filteredLevelItems = array.filter { $0["np"] == nil }
                
                for arr in filteredNpItems
                {
                    let dict =  arr as NSDictionary
                    self.setImages(imageDict: dict)
                }
                
                for arr in filteredLevelItems
                {
                    let dict =  arr as NSDictionary
                    self.setImages(imageDict: dict)
                }
                
                //                for arr in array
                //                {
                //                    let dict =  arr as NSDictionary
                //                    self.setImages(imageDict: dict)
                //                }
            }
        }
        
        //Parse the Bonus Plist - ToDo Shoaib
        
        if (bonusArray.count > 0)
        {
            for pName in bonusArray{
                
                if let path = appDelegate.ServerBounsPlistPath(fileName: pName)
                {
                    if let array = NSArray(contentsOfFile: path) as? [[String: Any]]
                    {
                        for arr in array
                        {
                            let dict =  arr as NSDictionary
                            self.setImages(imageDict: dict)
                        }
                    }
                }
            }
        }
        
        if(sourceDict.count == 0)
        {
            if let path = Bundle.main.path(forResource: "imagesproperty", ofType: "plist")
            {
                if let array = NSArray(contentsOfFile: path) as? [[String: Any]]
                {
                    for arr in array
                    {
                        let dict =  arr as NSDictionary
                        self.setImages(imageDict: dict)
                    }
                }
            }
        }
        self.sortCategories()
        
        var data = categoriesArray.filter{!self.categoryStringArray.contains($0)}
        data.append(contentsOf: categoryStringArray)
        categoriesArray.removeAll()
        categoriesArray = data
        
        topCollectionScrollIndexValue.removeAll()
        for i in topWindowsCategoryArray {
            if let index = categoriesArray.index(of: i) {
                topCollectionScrollIndexValue.append(index)
            }
        }
        self.categoryCollectionView.reloadData()
        self.topCollectionView.reloadData()
        
        initializeForNextView(viewMode:viewMode)
        SVProgressHUD.dismiss()
        
    }
    
    
    func sortCategories()
    {
        var isBonus = false
        var isNp = false
        var isNew = false
        if(self.categoriesArray.contains(bonusCategory))
        {
            isBonus = true
        }
        if(self.categoriesArray.contains(npCategory))
        {
            isNp = true
        }
        if(self.categoriesArray.contains(pCategory))
        {
            isNew = true
        }
        
        
        // New Category
        if(isNp && isBonus && isNew)
        {
            self.setSortOrder(category: npCategory, position: 0)
            self.setSortOrder(category: pCategory, position: 1)
            self.setSortOrder(category: bonusCategory, position: 2)
        }
            
            
        else if(isNp && isNew  && isBonus == false)
        {
            self.setSortOrder(category: npCategory, position: 0)
            self.setSortOrder(category: pCategory, position: 1)
        }
        else if(isNp && isNew == false && isBonus == false)
        {
            self.setSortOrder(category: npCategory, position: 0)
            
        }
            
        else if(isNp && isNew == false && isBonus == true)
        {
            
            self.setSortOrder(category: npCategory, position: 0)
            self.setSortOrder(category: bonusCategory, position: 1)
            
        }
            
        else if(isNp  == false && isNew == false && isBonus == true)
        {
            self.setSortOrder(category: bonusCategory, position: 0)
        }
            
        else if(isNp  == false && isNew == true && isBonus == true)
        {
            self.setSortOrder(category: pCategory, position: 0)
            self.setSortOrder(category: bonusCategory, position: 1)
            
        }
    }
    
    
    var categoryStringArray = [String]()
    func getCategoryName(imageDict: NSDictionary) {
        
        let category  =  imageDict.value(forKey: "category") as! String
        
        if !categoryStringArray.contains(category) {
            categoryStringArray.append(category)
        }
        
    }
    
    func loadServerImageFirst(name: NSString) {
        
        let thumName = NSString(format:"t_%@",name)
        
        let recordID = CKRecordID(recordName:thumName.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            //print("\n\n\n  Server image loaded\n\n\n")
            if let fileData = record.object(forKey: "data") as? Data {
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(thumName as String)
                
                let fileManager = FileManager.default
                
                if !fileManager.fileExists(atPath: paths){
                    fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
                }
            }
            //print("The user record is: \(record)")
        }
        
        let recordID2 = CKRecordID(recordName:name.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID2) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            //print("\n\n\n  saving image to Server image\n\n\n")
            let fileData = record.object(forKey: "data") as! Data
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name as String)
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: paths){
                fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            }
            //print("The user record is: \(record)")
        }
    }
    
    
    
    
    func setSortOrder(category:String, position:Int) {
        let index = self.categoriesArray.firstIndex(of: category)
        if self.categoriesArray.contains(category){
            self.categoriesArray.remove(at: index!)
            self.categoriesArray.insert(category, at: position)
        }
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.generateCollectionView(kType: kCollectionViewType.kCollectionViewIntial)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if !UserDefaults.standard.bool(forKey: "firstImageShow") {

        tabBarController!.tabBar.isUserInteractionEnabled = false
        }
      //  indicator.stopAnimating()
//        let newHeaderViewHeight: CGFloat = topDisplayViewTopConstraint.constant
//            if self.imageViewBottom.constant != 0 {
//             UIView.animate(withDuration: 0.25) {
//                    self.topCollectionView.isHidden = true
//                    self.currentPage.isHidden = true
//                    self.view.layoutSubviews()
//                }
//            }
      
        if(isTopScrollVisible==false){
            UIView.animate(withDuration: 0.2) {
                self.topCollectionView.isHidden = true
                self.currentPage.isHidden = true
                self.view.layoutSubviews()
            }
        }
        
        
        
        if isTopScrolllingApplied == false {
            applyTopViewScrolling()
        }
        
        self.setStatusBarColor(color: #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1))
        
        self.navigationController?.isNavigationBarHidden = true;
        
        
        self.tabBarController?.tabBar.isHidden = false
        //ToDo Shoaib
        //  if(isSubscriptionVC == false){
        let bonusPendingArray = UserDefaults.standard.stringArray(forKey: BONUS_NOT_CLAIMED) ?? [String]()
        
        if bonusPendingArray.count > 0{
            self.showClaimPopup()
        }
        
        if (appDelegate.isReloadNeeded){
            
            self.reloadView()
        }
        
        
        if let pagesView = self.view.viewWithTag(selectedCategoryIndex+tagVal) as? PagesView {
            pagesView.collectionView?.reloadData()
        }
        
        //           if (UIDevice.current.userInterfaceIdiom == .pad){
        //            if let pagesView = self.view.viewWithTag(selectedCategoryIndex+tagVal) as? PagesView {
        //                // to do bottom white space Shoaib // note always showing from top
        //                  DispatchQueue.main.async {
        //                    self.reloadView()
        //                   self.reloadInitilaViewOnForeground(kType: kCollectionViewType.kCollectionViewIntial)
        //                   // pagesView.collectionView?.reloadData()
        //
        //                }
        //            }
        //        }
        //        else{
        //            if let pagesView = self.view.viewWithTag(selectedCategoryIndex+tagVal) as? PagesView {
        //                pagesView.collectionView?.reloadData()
        //            }
        //        }
        
        appDelegate.saveRecordsToCloud()
        
        if(self.isVideoViewOpen == true){
            self.PlayVideo()
        }
        
        if isAppJustLunch == "YES" {
            isAppJustLunch = "NO"

            addRewardAfter5Days()

           // let currentToolWindowKeyValue = UserDefaults.standard.string(forKey: currentToolWindowKey) ?? ""
            let currentToolWindowKeyValue = UserDefaults.standard.string(forKey: InActiveCurrentToolWindowKey) ?? ""
            if currentToolWindowKeyValue == "" {
                fetchDefaultConfigValue()
                activatePreviousFetchValues()
            }
//            else {
//                activatePreviousFetchValues()
//
//                //getConfigValueDB()
//            }


        }
        
        var shouldShowAds = self.adsShouldBeCalled()
        
        if UserDefaults.standard.value(forKey: "sessionTime") != nil
        {
            // Manage session time checks of 5 and 10 minutes to show Ads
            let sessionTime: Int = (UserDefaults.standard.value(forKey: "sessionTime") as? Int)!
            //#120. A/B testing: revert to prior ad logics
            if(sessionTime >= interstitialTime && sessionTime <= rewardTime )
            {
                isreward = false
            }else if(sessionTime >= rewardTime){
                isreward = true
            }
            else if(sessionTime < interstitialTime){// || (sessionTime >= rewardTime)){
                shouldShowAds = false
            }
        }
        
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if(isExpired == "YES" || isExpired == nil){
            
            if isreward
            {
                rewardedAdHelper.rewardId = PAGES_MY_WORK_REWARD_Id
                print("---- Pages Screen ----")
                rewardedAdHelper.loadRewardedAd(adId: PAGES_MY_WORK_REWARD_Id)
                rewardedAdHelper.delegate = self
            }
            else {
                print("---- Pages Screen ----")
                interstitialAdHelper.loadInterstitial()
                interstitialAdHelper.delegate = self
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.setStatusBarColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        removeTopViewScrolling()
    }
    
    
    
    func activatePreviousFetchValues(labelValue: String = "Activate previous fetch values") {
    
        
        let inActiveReminderTime = UserDefaults.standard.integer(forKey: inActiveReminderTimeKey)
        let InActiveReminderTime1 = UserDefaults.standard.integer(forKey: InActiveReminderTimeKey1)
        let InActiveRewardTools = UserDefaults.standard.integer(forKey: InActiveRewardToolsKey)
        let InActiveRewardTime = UserDefaults.standard.integer(forKey: InActiveRewardTimeKey)
        let InActiveInterstitialTime = UserDefaults.standard.integer(forKey: InActiveInterstitialTimeKey)
        let InActiveCurrentToolWindow = UserDefaults.standard.string(forKey: InActiveCurrentToolWindowKey) ?? ""
        let activeBombValue = UserDefaults.standard.integer(forKey: bomb_sActive)
        let colorNumberActive = UserDefaults.standard.integer(forKey: color_numberActive)
        let purchasessActive = UserDefaults.standard.integer(forKey: purchasessActiveKey)
        let activeNewWindowValue = UserDefaults.standard.integer(forKey: inactiveNewWindow)
        let inActiveMysteryWindowValue = UserDefaults.standard.integer(forKey: inactiveMysteryWindow)
       
        
        UserDefaults.standard.set(inActiveReminderTime, forKey: reminderTimeKey)
        UserDefaults.standard.set(InActiveReminderTime1, forKey: reminderTime1Key)
        UserDefaults.standard.set(InActiveRewardTools, forKey: rewardToolsKey)
        UserDefaults.standard.set(InActiveRewardTime, forKey: rewardTimeKey)
        UserDefaults.standard.set(InActiveInterstitialTime, forKey: interstitialTimeKey)
        UserDefaults.standard.set(InActiveCurrentToolWindow, forKey: currentToolWindowKey)
        UserDefaults.standard.set(colorNumberActive, forKey: color_number)
        UserDefaults.standard.set(activeBombValue, forKey: bomb_s)
        UserDefaults.standard.set(purchasessActive, forKey: purchasessKey)
        UserDefaults.standard.set(activeNewWindowValue, forKey: newWindow)
        UserDefaults.standard.set(inActiveMysteryWindowValue, forKey: mysteryWin)
        
        
        reminderTime = UserDefaults.standard.integer(forKey: reminderTimeKey)
        reminderTime1 = UserDefaults.standard.integer(forKey: reminderTime1Key)
        rewardTools = UserDefaults.standard.integer(forKey: rewardToolsKey)
        rewardTime = UserDefaults.standard.integer(forKey: rewardTimeKey)
        interstitialTime = UserDefaults.standard.integer(forKey: interstitialTimeKey)
        currentToolWindow = UserDefaults.standard.string(forKey: currentToolWindowKey) ?? ""
        colorNumber =  UserDefaults.standard.integer(forKey: color_number)
        bomb_sNumber =  UserDefaults.standard.integer(forKey: bomb_s)
        purchasess = UserDefaults.standard.integer(forKey: purchasessKey)
        new_windowNumber =  UserDefaults.standard.integer(forKey: newWindow)
        mysteryWinNumber = UserDefaults.standard.integer(forKey: mysteryWin)
        
        print("\(labelValue)\nrewardTime = \(rewardTime)\ninterstitialTime = \(interstitialTime)\ncurrent_tool_window = \(currentToolWindow)\nreminder_time1 = \(reminderTime1)\nreminder_time = \(reminderTime)\nrewardTools = \(rewardTools)\nColor_number = \(colorNumber)\nBomb_s = \(bomb_sNumber)\npurchase_ss = \(purchasess)\nnew_window = \(new_windowNumber)\nmystery_Win = \(mysteryWinNumber)")
        
    }
    
    
    //MARK: -Custom Methods
    
    func generateCollectionView(kType:kCollectionViewType) {
        
        if selectedCategoryIndex < 0 {
            selectedCategoryIndex = 0
        }
        else if selectedCategoryIndex > categoriesArray.count - 1 {
            selectedCategoryIndex = categoriesArray.count - 1
        }

        appDelegate.logScreen(name: categoriesArray[selectedCategoryIndex])
        let cuPagesView = self.view.viewWithTag(tagVal+selectedCategoryIndex)
     //   var isBones = false
        /*if(categoriesArray[selectedCategoryIndex] == bonusCategory)
         {
         isBones = true
         //if(isClaimClicked)
         //{
         cuPagesView = nil
         //}
         }*/
        if(cuPagesView == nil)
        {
            let screenSize = UIScreen.main.bounds
            let topbarHeight = 50.0 as CGFloat
            let bottomBarHeight = 49.0 as CGFloat
            var statusBarHeight = 20 as CGFloat
            // code for iphone x
            if #available(iOS 11.0, *) {
                statusBarHeight = 70
            }
            var viewHeight = screenSize.height - (topbarHeight + bottomBarHeight + statusBarHeight)
            
            let modelName = UIDevice.modelName
            if(modelName.contains("iPhone 6"))
            {
                viewHeight = viewHeight + 50
            }
            
            reloadCurrentData(categoryName: categoriesArray[selectedCategoryIndex])
            
            let pagesView = PagesView()
            //pagesView.frame = CGRect(x:0,y:0,width:screenSize.width,height:viewHeight)
            let topDisplayViewHeight = self.topDisplayView.frame.height
            
            self.middleViewBottomConstraint.constant = -topDisplayViewHeight
            
            //            pagesView.bounds = middleView.bounds
            pagesView.bounds = CGRect(x: middleView.bounds.minX, y: middleView.bounds.minY, width: middleView.bounds.width, height: middleView.bounds.height + topDisplayViewTopConstraint.constant)
            
            pagesView.frame.origin.x = 0.0
            pagesView.frame.origin.y = 0.0
            pagesView.alpha = 0.0
            pagesView.currentLevelsArray = self.currentLevelsArray
            pagesView.currentSourceDict = self.currentSourceDict
            pagesView.tag = tagVal + selectedCategoryIndex
            pagesView.initializeView()
            pagesView.delegate = self
            middleView.addSubview(pagesView)
            
            switch kType {
            case kCollectionViewType.kCollectionViewLeft:
                pagesView.frame = CGRect(x:-screenSize.width,y:0,width:screenSize.width,height:viewHeight)
                break;
            case kCollectionViewType.kCollectionViewRight:
                pagesView.frame = CGRect(x:screenSize.width,y:0,width:screenSize.width,height:viewHeight)
                break;
            default:
                pagesView.frame = CGRect(x:0,y:0,width:screenSize.width,height:viewHeight)
                /* if(isBones)
                 {
                 if(isClaimClicked)
                 {
                 isClaimClicked = false
                 pagesView.frame = CGRect(x:0,y:0,width:screenSize.width,height:viewHeight)
                 }else{
                 pagesView.frame = CGRect(x:screenSize.width,y:0,width:screenSize.width,height:viewHeight)
                 }
                 
                 
                 }else{
                 pagesView.frame = CGRect(x:0,y:0,width:screenSize.width,height:viewHeight)
                 }*/
            }
            pagesView.alpha = 1.0
            middleView.layoutIfNeeded()
            
            if prevSelectedIndex != selectedCategoryIndex
            {
                
                let previousPagesView = self.view.viewWithTag(tagVal+prevSelectedIndex)
                //Devendra changes 0.6 to 0.2
                UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations: {
                    
                    if (previousPagesView != nil){
                        
                        switch kType {
                        case kCollectionViewType.kCollectionViewLeft:
                            previousPagesView?.frame = CGRect(x:screenSize.width,y:0,width:screenSize.width,height:viewHeight)
                        case kCollectionViewType.kCollectionViewRight:
                            previousPagesView?.frame = CGRect(x:-screenSize.width,y:0,width:screenSize.width,height:viewHeight)
                        default:
                            previousPagesView?.frame = CGRect(x:0,y:0,width:screenSize.width,height:viewHeight)
                        }
                        
                    }
                    pagesView.frame = CGRect(x:0,y:0,width:screenSize.width,height:viewHeight)
                    
                }, completion: { (finished: Bool) in
                    if (previousPagesView != nil){
                        previousPagesView?.removeFromSuperview()
                    }
                })
            }
        }
        else
        {
            
            if let pagesView = self.view.viewWithTag(selectedCategoryIndex+tagVal) as? PagesView {
                pagesView.currentSourceDict = self.currentSourceDict
                pagesView.collectionView?.reloadData()
                
                if self.isSelectClick {
                    self.isSelectClick = false
                    pagesView.collectionView?.setContentOffset(CGPoint(x: 0, y: -self.topDisplayViewTopConstraint.constant), animated: false)
                }
                isNotTabChange = false
                
            }
        }
        
        prevSelectedIndex = selectedCategoryIndex
    }
    
    //ToDo Shoaib
    func showClaimPopup()
    {
        // if (UserDefaults.standard.value(forKey:tutKeyPageVC) != nil){
        
        if(self.congratulationVC != nil){
            self.congratulationVC.view.removeFromSuperview()
        }
        self.congratulationVC = self.storyboard?.instantiateViewController(withIdentifier: "CongratulationsVC") as! CongratulationsVC
        self.congratulationVC.congratulateVCDelegate = self
        self.congratulationVC.view.frame = UIScreen.main.bounds
//                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                   let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//                    mainWindow.addSubview(self.congratulationVC.view)
//                }
//
        if #available(iOS 13.0, *) {
            // Use connectedScenes for iOS 13.0 and later
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                mainWindow.addSubview(self.congratulationVC.view)
            }
        } else {
            // Use alternative approach for iOS 11.3 and earlier
            if let mainWindow = UIApplication.shared.keyWindow {
                mainWindow.addSubview(self.congratulationVC.view)
            }
        }
    }
    //ToDo Shoaib
    func showGifTutorialVC()
    {
        if (UserDefaults.standard.value(forKey:tutKeyPageVC) == nil){
            UserDefaults.standard.set("yes", forKey: tutKeyPageVC)
            UserDefaults.standard.set("yes", forKey: newPicker)
            UserDefaults.standard.synchronize()
            
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "GifTutorialVC") as! GifTutorialVC
            vc.loadFrom = "Pages"
            vc.gifTutorialCloseTappedDelegate = self
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc,animated:true,completion:nil)
        }
    }
    
    
    func crossBtnTappedDelegate(sender: UIButton) {
        
        self.congratulationVC.view.removeFromSuperview()
        
    }
    
    func claimBtnTappedDelegate(sender: UIButton) {
        
        self.claimDidTapped()
        self.congratulationVC.view.removeFromSuperview()
        
    }
    
    fileprivate func GetBonusPlist() {
        var bonusPendingArray = UserDefaults.standard.stringArray(forKey: BONUS_NOT_CLAIMED) ?? [String]()
        
        guard let bonus = bonusPendingArray.first else { return }
        
        SVProgressHUD.show()
        self.appDelegate.fetchBonusPlistFile(fileName: bonus) { (isCompleted,errorMessage) in
            if(isCompleted)
            {
                if(!self.bonusArray.contains(bonus)){
                    self.bonusArray.append(bonus)
                }
                bonusPendingArray.remove(at:0)
                UserDefaults.standard.set(bonusPendingArray, forKey: BONUS_NOT_CLAIMED)
                if(self.bonusArray.count > 0)
                {
                    UserDefaults.standard.set(self.bonusArray, forKey: BONUS)
                    DispatchQueue.main.async {
                        SVProgressHUD.dismiss()
                    }
                    
                }
                self.GetBonusPlist()
            }
            else{
                
                
                self.appDelegate.logEvent(name: "Error_bonus", category: "bonus", action: "try_again")
                DispatchQueue.main.async {
                    SVProgressHUD.dismiss()
                    let alertController = UIAlertController(title: "Please try again!", message: nil, preferredStyle: .alert)
                    // let alertController = UIAlertController(title: errorMessage, message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
            
            DispatchQueue.main.async {
                self.reloadView(viewMode:kViewMode.kViewModeClaim)
            }
        }
    }
    
    func claimDidTapped()
    {
        isClaimClicked = true
        bonusArray = UserDefaults.standard.stringArray(forKey: BONUS) ?? [String]()
        GetBonusPlist()
        
    }
    
    func reloadCurrentData(categoryName : String) {
        
        currentSourceDict.removeAll()
        
        let arrObj = sourceDict[categoryName]
        
        var newArrObj : [ImageData] = []

        if arrObj != nil {
            if(categoryName == "Popular")
            {
                newArrObj = (arrObj?.sorted(by: {$0.n > $1.n}))!
            }
            else{
                newArrObj = (arrObj?.sorted(by: {$0.np > $1.np}))!
            }
        }

        var filteredLevel2Items = newArrObj.filter { $0.level == "1" }
        if filteredLevel2Items.count == 0 {
            filteredLevel2Items = newArrObj.filter { $0.level == "2" }
        }
        
        for obj in filteredLevel2Items {
            
            let imgDataObj =  obj as ImageData
            let levelName : String = imgDataObj.level!
            
            if currentSourceDict[levelName] != nil {
                currentSourceDict[levelName]?.append(imgDataObj)
            }
            else
            {
                currentSourceDict[levelName] = [imgDataObj]
            }
            
            if !currentLevelsArray.contains(levelName){
                currentLevelsArray.append(levelName)
            }
            
        }
        
        let filteredLevel1Items = newArrObj.filter { $0.level == "2" }
        
        for obj in filteredLevel1Items {
            
            let imgDataObj =  obj as ImageData
            currentSourceDict["1"]?.append(imgDataObj)
        }
        
    }
    
    func createCollectionViewInScrollView(index:Int) {
        
        reloadCurrentData(categoryName: categoriesArray[index])
        
        // self.categoryCollectionView.selectItem(at: IndexPath(index:selectedCategoryIndex), animated: true, scrollPosition: UICollectionViewScrollPosition.left)
        
        let screenSize = UIScreen.main.bounds
        let topbarHeight = 50.0 as CGFloat
        let bottomBarHeight = 49.0 as CGFloat
        let viewHeight = screenSize.height - topbarHeight - bottomBarHeight
        let xVal = CGFloat(index*Int(screenSize.width))
        
        reloadCurrentData(categoryName: categoriesArray[selectedCategoryIndex])
        
        let pagesView = PagesView()
        pagesView.frame = CGRect(x:xVal,y:0,width:screenSize.width,height:viewHeight)
        pagesView.currentLevelsArray = self.currentLevelsArray
        pagesView.currentSourceDict = self.currentSourceDict
        pagesView.tag = tagVal + selectedCategoryIndex
        pagesView.initializeView()
        middleView.addSubview(pagesView)
        //middleView.contentSize = CGSize(width:xVal+screenSize.width,height:viewHeight)
    }
    
    func initializeForNextView(viewMode:kViewMode = .kViewInitial)
    {
        
        if(categoriesArray.count <= selectedCategoryIndex)
        {
            selectedCategoryIndex = 0
        }
        if(viewMode == .kViewModeClaim)
        {
            if self.categoriesArray.contains(bonusCategory)
            {
                prevSelectedIndex = selectedCategoryIndex
                selectedCategoryIndex = self.categoriesArray.firstIndex(of:bonusCategory)!
            }
        }
        
        reloadCurrentData(categoryName: categoriesArray[selectedCategoryIndex])
        
        let indexPath = IndexPath(item: selectedCategoryIndex, section: 0)
        self.categoryCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        self.categoryCollectionView.reloadData()
        
        if(viewMode == .kViewModeClaim)
        {
            self.refreshCollectionOnNotificationReceived()
        }
        
    }
    
    func setImages(imageDict: NSDictionary) {
        //print("imageDict")
        // print(imageDict)
        
        var level :String = ""
        let name      =     imageDict.value(forKey: "name") as! String
        let gameLevel =     imageDict.value(forKey: "level")
        if let levels = gameLevel {
            level     =     String(describing:levels )
        }
        
        let category  =  imageDict.value(forKey: "category") as! String
        let imageId   =     category+"_"+level+"_"+name
        let position =     imageDict.value(forKey: "position") as! Int
        let purchase =     imageDict.value(forKey: "purchase") as! Int
        
        
        //For New & Popular Category
        var np :Int = 0
        if imageDict.value(forKey: "np") != nil
        {
            np = imageDict.value(forKey: "np") as! Int
        }
        ///
        
        //For Popular
        var new :Int = 0
        if imageDict.value(forKey: "n") != nil
        {
            new = imageDict.value(forKey: "n") as! Int
        }
        ///
        
        let imageData = ImageData()
        imageData.imageId = imageId
        imageData.category = category
        imageData.name = name
        imageData.level = level
        imageData.position = position
        imageData.purchase = purchase
        imageData.np = np
        imageData.n = new
        
        if(imageDict.value(forKey: "isTutorial") != nil)
        {
            self.imageDataTutorial = imageData
        }
        
        
        
        
        let npCategory: String! = "New"
        
        let arrObj = [imageData]
        
        if sourceDict[category] != nil {
            
            sourceDict[category]?.append(imageData)
            
            
        }
        else
        {
            sourceDict[category] = arrObj
            
        }
        
        //For Popular Category
        if imageData.np > 0
        {
            
            if !categoriesArray.contains(npCategory){
                categoriesArray.append(npCategory)
            }
            
            if sourceDict[npCategory] != nil
            {
                sourceDict[npCategory]?.append(imageData)
            }
            else
            {
                sourceDict[npCategory] = arrObj
            }
        }
        ///
        
        let pCategory: String! = "Popular"
        //For New Category
        if imageData.n > 0
        {
            
            if !categoriesArray.contains(pCategory){
                categoriesArray.append(pCategory)
            }
            
            if sourceDict[pCategory] != nil
            {
                sourceDict[pCategory]?.append(imageData)
            }
            else
            {
                sourceDict[pCategory] = arrObj
            }
        }
        ///
        
        
        if !categoriesArray.contains(category){
            categoriesArray.append(category)
        }
        
    }
    
    
    //MARK: -Swipe Recognizer
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            
            prevSelectedIndex = selectedCategoryIndex
            
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                //print("Swiped right")
                self.isSelectClick = true
                selectedCategoryIndex = selectedCategoryIndex == 0 ? 0 : selectedCategoryIndex - 1;
                initializeForNextView()
                generateCollectionView(kType: kCollectionViewType.kCollectionViewLeft)
            case UISwipeGestureRecognizerDirection.left:
                //print("Swiped left")
                self.isSelectClick = true
                selectedCategoryIndex = (selectedCategoryIndex < (categoriesArray.count - 1)) ? selectedCategoryIndex + 1 : selectedCategoryIndex;
                initializeForNextView()
                generateCollectionView(kType: kCollectionViewType.kCollectionViewRight)
            default:
                break
            }
        }
    }
    
    
    //MARK: - CollectionView DataSource and Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if collectionView == topCollectionView {
            return topCollectionScrollIndexValue.count
        }
        else {
            return (self.categoriesArray.count)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView == topCollectionView {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PageTopCollectionViewCell",for: indexPath) as! PageTopCollectionViewCell
            cell.layer.cornerRadius = 8.0
            cell.imgView.layer.cornerRadius = 8.0
            cell.imgView.image = UIImage(named: "patternImage\(indexPath.item+1)")
            
            let itemValue = "\(self.topCollectionLabel[indexPath.item])"
            let itemString = NSLocalizedString(itemValue, comment: "")
            let collectionString = NSLocalizedString("Collection", comment: "")
            cell.collectionLabel.text = "\(itemString)\n\(collectionString)"
            
            self.isTopShowOrNot = true
            return cell
            
        }
        else {
            let cellIdentifier = "catecell"
            let cell = self.categoryCollectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,for: indexPath) as! CategoryCollectionViewCell
            
            let str = categoriesArray[indexPath.row].capitalizingFirstLetter()
            
            cell.titleTxt.text = NSLocalizedString(str, comment:str)
            cell.isSelectedItem(val: (indexPath.row == selectedCategoryIndex))
            
            if indexPath.row == selectedCategoryIndex
            {
                reloadCurrentData(categoryName: categoriesArray[selectedCategoryIndex])
                //self.collectionView.reloadData() //Todo
            }
            
            return cell
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        
        if collectionView == topCollectionView {
            
            let height = collectionView.frame.height
            
            switch UIDevice.current.userInterfaceIdiom {
            case .carPlay, .tv, .unspecified:
                fallthrough
            case .phone:
                return CGSize(width: collectionView.frame.width * 0.8, height:height)
            case .pad:
                
                if self.view.frame.height > self.view.frame.width {
                    return CGSize(width: self.view.frame.width * 0.641, height:height)
                }
                else {
                    return CGSize(width: self.view.frame.width * 0.44, height:height)
                }
            case .mac:
               return CGSize(width: self.view.frame.width * 0.44, height:height)
                
            }
        }
        else {
            
            let categoryString = categoriesArray[indexPath.row].capitalizingFirstLetter()
            let localizedCategoryString = NSLocalizedString(categoryString, comment:"")
            
            var cellWidth = localizedCategoryString.size(withAttributes:[.font: UIFont.systemFont(ofSize: 17.0)]).width + 30.0
            if UIDevice.current.userInterfaceIdiom == .pad {
                cellWidth  = cellWidth + 20
            }
            return CGSize(width: cellWidth, height:(collectionView.frame.size.height))
            
        }
        
    }
    
    
    var isSelectClick = false
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        isNotTabChange = true
        
        prevSelectedIndex = selectedCategoryIndex
        selectedCategoryIndex = indexPath.row
        if collectionView == topCollectionView {
            selectedCategoryIndex = topCollectionScrollIndexValue[indexPath.row]
            appDelegate.logEvent(name: "Display_Window", category: "", action: "\(indexPath.row+1)")
        }
        
        initializeForNextView()
        
        isSelectClick = true
        if prevSelectedIndex < selectedCategoryIndex{
            generateCollectionView(kType: kCollectionViewType.kCollectionViewRight)
        }
        else if prevSelectedIndex > selectedCategoryIndex{
            generateCollectionView(kType: kCollectionViewType.kCollectionViewLeft)
        }
        else{
            generateCollectionView(kType: kCollectionViewType.kCollectionViewIntial)
        }
        self.currentPage.currentPage = indexPath.item
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var visibleRect = CGRect()
        
        visibleRect.origin = topCollectionView.contentOffset
        visibleRect.size = topCollectionView.bounds.size
        
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        //        let visiblePoint = CGPoint(x: visibleRect.maxX, y: visibleRect.midY)
        
        guard let indexPath = topCollectionView.indexPathForItem(at: visiblePoint) else { return }
        print(indexPath.item)
        
        if self.view.frame.height < self.view.frame.width {
            if indexPath.item == 5 {
                topCounter = -1
            }
        }
        else {
            topCounter = currentPage.currentPage
        }
        currentPage.currentPage = indexPath.item
        
    }
    
    func convertStrToInt (str: String) -> Int
    {
        if let myNumber = NumberFormatter().number(from: str) {
            return myNumber.intValue
        }
        else{
            print("string is not compatible to int")
            return 0;
        }
    }
    
    
    //MARK: - PagesView Delegate
    /*func showAlert() {
        
        SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        SVProgressHUD.setMaximumDismissTimeInterval(3.0)
        SVProgressHUD.showInfo(withStatus: "Current rewardTime value = \(rewardTime)\nCurrent interstitialTime value = \(interstitialTime)")

    }*/
    
    func didSelectioItem(item: ImageData){
        
        let currentLaunch = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        if (UserDefaults.standard.value(forKey:tutKeyPageVC) == nil && currentLaunch == 1)
        {
            return
        }
        
        //Check date and show ads
        
        //showAlert()
        self.isSubscriptionMode = false
        _imageData = item
        self.appDelegate.selectedImageData = _imageData
        var shouldShowAds = self.adsShouldBeCalled()
        
        
        if UserDefaults.standard.value(forKey: "sessionTime") != nil
        {
            // Manage session time checks of 5 and 10 minutes to show Ads
            let sessionTime: Int = (UserDefaults.standard.value(forKey: "sessionTime") as? Int)!
            
            //            if(sessionTime >= 0 && sessionTime < 10 )
            //            {
            //                isreward = false
            //            }
            //            else if(sessionTime < 5 || sessionTime >= 10){
            //                isreward = false
            //                //isreward = true  // To Show Reward Ads
            //            }
            
            //#120. A/B testing: revert to prior ad logics
            if(sessionTime >= interstitialTime && sessionTime <= rewardTime )
            {
                isreward = false
            }else if(sessionTime >= rewardTime){
                isreward = true
            }
            else if(sessionTime < interstitialTime){// || (sessionTime >= rewardTime)){
                shouldShowAds = false
            }
            
            
        }
        
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if ((item.purchase == 0) || ((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (item.purchase == 1 && (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))){
            
            if #available(iOS 10.0, *) {
                DBHelper.sharedInstance.saveImageInDb(imgData: item, isUploadToiCloud: true)
            } else {
                // Fallback on earlier versions
            }
            if (shouldShowAds)
            {
                if self.isInternetAvailable()
                {
                    self.showInterstialAndRewardedAds(isreward: self.isreward)
                    return
                }
                else
                {
                    // Show No Connection View
                    if (self.isHintPaintVisible == 1 && self.tipsView != nil)
                    {
                        self.tipsView.removeFromSuperview()
                        self.isHintPaintVisible = 0
                        self.addNoInternetView()
                    }else
                    {
                        self.isHintPaintVisible = 0
                        self.addNoInternetView()
                    }
                }
            }
            else
            {
                self.isVideoViewOpen = false
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                vc.imageData = item
                self.getCategoryNameAndIndex(name: item.category!)
                self.navigationController?.pushViewController(vc, animated: true);
                
            }
        }
        else
        {
            if isSubscriptionViewVisible == 0
            {
                self.launchSubscriptionType = 3
                self.appDelegate.logEvent(name: "Sub3_win", category: "Subscription", action: item.imageId ?? item.name!)
                isSubscriptionViewVisible = 1
                self.addIAPSubscriptionView()
            }
        }
    }
    
    //MARK:- Get Category Index Of Image
    func getCategoryNameAndIndex(name:String)
    {
        var indexValue = 0
        for categoryObject in categoriesArray {
            indexValue = indexValue + 1
            if categoryObject == name
            {
                UserDefaults.standard.set(indexValue - 1, forKey: "SELECTED_CATEGORY_INDEX")
                UserDefaults.standard.set(name, forKey: "SELECTED_CATEGORY_NAME")
                UserDefaults.standard.synchronize()
                break
            }
        }
    }
    
    //MARK:- Get Category Index Of Image
    func getCategoryIndexFromName(name:String) -> Int
    {
        var indexValue = 0
        for categoryObject in categoriesArray {
            indexValue = indexValue + 1
            if categoryObject.lowercased() == name.lowercased()
            {
                return indexValue - 1
            }
        }
        return 0
    }
    
    //MARK:- Change selected category index
    @objc func changeSlectedCategoryIndex(notification: NSNotification) {
        if UserDefaults.standard.value(forKey: "SELECTED_CATEGORY_INDEX") != nil
        {
            //let indexValue = UserDefaults.standard.integer(forKey: "SELECTED_CATEGORY_INDEX")
            let catValue = UserDefaults.standard.value(forKey: "SELECTED_CATEGORY_NAME") as? String
            self.perform(#selector(reloadategoryCollectionView(name:)), with: catValue!, afterDelay: 0.1)
        }
    }
    
    //MARK: Category Collection reload
    @objc func reloadategoryCollectionView(name: String)
    {
        self.tabBarController?.selectedIndex = 1  // shoaib
        if(categoriesArray.count <= selectedCategoryIndex)
        {
            selectedCategoryIndex = 0
        }
        let indexValue = self.getCategoryIndexFromName(name: name)
        prevSelectedIndex = selectedCategoryIndex
        selectedCategoryIndex = indexValue
        reloadCurrentData(categoryName: categoriesArray[selectedCategoryIndex])
        
        let indexPath = IndexPath(item: selectedCategoryIndex, section: 0)
        self.categoryCollectionView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition.centeredHorizontally)
        self.categoryCollectionView.reloadData()
        self.perform(#selector(refreshCollectionOnNotificationReceived), with: nil, afterDelay: 0.2)
    }
    
    @objc func refreshCollectionOnNotificationReceived()
    {
        if prevSelectedIndex < selectedCategoryIndex{
            generateCollectionView(kType: kCollectionViewType.kCollectionViewRight)
        }
        else if prevSelectedIndex > selectedCategoryIndex{
            generateCollectionView(kType: kCollectionViewType.kCollectionViewLeft)
        }
        else{
            generateCollectionView(kType: kCollectionViewType.kCollectionViewIntial)
        }
    }
    
    //MARK:- IAP View
    func addIAPView()
    {
        
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            
            let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            })
            alertView.addAction(action)
            
            DispatchQueue.main.async(execute: {
                if !(type == .purchasedWeek || type == .purchasedMonth || type == .purchasedYear) {
                    strongSelf.present(alertView, animated: true, completion: nil)
                }

                self?.removeIAPView()
                
                
                if (type == .purchased) || (type == .restored)
                {
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeNonConsumable)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                }
                else  if (type == .purchasedWeek) || (type == .restoredWeek)
                {
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeWeekSubscription)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                }
                else  if (type == .purchasedMonth) || (type == .restoredMonth)
                {
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeMonthSubscription)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                }
                else  if (type == .purchasedYear) || (type == .restoredYear)
                {
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeYearSubscription)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                }
            })
        }
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        print("Width===\(screenSize.width),Height===\(screenSize.height)")
        self.iapView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
        self.iapView.backgroundColor = UIColor.clear
        self.iapView.alpha = 1.0
        //self.view.addSubview(self.iapView)
//        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//           let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//            mainWindow.addSubview(self.iapView)
//        }
        
        if #available(iOS 13.0, *) {
            // Use connectedScenes for iOS 13.0 and later
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                mainWindow.addSubview(self.iapView)
            }
        } else {
            // Use alternative approach for iOS 11.3 and earlier
            if let mainWindow = UIApplication.shared.keyWindow {
                mainWindow.addSubview(self.iapView)
            }
        }


        //balckView
        let blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
        blackView.backgroundColor = UIColor.black
        blackView.alpha = 0.7
        self.iapView.addSubview(blackView)
        
        var width_white : CGFloat = 300
        var height_white : CGFloat = 455
        var msg_lbl_height : CGFloat = 100
        var msg_lbl_yVal : CGFloat = 170
        var button_width : CGFloat = 220
        var button_height : CGFloat = 50
        var unlock_yVal : CGFloat = 327
        var restore_yVal : CGFloat = 390
        
        var cross_btn_width : CGFloat = 80
        let offset : CGFloat = 5
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            width_white = 470
            height_white = 700
            cross_btn_width = 90
            msg_lbl_height = 120
            msg_lbl_yVal = 250
            
            button_width = 340
            button_height = 74
            unlock_yVal = 500
            restore_yVal = 600
        }
        
        let xVal_white = (screenSize.width - width_white)/2
        let yVal_white = (screenSize.height - height_white)/2
        
        let whiteRect = CGRect(x: xVal_white, y: yVal_white, width: width_white, height: height_white)
        let bgImageRect = CGRect(x: 0, y: 0, width: whiteRect.width, height: whiteRect.height)
        let crossButtonRect = CGRect(x: whiteRect.width - offset - cross_btn_width, y: offset, width: cross_btn_width, height: cross_btn_width)
        let msgLabelRect = CGRect(x: 0, y: msg_lbl_yVal, width:whiteRect.width, height: msg_lbl_height)
        let unlockRect = CGRect(x: (whiteRect.width - button_width) / 2, y: unlock_yVal, width: button_width, height: button_height)
        let restoreRect = CGRect(x: (whiteRect.width - button_width) / 2, y: restore_yVal, width: button_width, height: button_height)
        
        
        //whiteView
        let whiteView = UIView(frame: whiteRect)
        whiteView.backgroundColor = UIColor.clear
        whiteView.alpha = 1.0
        self.iapView.addSubview(whiteView)
        //bgImage
        //        let bgImage = UIImageView(frame: bgImageRect)
        //        if UIDevice.current.userInterfaceIdiom == .phone
        //        {
        //            bgImage.image = UIImage(named: "iap_iphone")
        //        }
        //        else if UIDevice.current.userInterfaceIdiom == .pad
        //        {
        //            bgImage.image = UIImage(named: "iap_ipad")
        //        }
        //        bgImage.contentMode = .scaleAspectFill
        //        whiteView.addSubview(bgImage)
        //crossButton
        let crossButton = UIButton(frame: crossButtonRect)
        crossButton.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
        crossButton.addTarget(self, action:#selector(self.removeIAPView), for: .touchUpInside)
        whiteView.addSubview(crossButton)
        //msgLabel
        let msgLabel = UILabel(frame: msgLabelRect)
        
        let msg1 = NSLocalizedString("Holiday Special", comment: "")
        let msg2 = "!\n"
        let msg3 = NSLocalizedString("Unlock over 100 pictures", comment: "")
        let msg4 = "\n"
        let msg5 = NSLocalizedString("They are yours to keep", comment: "")
        let msg6 = NSLocalizedString("No recurring fee", comment: "")
        let msg7 = "."
        
        msgLabel.text =  msg1+msg2+msg3+msg4+msg5+msg4+msg6+msg7
        msgLabel.textAlignment = NSTextAlignment.center
        msgLabel.textColor = UIColor.darkGray
        msgLabel.numberOfLines = 5
        whiteView.addSubview(msgLabel)
        //unlockButton
        let unlockButton = UIButton(frame: unlockRect)
        let str = NSLocalizedString("Unlock Starter Pack", comment: "")
        unlockButton.setTitle(str, for: UIControlState.normal)
        
        
        unlockButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        unlockButton.addTarget(self, action:#selector(self.unlockStarter), for: .touchUpInside)
        whiteView.addSubview(unlockButton)
        //restoreButton
        let restoreButton = UIButton(frame: restoreRect)
        restoreButton.setTitle(NSLocalizedString("Restore", comment: ""), for: UIControlState.normal)
        restoreButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        restoreButton.addTarget(self, action:#selector(self.restorePurchase), for: .touchUpInside)
        whiteView.addSubview(restoreButton)
        whiteView.bringSubview(toFront: self.iapView)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
            {
                self.iapView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        }, completion:  nil)
        
    }
    
    //MARK:- Remove IAP View
    @objc func removeIAPView()
    {
        SVProgressHUD.dismiss()
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
            {
                let screenSize: CGRect = UIScreen.main.bounds
                self.iapView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        }, completion: { (finished: Bool) in
            self.iapView.removeFromSuperview()
        })
    }
    
    
    //MARK:- IAP Subscription View
    func addIAPSubscriptionView(mode:Int = 0)
    {
        
        IAPHandler.shared.purchaseStatusBlock = {[weak self] (type) in
            guard let strongSelf = self else{ return }
            
            let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                self?.showAdTrackingWindow()
            })
            alertView.addAction(action)
            
            DispatchQueue.main.async(execute: {
                if !(type == .purchasedWeek || type == .purchasedMonth || type == .purchasedYear || type == .failed) {
                    strongSelf.present(alertView, animated: true, completion: nil)
                }
                
                if type == .failed {
                    self?.isSubscriptionFail = true
                    self?.removeIAPSubscriptionView()
                    let alertFailedView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
                    let failedAction = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
                       // self?.showAdTrackingWindow()
                    })
                    strongSelf.present(alertFailedView, animated: true, completion: nil)
                    alertFailedView.addAction(failedAction)
                }
                else {
                    self?.removeIAPSubscriptionView()
                }
                
                if (type == .purchased) || (type == .restored)
                {
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeNonConsumable)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                }
                else  if (type == .purchasedWeek) || (type == .restoredWeek)
                {
                    if (type == .purchasedWeek)
                    {
                        if(self?.launchSubscriptionType == 1){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Updated_launch")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                            }else {
                                self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Launch")
                                self?.appDelegate.logEvent(name: "weekly_sub_comop_LC", category: "Subscription", action: "Launch")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                            }
                        } else if(self?.launchSubscriptionType == 2){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Updated_banner")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                            }else {
                                self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Banner")
                                self?.appDelegate.logEvent(name: "weekly_sub_comp_BN", category: "Subscription", action: "Banner")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                            }
                        }else{
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Updated_pages")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                            }else {
                                self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Pages")
                                self?.appDelegate.logEvent(name: "weekly_sub_comp_PG", category: "Subscription", action: "Pages")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                            }
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeWeekSubscription)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                    else {
                        self!.reloadView()
                        self?.hideBottomImage()
                    }
                    
                }
                else  if (type == .purchasedMonth) || (type == .restoredMonth)
                {
                    if (type == .purchasedMonth)
                    {
                        if(self?.launchSubscriptionType == 1){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Updated Launch Subscription Screen")
                            }else {
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Pages")
                                
                            }
                        } else if(self?.launchSubscriptionType == 2){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Updated Banner Subscription Screen")
                            }else {
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Pages")
                                
                            }
                        }else{
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Updated Pages Subscription Screen")
                            }else {
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Pages")
                                
                            }
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeMonthSubscription)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                }
                else  if (type == .purchasedYear) || (type == .restoredYear)
                {
                    if (type == .purchasedYear)
                    {
                        if(self?.launchSubscriptionType == 1){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Updated Launch Subscription Screen")
                            }else {
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Pages")
                            }
                        } else if(self?.launchSubscriptionType == 2){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Updated Banner Subscription Screen")
                            }else {
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Pages")
                                
                            }
                        }else{
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Updated Pages Subscription Screen")
                            }else {
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Pages")
                                
                            }
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeYearSubscription)
                    if let pagesView = self?.view.viewWithTag((self?.selectedCategoryIndex)!+(self?.tagVal)!) as? PagesView {
                        pagesView.collectionView?.reloadData()
                        self?.hideBottomImage()
                    }
                }
                
            })
            self?.viewDidLayoutSubviews()
        }
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        self.iapSubscriptionView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
        self.iapSubscriptionView.backgroundColor = UIColor.white
        self.iapSubscriptionView.alpha = 1.0
//        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//            if let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//                mainWindow.addSubview(self.iapSubscriptionView)
//            }
//        }
        
        if #available(iOS 13.0, *) {
            // Use connectedScenes for iOS 13.0 and later
            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                if let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                    mainWindow.addSubview(self.iapSubscriptionView)
                }
            }
        } else {
            // Use alternative approach for iOS 11.3 and earlier
            if let mainWindow = UIApplication.shared.keyWindow {
                mainWindow.addSubview(self.iapSubscriptionView)
            }
        }


        
        var width_white : CGFloat = 320
        var height_white : CGFloat = 568
        var cross_btn_width : CGFloat = 30
        var msg_lbl_height : CGFloat = 40
        var msg_lbl_yVal : CGFloat = 195
        var button_yVal : CGFloat = 240
        var button_width : CGFloat = 198
        var button_height : CGFloat = 42
        var help_btn_width : CGFloat = 40
        var offsetHelp : CGFloat = 15
        // shoaib
        var marginBottom :CGFloat = 20
        
        if UIDevice().userInterfaceIdiom == .phone {
            switch UIScreen.main.bounds.size.height{
            case 480:
                marginBottom = 15
            case 568:
                marginBottom = 15
            default:
                marginBottom  = 20
            }
        }
        
        if screenSize.width == 320
        {
            marginBottom = 15
        }
        
        if screenSize.width == 320
        {
            offsetHelp = 10
        }
        
        var button_offset : CGFloat = 11
        var longmsg_lbl_height : CGFloat = 160
        var longmsg_lbl_yVal : CGFloat = 420
        
        var offsetY_iPhoneX: CGFloat = 0
        
        if (screenSize.height == 812)
        {
            offsetY_iPhoneX = 20
        }
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            width_white  = 768
            height_white  = 1024
            cross_btn_width = 50
            msg_lbl_height = 130
            msg_lbl_yVal = 325
            button_yVal = 466
            button_width = 340
            button_height = 74
            help_btn_width = 50
            button_offset = 18
            longmsg_lbl_height  = 200
            longmsg_lbl_yVal  = 810
            
            if UIDevice.current.orientation.isLandscape
            {
                width_white  = 1024
                height_white  = 768
                cross_btn_width = 50
                msg_lbl_height = 130
                msg_lbl_yVal = 210
                button_yVal = 318
                button_width = 340
                button_height = 76
                help_btn_width = 50
                button_offset = 18
                longmsg_lbl_height  = 350
                longmsg_lbl_yVal  = 530
            }
            
        }
        
        let xVal_white = (screenSize.width - width_white)/2
        let yVal_white = (screenSize.height - height_white)/2
        
        let crossButtonRect = CGRect(x: (offsetHelp), y: (offsetHelp*2)+offsetY_iPhoneX, width: cross_btn_width, height: cross_btn_width)
        let helpButtonRect = CGRect(x: offsetHelp*2, y: screenSize.height - (offsetHelp) - (help_btn_width + marginBottom), width: help_btn_width, height: help_btn_width)
        
        let whiteRect = CGRect(x: xVal_white, y: yVal_white-50, width: width_white, height: height_white)
        let bgImageRect = CGRect(x: 0, y: 0, width: whiteRect.width, height: whiteRect.height)
        let msgLabelRect = CGRect(x: 0, y: msg_lbl_yVal, width:whiteRect.width, height: msg_lbl_height)
        let buttonWeekRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal, width: button_width, height: button_height)
        let buttonMonthRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+button_height+button_offset , width: button_width, height: button_height)
        let buttonYearRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*2)+(button_offset*2) , width: button_width, height: button_height)
        var buttonRestoreRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*3)+(button_offset*2)+button_offset/2, width: button_width, height: button_height)
        let longMsgRect = CGRect(x: 0, y: longmsg_lbl_yVal-10, width:whiteRect.width, height: longmsg_lbl_height)
        var termsButtonRect = CGRect(x: (screenSize.width - button_width) / 2, y: screenSize.height - (offsetHelp) - (25), width: button_width, height: 30)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
            {
                termsButtonRect = CGRect(x: (screenSize.width - 170), y: screenSize.height - (offsetHelp) - help_btn_width-10, width: 150, height: button_height)
                buttonRestoreRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*3)+(button_offset*2), width: button_width, height: button_height)
                self.viewDidLayoutSubviews()
            }
        }
        
        let whiteView = UIView(frame: whiteRect)
        whiteView.backgroundColor = UIColor.clear
        whiteView.alpha = 1.0
        whiteView.clipsToBounds = true
        whiteView.layer.cornerRadius = 15
        self.iapSubscriptionView.addSubview(whiteView)
        //bgImage
        //        let bgImage = UIImageView(frame: bgImageRect)
        //        if UIDevice.current.userInterfaceIdiom == .phone
        //        {
        //            bgImage.image = UIImage(named: "subs_iphone_a")
        //        }
        //        else if UIDevice.current.userInterfaceIdiom == .pad
        //        {
        //            bgImage.image = UIImage(named: "subs_ipad_a")
        //            if UIDevice.current.orientation.isLandscape
        //            {
        //                bgImage.image = UIImage(named: "subs_ipadh_a")
        //            }
        //        }
        //        bgImage.contentMode = .scaleAspectFill
        //        whiteView.addSubview(bgImage)
        
        //crossButton
        let frameValue = CGRect(x: crossButtonRect.minX, y: crossButtonRect.minY - 10, width: crossButtonRect.width, height: crossButtonRect.height)
        let crossButton = UIButton(frame: frameValue)
        crossButton.setImage(UIImage(named: "cancel_subs"), for: UIControlState.normal)
        crossButton.addTarget(self, action:#selector(self.removeIAPSubscriptionView), for: .touchUpInside)
        iapSubscriptionView.addSubview(crossButton)
        //HelpButton
        let helpButton = UIButton(frame: helpButtonRect)
        helpButton.setImage(UIImage(named: "help"), for: UIControlState.normal)
        helpButton.addTarget(self, action:#selector(self.presentHelpView), for: .touchUpInside)
        helpButton.isHidden = true
//        if UIDevice.current.userInterfaceIdiom == .pad
//        {
//            if UIDevice.current.orientation.isLandscape
//            {
//                helpButton.isHidden = false
//
//            }
//        }
        iapSubscriptionView.addSubview(helpButton)
        //termsButton
        let termsButton = UIButton(frame: termsButtonRect)
        termsButton.setTitle(NSLocalizedString("Terms & Privacy", comment: ""), for: UIControlState.normal)
        termsButton.addTarget(self, action:#selector(self.presentTermsView), for: .touchUpInside)
        termsButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        termsButton.titleLabel?.textAlignment  = NSTextAlignment.center
        termsButton.titleLabel?.font = .systemFont(ofSize: 14)
//        termsButton.backgroundColor = .red
//        iapSubscriptionView.backgroundColor = .blue
        iapSubscriptionView.addSubview(termsButton)
        //Saddam Added.
        //Middle View
        let cgRectValue = CGRect(x: whiteView.frame.minX, y: crossButton.frame.maxY + 5, width: whiteRect.width, height: termsButton.frame.minY - crossButton.frame.maxY - 16)
        let newContentView = UIView(frame: cgRectValue)
//        newContentView.backgroundColor = UIColor.red
        self.iapSubscriptionView.addSubview(newContentView)
        
        //Scroll View. newContentView.frame.width
        let newScrollView = UIScrollView(frame:CGRect(x: 0, y: 0, width: newContentView.frame.width, height: newContentView.frame.height))
        newScrollView.contentSize = CGSize(width: newContentView.frame.width, height: 630)
        //newContentView.frame.width
//        newScrollView.backgroundColor = UIColor.blue
        newContentView.addSubview(newScrollView)
        var gapping = CGFloat(8.0)
        if UIDevice.current.userInterfaceIdiom == .pad {
            gapping = CGFloat(15.0)
        }
        
        
        //msgLabel
        let msgLabel = UILabel(frame: msgLabelRect)
        msgLabel.text = NSLocalizedString("Get Pixel Coloring Pro for unlimited access\nto all pictures and updates.", comment: "")
        msgLabel.textAlignment = NSTextAlignment.center
        msgLabel.textColor = UIColor.darkGray
        msgLabel.font = UIFont.systemFont(ofSize: 14.0)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            msgLabel.font = UIFont.systemFont(ofSize: 20.0)
        }
        msgLabel.numberOfLines = 2
        msgLabel.sizeToFit()
        msgLabel.frame = CGRect(x: newScrollView.frame.midX - msgLabel.frame.width/2.0, y: (cgRectValue.height * 0.4) + gapping, width: msgLabel.frame.width, height:msgLabel.frame.height)
        newScrollView.addSubview(msgLabel)
        newScrollView.showsVerticalScrollIndicator = false
        newScrollView.showsHorizontalScrollIndicator = false
        
        //Image View.
        var widthValue = self.view.frame.width * 0.744
        // widthValue = 220.0
        if UIDevice.current.userInterfaceIdiom == .pad {
            if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height)){
                widthValue = self.view.frame.width * 0.35
            }
            else {
                widthValue = self.view.frame.width * 0.50
            }
        }
    
        
        print("newScrollView : \(widthValue)")
        let passImage = UIImageView(frame: CGRect(x: newScrollView.frame.midX - widthValue/2.0, y: 0, width: widthValue, height: widthValue))
        if _imageData != nil {
            guard  let img = appDelegate.getImage(imgName: _imageData.name, imageId: _imageData.imageId!,isThumb: false) else {
                return
            }
            passImage.image = img
            passImage.contentMode = .scaleAspectFit
        }
        else {
            passImage.isHidden = true
        }
        
        if freeTrailImageName != "" {
            passImage.image = #imageLiteral(resourceName: "pl2_icon")
            passImage.contentMode = .scaleAspectFit
            passImage.isHidden = false
        }
        
        newScrollView.addSubview(passImage)
        msgLabel.frame = CGRect(x: newScrollView.frame.midX - msgLabel.frame.width/2.0, y: passImage.frame.height + gapping, width: msgLabel.frame.width, height:msgLabel.frame.height)
        
        //weekButton
        let weekButton = UIButton(frame: CGRect(x: newScrollView.frame.midX - buttonWeekRect.width/2.0, y: msgLabel.frame.maxY + gapping + 5, width: buttonWeekRect.width, height:buttonWeekRect.height))
        //        let weekButton = UIButton(frame: buttonWeekRect)
        var attrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 10.0),
            NSAttributedStringKey.foregroundColor : UIColor.darkGray
        ]
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            attrs = [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18.0),
                NSAttributedStringKey.foregroundColor : UIColor.darkGray
            ]
        }
        let attString = NSMutableAttributedString()
        weekButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        let weekStr = NSLocalizedString("/ Week", comment: "")
        print("pagesVC ")
        
        var weekPrice = ""
        if let val = UserDefaults.standard.value(forKey: "WEEKLY_PRICE"){
            weekPrice = val as! String
        }//"$ 2.99 "
        
        let newLineStr = "\n"
        let monthStr = NSLocalizedString("/ Month", comment: "")
        
        var monthPrice = ""
//        if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE"){
//            monthPrice = val as! String
//        }
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_MODS"){
                    monthPrice = val as! String
                    print("monthPrice MONTHLY_PRICE_MODS : - \(monthPrice)")
                }
            }else {
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE"){
                    monthPrice = val as! String
                    print("monthPrice: - \(monthPrice)")
                }
            }
        
        var monthOffPrice = ""
//        if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"){
//            monthOffPrice = val as! String
//        }
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER_MODS"){
                    monthOffPrice = val as! String
                }
            }else {
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"){
                    monthOffPrice = val as! String
                }
            }
        
        let yearStr = NSLocalizedString("/ Year", comment: "")
        
        var yearPrice = ""
        if let val = UserDefaults.standard.value(forKey: "YEARLY_PRICE"){
            yearPrice = val as! String
        }
        
        
        var freeTrialAttrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 13, weight: .heavy),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            freeTrialAttrs = [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 22, weight: .heavy),
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
            
        }
        attString.append(NSAttributedString(string: NSLocalizedString("FREE TRIAL", comment: "") + newLineStr, attributes:freeTrialAttrs ))
        attString.append(NSAttributedString(string: NSLocalizedString("3 days free trial then", comment: "") + weekPrice+weekStr, attributes: attrs))
        
        weekButton.setAttributedTitle(attString, for: .normal)
        weekButton.titleLabel?.numberOfLines = 0
        weekButton.titleLabel?.textAlignment  = NSTextAlignment.center
        weekButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        weekButton.addTarget(self, action:#selector(self.subscriptionWeekPurchase), for: .touchUpInside)
        weekButton.titleLabel!.adjustsFontSizeToFitWidth = true;
        weekButton.titleLabel!.minimumScaleFactor = 0.5;
        weekButton.backgroundColor = #colorLiteral(red: 0.9979798198, green: 0.4009326696, blue: 0.3994571269, alpha: 1)
        weekButton.layer.cornerRadius = weekButton.frame.height/2.0
        weekButton.clipsToBounds = true
        newScrollView.addSubview(weekButton)
        
        //monthButton
        let monthButton = UIButton(frame: CGRect(x: newScrollView.frame.midX - buttonWeekRect.width/2.0, y: weekButton.frame.maxY + gapping, width: buttonMonthRect.width, height:buttonMonthRect.height))
        //        let monthButton = UIButton(frame: buttonMonthRect)
        let attString2 = NSMutableAttributedString()
        monthButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        var topLabelAttributes = [NSAttributedStringKey.font : UIFont(name:"Avenir-Heavy", size:14)!,NSAttributedStringKey.foregroundColor : UIColor.gray]
        if UIDevice.current.userInterfaceIdiom == .pad{
            topLabelAttributes = [NSAttributedStringKey.font : UIFont(name:"Avenir-Heavy", size:22)!,NSAttributedStringKey.foregroundColor : UIColor.gray]
        }
        attString2.append(NSAttributedString(string: monthPrice+monthStr+newLineStr, attributes: topLabelAttributes))
        
        attString2.append(NSAttributedString(string: NSLocalizedString("1 month subscription", comment: ""), attributes: attrs))
        monthButton.setAttributedTitle(attString2, for: .normal)
        monthButton.titleLabel?.numberOfLines = 0
        monthButton.titleLabel?.textAlignment  = NSTextAlignment.center
        monthButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        monthButton.addTarget(self, action:#selector(self.subscriptionMonthPurchase), for: .touchUpInside)
        monthButton.titleLabel!.adjustsFontSizeToFitWidth = true;
        monthButton.titleLabel!.minimumScaleFactor = 0.5;
        monthButton.backgroundColor = #colorLiteral(red: 0.4993353486, green: 0.7986764312, blue: 0.8999509811, alpha: 1)
        monthButton.layer.cornerRadius = monthButton.frame.height/2.0
        monthButton.clipsToBounds = true
        //        whiteView.addSubview(monthButton)
        newScrollView.addSubview(monthButton)
        
        
        var updatePurchaseMargin:CGFloat = 0
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            updatePurchaseMargin = 30
           
            if UIDevice.current.userInterfaceIdiom == .pad{
                updatePurchaseMargin = -25 + 15
            }
        }
       
        //yearButton
        let yearView = UIView(frame: CGRect(x: newScrollView.frame.midX - buttonYearRect.width/2.0, y: monthButton.frame.maxY + gapping + updatePurchaseMargin, width: buttonYearRect.width , height: buttonYearRect.height))
        yearView.backgroundColor = #colorLiteral(red: 0.4993353486, green: 0.7986764312, blue: 0.8999509811, alpha: 1)
        yearView.layer.cornerRadius = yearView.frame.height/2.0
        yearView.clipsToBounds = true
        newScrollView.addSubview(yearView)
        
        
        
        let yearButton = UIButton(frame: CGRect(x: 0, y: 0, width: buttonYearRect.width, height: buttonYearRect.height))
        yearView.addSubview(yearButton)
        let attString3 = NSMutableAttributedString()
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            yearView.backgroundColor = #colorLiteral(red: 0.9388599992, green: 0.4397807419, blue: 0.3910028338, alpha: 1)
            yearButton.setTitle(NSLocalizedString("Continue", comment: ""),for: .normal)
            yearButton.titleLabel!.textColor = UIColor.white
            yearButton.addTarget(self, action:#selector(self.subscriptionPurchase), for: .touchUpInside)
            if UIDevice.current.userInterfaceIdiom == .pad {
                yearButton.titleLabel!.font = UIFont.systemFont(ofSize: 30.0)
            }
            else {
                yearButton.titleLabel!.font = UIFont.systemFont(ofSize: 20.0)
            }
            yearButton.titleLabel!.adjustsFontSizeToFitWidth = true;
            yearButton.titleLabel!.minimumScaleFactor = 0.5;

        }else{
            
            yearButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            attString3.append(NSAttributedString(string: yearPrice+yearStr+newLineStr, attributes: topLabelAttributes))
            attString3.append(NSAttributedString(string: NSLocalizedString("1 year subscription", comment: ""), attributes: attrs))
            yearButton.setAttributedTitle(attString3, for: .normal)
            yearButton.titleLabel?.numberOfLines = 0
            yearButton.titleLabel?.textAlignment  = NSTextAlignment.center
            yearButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            yearButton.addTarget(self, action:#selector(self.subscriptionYearPurchase), for: .touchUpInside)
            yearButton.titleLabel!.adjustsFontSizeToFitWidth = true;
            yearButton.titleLabel!.minimumScaleFactor = 0.5;
            let offLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            offLabel.text = "60%\nOFF"
            offLabel.textAlignment = NSTextAlignment.center
            offLabel.textColor = UIColor.white
            offLabel.font = UIFont.systemFont(ofSize: 10.0, weight: .medium)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                offLabel.font = UIFont.systemFont(ofSize: 16.0)
            }
            offLabel.numberOfLines = 2
            offLabel.sizeToFit()
            offLabel.frame = CGRect(x: yearButton.frame.width - (offLabel.frame.width+14), y: yearButton.frame.midY - (offLabel.frame.height+6)/2.0, width: offLabel.frame.width+16, height: offLabel.frame.height+6)
            offLabel.backgroundColor = #colorLiteral(red: 0.9986391664, green: 0.2024247646, blue: 0.999342978, alpha: 1)
            offLabel.layer.cornerRadius = 8.0
            offLabel.clipsToBounds = true
            yearView.addSubview(offLabel)
        }
        
        
        
        
        
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1)
        {
            monthButton.isHidden = true
            weekButton.isHidden = true
            // Task#256 Vivek
            var boxSize:CGFloat = 100
            var fontSize:CGFloat = 10
            var height:CGFloat = 40
            var topMargin:CGFloat = 5
            var fontTitleSize:CGFloat = 13
            var subscriptionUIView = UIView(frame: CGRect(x: newScrollView.frame.origin.x,
                                                          y: msgLabel.frame.maxY + gapping + 5,
                                                          width: newScrollView.frame.width,
                                                          height: 120))
            if UIDevice.current.userInterfaceIdiom == .pad {
                subscriptionUIView = UIView(frame: CGRect(x: newScrollView.frame.origin.x,
                                                                          y: msgLabel.frame.maxY + gapping + 5,
                                                                          width: newScrollView.frame.width,
                                                                          height: 160))
            }

            subscriptionUIView.backgroundColor = .clear
//            subscriptionUIView.backgroundColor = .systemPink
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                boxSize = boxSize+50
                fontSize = 16
                height = 80
                topMargin = -5
               
                if let currentLanguage = Locale.currentLanguage {
                    switch  currentLanguage.rawValue{
                    case "Italian":
                        fontTitleSize = 18
                        break
                    case "French": // French
                        fontTitleSize = 18
                        break
                    default:
                        fontTitleSize = 20
                    }
                    
                }
            }
            else {
                boxSize = 100
                fontSize = 10
                height = 40
                topMargin = 5
               
                if let currentLanguage = Locale.currentLanguage {
                    switch  currentLanguage.rawValue{
                    case "Italian":
                        fontTitleSize = 11
                        break
                    case "French": // French
                        fontTitleSize = 11
                        break
                    default:
                        fontTitleSize = 13
                    }
                    
                }
            }
            
            //monthSubsV2iew!
            monthSubsView = UIView(frame: CGRect(x: 0,
                                                 y: 0,
                                                 width: boxSize,
                                                 height: boxSize))
            
            monthSubsView!.center = CGPoint(x: subscriptionUIView.bounds.midX,
                                            y: subscriptionUIView.bounds.midY - 10 )
            monthSubsView!.backgroundColor = .white
            monthSubsView!.layer.cornerRadius = 10
            monthSubsView!.layer.borderColor = UIColor(red: 0.91, green: 0.49, blue: 0.45, alpha: 1.00).cgColor
            monthSubsView!.layer.borderWidth = 2.0
            monthSubsView!.clipsToBounds = true
            
            
            subscriptionUIView.addSubview(monthSubsView!)
            
            //weekSubsView!
            if UIDevice.current.userInterfaceIdiom == .pad {
                weekSubsView = UIView(frame: CGRect(x: monthSubsView!.frame.origin.x - boxSize - 15,
                                                                y: monthSubsView!.frame.origin.y, width: boxSize, height: boxSize))
            }
            else {
                weekSubsView = UIView(frame: CGRect(x: monthSubsView!.frame.origin.x - boxSize - 6,
                                                    y: monthSubsView!.frame.origin.y, width: boxSize, height: boxSize))
            }

            
            weekSubsView!.backgroundColor = .white
            weekSubsView!.layer.cornerRadius = 10
            weekSubsView!.layer.borderColor = UIColor.gray.cgColor
            weekSubsView!.layer.borderWidth = 2.0
            weekSubsView!.clipsToBounds = true
            subscriptionUIView.addSubview(weekSubsView!)
            
            //yearSubsView!
            if UIDevice.current.userInterfaceIdiom == .pad {
                yearSubsView = UIView(frame: CGRect(x: monthSubsView!.frame.origin.x + monthSubsView!.frame.size.width + 15,
                                                    y: monthSubsView!.frame.origin.y, width: boxSize, height: boxSize))
            }
            else {
                yearSubsView = UIView(frame: CGRect(x: monthSubsView!.frame.origin.x + monthSubsView!.frame.size.width + 6,
                                                    y: monthSubsView!.frame.origin.y, width: boxSize, height: boxSize))
            }
            yearSubsView!.backgroundColor = .white
            yearSubsView!.layer.cornerRadius = 10
            yearSubsView!.layer.borderColor = UIColor.gray.cgColor
            yearSubsView!.layer.borderWidth = 2.0
            yearSubsView!.clipsToBounds = true
            subscriptionUIView.addSubview(yearSubsView!)
            
            
            //monthSubscptionLabel
            let oneMonthLabel = UILabel(frame: CGRect(x: 5,
                                                      y: topMargin,
                                                      width: monthSubsView!.frame.size.width - 10,
                                                      height: height))
            oneMonthLabel.text = (NSLocalizedString("Monthly Subscription", comment: ""))
                //"\(NSLocalizedString("Monthly", comment: ""))\n\(NSLocalizedString("Subscription", comment: ""))"
            oneMonthLabel.numberOfLines = 0
            oneMonthLabel.lineBreakMode = .byWordWrapping
            oneMonthLabel.textAlignment = .center
            monthSubsView!.addSubview(oneMonthLabel)
            oneMonthLabel.font = oneMonthLabel.font.withSize(fontTitleSize)
//            oneMonthLabel.backgroundColor = .red
//            monthSubsView!.backgroundColor = .yellow
//            subscriptionUIView.backgroundColor = .gray
            
            let oneMonthAmountLabel = UILabel(frame: CGRect(x: 10,
                                                            y: monthSubsView!.frame.maxY-45,
                                                            width:boxSize - 20,
                                                            height: 25))
            oneMonthAmountLabel.font = oneMonthAmountLabel.font.withSize(fontSize+1)
            oneMonthAmountLabel.text = monthPrice+monthStr
           // oneMonthAmountLabel.sizeToFit()
            oneMonthAmountLabel.textAlignment = .center
            oneMonthAmountLabel.adjustsFontSizeToFitWidth = true
            monthSubsView!.addSubview(oneMonthAmountLabel)
            
            let oneMonthInitialAmountLabel = UILabel(frame: CGRect(x: 10,
                                                                   y:monthSubsView!.frame.maxY-20,
                                                                   width:boxSize - 20,
                                                                   height: 15))
            oneMonthInitialAmountLabel.font = oneMonthInitialAmountLabel.font.withSize(fontSize+1)
          
            //let monthStr = NSLocalizedString("/ Month", comment: "")
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: monthOffPrice+monthStr)
            if #available(iOS 14, *) {
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            } else {
                attributeString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
                attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
               
            }
            
          
            oneMonthAmountLabel.text = monthPrice+monthStr
            oneMonthInitialAmountLabel.attributedText = attributeString
            oneMonthInitialAmountLabel.textAlignment = .center
            oneMonthInitialAmountLabel.adjustsFontSizeToFitWidth = true
            monthSubsView!.addSubview(oneMonthInitialAmountLabel)
           // oneMonthInitialAmountLabel.backgroundColor = .green
            let image = UIImage(named: "monds_ipad")
            let ratioFactor = (image?.size.height)! / (image?.size.width)!
            var yValue = oneMonthInitialAmountLabel.frame.maxY - 8
            if UIDevice.current.userInterfaceIdiom == .pad {
                yValue = oneMonthInitialAmountLabel.frame.maxY - 25
            }

            var heightValue = 120 - yValue
            if UIDevice.current.userInterfaceIdiom == .pad {
                heightValue = 45//135 - yValue
            }
            let widthValue = heightValue * ratioFactor
            
            var xValue = monthSubsView!.frame.origin.x + monthSubsView!.frame.size.width + 2 - widthValue
            if UIDevice.current.userInterfaceIdiom == .pad {
                xValue = monthSubsView!.frame.origin.x + monthSubsView!.frame.size.width + 11 - widthValue
            }

            
            let  offerImage = UIImageView(frame: CGRect(x: xValue, y: yValue, width: heightValue, height: heightValue))
            offerImage.image = image
            subscriptionUIView.addSubview(offerImage)
            //monds_ipad
            
            
            
            //weekSubscptionLabel
            let oneWeekLabel = UILabel(frame: CGRect(x: 5,
                                                     y: topMargin,
                                                     width: weekSubsView!.frame.size.width - 10,
                                                     height: height))
            oneWeekLabel.text = (NSLocalizedString("Weekly Subscription", comment: ""))
            //"\(NSLocalizedString("Weekly", comment: ""))\n\(NSLocalizedString("Subscription", comment: ""))"
            oneWeekLabel.numberOfLines = 0
            oneWeekLabel.lineBreakMode = .byWordWrapping
            oneWeekLabel.adjustsFontSizeToFitWidth = true
            oneWeekLabel.textAlignment = .center
            weekSubsView!.addSubview(oneWeekLabel)
            oneWeekLabel.font = oneWeekLabel.font.withSize(fontTitleSize)
        
            
            //oneWeekAmountLabel
            
            let oneWeekAmountLabel = UILabel(frame: CGRect(x: 10,
                                                           y: weekSubsView!.frame.maxY-45,
                                                           width:boxSize - 20,
                                                           height: 25))
            oneWeekAmountLabel.font = oneWeekAmountLabel.font.withSize(fontSize+1)
            oneWeekAmountLabel.text = weekPrice+weekStr//"$8.99/\(NSLocalizedString("Week", comment: ""))"
            oneWeekAmountLabel.adjustsFontSizeToFitWidth = true
            oneWeekAmountLabel.textAlignment = .center
          
            weekSubsView!.addSubview(oneWeekAmountLabel)
            
            //oneYearLabel
            let oneYearLabel = UILabel(frame: CGRect(x: 5, y: topMargin,
                                                     width: yearSubsView!.frame.size.width - 10,
                                                     height: height))
            oneYearLabel.text = (NSLocalizedString("Yearly Subscription", comment: ""))
                //"\(NSLocalizedString("Annual", comment: ""))\n\(NSLocalizedString("Subscription", comment: ""))"
            oneYearLabel.numberOfLines = 0
            oneYearLabel.lineBreakMode = .byWordWrapping
            oneYearLabel.textAlignment = .center
            yearSubsView!.addSubview(oneYearLabel)
            oneYearLabel.font = oneYearLabel.font.withSize(fontTitleSize)
            //oneYearLabel.backgroundColor = .red
            
            //oneYearAmountLabel
            
            let oneYearAmountLabel = UILabel(frame: CGRect(x: 10,
                                                           y: yearSubsView!.frame.maxY-45,
                                                           width:boxSize - 20,
                                                           height:25))
            oneYearAmountLabel.font = oneYearAmountLabel.font.withSize(fontSize+1)
            oneYearAmountLabel.text = yearPrice+yearStr
            oneYearAmountLabel.adjustsFontSizeToFitWidth = true
            oneYearAmountLabel.textAlignment = .center
           
            yearSubsView!.addSubview(oneYearAmountLabel)
            
            let weekGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
            let monthGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
            let yearGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
            
            weekSubsView?.tag = 0
            monthSubsView?.tag = 1
            yearSubsView?.tag = 2
            monthSubsView!.addGestureRecognizer(monthGestureRecognizer)
            weekSubsView!.addGestureRecognizer(weekGestureRecognizer)
            yearSubsView!.addGestureRecognizer(yearGestureRecognizer)
            
            if #available(iOS 13.0, *) {
                overrideUserInterfaceStyle = .light
            } else {
                // Fallback on earlier versions
            }
            newScrollView.backgroundColor = .white
            
            newScrollView.addSubview(subscriptionUIView)
            
            appDelegate.logEvent(name: "Updated_Pages_Subscription", category: "Subscription", action: "View Updated Pages Subscription")
        }
        //restoreButton
        let restoreButton = UIButton(frame: CGRect(x: newScrollView.frame.midX - buttonRestoreRect.width/2.0, y: yearView.frame.maxY + gapping, width: buttonRestoreRect.width, height: buttonRestoreRect.height-16))
        //        let restoreButton = UIButton(frame: buttonRestoreRect)
        if UIDevice.current.userInterfaceIdiom == .pad{
            let attributes = [NSAttributedStringKey.font : UIFont(name:"Avenir", size:22)!,NSAttributedStringKey.foregroundColor : UIColor.darkGray]
            restoreButton.setAttributedTitle(NSAttributedString(string: NSLocalizedString("Restore", comment: ""), attributes: attributes), for: .normal)
        }else{
            restoreButton.setTitle(NSLocalizedString("Restore", comment: ""), for: UIControlState.normal)
        }
        restoreButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        restoreButton.addTarget(self, action:#selector(self.restorePurchase), for: .touchUpInside)
        //        whiteView.addSubview(restoreButton)
        //        restoreButton.backgroundColor = UIColor.systemPink
        newScrollView.addSubview(restoreButton)
        
        //longMsgLabel
        let longMsgLabel = UILabel(frame: CGRect(x: newScrollView.frame.midX - longMsgRect.width/2.0, y: restoreButton.frame.maxY + gapping, width: longMsgRect.width, height: longMsgRect.height-20))
        //        let longMsgLabel = UILabel(frame: longMsgRect)
        longMsgLabel.text = NSLocalizedString("Subscription may be managed by the user and auto-renewal\nmay be turned off by going to the user’s Account Settings\nafter purchase. Any unused portion of a free trial period, if\noffered, will be forfeited when the user purchases a subscription\nto that publication, where applicable. Payment will be charged to\niTunes Account at confirmation of purchase. Subscription\nautomatically renews unless auto-renew is turned off at least \n24-hours before the end of the current period. Account will \nbe charged for renewal within 24-hour prior to the \nend of the current period, and identify the cost of the renewal.", comment: "")
        longMsgLabel.textAlignment = NSTextAlignment.center
        longMsgLabel.textColor = UIColor.lightGray
        longMsgLabel.font = UIFont.systemFont(ofSize: 10.0)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            //            if UIDevice.current.orientation.isLandscape
            //            {
            longMsgLabel.text = NSLocalizedString("Subscription may be managed by the user and auto-renewal may be turned off by\n going to the user’s Account Settings after purchase. Any unused portion of a free trial period,\n if offered, will be forfeited when the user purchases a subscription to that publication,\n where applicable. Payment will be charged to iTunes Account at confirmation of purchase.\n Subscription automatically renews unless auto-renew is turned off at least 24-hours\n before the end of the current period. Account will be charged for renewal within 24-hour\n prior to the end of the current period, and identify the cost of the renewal.", comment: "")
            longMsgLabel.font = UIFont.systemFont(ofSize: 13.0)
            //}
        }
        longMsgLabel.numberOfLines = 15
        //        longMsgLabel.backgroundColor = UIColor.systemPink
        longMsgLabel.sizeToFit()
        longMsgLabel.frame = CGRect(x: newScrollView.frame.midX - longMsgLabel.frame.width/2.0, y: longMsgLabel.frame.minY, width: longMsgLabel.frame.width, height:longMsgLabel.frame.height)
        newScrollView.contentSize = CGSize(width: newContentView.frame.width, height: longMsgLabel.frame.maxY)
        newScrollView.addSubview(longMsgLabel)
        //Saddam Updated.
        
        self.subscriptionVC?.view.frame.origin.y = UIScreen.main.bounds.height
        
        UIView.animate(withDuration: 0.5, delay: 0.5, options: [], animations:
                        {
                            self.iapSubscriptionView.isHidden = false
                            self.iapSubscriptionView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
                            if mode == 1 {
                                
                                self.mode = mode
                                self.subscriptionVC?.view.frame = self.iapSubscriptionView.frame
                                self.subscriptionVC?.btnFreeTrial.addTarget(self, action:#selector(self.subscriptionWeekPurchaseSub1_FT_applaunch), for: .touchUpInside)
                                
                                self.subscriptionVC?.cancelBtn.addTarget(self, action:#selector(self.removeIAPSubscriptionView), for: .touchUpInside)
//                                if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//                                    if let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//                                        mainWindow.insertSubview(self.subscriptionVC!.view, at: mainWindow.subviews.count)
//                                    }
//                                }
                                
                                if #available(iOS 13.0, *) {
                                    // Use connectedScenes for iOS 13.0 and later
                                    if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                        if let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                                            mainWindow.insertSubview(self.subscriptionVC!.view, at: mainWindow.subviews.count)
                                        }
                                    }
                                } else {
                                    // Use alternative approach for iOS 11.3 and earlier
                                    if let mainWindow = UIApplication.shared.keyWindow {
                                        mainWindow.addSubview(self.subscriptionVC!.view)
                                    }
                                }


                                self.iapSubscriptionView.isHidden = true
                                self.iapSubscriptionView.clipsToBounds = false
                            }
                        }, completion:  { (finish) in
                            self.setStatusBarColor(color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
                            if(self.loadLaunchView != nil){
                                self.loadLaunchView.removeFromSuperview()
                            }
                            
                        })
        
        
    }
    func selectSubscriptionType(_ sView:UIView){
            weekSubsView!.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
            monthSubsView!.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
            yearSubsView!.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
            sView.layer.borderColor =  UIColor(red: 0.91, green: 0.49, blue: 0.45, alpha: 1.00).cgColor
            selectedPurchaseType = sView.tag
           print("selectedPurchaseType \(selectedPurchaseType)")
        }
        
        @objc func didTapView(_ sender: UITapGestureRecognizer) {
            selectSubscriptionType(sender.view!)
        }

    //MARK:- Remove IAP Subscription View
    var isSubscriptionFail = false
    @objc func removeIAPSubscriptionView()
    {
        
        isSubscriptionViewVisible = 0
        freeTrailImageName = ""
        SVProgressHUD.dismiss()
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
                            let screenSize: CGRect = UIScreen.main.bounds
                            self.iapSubscriptionView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                            self.subscriptionVC?.view.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                        }, completion: { (finished: Bool) in
                            self.isSubscriptionVC = false
                            self.iapSubscriptionView.removeFromSuperview()
                            self.subscriptionVC?.view.removeFromSuperview()
                            self.subscriptionVC = nil
                            self.setStatusBarColor(color: #colorLiteral(red: 0.9490196078, green: 0.9490196078, blue: 0.968627451, alpha: 1))
                            if(self.appDelegate.imageDataNotification != nil){
                                DispatchQueue.main.async {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                                    vc.imageData = self.appDelegate.imageDataNotification
                                    self.navigationController?.pushViewController(vc, animated: true)
                                    //self.appDelegate.imageDataNotification = nil // need to check
                                }
                            }
                            else if(self.isSubscriptionMode == true && self.launchSubscriptionType == 1){
                                if self.isSubscriptionFail == false {
                                    self.showAdTrackingWindow()
                                }
                                
                            }
                            
                        })
    }
    
    
    
    //MARK:- Present Help View View
    @objc func presentHelpView()
    {
        appDelegate.logEvent(name: "info", category: "Subscription", action: "Pages")
        self.presentHelpAndTermsView(openThisString: NSLocalizedString("help_base", comment: ""))
    }
    
    //MARK:- Present Terms View View
    @objc func presentTermsView()
    {
        self.presentHelpAndTermsView(openThisString: "about")
    }
    
    //MARK: Present Help & Terms View
    @objc func presentHelpAndTermsView(openThisString: String)
    {
        if isHelpViewVisible == 0
        {
            isHelpViewVisible = 1
            let screenSize: CGRect = UIScreen.main.bounds
            self.helpView = UIView(frame: CGRect(x:iapSubscriptionView.frame.origin.x, y: screenSize.height, width: iapSubscriptionView.frame.size.width, height: iapSubscriptionView.frame.size.height))
            self.helpView.backgroundColor = UIColor.white
            self.helpView.alpha = 1.0
            
            iapSubscriptionView.addSubview(self.helpView)
            let cross_btn_width : CGFloat = 80
            let offset : CGFloat = 10
            let crossButtonRect = CGRect(x: screenSize.width - offset - cross_btn_width, y: offset, width: cross_btn_width, height: cross_btn_width)
            let webViewRect = CGRect(x: offset, y: offset+cross_btn_width, width: screenSize.width-(2*offset), height: screenSize.height - (offset+cross_btn_width + 10))
            
            //crossButton
            let crossButton = UIButton(frame: crossButtonRect)
            crossButton.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
            crossButton.addTarget(self, action:#selector(self.removeHelpView), for: .touchUpInside)
            helpView.addSubview(crossButton)
            //webView
            let webView = UIWebView(frame: webViewRect)
            webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: openThisString, ofType: "docx") ?? "")))
            webView.delegate = self
            webView.scalesPageToFit = true
            webView.backgroundColor = UIColor.clear
            SVProgressHUD.show()
            helpView.addSubview(webView)
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                {
                    self.helpView.frame = CGRect(x: self.iapSubscriptionView.frame.origin.x, y: self.iapSubscriptionView.frame.origin.y, width: self.iapSubscriptionView.frame.size.width, height: self.iapSubscriptionView.frame.size.height)
            },
                           completion:  nil)
        }
    }
    
    
    //MARK: Image Show Delegate
    var headerViewMaxHeight: CGFloat = 0
    var headerViewMinHeight: CGFloat = 100 + UIApplication.shared.statusBarFrame.height
    var isNotTabChange = false
    
    
    func didScrollDown(scroll: UIScrollView) {
        
        if isNotTabChange == false {
            
            //For Top Windows View.
            let y: CGFloat = scroll.contentOffset.y
            let newHeaderViewHeight: CGFloat = topDisplayViewTopConstraint.constant - y
            
            if newHeaderViewHeight > headerViewMaxHeight {
                topDisplayViewTopConstraint.constant = headerViewMaxHeight
                UIView.animate(withDuration: 0.0) {
                    self.view.layoutSubviews()
                }
                
            } else if newHeaderViewHeight < headerViewMinHeight {
                topDisplayViewTopConstraint.constant = headerViewMinHeight + 4
                UIView.animate(withDuration: 0.0) {
                    self.view.layoutSubviews()
                }
                
            } else {
                topDisplayViewTopConstraint.constant = newHeaderViewHeight
                scroll.contentOffset.y = 0 // block scroll view
                UIView.animate(withDuration: 0.0) {
                    self.view.layoutSubviews()
                }
            }
            
            
            
            
            
            //For Bottom Unlock View.
            if scroll.contentOffset.y == 0 || scroll.contentOffset.y < 0 {
                if self.imageViewBottom.constant != CGFloat(-self.imageViewHeightValue) {
                    self.hideBottomImage()
                    self.isTopScrollVisible = true
                }
            }
            else {
                if self.imageViewBottom.constant != 0 {
                    self.isTopScrollVisible = false
                    self.showBottomImage()
                }
            }
        }
    }
    
    func hideBottomImage() {
        
        self.imageViewBottom.constant = CGFloat(-self.imageViewHeightValue)
        
        UIView.animate(withDuration: 0.25) { [self] in
            self.topCollectionView.isHidden = false
            self.currentPage.isHidden = false

            self.imageView.isHidden = true
            self.unlockImageLabeliPad.isHidden = true
            self.unlockImageLabeliPhone.isHidden = true
            self.freeTrailButtoniPad.isHidden = true
            self.freeTrailButton.isHidden = true
           
            self.view.layoutSubviews()
        }
    }
    
    func showBottomImage() {
        self.imageViewBottom.constant = 0
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if !((((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || ((appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))))
        {
            imageView.isHidden = false
            if UIDevice.current.userInterfaceIdiom == .pad {
                self.unlockImageLabeliPad.isHidden = false
                self.unlockImageLabeliPhone.isHidden = true
                
                self.freeTrailButtoniPad.isHidden = false
                self.freeTrailButton.isHidden = true
            }
            else {
                self.unlockImageLabeliPad.isHidden = true
                self.unlockImageLabeliPhone.isHidden = false
                
                self.freeTrailButtoniPad.isHidden = true
                self.freeTrailButton.isHidden = false
            }
        }
        else{
            self.imageView.isHidden = true
            self.unlockImageLabeliPad.isHidden = true
            self.unlockImageLabeliPhone.isHidden = true
            self.freeTrailButtoniPad.isHidden = true
            self.freeTrailButton.isHidden = true
        }
        UIView.animate(withDuration: 0.25) {
            self.topCollectionView.isHidden = true
            self.currentPage.isHidden = true
            self.view.layoutSubviews()
        }
    }
    
    
    var freeTrailImageName = ""
    @IBAction func freeTrailBtnClick(_ sender: UIButton) {
        if(isSubscriptionVC == false){
          
            self.isSubscriptionVC = true
            self.launchSubscriptionType = 2
            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
            if(isExpired == "YES" || isExpired == nil){
                UserDefaults.standard.set(false, forKey: SHOW_SUBSCRIPTION)
                self.appDelegate.logEvent(name: "Banner_Subscription_window", category: "Subscription", action: categoriesArray[selectedCategoryIndex])
                self.subscriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionVC") as? SubscriptionVC
                self.subscriptionVC?.loadViewIfNeeded()
                self.isSubscriptionMode = true
                self.subscriptionVC?.isFromFreeButton = true
                self.addIAPSubscriptionView(mode: 1)
            }
        }
        
        //        appDelegate.logEvent(name: "Sub4_BN", category: "Subscription", action: "Pages")
        //        //appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Banner")
        //        isPagesFreeTrailButtonClick = true
        //        //subscriptionWeekPurchase()
        //        isSubscriptionViewVisible = 1
        //        freeTrailImageName = "pl2_icon"
        //        addIAPSubscriptionView()
        
        
    }
    
    //MARK:- Remove help View
    @objc func removeHelpView()
    {
        isHelpViewVisible = 0
        SVProgressHUD.dismiss()
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
            {
                let screenSize: CGRect = UIScreen.main.bounds
                self.helpView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        }, completion: { (finished: Bool) in
            self.helpView.removeFromSuperview()
        })
    }
    
    // MARK: - UIWebViewDelegate
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }
    
    // MARK: - RESTORE PURCHASE
    @objc func restorePurchase()
    {
        appDelegate.logEvent(name: "restore_purchase", category: "Subscription", action: "Pages")
        if (UserDefaults.standard.object(forKey: "EXPIRE_INTENT") != nil)
        {
            let expirationIntent = UserDefaults.standard.integer(forKey: "EXPIRE_INTENT")
            if expirationIntent != 1
            {
                SVProgressHUD.show()
                IAPHandler.shared.restorePurchase()
            }
            else
            {
                self.removeIAPSubscriptionView()
                let alertView = UIAlertController(title: "", message: "No Active Subscription!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertView.addAction(action)
                self.present(alertView, animated: true, completion: nil)
                SVProgressHUD.dismiss()
            }
        }
        else
        {
            SVProgressHUD.show()
            IAPHandler.shared.restorePurchase()
        }
    }
    
    // MARK: - RESTORE PURCHASE
    @objc func unlockStarter()
    {
        SVProgressHUD.show()
        IAPHandler.shared.purchaseMyProduct(product_identifier: STARTER_PRODUCT_ID)
    }
    
    // MARK: - SUBSCRIPTION WEEK PURCHASE
    @objc func subscriptionWeekPurchase()
    {
        SVProgressHUD.show()
        
        if self.mode == 0 {
            //appDelegate.logEvent(name: "weekly_subscription_pg", category: "Subscription", action: "Pages")
        }else {
            appDelegate.logEvent(name: "Sub2_FT", category: "Subscription", action: "Free Button")
            appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Pages")
            appDelegate.logEvent(name: "weekly_sub_1", category: "Subscription", action: "Pages")
            
        }
        IAPHandler.shared.purchaseMyProduct(product_identifier: WEEK_SUBSCRIPTION_PRODUCT_ID)
    }
    
    // MARK: - SUBSCRIPTION WEEK PURCHASE
    @objc func subscriptionWeekPurchaseSub1_FT_applaunch()
    {
       self.selectedPurchaseType =  self.subscriptionVC?.selectedPurchaseType ?? 0
        subscriptionPurchase()
//        self.isSubscriptionVC = false
//        SVProgressHUD.show()
//        if(self.launchSubscriptionType == 2){
//            appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Banner")
//            appDelegate.logEvent(name: "weekly_subscription_bn", category: "Subscription", action: "Banner")
//            appDelegate.logEvent(name: "weekly_sub_1", category: "Subscription", action: "Banner")
//        }else{
//            appDelegate.logEvent(name: "weekly_subscription_la", category: "Subscription", action: "Launch")
//            appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Launch")
//        }
//        IAPHandler.shared.purchaseMyProduct(product_identifier: WEEK_SUBSCRIPTION_PRODUCT_ID)
       
    }
    
    
    // MARK: - SUBSCRIPTION YEAR PURCHASE
        @objc func subscriptionPurchase()
        {
            SVProgressHUD.show()
            if(selectedPurchaseType == 0){
                if(self.launchSubscriptionType == 2){
                    appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Banner")
                    appDelegate.logEvent(name: "weekly_subscription_bn", category: "Subscription", action: "Banner")
                    appDelegate.logEvent(name: "weekly_sub_1", category: "Subscription", action: "Banner")
                }else{
                    appDelegate.logEvent(name: "weekly_subscription_la", category: "Subscription", action: "Launch")
                    appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Launch")
                }
                IAPHandler.shared.purchaseMyProduct(product_identifier: WEEK_SUBSCRIPTION_PRODUCT_ID)
            }
            
            else if(selectedPurchaseType == 1){
                subscriptionMonthPurchase()
            }else {
                
                subscriptionYearPurchase()
            }
        }

    // MARK: - SUBSCRIPTION MONTH PURCHASE
    @objc func subscriptionMonthPurchase()
    {
        SVProgressHUD.show()
        appDelegate.logEvent(name: "monthly_subscription_pg", category: "Subscription", action: "Pages")
        appDelegate.logEvent(name: "monthly_subscription", category: "Subscription", action: "Pages")
       
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            MONTH_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2mods"
        }
        IAPHandler.shared.purchaseMyProduct(product_identifier: MONTH_SUBSCRIPTION_PRODUCT_ID)
    }
    // MARK: - SUBSCRIPTION YEAR PURCHASE
    @objc func subscriptionYearPurchase()
    {
        SVProgressHUD.show()
        appDelegate.logEvent(name: "yearly_subscription_pg", category: "Subscription", action: "Pages")
        appDelegate.logEvent(name: "yearly_subscription", category: "Subscription", action: "Pages")
        IAPHandler.shared.purchaseMyProduct(product_identifier: YEAR_SUBSCRIPTION_PRODUCT_ID)
    }
    
    
    //Show intertial/reward ads function:
    func showInterstialAndRewardedAds(isreward:Bool)
    {
        var isExpired = "YES"
        if UserDefaults.standard.value(forKey: "IS_EXPIRED") != nil
        {
            isExpired = (UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String)!
        }
        if (((self.appDelegate.purchaseType() == .kPurchasTypeNone) || isExpired == "YES"))
        {
            //Show intertial ads after 5 min  isreward
            
            if(isreward == false)
            {
                
                self.showIntertialAds()

            }
            else{
                //Show reward ads after 10 mins
                
                self.showRewardedAds()
            }

        }
    }
    
    
    //Save Current date to check day changed
    func adsShouldBeCalled() -> Bool
    {
        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        var isFirstSession:Bool = false
        if(UserDefaults.standard.value(forKey: "isFirstSession") != nil)
        {
            isFirstSession = (UserDefaults.standard.value(forKey: "isFirstSession") as? Bool)!
        }
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        
        //self.appDelegate.CheckisFirstSession()
        
        if((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO")
        {
            return false
        }
        else if UserDefaults.standard.value(forKey: "is_first_image_completed") == nil
        {
            return false
        }
        else if (isFirstSession == true)
        {
            return false
        }
        else if (launchCount < 2){
            return false
        }
        else{
            
            return true
        }
        
        
        
        //        let date = Date()
        //        let formatter = DateFormatter()
        //        formatter.dateFormat = "dd-MM-yyyy"
        //        let result = formatter.string(from: date)
        //        if UserDefaults.standard.value(forKey: "current_date_string") != nil{
        //            let prevDateString = UserDefaults.standard.value(forKey: "current_date_string") as? String
        //            if prevDateString != result
        //            {
        //                UserDefaults.standard.set(result, forKey: "current_date_string")
        //                UserDefaults.standard.synchronize()
        //                return true
        //            }
        //            else
        //            {
        //                return false
        //            }
        //        }
        //        else
        //        {
        //            UserDefaults.standard.set(result, forKey: "current_date_string")
        //            UserDefaults.standard.synchronize()
        //            return true
        //        }
    }
    //MARK: Show Ads
    //MARK: Show Ads
    @objc func showIntertialAds()
    {
        //print("-- Pages Screen--")
      //  interstitialAdHelper.loadInterstitial()
      //  interstitialAdHelper.delegate = self
        interstitialAdHelper.showIntersialAd(viewController: self)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.imageData =  self.appDelegate.selectedImageData
        
        //self.imageArray[index]
        self.navigationController?.pushViewController(vc, animated: true);
        
    }
    
    @objc func showRewardedAds()
    {
       // self.rewardedAdHelper.rewardId = PAGES_MY_WORK_REWARD_Id
       // print("---- Pages Screen ----")
       // self.rewardedAdHelper.loadRewardedAd(adId: PAGES_MY_WORK_REWARD_Id)
      //  self.rewardedAdHelper.delegate = self
        self.rewardedAdHelper.showRewardedAd(viewController: self)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.imageData =  self.appDelegate.selectedImageData
        
        //self.imageArray[index]
        self.navigationController?.pushViewController(vc, animated: true);
        
    }
    
    func GotoHome(action: UIAlertAction){self.isVideoViewOpen = true
        self.isVideoViewOpen = false
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.imageData = _imageData
        self.getCategoryNameAndIndex(name: _imageData.category!)
        self.navigationController?.pushViewController(vc, animated: true);
        
    }
    
    fileprivate func PlayVideo() {
        self.isVideoViewOpen = false
        DispatchQueue.main.async {
            if #available(iOS 10.0, *) {
                //self.appDelegate.selectedImageData = _imageData
                // DBHelper.sharedInstance.saveImageInDb(imgData: self._imageData, isUploadToiCloud: true)
                DBHelper.sharedInstance.saveImageInDb(imgData: self.appDelegate.selectedImageData, isUploadToiCloud: true)
            } else {
                // Fallback on earlier versions
            }
            
            // UserDefaults.standard.set(0, forKey: "sessionTime")
            // UserDefaults.standard.synchronize()
            
        }
    }
    
    func didFailToLoadWithError(error: Error) {
        
        self.adRequestInProgress = false
        self.isVideoViewOpen = false
        
        if(self.shouldShowRewardedVideo)
        {
            DispatchQueue.main.async {
                self.appDelegate.logEvent(name: "No_Fill_pg", category: "Video", action: "PagesVC")
                self.appDelegate.logEvent(name: "No_Reward_PG", category: "Video", action: "PG")
                
                self.shouldShowRewardedVideo = false
                print("Reward based video ad failed to load: \(error.localizedDescription)")
                
                if let rootViewController = UIApplication.topViewController() {
                    if rootViewController is PagesVC
                    {
                        let alertController = UIAlertController(title: "Try again!", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: self.GotoHome )
                        alertController.addAction(defaultAction)
//                        if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
//                            if let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
//                                mainWindow.rootViewController?.present(alertController, animated: true, completion: nil)
//                            }
//                        }
                        
                        if #available(iOS 13.0, *) {
                            // Use connectedScenes for iOS 13.0 and later
                            if let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                                if let mainWindow = windowScene.windows.first(where: { $0.isKeyWindow }) {
                                    if let rootViewController = mainWindow.rootViewController {
                                        rootViewController.present(alertController, animated: true, completion: nil)
                                    }
                                }
                            }
                        } else {
                            // Use alternative approach for iOS 11.3 and earlier
                            if let mainWindow = UIApplication.shared.keyWindow {
                                if let rootViewController = mainWindow.rootViewController {
                                    rootViewController.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }


                    }
                }
                
            }
        }
    }
    
    @objc func rewardBasedVideoAdWillLeaveApplication() {
        self.isVideoViewOpen = false
        print("Reward based video ad will leave application.")
        backgroundOrientation = false
    }
  
    
    func adDidCompletePlaying() {
        self.isVideoViewOpen = false
        self.shouldShowRewardedVideo = false
    }
    
    
    
    func adDidClose() {
        self.isVideoViewOpen = false
        self.shouldShowRewardedVideo = false
    }
    
    @objc func intertialBasedVideoAdDone() {
        self.PlayVideo()
    }
    
    
    @objc func rewardBasedVideoAdDone() {
        self.isVideoViewOpen = false
    }
    
    //MARK:- Check Internet
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
    
    
    //MARK:- IAP NoInterNetConnection View
    func NoConnectionView()
    {
        
        self.addNoInternetView()
        //        if(self.noConnectionVC != nil){
        //            self.noConnectionVC.view.removeFromSuperview()
        //        }
        //        self.noConnectionVC = self.storyboard?.instantiateViewController(withIdentifier: "NoConnectionVC") as! NoConnectionVC
        //        self.noConnectionVC.noConnectionVCDelegate = self
        //        self.noConnectionVC.view.frame = UIScreen.main.bounds
        //
        //        UIApplication.shared.keyWindow?.insertSubview(self.noConnectionVC.view, at: self.view.subviews.count )
        
    }
    func crossBtnNoConnectionTapDelegate(sender: UIButton) {
        
        self.noConnectionVC.view.removeFromSuperview()
        
    }
    
    func tryBtnTappedDelegate(sender: UIButton) {
        self.noConnectionVC.view.removeFromSuperview()
        if self.isInternetAvailable()
        {
            print("SHOW ADS TRUEEE")
            self.showInterstialAndRewardedAds(isreward:isreward)
            return
        }
        
        
    }
    
    
    //MARK:- IAP addNoInternetView View
    func addNoInternetView()
    {
        if isHintPaintVisible == 0
        {
            appDelegate.logEvent(name: "No_Internet_Pg", category: "No_Internet", action: "Show_Ads")
            
            isHintPaintVisible = 1
            let window = UIApplication.shared.keyWindow!
            let screenSize: CGRect = UIScreen.main.bounds
            self.tipsView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
            self.tipsView.backgroundColor = UIColor.clear
            self.tipsView.alpha = 1.0
            window.addSubview(self.tipsView);
            
            var width_white : CGFloat = 300
            var height_white : CGFloat = 431
            let offset : CGFloat = 10
            var fontSizeWithBold : UIFont = UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight(rawValue: 0.7))
            var fontSizeWithNormal : UIFont = UIFont.systemFont(ofSize: 11.0)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                width_white = 500
                height_white = 718
                if self.view.frame.width > self.view.frame.height{
                    print("landscape")
                    width_white = height_white/1.436
                    height_white = self.view.frame.height * 0.75
                }
                fontSizeWithBold = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight(rawValue: 0.7))
                fontSizeWithNormal = UIFont.systemFont(ofSize: 18.0)
                //                fontSizeWithBold = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight(rawValue: 0.7))
                //                fontSizeWithNormal = UIFont.systemFont(ofSize: 15.0)
            }
            let x_white : CGFloat = (screenSize.width - width_white) / 2
            let y_white : CGFloat = (screenSize.height - height_white) / 2
            
            let whiteRect = CGRect(x: x_white, y: y_white, width: width_white, height: height_white)
            var crossButtonRect = CGRect(x: offset, y: offset, width: offset*3, height: offset*3)
            var tipsLblRect = CGRect(x: 0, y: (height_white - offset) / 2, width: width_white, height: offset*7)
            var watchButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 125, width: width_white - (offset*8), height: offset*6)
            var proButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 55, width: width_white - (offset*8), height: offset*6)
            
            var imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                crossButtonRect = CGRect(x: offset, y: offset, width: offset*4, height: offset*4)
                tipsLblRect = CGRect(x: 0, y: height_white / 2, width: width_white, height: offset*9)
                watchButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 210, width: width_white - (offset*14), height: offset*9)
                // proButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 95, width: width_white - (offset*14), height: offset*9)
                proButtonRect = CGRect(x: offset*7, y: (height_white) - (offset*9 + 10), width: width_white - (offset*14), height: offset*9)
                imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
                
                if self.view.frame.width > self.view.frame.height{ // landscape
                    crossButtonRect = CGRect(x: offset*6, y: offset, width: offset*4, height: offset*4)
                    watchButtonRect = CGRect(x: offset*7, y: (height_white * 0.78), width: width_white - (offset*14), height: offset*9)
                    //proButtonRect = CGRect(x: offset*7, y: (height_white * 0.61), width: width_white - (offset*14), height: offset*9)
                    proButtonRect = CGRect(x: offset*7, y: (height_white - (offset*9+10)), width: width_white - (offset*14), height: offset*9)
                }
            }
            
            //TransParent View
            var blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            blackView.backgroundColor = UIColor.black
            blackView.alpha = 0.3
            self.tipsView.addSubview(blackView)
            
            //WhiteView
            let whiteView = UIView(frame: whiteRect)
            self.tipsView.addSubview(whiteView)
            self.tipsView.bringSubview(toFront: whiteView)
            
            //BackgroundImage
            var bgImage: UIImage!
            var tipsTextString: String!
            bgImage = UIImage(named: "internet1_iphone")
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                if self.view.frame.height > self.view.frame.width{
                    print("potrait")
                    bgImage = UIImage(named: "internet1_ipad_v")
                }else{
                    print("lanscape")
                    bgImage = UIImage(named: "internet1_ipad_v")
                }
            }
            let str1 = NSLocalizedString("Oops", comment: "")
            let str2 = NSLocalizedString("\n", comment: "")
            let str3 = NSLocalizedString("No Internet Connection", comment: "")
            let str4 = NSLocalizedString("Please try again", comment: "")
            tipsTextString = str1 + str2 + str3 + str2 + str4
            
            let tipsImageView = UIImageView(frame: imageRect)
            tipsImageView.image = bgImage
            tipsImageView.contentMode = .scaleAspectFit
            whiteView.addSubview(tipsImageView)
            
            //CancelButton
            let crossButton = UIButton(frame: crossButtonRect)
            crossButton.setImage(UIImage(named: "cancel_subs"), for: UIControlState.normal)
            crossButton.addTarget(self, action:#selector(self.removeTipsView), for: .touchUpInside)
            whiteView.addSubview(crossButton)
            whiteView.bringSubview(toFront: crossButton)
            //TextLabel
            let tipsLabel = UILabel(frame: tipsLblRect)
            tipsLabel.text = tipsTextString
            tipsLabel.textAlignment = NSTextAlignment.center
            tipsLabel.textColor = UIColor.black
            tipsLabel.numberOfLines = 3
            tipsLabel.font = fontSizeWithBold
            whiteView.addSubview(tipsLabel)
            //RetryButton
            let retryButton = UIButton(frame: watchButtonRect)
            retryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
            retryButton.setTitleColor(UIColor.white, for: .normal)
            retryButton.titleLabel?.font = fontSizeWithBold
            retryButton.titleLabel?.textAlignment  = NSTextAlignment.center
            retryButton.addTarget(self, action:#selector(retryButtonClicked), for: .touchUpInside)
            whiteView.addSubview(retryButton)
            
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                {
                    self.tipsView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            }, completion:  nil)
        }
    }
    
    
    //MARK:- Retry button Clicked
    @objc func retryButtonClicked()
    {
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                                {
                                    let screenSize: CGRect = UIScreen.main.bounds
                                    self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                                }, completion: { (finished: Bool) in
                                    self.tipsView.removeFromSuperview()
                                    self.isHintPaintVisible = 0
                                    if self.isInternetAvailable()
                                    {
                                        self.removeTipsView()
                                        self.showInterstialAndRewardedAds(isreward: self.isreward)
                                        return
                                    }
                                    else
                                    {
                                        if (self.isHintPaintVisible == 1 && self.tipsView != nil)
                                        {
                                            self.tipsView.removeFromSuperview()
                                            self.isHintPaintVisible = 0
                                            self.addNoInternetView()
                                        }else
                                        {
                                            self.addNoInternetView()
                                        }
                                    }
                                })

    }
    
    //MARK:- Remove Tips View
    @objc func removeTipsView()
    {
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
            {
                let screenSize: CGRect = UIScreen.main.bounds
                self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        }, completion: { (finished: Bool) in
            self.isHintPaintVisible = 0
            self.isPaintBucketDisplay = false
            self.tipsView.removeFromSuperview()
        })
        
        
        
    }
    
//    func launchImage() -> UIImage? {
//
//        guard let launchImages = Bundle.main.infoDictionary?["UILaunchImages"] as? [[String: Any]] else { return nil }
//
//        let screenSize = UIScreen.main.bounds.size
//
//        var interfaceOrientation: String
//        switch UIApplication.shared.statusBarOrientation {
//        case .portrait,
//             .portraitUpsideDown:
//            interfaceOrientation = "Portrait"
//        default:
//            interfaceOrientation = "Landscape"
//        }
//
//        for launchImage in launchImages {
//
//            guard let imageSize = launchImage["UILaunchImageSize"] as? String else { continue }
//            let launchImageSize = CGSizeFromString(imageSize)
//
//            guard let launchImageOrientation = launchImage["UILaunchImageOrientation"] as? String else { continue }
//
//            if
//                launchImageSize.equalTo(screenSize),
//                launchImageOrientation == interfaceOrientation,
//                let launchImageName = launchImage["UILaunchImageName"] as? String {
//                return UIImage(named: launchImageName)
//            }
//        }
//
//        return nil
//    }
//
    //    func setInCompleteImageReminder()
    //    {
    //        let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
    //        if isRegisteredForRemoteNotifications {
    //
    //            var completedID = [String]()
    //            let defaults = UserDefaults.standard
    //
    //            if defaults.array(forKey: "mywork_completed_id") != nil {
    //                completedID = (defaults.array(forKey: "mywork_completed_id")  as? [String])!
    //            }
    //
    //            let dbHelper = DBHelper.sharedInstance
    //            var imageArrayTemp = dbHelper.getMyWorkImages()
    //            var tempImageData = [ImageData]()
    //
    //            //Remove Complete Data.
    //            for imageDataTemp in imageArrayTemp
    //            {
    //                if (!completedID.contains(imageDataTemp.imageId!))
    //                {
    //                    tempImageData.append(imageDataTemp)
    //                }
    //            }
    //            imageArrayTemp = tempImageData
    //            tempImageData.removeAll()
    //            //End
    //
    //            var assignNotiCount = 1
    //            var imageDataItemObject = [ImageDataItem]()
    //            var imageDataItemId = [String]()
    //            var doneString = UserDefaults.standard.string(forKey: "doneNotificationString") ?? ""
    //
    //            var doneStringArray = [String]()
    //            if doneString != "" {
    //                doneStringArray = self.stringToStringArray(value: doneString)
    //            }
    //            if imageArrayTemp.count > 0 {
    //                for index in 0...imageArrayTemp.count-1 {
    //                    if assignNotiCount <= MAX_NOTIFICATION_COUNT {
    //                        if !(doneString.contains(imageArrayTemp[index].imageId!)) {
    //                            imageDataItemObject.append(ImageDataItem(imageId: imageArrayTemp[index].imageId!, category: imageArrayTemp[index].category!,name: imageArrayTemp[index].name!, UUID: UUID().uuidString, level: imageArrayTemp[index].level!, position: imageArrayTemp[index].position!, purchase: imageArrayTemp[index].purchase!))
    //                            imageDataItemId.append(imageArrayTemp[index].imageId!)
    //                            doneStringArray.append(imageArrayTemp[index].imageId!)
    //                            assignNotiCount += 1
    //                        }
    //                    }
    //                }
    //            }
    //
    //            print(imageDataItemObject.count)
    //            if imageDataItemObject.count < MAX_NOTIFICATION_COUNT {
    //
    //                UserDefaults.standard.set("", forKey: "doneNotificationString")
    //                doneStringArray = imageDataItemId
    //                doneString = self.stringArrayToString(value: imageDataItemId)
    //                if imageArrayTemp.count > 0 {
    //                    for index in 0...imageArrayTemp.count-1 {
    //                        if assignNotiCount <= MAX_NOTIFICATION_COUNT {
    //                            if !(doneString.contains(imageArrayTemp[index].imageId!)) {
    //                                imageDataItemObject.append(ImageDataItem(imageId: imageArrayTemp[index].imageId!, category: imageArrayTemp[index].category!,name: imageArrayTemp[index].name!, UUID: UUID().uuidString, level: imageArrayTemp[index].level!, position: imageArrayTemp[index].position!, purchase: imageArrayTemp[index].purchase!))
    //                                imageDataItemId.append(imageArrayTemp[index].imageId!)
    //                                doneStringArray.append(imageArrayTemp[index].imageId!)
    //                                assignNotiCount += 1
    //                            }
    //                        }
    //                    }
    //                }
    //            }
    //
    //            let saveString = self.stringArrayToString(value: doneStringArray)
    //            UserDefaults.standard.set(saveString, forKey: "doneNotificationString")
    //            print("Save string : \(saveString)")
    //            print(imageDataItemObject)
    //
    //            var timeDelay = timeDelayValue
    //            for sendObject in imageDataItemObject {
    //                ImageReminder.sharedInstance.addNotificationItem(sendObject, timeValue: timeDelay)
    //                timeDelay += timeDelayValue
    //            }
    //
    //        }
    //    }
    
    //    func stringArrayToString(value:[String]) -> String{
    //        return value.joined(separator: ",")
    //    }
    //
    //    func stringToStringArray(value:String) -> [String]{
    //        return value.components(separatedBy: ",")
    //    }
    
    
    func applyTopViewScrolling() {
        
        isTopScrolllingApplied = true
        self.topTimer?.invalidate()
        self.topTimer = nil
        self.topTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.autoScrollTopView), userInfo: nil, repeats: true)
        
    }
    
    func removeTopViewScrolling() {
        
        isTopScrolllingApplied = false
        self.topTimer?.invalidate()
        self.topTimer = nil

    }
    
    @objc func autoScrollTopView() {
        if (appDelegate.isReloadNeeded) {
            
            self.reloadView()
        }
        if isTopShowOrNot == true {
            if topCounter < 7 {
                if let index = IndexPath.init(item: topCounter, section: 0) as? IndexPath {
                    if index.item < topCollectionView.numberOfItems(inSection: 0) {
                        if (self.topCollectionView.indexPathsForVisibleItems.contains(index)) {
                            self.topCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                            topCounter += 1
                        }
                    }
                }
            }
            else {
                topCounter = 0
                if let index = IndexPath.init(item: topCounter, section: 0) as? IndexPath {
                    if index.item < topCollectionView.numberOfItems(inSection: 0) {
                        if !(self.topCollectionView.indexPathsForVisibleItems.contains(index)) {
                            self.topCollectionView.scrollToItem(at: index, at: .centeredHorizontally, animated: true)
                            topCounter = 1
                        }
                    }
                }
            }
        }
    }
    
    
    func setStatusBarColor(color: UIColor) {
        
        if #available(iOS 13.0, *) {
            let app = UIApplication.shared
            let statusBarHeight: CGFloat = app.statusBarFrame.size.height
            
            let statusbarView = UIView()
            statusbarView.backgroundColor = color
            
            view.addSubview(statusbarView)
            
            statusbarView.translatesAutoresizingMaskIntoConstraints = false
            statusbarView.heightAnchor
                .constraint(equalToConstant: statusBarHeight).isActive = true
            statusbarView.widthAnchor
                .constraint(equalTo: view.widthAnchor, multiplier: 1.0).isActive = true
            statusbarView.topAnchor
                .constraint(equalTo: view.topAnchor).isActive = true
            statusbarView.centerXAnchor
                .constraint(equalTo: view.centerXAnchor).isActive = true
            
        } else {
            let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView
            statusBar?.backgroundColor = color
            
        }
        
    }
    
    //MARK: Config Value Fetch.
    func fetchConfig() {
        let expirationDuration = 3600
        remoteConfig.fetch(withExpirationDuration: TimeInterval(expirationDuration)) { (status, error) -> Void in
            if status == .success {
                print("Config fetched!")
                self.remoteConfig.activate { (status, error) in
                    DispatchQueue.main.async {
                        self.fetchConfigValues()
                        
                        let isAdTrackingPromptAuthorizationValue = UserDefaults.standard.bool(forKey: isAdTrackingPromptAuthorization)
                        if !isAdTrackingPromptAuthorizationValue {
                            if #available(iOS 14, *) {
                                if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                                    self.setComplianceWindowAndAdTrackingValues()
                                    print("trackingAuthorizationStatus notDetermined")
                                }
                                else if ATTrackingManager.trackingAuthorizationStatus == .restricted {
                                    self.setComplianceWindowAndAdTrackingValues()
                                    print("trackingAuthorizationStatus restricted")
                                }
                                else if ATTrackingManager.trackingAuthorizationStatus == .denied {
                                    self.setComplianceWindowAndAdTrackingValues()
                                    print("trackingAuthorizationStatus denied")
                                }
                                
                            }
                        }
                    }
                }
            } else {
                DispatchQueue.main.async{
                    print("Config not fetched")
                    print("Error: \(error?.localizedDescription ?? "No error available.")")
                }
            }
        }
    }
    
    func setComplianceWindowAndAdTrackingValues() {
        
        let ad_TrackingConfigKey = "Ad_Tracking"
        appDelegate.adTrackingPromptValue = remoteConfig[ad_TrackingConfigKey].numberValue as! Int
        print("Fetch and Active Ad_Tracking value = \(remoteConfig[ad_TrackingConfigKey].numberValue as! Int)")
        timerForComplianceWindowFetch?.invalidate()
        timerForComplianceWindowFetch = nil
        loadWithOutLiveValues()
        
    }


    func fetchDefaultConfigValue() {

        guard let URL = Bundle.main.url(forResource: "RemoteConfigDefaults", withExtension: "plist"),
              let remoteConfigDefaultsDict = NSDictionary(contentsOf: URL) else {
            return
        }
        
        let rewardToolsConfigKey = "reward_tools"
        let reminderTimeConfigKey = "reminder_time"
        let reminderTime1ConfigKey = "reminder_time1"
        let rewardTimeConfigKey = "rewardTime"
        let interstitialTimeConfigKey = "interstitialTime"
        let currentToolWindowConfigKey = "current_tool_window"
        let purchasessConfigkey = "purchase_ss"
        let newWindowConfigkey = "new_window"
        let mystery_winConfigKey = "Mystery_win"
        let reminder_time = remoteConfigDefaultsDict.value(forKey: reminderTimeConfigKey) as! Int
        let reminder_time1 = remoteConfigDefaultsDict.value(forKey:reminderTime1ConfigKey) as! Int
        let reward_tools = remoteConfigDefaultsDict.value(forKey: rewardToolsConfigKey) as! Int
        let rewardTime = remoteConfigDefaultsDict.value(forKey: rewardTimeConfigKey) as! Int
        let interstitialTime = remoteConfigDefaultsDict.value(forKey: interstitialTimeConfigKey) as! Int
        let current_tool_window = remoteConfigDefaultsDict.value(forKey: currentToolWindowConfigKey) as! String
        let color_Number = remoteConfigDefaultsDict.value(forKey: color_number) as! Int
        let bombs = remoteConfigDefaultsDict.value(forKey: bomb_s) as! Int
        let purchase_ss = remoteConfigDefaultsDict.value(forKey: purchasessConfigkey) as! Int
        let newWindow = remoteConfigDefaultsDict.value(forKey: newWindowConfigkey) as! Int
        let mystery_win = remoteConfigDefaultsDict.value(forKey: mystery_winConfigKey) as! Int
        
        UserDefaults.standard.set(reminder_time, forKey: inActiveReminderTimeKey)
        UserDefaults.standard.set(reminder_time1, forKey: InActiveReminderTimeKey1)
        UserDefaults.standard.set(reward_tools, forKey: InActiveRewardToolsKey)
        UserDefaults.standard.set(rewardTime, forKey: InActiveRewardTimeKey)
        UserDefaults.standard.set(interstitialTime, forKey: InActiveInterstitialTimeKey)
        UserDefaults.standard.set(current_tool_window, forKey: InActiveCurrentToolWindowKey)
        UserDefaults.standard.set(color_Number, forKey: color_numberActive)
        UserDefaults.standard.set(bombs, forKey: bomb_sActive)
        UserDefaults.standard.set(purchase_ss, forKey: purchasessActiveKey)
        UserDefaults.standard.set(newWindow, forKey: inactiveNewWindow)
        UserDefaults.standard.set(mystery_win, forKey: inactiveMysteryWindow)
       // getConfigValueDB(labelValue: "Set Default from RemoteConfigDefaults.plist")

    }
    
    func getConfigValueDB(labelValue: String = "Activate previous fetch values") {
        
        reminderTime = UserDefaults.standard.integer(forKey: reminderTimeKey)
        reminderTime1 = UserDefaults.standard.integer(forKey: reminderTime1Key)
        rewardTools = UserDefaults.standard.integer(forKey: rewardToolsKey)
        rewardTime = UserDefaults.standard.integer(forKey: rewardTimeKey)
        interstitialTime = UserDefaults.standard.integer(forKey: interstitialTimeKey)
        currentToolWindow = UserDefaults.standard.string(forKey: currentToolWindowKey) ?? ""
        colorNumber =  UserDefaults.standard.integer(forKey: color_number)
        bomb_sNumber =  UserDefaults.standard.integer(forKey: bomb_s)
        purchasess = UserDefaults.standard.integer(forKey: purchasessKey)
        new_windowNumber =  UserDefaults.standard.integer(forKey: newWindow)
        new_windowNumber =  UserDefaults.standard.integer(forKey: newWindow)
        mysteryWinNumber =  UserDefaults.standard.integer(forKey: mysteryWin)
        print("\(labelValue)\nrewardTime = \(rewardTime)\ninterstitialTime = \(interstitialTime)\ncurrent_tool_window = \(currentToolWindow)\nreminder_time1 = \(reminderTime1)\nreminder_time = \(reminderTime)\nrewardTools = \(rewardTools)\nColor_number = \(colorNumber)\nBomb_s = \(bomb_sNumber)\npurchase_ss = \(purchasess)\nnew_winodw = \(new_windowNumber)\nmystery_Win = \(mysteryWinNumber)")

    }

    
    func fetchConfigValues() {
        
        let rewardToolsConfigKey = "reward_tools"
        let reminderTimeConfigKey = "reminder_time"
        let reminderTime1ConfigKey = "reminder_time1"
        let rewardTimeConfigKey = "rewardTime"
        let interstitialTimeConfigKey = "interstitialTime"
        let currentToolWindowConfigKey = "current_tool_window"
        
        let colorNumberConfigKey = "Color_number"
        let bomb_sConfigKey = "Bomb_s"
        let purchasessConfigkey = "purchase_ss"
        let new_windowConfigKey = "new_window"
        let mystery_winConfigKey = "Mystery_win"
        let rewardTime = Int64(remoteConfig[rewardTimeConfigKey].numberValue as! Int)
        let reminder_time1 = Int64(remoteConfig[reminderTime1ConfigKey].numberValue as! Int)
        let interstitialTime = Int64(remoteConfig[interstitialTimeConfigKey].numberValue as! Int)
        let reminder_time = Int64(remoteConfig[reminderTimeConfigKey].numberValue as! Int)
        let reward_tools = Int64(remoteConfig[rewardToolsConfigKey].numberValue as! Int)
        
        let Color_number = Int64(remoteConfig[colorNumberConfigKey].numberValue as! Int)
        let Bomb_s = Int64(remoteConfig[bomb_sConfigKey].numberValue as! Int)
        let new_window = Int64(remoteConfig[new_windowConfigKey].numberValue as! Int)
        let purchase_ss = Int64(remoteConfig[purchasessConfigkey].numberValue as! Int)
        let Mystery_win = Int64(remoteConfig[mystery_winConfigKey].numberValue as! Int)
        
        var currentToolWindowValue = "tool_win_1"
        if let current_tool_window_value = remoteConfig[currentToolWindowConfigKey].stringValue {
            currentToolWindowValue = current_tool_window_value
        }
        else {
            guard let URL = Bundle.main.url(forResource: "RemoteConfigDefaults", withExtension: "plist"),
                  let remoteConfigDefaultsDict = NSDictionary(contentsOf: URL) else {
                return
            }
            currentToolWindowValue = remoteConfigDefaultsDict.value(forKey: currentToolWindowConfigKey) as! String
        }
        
        let current_tool_window = currentToolWindowValue
    
        UserDefaults.standard.set(reminder_time, forKey: inActiveReminderTimeKey)
        UserDefaults.standard.set(reminder_time1, forKey: InActiveReminderTimeKey1)
        UserDefaults.standard.set(reward_tools, forKey: InActiveRewardToolsKey)
        UserDefaults.standard.set(rewardTime, forKey: InActiveRewardTimeKey)
        UserDefaults.standard.set(interstitialTime, forKey: InActiveInterstitialTimeKey)
        UserDefaults.standard.set(current_tool_window, forKey: InActiveCurrentToolWindowKey)
        UserDefaults.standard.set(Bomb_s, forKey: bomb_sActive)
        UserDefaults.standard.set(Color_number, forKey: color_numberActive)
        UserDefaults.standard.set(purchase_ss, forKey: purchasessActiveKey)
        UserDefaults.standard.set(new_window, forKey: inactiveNewWindow)
        UserDefaults.standard.set(Mystery_win, forKey: inactiveMysteryWindow)
        
        print("Current config fetch value\nrewardTime = \(rewardTime)\ninterstitialTime = \(interstitialTime)\ncurrent_tool_window = \(current_tool_window)\nreminder_time1 = \(reminder_time1)\nreminder_time = \(reminder_time)\nreward_tools = \(reward_tools)\nColor_number = \(Color_number)\nBomb_s = \(Bomb_s)\npurchase_ss = \(purchase_ss)\nnew_window = \(new_window)\nmystery_Win = \(Mystery_win)")
    }
    
    //MARK: Download n image of each category first, then np category image start
    var imagesCategoryArray = [CategoryStringModel]()
    var tempCategoryArray = [String]()
    let numberOfImage = 6
    var timerForInitialDelay: Timer?
    var timerForComplianceWindowFetch: Timer?

    @objc func performFetch() {
        
        downloadNImagesForCategory()
        
    }
    
    func downloadNImagesForCategory() {
        
        if let path = appDelegate.serverPlistPath() {
            
            if let array = NSArray(contentsOfFile: path) as? [[String: Any]] {
                
                imagesCategoryArray.removeAll()
                
                for arr in array {
                    let dict =  arr as NSDictionary
                    getImagesCategoryData(imageDict: dict)
                }
                
                tempCategoryArray.removeAll()
                
                for value in imagesCategoryArray {
                    
                    for index in 0...value.categoryImages.count - 1 {
                        
                        if appDelegate.getImage(imgName: value.categoryImages[index], imageId: value.categoryImagesId[index]) != nil {
                            
                        }
                        else {
                            DispatchQueue.global(qos: .background).async {
                                self.loadServerImageForCategory(name: "\(value.categoryImages[index])" as NSString)
                            }
                        }
                        
                    }
                }
                
                let filteredNpItems = array.filter { $0["np"] != nil }
                for arr in filteredNpItems {
                    let dict =  arr as NSDictionary
                    
                    let categoryName  =  dict.value(forKey: "category") as! String
                    let imageName      =     dict.value(forKey: "name") as! String
                    
                    var level :String = ""
                    let gameLevel =     dict.value(forKey: "level")
                    if let levels = gameLevel {
                        level     =     String(describing:levels )
                    }
                    
                    let imageId = categoryName+"_"+level+"_"+imageName
                    
                    if appDelegate.getImage(imgName: imageName, imageId: imageId) != nil {
                        
                    }
                    else {
                        DispatchQueue.global(qos: .background).async {
                            self.loadServerImageForCategory(name: "\(imageName)" as NSString)
                        }
                    }
                    
                }
                
            }
            else {
                print("Fail to fetch list.")
                timerForInitialDelay?.invalidate()
                timerForInitialDelay = nil
                timerForInitialDelay = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.performFetch), userInfo:nil, repeats:false)
            }
        }
        else {
            print("Fail to fetch list.")
            timerForInitialDelay?.invalidate()
            timerForInitialDelay = nil
            timerForInitialDelay = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.performFetch), userInfo:nil, repeats:false)
        }
        
    }
    
    func getImagesCategoryData(imageDict: NSDictionary) {
        
        let categoryName  =  imageDict.value(forKey: "category") as! String
        let imageName      =     imageDict.value(forKey: "name") as! String
        
        var level :String = ""
        let gameLevel =     imageDict.value(forKey: "level")
        if let levels = gameLevel {
            level     =     String(describing:levels )
        }
        
        let imageId = categoryName+"_"+level+"_"+imageName
        if tempCategoryArray.count <= 25 {
        if !tempCategoryArray.contains(categoryName) {
            tempCategoryArray.append(categoryName)
            imagesCategoryArray.append(CategoryStringModel(categoryName: categoryName, categoryImages: [imageName], categoryImagesId: [imageId]))
        }
        else {
            if let indexValue = imagesCategoryArray.firstIndex(where: {$0.categoryName == categoryName}) {
                if imagesCategoryArray[indexValue].categoryImages.count < numberOfImage {
                    imagesCategoryArray[indexValue].categoryImages.append(imageName)
                    imagesCategoryArray[indexValue].categoryImagesId.append(imageId)
                }
            }
        }
        }
        
    }
    
    func loadServerImageForCategory(name: NSString) {
        
        let thumName = NSString(format:"t_%@",name)
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
        
        let recordID2 = CKRecordID(recordName:name.deletingPathExtension)
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
    //End: Download n image of each category first, then np category image start.
    
    
    //MARK: Daily Gift Feature Code.
    func showAdTrackingWindow() {

        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        let isAdTrackingPromptAuthorizationValue = UserDefaults.standard.bool(forKey: isAdTrackingPromptAuthorization)
        
        if appDelegate.adTrackingPromptValue == 1 && !isAdTrackingPromptAuthorizationValue && launchCount > 1 {
            appDelegate.logEvent(name: "Track_1", category: "App Tracking Prompt", action: "App Tracking Prompt display")
            if appdel.pagesVC == nil {
                appdel.pagesVC = self
            }
            appdel.showAdTrackingPrompt(isNeedToShowSubscription: "1")
        }
        else {
            showGiftScreen()
        }

    }
    

    func showGiftScreen() {
        
        var isExpiredString = ""
        if let isExpired = UserDefaults.standard.string(forKey: "IS_EXPIRED") {
            isExpiredString = isExpired
        }
        
        if !(((self.appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpiredString == "NO") || ((self.appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))) {
            
            if let giftClaimCount = UserDefaults.standard.integer(forKey: giftClaimCountValue) as? Int {
                if giftClaimCount < 5 {
                    
                    /*
                     Logic for Day change:
                     let formatter = DateFormatter()
                     formatter.dateFormat = "yyyy-MM-dd"
                     let date1String = "2020-12-08"
                     let date2String = "2020-12-09"
                     let date1 = formatter.date(from: date1String)
                     let date2 = formatter.date(from: date2String)
                     let days = Calendar.current.dateComponents([.day,], from: date1!, to: date2!).day ?? 0
                     print(days)
                     */
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone.current
                    formatter.locale = Locale.current
                    let newDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
                    // newDate = Calendar.current.date(byAdding: .hour, value: -2, to:newDate!)
                    let giftDisplayTimeString = formatter.string(from:newDate!)
                    
                    if let giftDisplayTimeValue = UserDefaults.standard.string(forKey: giftWindowsVisibleTime) {
                        
                        let previousGiftDisplayDate = formatter.date(from: giftDisplayTimeValue)
                        
                        // previousGiftDisplayDate = Calendar.current.date(byAdding: .day, value: -5, to: formatter.date(from: giftDisplayTimeValue)!)
                        // previousGiftDisplayDate = Calendar.current.date(byAdding: .minute, value: 50, to: previousGiftDisplayDate!)
                        
                        let nowDate = formatter.date(from: giftDisplayTimeString)!
                        
                        print("GIFT PREVIOUS DATE:- \(previousGiftDisplayDate!)")
                        print("GIFT NOW DATE:- \(nowDate)")
                        
                        print("CURRENT TIME ZONE - GIFT PREVIOUS DATE:- \(giftDisplayTimeValue)")
                        print("CURRENT TIME ZONE - GIFT NOW DATE:- \(giftDisplayTimeString)")
                        
                        
                        let compValue = getCompareValue(previousGiftDisplayDate: previousGiftDisplayDate!, nowDate: nowDate)
                        
                        if compValue != -1 {
                            
                            if compValue >= giftTimeDelayValue {
                                UserDefaults.standard.set("\(giftDisplayTimeString)", forKey: giftWindowsVisibleTime)
                                if compValue >= 2*giftTimeDelayValue {
                                    UserDefaults.standard.set(0, forKey: giftClaimCountValue)
                                }
                                self.showGiftWindow()
                            }
                            else {
                                self.appDelegate.checkForRemoteNotificationIsEnabled()
                            }
                        }
                        else {
                            self.appDelegate.checkForRemoteNotificationIsEnabled()
                        }
                    }
                    else {
                        UserDefaults.standard.set("\(giftDisplayTimeString)", forKey: giftWindowsVisibleTime)
                        self.showGiftWindow()
                    }
                }
                else {
                    self.appDelegate.checkForRemoteNotificationIsEnabled()
                }
            }
            else {
                self.appDelegate.checkForRemoteNotificationIsEnabled()
            }
        }
        else {
            self.appDelegate.checkForRemoteNotificationIsEnabled()
        }
        
    }
    
    func addRewardAfter5Days() {
        
        //Set daily gift value if complete 5 days.
        if let giftClaimCount = UserDefaults.standard.integer(forKey: giftClaimCountValue) as? Int {
            if giftClaimCount == 5 {
                
                //                if let currentHintCountValue = UserDefaults.standard.integer(forKey: "GIFT_HINT_COUNT") as? Int {
                let hintCountValue = hints12Reward
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let nowTimeString = formatter.string(from: Date())
                
                if let giftDisplayTimeValue = UserDefaults.standard.string(forKey: giftWindowsVisibleTime) {
                    
                    let previousGiftDisplayDate = formatter.date(from: giftDisplayTimeValue)
                    let nowDate = formatter.date(from: nowTimeString)
                    
                    let compValue = getCompareValue(previousGiftDisplayDate: previousGiftDisplayDate!, nowDate: nowDate!)

                    if compValue != -1 {

                        if (compValue == adsTimeDelayValue) {
                            UserDefaults.standard.set("\(nowTimeString)", forKey: giftWindowsVisibleTime)
                            UserDefaults.standard.set(hintCountValue, forKey: "GIFT_HINT_COUNT")
                        }
                        else if compValue >= 2*adsTimeDelayValue {
                            UserDefaults.standard.set(0, forKey: "GIFT_HINT_COUNT")
                            UserDefaults.standard.set(0, forKey: giftClaimCountValue)
                            UserDefaults.standard.set(nil, forKey: giftWindowsVisibleTime)
                        }
                    }
                }
                //                }
            }
        }
    }
    
    func getCompareValue(previousGiftDisplayDate: Date, nowDate: Date) -> Int {
        //let previousGiftDisplayDate = previousGiftDisplayDate.localDate(date: previousGiftDisplayDate)
        //let nowDate = nowDate.localDate()
        var compValue = -1
      
        if adsTimeComponent == .second {
            if let comp = Calendar.current.dateComponents([adsTimeComponent,Calendar.Component.timeZone], from: previousGiftDisplayDate, to: nowDate).second {
                compValue = comp
            }
        }
        else if adsTimeComponent == .minute {
            if let comp = Calendar.current.dateComponents([adsTimeComponent], from: previousGiftDisplayDate, to: nowDate).minute {
                compValue = comp
            }
        }
        else if adsTimeComponent == .hour {
            if let comp = Calendar.current.dateComponents([adsTimeComponent], from: previousGiftDisplayDate, to: nowDate).hour {
                compValue = comp
            }
        }
        else if adsTimeComponent == .day {
           
            compValue =  dayDifferance(previousGiftDisplayDate: previousGiftDisplayDate, nowDate: nowDate)
//            if let comp = Calendar.current.dateComponents([giftTimeComponent,Calendar.Component.timeZone], from: previousGiftDisplayDate, to: nowDate).day {
//                compValue = comp
//
////                let notifyTime = Calendar.current.dateComponents(in: TimeZone.current, from: previousGiftDisplayDate)
////                let year = notifyTime.year
////                let month = notifyTime.month
////                let day = notifyTime.day
////
////                print(notifyTime)
//            }
        }
        
        return compValue

    }
    
    func dayDifferance( previousGiftDisplayDate: Date, nowDate: Date) -> Int{

        let dateComponents = Calendar.current.dateComponents(in: TimeZone.current, from: previousGiftDisplayDate)
        let current =  Calendar.current.dateComponents(in: TimeZone.current, from: nowDate)
        var compValue = -1
        
        if let comp = Calendar.current.dateComponents([giftTimeComponent,Calendar.Component.timeZone], from: previousGiftDisplayDate, to: nowDate).day {
            compValue =  comp
        }
        if(dateComponents.year == current.year){
            if(dateComponents.month == current.month){
                compValue =  current.day! - dateComponents.day!
                return  compValue
            }
            else if(current.month! > dateComponents.month!){
                
                if(current.month! - dateComponents.month! > 1){
                    compValue = 2
                    return  compValue
                }
            }
        }
        return compValue
    }
   


    func showGiftWindow() {
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DailyGiftViewController") as! DailyGiftViewController
        vc.dailyGiftViewControllerDelegate = self
        vc.modalPresentationStyle = .overFullScreen

        
        self.present(vc,animated:true,completion:nil)

    }

    //MARK: DailyGiftViewControllerDelegate.
    func dailyGiftCrossBtnDelegate() {
        self.appDelegate.checkForRemoteNotificationIsEnabled()
    }

    
    //MARK:Show new paint bucket info popup!
    var isPaintBucketDisplay = false
    func showNewPaintBucketInfoPopup() {

        DispatchQueue.main.async { [weak self] in
            self?.showBucketPopup()
        }

    }

    @objc func showBucketPopup() {
        
        let isNewPaintBucketInfoShow = UserDefaults.standard.bool(forKey: "isNewPaintBucketInfoShow")
        
        if isNewPaintBucketInfoShow == false || isPaintBucketDisplay == true {
            
            isPaintBucketDisplay = true
            
            //            appDelegate.logEvent(name: "No_Internet_Pg", category: "No_Internet", action: "Show_Ads")
            
            let window = UIApplication.shared.keyWindow!
            let screenSize: CGRect = UIScreen.main.bounds
            self.tipsView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
            self.tipsView.backgroundColor = UIColor.clear
            self.tipsView.alpha = 1.0
            window.addSubview(self.tipsView);
            
            var width_white : CGFloat = 300
            var height_white : CGFloat = 431
            let offset : CGFloat = 10
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                width_white = 500
                height_white = 718
                if self.view.frame.width > self.view.frame.height{
                    print("landscape")
                    width_white = height_white/1.436
                    height_white = self.view.frame.height * 0.75
                }
            }
            let x_white : CGFloat = (screenSize.width - width_white) / 2
            let y_white : CGFloat = (screenSize.height - height_white) / 2
            
            let whiteRect = CGRect(x: x_white, y: y_white, width: width_white, height: height_white)
            var crossButtonRect = CGRect(x: offset, y: offset, width: offset*3, height: offset*3)
            var tipsLblRect = CGRect(x: 0, y: (height_white - offset) / 1.75, width: width_white, height: offset*8)
            
            var watchButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 125, width: width_white - (offset*8), height: offset*6)
            var proButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 55, width: width_white - (offset*8), height: offset*6)
            
            var imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
            if UIDevice.current.userInterfaceIdiom == .pad {
                crossButtonRect = CGRect(x: offset, y: offset, width: offset*4, height: offset*4)
                tipsLblRect = CGRect(x: 0, y: height_white / 1.70, width: width_white, height: offset*10)
                watchButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 210, width: width_white - (offset*14), height: offset*9)
                // proButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 95, width: width_white - (offset*14), height: offset*9)
                proButtonRect = CGRect(x: offset*7, y: (height_white) - (offset*9 + 10), width: width_white - (offset*14), height: offset*9)
                imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
                
                if self.view.frame.width > self.view.frame.height{ // landscape
                    crossButtonRect = CGRect(x: offset*7, y: offset, width: offset*4, height: offset*4)
                    tipsLblRect = CGRect(x: 0, y: height_white / 1.8, width: width_white, height: offset*10)
                    watchButtonRect = CGRect(x: offset*7, y: (height_white * 0.78), width: width_white - (offset*14), height: offset*9)
                    //proButtonRect = CGRect(x: offset*7, y: (height_white * 0.61), width: width_white - (offset*14), height: offset*9)
                    proButtonRect = CGRect(x: offset*7, y: (height_white - (offset*9+10)), width: width_white - (offset*14), height: offset*9)
                }
            }
            
            //TransParent View
            let blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
            blackView.backgroundColor = UIColor.black
            blackView.alpha = 0.3
            self.tipsView.addSubview(blackView)
            
            //WhiteView
            let whiteView = UIView(frame: whiteRect)
            self.tipsView.addSubview(whiteView)
            self.tipsView.bringSubview(toFront: whiteView)
            
            //BackgroundImage
            var bgImage: UIImage!
            bgImage = UIImage(named: "paint_note_iphone")
            if UIDevice.current.userInterfaceIdiom == .pad {
                if self.view.frame.height > self.view.frame.width {
                    print("potrait")
                    bgImage = UIImage(named: "paint_note_ipad_v")
                }
                else {
                    print("lanscape")
                    bgImage = UIImage(named: "paint_note_ipad_v")
                }
            }
            
            let tipsImageView = UIImageView(frame: imageRect)
            tipsImageView.image = bgImage
            tipsImageView.contentMode = .scaleAspectFit
            whiteView.addSubview(tipsImageView)
            
            //CancelButton
            let crossButton = UIButton(frame: crossButtonRect)
            crossButton.setImage(UIImage(named: "cancel_subs"), for: UIControlState.normal)
            crossButton.addTarget(self, action:#selector(self.removeTipsView), for: .touchUpInside)
            whiteView.addSubview(crossButton)
            whiteView.bringSubview(toFront: crossButton)
            
            
            var fontSizeWithBold : UIFont = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.semibold)
            var fontSizeWithNormal : UIFont = UIFont.systemFont(ofSize: 14.0, weight: UIFont.Weight.medium)
            if UIDevice.current.userInterfaceIdiom == .pad {
                fontSizeWithBold = UIFont.systemFont(ofSize: 25.0, weight: UIFont.Weight.semibold)
                fontSizeWithNormal = UIFont.systemFont(ofSize: 21.0, weight: UIFont.Weight.medium)
            }
            
            var heightForSpace = UIFont.systemFont(ofSize: 5.0, weight: UIFont.Weight.medium)
            if UIDevice.current.userInterfaceIdiom == .pad {
                heightForSpace = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
            }
            
            
            let attrs1 = [NSAttributedString.Key.font : fontSizeWithBold, NSAttributedString.Key.foregroundColor : UIColor.black]
            
            let attrs2 = [NSAttributedString.Key.font : fontSizeWithNormal, NSAttributedString.Key.foregroundColor : UIColor.black]
            
            let attrs3 = [NSAttributedString.Key.font : heightForSpace, NSAttributedString.Key.foregroundColor : UIColor.black]
            
            let text = NSMutableAttributedString()
            text.append(NSAttributedString(string: NSLocalizedString("New Paint Bucket!", comment: ""), attributes: attrs1));
            text.append(NSAttributedString(string: NSLocalizedString("\n \n", comment: ""), attributes: attrs3));
            text.append(NSAttributedString(string: NSLocalizedString("Feature can be turned", comment: ""), attributes: attrs2))
            text.append(NSAttributedString(string: NSLocalizedString("\n", comment: ""), attributes: attrs2))
            text.append(NSAttributedString(string: NSLocalizedString("off at Settings", comment: ""), attributes: attrs2))
            
            //TextLabel
            let tipsLabel = UILabel(frame: tipsLblRect)
            tipsLabel.attributedText = text
            tipsLabel.textAlignment = NSTextAlignment.center
            tipsLabel.numberOfLines = 5
            whiteView.addSubview(tipsLabel)
            
            //RetryButton
            let retryButton = UIButton(frame: watchButtonRect)
            retryButton.setTitle(NSLocalizedString("OK", comment: ""), for: .normal)
            retryButton.setTitleColor(UIColor.white, for: .normal)
            retryButton.titleLabel?.font = fontSizeWithBold
            retryButton.titleLabel?.textAlignment  = NSTextAlignment.center
            retryButton.addTarget(self, action:#selector(okButtonClicked), for: .touchUpInside)
            whiteView.addSubview(retryButton)
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                                self.tipsView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
                                UserDefaults.standard.set(true, forKey:"isNewPaintBucketInfoShow")
                            }, completion:  nil)
            
            
        }
    }

    //MARK:- ok button Clicked
    @objc func okButtonClicked() {
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
            {
                let screenSize: CGRect = UIScreen.main.bounds
                self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
            }, completion: { (finished: Bool) in
                self.tipsView.removeFromSuperview()
//                self.tabBarController?.selectedIndex = 3
                self.isPaintBucketDisplay = false
        })
    }

}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt32()
        Scanner(string: hex).scanHexInt32(&int)
        let a, r, g, b: UInt32
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
//Mark:- extension didTappedInTableview
extension PagesVC:GifTutorialCloseTappedDelegate {
    func GifTutorialCloseTapped() {
        
        
        if(self.imageDataTutorial != nil)
        {
            _imageData = self.imageDataTutorial
        }
        else{
            _imageData = ImageData()
            _imageData.imageId = "food_fo89.png"
            _imageData.category = "food"
            _imageData.level = "1"
            _imageData.name = "fo89.png"
            _imageData.np = 93
            _imageData.purchase = 0
            _imageData.position = 18
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.imageData = _imageData
        vc.isGifTutorialCloseTapped = true
        self.getCategoryNameAndIndex(name: _imageData.category!)
        
        
        if #available(iOS 10.0, *) {
            DBHelper.sharedInstance.saveImageInDb(imgData: _imageData, isUploadToiCloud: true)
        } else {
            // Fallback on earlier versions
        }
        appDelegate.logEvent(name: "Tutorial_p1", category: "Tutorial", action: "Viewing tutorial 1-4")
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    func GifTutorialGetActiveIndex(activeIndex: Int,toolImage:UIImageView) {
        toolImage.isHidden = true
        //
    }
}


extension UNNotificationAttachment {
    static func create(identifier: String, image: UIImage, options: [NSObject : AnyObject]?) -> UNNotificationAttachment? {
        let fileManager = FileManager.default
        let tmpSubFolderName = ProcessInfo.processInfo.globallyUniqueString
        let tmpSubFolderURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tmpSubFolderName, isDirectory: true)
        do {
            try fileManager.createDirectory(at: tmpSubFolderURL, withIntermediateDirectories: true, attributes: nil)
            let imageFileIdentifier = identifier+".png"
            let fileURL = tmpSubFolderURL.appendingPathComponent(imageFileIdentifier)
            guard let imageData = UIImagePNGRepresentation(image) else {
                return nil
            }
            try imageData.write(to: fileURL)
            let imageAttachment = try UNNotificationAttachment.init(identifier: imageFileIdentifier, url: fileURL, options: options)
            return imageAttachment        } catch {
                print("error " + error.localizedDescription)
        }
        return nil
    }
}


extension Date {
    func localDate() -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: nowUTC) else {return Date()}

        return localDate
    }
    
    func localDate(date:Date) -> Date {
        let nowUTC = Date()
        let timeZoneOffset = Double(TimeZone.current.secondsFromGMT(for: nowUTC))
        guard let localDate = Calendar.current.date(byAdding: .second, value: Int(timeZoneOffset), to: date) else {return Date()}

        return localDate
    }
}


