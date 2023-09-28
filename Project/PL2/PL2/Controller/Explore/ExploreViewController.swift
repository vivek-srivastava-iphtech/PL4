//
//  ExploreViewController.swift
//
//  Created by Saddam Khan on 5/31/21.
//  Copyright © 2021 iPHSTech31. All rights reserved.
//

import UIKit
import SVProgressHUD
import FirebaseRemoteConfig
import AppTrackingTransparency

class ExploreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,DailyGiftViewControllerDelegate, CollectionsCollectionViewDelegate {

    
    @IBOutlet weak var exploreCollectionView: UICollectionView!
    
    
    var groupNameArray = ["Editor's Picks","Journey","Popular","Collections", "Recent"]
    var groupDataArray = [ExploreData]()
    var editorDataArray = [ExploreData]()
    var journeyDataArray = [ExploreData]()
    var popularDataArray = [ExploreData]()
    var collectionsDataArray = [ExploreData]()
    var recentDataArray = [ExploreData]()
    var recentAllDataArray = [ExploreData]()
    var myWorkCategory = [String]()
    var remoteConfig: RemoteConfig!
    //  var isAppJustLunch = "YES"
    var iapSubscriptionView : UIView!
    var loadLaunchView : UIView!
    var isSubscriptionVC :Bool = true
    var isSubscriptionMode :Bool = false
    var launchSubscriptionType:Int = 0 // 1 Launch, 2 Banner, 3 LockThumb
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var subscriptionVC: SubscriptionVC?
    var isSubscriptionViewVisible = 0
    var selectedCategoryIndex = 0
    var prevSelectedIndex = 0
    var dullView = UIView()
    let tagVal = 100
    var _imageData : ImageData!
    var mode = 0
    var freeTrailImageName = ""
    var tipsView : UIView!
    var isHintPaintVisible = 0
    var ismystery_win_Visible = 0
    var completedArr = [ImageData]()
    var isSubscriptionFail = false
    let STARTER_PRODUCT_ID = "com.moomoolab.pl2sp"
    let WEEK_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2wk"
    var MONTH_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2mo"
    let YEAR_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2yr"
    var selectedPurchaseType = 1 // 0 weekly,1 Monthly,2 yearly
    var timerForComplianceWindowFetch: Timer?
    lazy var containerStackView: UIStackView = {
        let spacer = UIView()
        let stackView = UIStackView(arrangedSubviews: [self.view])
        stackView.axis = .vertical
        stackView.spacing = 16.0
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = editorBGColor
        self.exploreCollectionView.backgroundColor = editorBGColor
        loadExploreData()
        
        remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        remoteConfig.setDefaults(fromPlist: "RemoteConfigDefaults")
        
        let currentLaunch = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        if(currentLaunch > 1){
            activatePreviousFetchValues()
            // getConfigValueDB()
            fetchConfig()
        }
        
        self.checkForTheLaunchCounter()
       // isNotificationTap = false
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(reloadExploreView(notification:)), name: NSNotification.Name(rawValue: "orientation_change_explore"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(activePagesTabBar(notification:)), name: NSNotification.Name(rawValue: "active_Pages_TabBar"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(redirectToHome(notification:)), name: NSNotification.Name(rawValue: "load_home_page"), object: nil)
        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.logScreen(name: "Explore")
        self.navigationController?.isNavigationBarHidden = true;
        self.tabBarController?.tabBar.isHidden = false
        print("viewWillAppear")
        self.reloadRecentView()
        updateLayoutOrientation() //changes
        appDelegate.refreshOrintationView()
    }
    
    func updateLayoutOrientation() {
        let statusBarOrientation = UIApplication.shared.statusBarOrientation
        if statusBarOrientation == .portrait || statusBarOrientation == .portraitUpsideDown {
            landsacpeOrientation = false
            potraitOrientation = true
        }
        else if statusBarOrientation == .landscapeRight || statusBarOrientation == .landscapeLeft{
            landsacpeOrientation = true
            potraitOrientation = false
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let orientation = UIDevice.current.orientation
        
        if orientation.isPortrait {
            print("isPortrait")
            potraitOrientation = true
            landsacpeOrientation = false
        }
        else if orientation.isLandscape {
            print("isLandscape")
            landsacpeOrientation = true
            potraitOrientation = false
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        appDelegate.imageDataNotification =  nil
        self.exploreCollectionView.isUserInteractionEnabled = true
        
    }
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
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
        new_windowNumber = UserDefaults.standard.integer(forKey: newWindow)
        purchasess = UserDefaults.standard.integer(forKey: purchasessKey)
        mysteryWinNumber =  UserDefaults.standard.integer(forKey: mysteryWin)
        print("\(labelValue)\nrewardTime = \(rewardTime)\ninterstitialTime = \(interstitialTime)\ncurrent_tool_window = \(currentToolWindow)\nreminder_time1 = \(reminderTime1)\nreminder_time = \(reminderTime)\nrewardTools = \(rewardTools)\nColor_number = \(colorNumber)\nBomb_s = \(bomb_sNumber)\npurchase_ss = \(purchasess)\nnew_window = \(new_windowNumber)\nmystery_Win = \(mysteryWinNumber)")
        
    }
    
    fileprivate func setConfigPreviousSession() {
        reminderTime = UserDefaults.standard.integer(forKey: reminderTimeKey)
        reminderTime1 = UserDefaults.standard.integer(forKey: reminderTime1Key)
        rewardTools = UserDefaults.standard.integer(forKey: rewardToolsKey)
        rewardTime = UserDefaults.standard.integer(forKey: rewardTimeKey)
        interstitialTime = UserDefaults.standard.integer(forKey: interstitialTimeKey)
        currentToolWindow = UserDefaults.standard.string(forKey: currentToolWindowKey) ?? ""
        colorNumber =  UserDefaults.standard.integer(forKey: color_number)
        bomb_sNumber =  UserDefaults.standard.integer(forKey: bomb_s)
        new_windowNumber = UserDefaults.standard.integer(forKey: newWindow)
        purchasess = UserDefaults.standard.integer(forKey: purchasessKey)
        mysteryWinNumber =  UserDefaults.standard.integer(forKey: mysteryWin)
       
        
        UserDefaults.standard.set(reminderTime, forKey: inActiveReminderTimeKey)
        UserDefaults.standard.set(reminderTime1, forKey: InActiveReminderTimeKey1)
        UserDefaults.standard.set(rewardTools, forKey: InActiveRewardToolsKey)
        UserDefaults.standard.set(rewardTime, forKey: InActiveRewardTimeKey)
        UserDefaults.standard.set(interstitialTime, forKey: InActiveInterstitialTimeKey)
        UserDefaults.standard.set(currentToolWindow, forKey: InActiveCurrentToolWindowKey)
        UserDefaults.standard.set(colorNumber, forKey: color_numberActive)
        UserDefaults.standard.set(bomb_sNumber, forKey: bomb_sActive)
        UserDefaults.standard.set(new_windowNumber, forKey: inactiveNewWindow)
        UserDefaults.standard.set(purchasess, forKey: purchasessActiveKey)
        UserDefaults.standard.set(mysteryWinNumber, forKey: inactiveMysteryWindow)
    }
    
    fileprivate func activateInactiveConfig() {
        let inActiveReminderTime = UserDefaults.standard.integer(forKey: inActiveReminderTimeKey)
        let InActiveReminderTime1 = UserDefaults.standard.integer(forKey: InActiveReminderTimeKey1)
        let InActiveRewardTools = UserDefaults.standard.integer(forKey: InActiveRewardToolsKey)
        let InActiveRewardTime = UserDefaults.standard.integer(forKey: InActiveRewardTimeKey)
        let InActiveInterstitialTime = UserDefaults.standard.integer(forKey: InActiveInterstitialTimeKey)
        let InActiveCurrentToolWindow = UserDefaults.standard.string(forKey: InActiveCurrentToolWindowKey) ?? ""
        let activeBombValue = UserDefaults.standard.integer(forKey: bomb_sActive)
        let activeNewWindowValue = UserDefaults.standard.integer(forKey: inactiveNewWindow)
        let colorNumberActive = UserDefaults.standard.integer(forKey: color_numberActive)
        let purchasessActive = UserDefaults.standard.integer(forKey: purchasessActiveKey)
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
        mysteryWinNumber =  UserDefaults.standard.integer(forKey: mysteryWin)
    }
    
    func activatePreviousFetchValues(labelValue: String = "Activate previous fetch values") {
        let currentToolWindowKeyValue = UserDefaults.standard.string(forKey: InActiveCurrentToolWindowKey) ?? ""
        
        if(currentToolWindowKeyValue == "" && UserDefaults.standard.integer(forKey: reminderTimeKey) > 0){
            setConfigPreviousSession()
        }
        
        activateInactiveConfig()
        
        print("\(labelValue)\nrewardTime = \(rewardTime)\ninterstitialTime = \(interstitialTime)\ncurrent_tool_window = \(currentToolWindow)\nreminder_time1 = \(reminderTime1)\nreminder_time = \(reminderTime)\nrewardTools = \(rewardTools)\nColor_number = \(colorNumber)\nBomb_s = \(bomb_sNumber)\npurchase_ss = \(purchasess)\nnew_window = \(new_windowNumber)\nmystery_Win = \(mysteryWinNumber)")
        
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
    
    func saveDefaultConfigValue() {
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
        let newWindowValue = remoteConfigDefaultsDict.value(forKey: newWindowConfigkey) as! Int
        let mystery_winValue = remoteConfigDefaultsDict.value(forKey: mystery_winConfigKey) as! Int
        UserDefaults.standard.set(reminder_time, forKey: reminderTimeKey)
        UserDefaults.standard.set(reminder_time1, forKey: reminderTime1Key)
        UserDefaults.standard.set(reward_tools, forKey: rewardToolsKey)
        UserDefaults.standard.set(rewardTime, forKey: rewardTimeKey)
        UserDefaults.standard.set(interstitialTime, forKey: interstitialTimeKey)
        UserDefaults.standard.set(current_tool_window, forKey: currentToolWindowKey)
        UserDefaults.standard.set(color_Number, forKey: color_number)
        UserDefaults.standard.set(bombs, forKey: bomb_s)
        UserDefaults.standard.set(newWindowValue, forKey: newWindow)
        UserDefaults.standard.set(purchase_ss, forKey: purchasessKey)
        UserDefaults.standard.set(mystery_winValue, forKey: mysteryWin)
        
        getConfigValueDB(labelValue: "Set Default from RemoteConfigDefaults.plist")
        
    }
    
    @objc func reloadExploreView(notification: NSNotification) {
        
        if isSubscriptionViewVisible == 1
        {
            self.iapSubscriptionView.removeFromSuperview()
            self.addIAPSubscriptionView()
        }
        
        if (isHintPaintVisible == 1 && self.tipsView != nil)
        {
            self.tipsView.removeFromSuperview()
            self.isHintPaintVisible = 0
            self.takeToNewCategoryView()
            
        }
        if (ismystery_win_Visible == 1 && self.tipsView != nil)
        {
            self.tipsView.removeFromSuperview()
            self.ismystery_win_Visible = 0
            self.takeToMysteryView()
            
        }
        if(self.appDelegate.isReloadExploreNeeded){
            self.appDelegate.isReloadExploreNeeded = false
            loadExploreData(isReload: false)

            DispatchQueue.main.async {
                let cells = self.exploreCollectionView.visibleCells
                for cell in cells {
                    if( cell.tag == 1000){
                        guard let cell = cell as? PopularRecentCell else { continue }
                        cell.groupDataArray = self.recentDataArray
                        cell.layoutIfNeeded()
                        cell.sliderCollectionView.reloadData()
                    }
                    else if( cell.tag == 1002){
                        guard let cell = cell as? PopularRecentCell else { continue }
                        cell.groupDataArray = self.popularDataArray
                        cell.layoutIfNeeded()
                        cell.sliderCollectionView.reloadData()
                    }
                    else if( cell.tag == 1003){
                        guard let cell = cell as? CollectionsCollectionViewCell else { continue }
                        cell.groupDataArray = self.collectionsDataArray
                        cell.layoutIfNeeded()
                        cell.sliderCollectionView.reloadData()
                    }
                    else if( cell.tag == 1004){
                        guard let cell = cell as? SliderCollectionViewCell else { continue }
                        cell.groupDataArray = self.editorDataArray
                        cell.layoutIfNeeded()
                        cell.sliderCollectionView.reloadData()
                    }
                }
            }

        }
        DispatchQueue.main.async {
        self.exploreCollectionView.collectionViewLayout.invalidateLayout()
        self.exploreCollectionView.layoutIfNeeded()
        }
            
    }
    
    
    
    
    @objc func redirectToHome(notification: NSNotification){
        if(appDelegate.imageDataNotification != nil){
            self.appDelegate.logEvent(name: "Launch_app_notification", category: "Notification", action: "Tapping the Notification")
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
            vc.imageData = appDelegate.imageDataNotification
            self.navigationController?.pushViewController(vc, animated: true);
        }
        
    }
    
    //MARK:- loadExploreData
    func loadExploreData(isReload:Bool = true) {
        getExploreDataFromProperityList()
        self.editorDataArray = Array(self.groupDataArray.filter{$0.type == "editor"}.prefix(editorCollectionCount))
        self.popularDataArray = Array(self.groupDataArray.filter{$0.type == "popular"}.prefix(popularCollectionCount))
        self.collectionsDataArray = Array(self.groupDataArray.filter{$0.type == "collections"}.prefix(collectionsCollectionCount))
        self.recentAllDataArray = self.groupDataArray.filter{$0.type == "popular"}
        self.journeyDataArray = self.groupDataArray.filter{$0.type == "journy"}
        self.recentDataArray.removeAll()
        for item in  myWorkCategory
        {
            
//            let filtered = self.recentAllDataArray.filter{ $0.category.lowercased().contains(item.lowercased()) }.first
//            if(filtered != nil){
//                self.recentDataArray.append(filtered!)
//            }
            
            let index = self.recentAllDataArray.firstIndex{$0.category.lowercased() == item.lowercased()}
            if(index != nil){
            let filtered = self.recentAllDataArray[index!]
           // if(filtered.name != nil){
                self.recentDataArray.append(filtered)
            //}
            }
//            let filtered = self.recentAllDataArray.filter{ $0.category.lowercased().contains(item.lowercased()) }.first
//            if(filtered != nil){
//                self.recentDataArray.append(filtered!)
//            }
        }
        resentLogEvent()
        if(isReload){
        self.exploreCollectionView.reloadData()
        }
    }
    
    func resentLogEvent()
    {
        if(self.recentDataArray.count == 0 ){
            return
        }
        else if(recentDataArray.count <= 5 )
        {
            self.appDelegate.logEvent(name: "recent_L1", category: "Explore Recent", action: "Recent")
        }
        else if(self.recentDataArray.count > 5 && self.recentDataArray.count <= 10 )
        {
            self.appDelegate.logEvent(name: "recent_L2", category: "Explore Recent", action: "Recent")
        }
        else if(self.recentDataArray.count > 10 && self.recentDataArray.count <= 15 )
        {
            self.appDelegate.logEvent(name: "recent_L3", category: "Explore Recent", action: "Recent")
        }
        else
        {
            self.appDelegate.logEvent(name: "recent_L4", category: "Explore Recent", action: "Recent")
        }
    }
        
    
    //MARK:- Change PageControl
    @objc func activePagesTabBar(notification: NSNotification) {
        
        self.tabBarController?.selectedIndex = 1
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now())
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "show_selected_category"), object: nil)
        }
        //  self.tabBarController?.selectedIndex = 1
        
    }
    
    // check second lanunch
    func checkForTheLaunchCounter() {
        
        self.loadLaunchView = UIView(frame: CGRect(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height))
        self.loadLaunchView.backgroundColor = .white
        let logo = UIImageView(frame: CGRect(x:0,y:0,width:self.loadLaunchView.frame.size.width,height:self.loadLaunchView.frame.size.height))
        logo.image = self.launchImage()
        self.loadLaunchView.addSubview(logo)
        UIApplication.shared.keyWindow?.insertSubview(self.loadLaunchView!, at: self.view.subviews.count)
        
        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        let isShowSubs = UserDefaults.standard.bool(forKey: SHOW_SUBSCRIPTION)
        
        let isAdTrackingPromptAuthorizationValue = UserDefaults.standard.bool(forKey: isAdTrackingPromptAuthorization)
        let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType)
        let isKillByForceKey = UserDefaults.standard.string(forKey: isKillByForce)
        let isComplianceDoneValue = UserDefaults.standard.bool(forKey: isComplianceDone)
        
        if (launchCount >= 2 && isShowSubs == true) {
            
            if #available(iOS 14.0, *) {
                if (detectAppTypeValue == "New" || detectAppTypeValue == "Old" ) && isAdTrackingPromptAuthorizationValue {
                    
                    if isKillByForceKey == "1" {
                        self.showComplianceWindowForQuitReason()
                    }
                    else {
                        showSubscriptionView()
                    }
                }
                else if (detectAppTypeValue == "New" || detectAppTypeValue == "Old" ) && !isAdTrackingPromptAuthorizationValue {
                    
                    if isKillByForceKey == "1" {
                        self.showComplianceWindowForQuitReason()
                    }
                    else if !isComplianceDoneValue && detectAppTypeValue == "New" {
                        //                        self.loadWithOutLiveValues()
                    }
                    else {
                        if(self.loadLaunchView != nil){
                            self.loadLaunchView.removeFromSuperview()
                        }
                        showSubscriptionView()
                    }
                }
            }
            else {
                
                if isKillByForceKey == "1" {
                    
                    self.loadLaunchView.removeFromSuperview()
                    appDelegate.ShowComplianceWindow1()
                }
                else if !isComplianceDoneValue && detectAppTypeValue == "New" {
                    //                    self.loadWithOutLiveValues()
                }
                else {
                    showSubscriptionView()
                }
                
            }
            
        } else {
            
            if #available(iOS 14.0, *) {
                if (detectAppTypeValue == "New" || detectAppTypeValue == "Old" ) && isAdTrackingPromptAuthorizationValue {
                    if(self.loadLaunchView != nil){
                        self.loadLaunchView.removeFromSuperview()
                    }
                }
                else if launchCount >= 2 {
                    if(self.loadLaunchView != nil){
                        self.loadLaunchView.removeFromSuperview()
                    }
                }
            }
            else {
                if(self.loadLaunchView != nil){
                    self.loadLaunchView.removeFromSuperview()
                }
            }
        }
    }
    
    
    func showComplianceWindowForQuitReason() {
        
        self.loadLaunchView.removeFromSuperview()
        
        let detectAppTypeValue = UserDefaults.standard.string(forKey: detectAppType)
        if detectAppTypeValue == "Old" {
            appDelegate.currentWindowString = "comp_win_1"
        }else if detectAppTypeValue == "New" {
            //Eliminate fetching compliance_window value from remote config, the default will be used for "New" that is "com_win_2"
        }
        if appDelegate.currentWindowString == "comp_win_1" {
            appDelegate.ShowComplianceWindow1()
        }
        else if appDelegate.currentWindowString == "comp_win_2" {
            appDelegate.ShowComplianceWindow2()
        }
        
    }
    
    func showSubscriptionView() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.isSubscriptionVC = true
            self.launchSubscriptionType = 1
            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
            if(isExpired == "YES" || isExpired == nil){
                UserDefaults.standard.set(false, forKey: SHOW_SUBSCRIPTION)
                self.appDelegate.logEvent(name: "Launch_Subscription_window", category: "Subscription", action: "Free Trial Button")
                self.appDelegate.logEvent(name: "Launch_Sub_wins", category: "Subscription", action: "Non_up_sub")
                self.appDelegate.logEvent(name: "Audience_Beta", category: "Subscription", action: "Free Trial Button")
                self.subscriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionVC") as? SubscriptionVC
                self.subscriptionVC?.loadViewIfNeeded()
                self.isSubscriptionMode = true
                self.addIAPSubscriptionView(mode: 1)
            }
            else
            {
                if(self.loadLaunchView != nil)
                {
                    self.loadLaunchView.removeFromSuperview()
                    if(self.appDelegate.imageDataNotification != nil){
                        DispatchQueue.main.async {
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                            vc.imageData = self.appDelegate.imageDataNotification
                            self.navigationController?.pushViewController(vc, animated: true)
                            //self.appDelegate.imageDataNotification = nil // need to check
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - SUBSCRIPTION WEEK PURCHASE
    @objc func subscriptionWeekPurchaseSub1_FT_applaunch()
    {
        //        self.isSubscriptionVC = false
        //        SVProgressHUD.show()
        //        if(self.launchSubscriptionType == 2){
        //         appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Banner")
        //         appDelegate.logEvent(name: "weekly_subscription_bn", category: "Subscription", action: "Banner")
        //            appDelegate.logEvent(name: "weekly_sub_1", category: "Subscription", action: "Banner")
        //        }else{
        //         appDelegate.logEvent(name: "weekly_subscription_la", category: "Subscription", action: "Launch")
        //         appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Launch")
        //        }
        //        IAPHandler.shared.purchaseMyProduct(product_identifier: WEEK_SUBSCRIPTION_PRODUCT_ID)
        
        self.selectedPurchaseType =  self.subscriptionVC?.selectedPurchaseType ?? 0
        subscriptionPurchase()
        
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
    
    
    var isNedToComplianceShow = "0"

    @objc func loadWithOutLiveValues() {
        
        timerForComplianceWindowFetch?.invalidate()
        timerForComplianceWindowFetch = nil

        if(self.loadLaunchView != nil){
            self.loadLaunchView.removeFromSuperview()
        }

        if isNedToComplianceShow == "0" {
            isNedToComplianceShow = "1"
            appDelegate.showComplianceWindow()
        }
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
        let newWindowConfigkey = "new_window"
        let mystery_winConfigKey = "Mystery_win"
        let rewardTime = Int64(remoteConfig[rewardTimeConfigKey].numberValue as! Int)
        let reminder_time1 = Int64(remoteConfig[reminderTime1ConfigKey].numberValue as! Int)
        let interstitialTime = Int64(remoteConfig[interstitialTimeConfigKey].numberValue as! Int)
        let reminder_time = Int64(remoteConfig[reminderTimeConfigKey].numberValue as! Int)
        let reward_tools = Int64(remoteConfig[rewardToolsConfigKey].numberValue as! Int)
        
        let Color_number = Int64(remoteConfig[colorNumberConfigKey].numberValue as! Int)
        let Bomb_s = Int64(remoteConfig[bomb_sConfigKey].numberValue as! Int)
        let newWindow = Int64(remoteConfig[newWindowConfigkey].numberValue as! Int)
        let mystery_win = Int64(remoteConfig[mystery_winConfigKey].numberValue as! Int)
        let purchase_ss = Int64(remoteConfig[purchasessConfigkey].numberValue as! Int)
        
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
        UserDefaults.standard.set(newWindow, forKey: inactiveNewWindow)
        UserDefaults.standard.set(mystery_win, forKey: inactiveMysteryWindow)
        
        print("Current config fetch value\nrewardTime = \(rewardTime)\ninterstitialTime = \(interstitialTime)\ncurrent_tool_window = \(current_tool_window)\nreminder_time1 = \(reminder_time1)\nreminder_time = \(reminder_time)\nreward_tools = \(reward_tools)\nColor_number = \(Color_number)\nBomb_s = \(Bomb_s)\npurchase_ss = \(purchase_ss)\nnew_window = \(newWindow)\nmystery_Win = \(mystery_win)")
    }
    
    // MARK: - SUBSCRIPTION YEAR PURCHASE
    @objc func subscriptionPurchase()
    {
        SVProgressHUD.show()
        if(selectedPurchaseType == 0){
            
            appDelegate.logEvent(name: "weekly_subscription_la", category: "Subscription", action: "Launch")
            appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "Launch")
            
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
                if !(type == .purchasedWeek || type == .purchasedMonth || type == .purchasedYear) {
                    strongSelf.present(alertView, animated: true, completion: nil)
                }
                
                if type == .failed {
                    self?.isSubscriptionFail = true
                    self?.removeIAPSubscriptionView()
                    self?.dismiss(animated: true, completion: nil)
                }
                else {
                    self?.removeIAPSubscriptionView()
                }
                
                if (type == .purchased) || (type == .restored)
                {
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeNonConsumable)
                    self?.reloadView()
                    
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
                    self?.reloadView()
                    
                }
                else  if (type == .purchasedMonth) || (type == .restoredMonth)
                {
                    if (type == .purchasedMonth)
                    {
                        if(self?.launchSubscriptionType == 1){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Updated_launch")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                            }else {
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Launch")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                                
                            }
                        } else if(self?.launchSubscriptionType == 2){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Updated_banner")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                            }else {
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Banner")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                                
                            }
                        }else{
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Updated_pages")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                            }else {
                                self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Pages")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                                
                            }
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeMonthSubscription)
                    self?.reloadView()
                }
                else  if (type == .purchasedYear) || (type == .restoredYear)
                {
                    if (type == .purchasedYear)
                    {
                        if(self?.launchSubscriptionType == 1){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Updated_launch")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                            }else {
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Launch")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                            }
                        } else if(self?.launchSubscriptionType == 2){
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Updated_banner")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                            }else {
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Banner")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                                
                            }
                        }else{
                            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Updated_pages")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                            }else {
                                self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Pages")
                                self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                                
                            }
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeYearSubscription)
                    self?.reloadView()
                }
                
            })
            self?.viewDidLayoutSubviews()
        }
        
        let screenSize: CGRect = UIScreen.main.bounds
        
        self.iapSubscriptionView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
        self.iapSubscriptionView.backgroundColor = UIColor.white
        self.iapSubscriptionView.alpha = 1.0
        UIApplication.shared.keyWindow?.addSubview(self.iapSubscriptionView)
        
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
                                if(UserDefaults.standard.integer(forKey: LAUNCH_COUNT)) > 1
                                {
                                    UIApplication.shared.keyWindow?.insertSubview(self.subscriptionVC!.view, at: self.view.subviews.count)
                                }
                                else {
                                    self.subscriptionVC!.modalPresentationStyle = .overFullScreen
                                    self.present(self.subscriptionVC!,animated:true,completion:nil)
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
    
    
    
    
    //MARK:- Remove IAP Subscription View
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
                            self.isSubscriptionVC = true
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
    
    func reloadView(){
        DispatchQueue.main.async {
            self.exploreCollectionView.reloadItems(at: [IndexPath(row: 1, section:0 )])
            //self.exploreCollectionView.reloadData()
            // self.exploreCollectionView!.reloadData()
            self.exploreCollectionView!.collectionViewLayout.invalidateLayout()
            self.exploreCollectionView!.layoutSubviews()
        }
        
    }
    
    //MARK: Daily Gift Feature Code.
    func showAdTrackingWindow() {
        
        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        let isAdTrackingPromptAuthorizationValue = UserDefaults.standard.bool(forKey: isAdTrackingPromptAuthorization)
        
        if appDelegate.adTrackingPromptValue == 1 && !isAdTrackingPromptAuthorizationValue && launchCount > 1 {
            appDelegate.logEvent(name: "Track_1", category: "App Tracking Prompt", action: "App Tracking Prompt display")
            if appDelegate.pagesVC == nil {
                // appDelegate.pagesVC = self
            }
            if #available(iOS 14, *) {
                if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
                    appDelegate.showAdTrackingPrompt(isNeedToShowSubscription: "1")
                }
            }
        }
        else {
            let mysteryWinValue = UserDefaults.standard.integer(forKey: mysteryWin)
                    if(mysteryWinValue > 0 && mysteryWinValue <= 8){
                        showMysterScreen()
                    }else{
                        showGiftScreen()
                    }
        }
        
    }
    
    func showGiftScreen() {
        var isExpiredString = ""
        if let isExpired = UserDefaults.standard.string(forKey: "IS_EXPIRED") {
            isExpiredString = isExpired
        }
        
        if !(((self.appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpiredString == "NO") || ((self.appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))) {
            
            if let giftClaimCount = UserDefaults.standard.integer(forKey: giftClaimCountValue) as? Int {
                if giftClaimCount < 500 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone.current
                    formatter.locale = Locale.current
                    let newDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
                    // newDate = Calendar.current.date(byAdding: .hour, value: -2, to:newDate!)
                    let giftDisplayTimeString = formatter.string(from:newDate!)
                    
                    if let giftDisplayTimeValue = UserDefaults.standard.string(forKey: giftWindowsVisibleTime) {
                        
                        let previousGiftDisplayDate = formatter.date(from: giftDisplayTimeValue)
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
    
    func showMysterScreen(){
        var isExpiredString = ""
        if let isExpired = UserDefaults.standard.string(forKey: "IS_EXPIRED") {
            isExpiredString = isExpired
        }
        
        if !(((self.appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpiredString == "NO") || ((self.appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))) {
            
            if let mysteryClaimCount = UserDefaults.standard.integer(forKey: mysteryClaimCountValue) as? Int {
                if mysteryClaimCount < 500 {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    formatter.timeZone = TimeZone.current
                    formatter.locale = Locale.current
                    let newDate = Calendar.current.date(byAdding: .day, value: 0, to: Date())
                    // newDate = Calendar.current.date(byAdding: .hour, value: -2, to:newDate!)
                    let mysteryDisplayTimeString = formatter.string(from:newDate!)
                    
                    if let mysteryDisplayTimeValue = UserDefaults.standard.string(forKey: mysteryWindowsVisibleTime) {
                        
                        let previousGiftDisplayDate = formatter.date(from: mysteryDisplayTimeValue)
                        let nowDate = formatter.date(from: mysteryDisplayTimeString)!
                        
                        print("MYSTERY PREVIOUS DATE:- \(previousGiftDisplayDate!)")
                        print("MYSTERY NOW DATE:- \(nowDate)")
                        
                        print("CURRENT TIME ZONE - MYSTERY PREVIOUS DATE:- \(mysteryDisplayTimeValue)")
                        print("CURRENT TIME ZONE - MYSTERY NOW DATE:- \(mysteryDisplayTimeString)")
                        
                        
                        let compValue = getCompareValue(previousGiftDisplayDate: previousGiftDisplayDate!, nowDate: nowDate)
                        
                        if compValue != -1 {
                            // Nitin Gupta
                            if compValue >= giftTimeDelayValue {
                                UserDefaults.standard.set("\(mysteryDisplayTimeString)", forKey: mysteryWindowsVisibleTime)
                                if compValue >= 2*giftTimeDelayValue {
                                    UserDefaults.standard.set(0, forKey: mysteryClaimCountValue)
                                }
                                self.takeToMysteryView()
                            }
//                            else {
//                                self.appDelegate.checkForRemoteNotificationIsEnabled()
//                            }
                        }
                        else {
                            self.appDelegate.checkForRemoteNotificationIsEnabled()
                        }
                    }
                    else {
                        UserDefaults.standard.set("\(mysteryDisplayTimeString)", forKey: mysteryWindowsVisibleTime)
                        self.takeToMysteryView()
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
    
    func showGiftWindow() {
        let giftFirst = UserDefaults.standard.bool(forKey: gift_1_first)
        if(giftFirst == false){
            UserDefaults.standard.set(true, forKey: gift_1_first)
            appDelegate.logEvent(name: "gift_1_first", category: "Daily Gift Window", action: "Show_Daily_Gift")
        }
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "DailyGiftViewController") as! DailyGiftViewController
        vc.dailyGiftViewControllerDelegate = self
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc,animated:true,completion:nil)
        
        
    }
    
    func getCompareValue(previousGiftDisplayDate: Date, nowDate: Date) -> Int {
        //let previousGiftDisplayDate = previousGiftDisplayDate.localDate(date: previousGiftDisplayDate)
        //let nowDate = nowDate.localDate()
        var compValue = -1
        
        if giftTimeComponent == .second {
            if let comp = Calendar.current.dateComponents([giftTimeComponent,Calendar.Component.timeZone], from: previousGiftDisplayDate, to: nowDate).second {
                compValue = comp
            }
        }
        else if giftTimeComponent == .minute {
            if let comp = Calendar.current.dateComponents([giftTimeComponent], from: previousGiftDisplayDate, to: nowDate).minute {
                compValue = comp
            }
        }
        else if giftTimeComponent == .hour {
            if let comp = Calendar.current.dateComponents([giftTimeComponent], from: previousGiftDisplayDate, to: nowDate).hour {
                compValue = comp
            }
        }
        else if giftTimeComponent == .day {
            
            compValue =  dayDifferance(previousGiftDisplayDate: previousGiftDisplayDate, nowDate: nowDate)
            
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
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        reloadRecentView()
    }
    
    func reloadRecentView(){
        self.getAllCompletedImagesFromDB()
        self.recentDataArray.removeAll()
        for item in  myWorkCategory
        {
            let index = self.recentAllDataArray.firstIndex{$0.category.lowercased() == item.lowercased()}
            if(index != nil){
            let filtered = self.recentAllDataArray[index!]
           // if(filtered.name != nil){
                self.recentDataArray.append(filtered)
            //}
            }
            
//            let filtered = self.recentAllDataArray.filter{ $0.category.lowercased().contains(item.lowercased()) }.first
//            if(filtered != nil){
//                self.recentDataArray.append(filtered!)
//            }
        }
        resentLogEvent()
        DispatchQueue.main.async {
            let cells = self.exploreCollectionView.visibleCells
            for cell in cells {
                guard let cell = cell as? PopularRecentCell else { continue }
                if( cell.tag == 1000){
                    cell.groupDataArray = self.recentDataArray
                    cell.layoutIfNeeded()
                    cell.sliderCollectionView.reloadData()
                    print("recentDataArray")
                    print(self.recentDataArray)
                }
            }
        }
        
    }
    
  
    
    func getAllCompletedImagesFromDB(){
        completedArr.removeAll()
        let dbHelper = DBHelper.sharedInstance
        let imageArrayTemp = dbHelper.getMyWorkImages()
        if(imageArrayTemp.count == 0){
            myWorkCategory.removeAll()
        }
       print("MyWorkImages")
        for item in imageArrayTemp {
            print(item.category!+"_"+item.name!)
        }

        var lastEditImageName = ""
        if(UserDefaults.standard.value(forKey: "LastEditImageName") != nil)
        {
            lastEditImageName = (UserDefaults.standard.value(forKey: "LastEditImageName") as? String)!
        }
        
        for imgDataTemp in imageArrayTemp
        {
            guard let category = imgDataTemp.category else { return }
            if(!myWorkCategory.contains(category.lowercased())){
                if(imgDataTemp.name!.lowercased() == lastEditImageName.lowercased())
                {
                    myWorkCategory.insert(category.lowercased(), at: 0)
                }
                else{
                    myWorkCategory.append(category.lowercased())
                }
            }else{
                if(imgDataTemp.name!.lowercased() == lastEditImageName.lowercased())
                {
                    myWorkCategory.removeAll { $0 == category.lowercased()}
                    
                    myWorkCategory.insert(category.lowercased(), at: 0)
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
    
    
    func launchImage() -> UIImage? {
        
        guard let launchImages = Bundle.main.infoDictionary?["UILaunchImages"] as? [[String: Any]] else { return nil }
        
        let screenSize = UIScreen.main.bounds.size
        
        var interfaceOrientation: String
        switch UIApplication.shared.statusBarOrientation {
        case .portrait,
             .portraitUpsideDown:
            interfaceOrientation = "Portrait"
        default:
            interfaceOrientation = "Landscape"
        }
        
        for launchImage in launchImages {
            
            guard let imageSize = launchImage["UILaunchImageSize"] as? String else { continue }
            let launchImageSize = CGSizeFromString(imageSize)
            
            guard let launchImageOrientation = launchImage["UILaunchImageOrientation"] as? String else { continue }
            
            if
                launchImageSize.equalTo(screenSize),
                launchImageOrientation == interfaceOrientation,
                let launchImageName = launchImage["UILaunchImageName"] as? String {
                return UIImage(named: launchImageName)
            }
        }
        
        return nil
    }
    
    //MARK:- getExploreDataFromProperityList
    func getExploreDataFromProperityList() {
        if let path = appDelegate.serverExplorePlistPath()
        {
            if let array = NSArray(contentsOfFile: path) as? [[String: Any]]
            {
                self.groupDataArray.removeAll()
                for arr in array
                {
                    let dict =  arr as NSDictionary
                    let exploreData = ExploreData(data: dict)
                    self.groupDataArray.append(exploreData)
                }
            }
        }
        
        if(self.groupDataArray.count == 0)
        {
            if let path = Bundle.main.path(forResource: "explore", ofType: "plist") {
                if let array = NSArray(contentsOfFile: path) as? [[String: Any]]
                {
                    self.groupDataArray.removeAll()
                    for arr in array
                    {
                        let dict =  arr as NSDictionary
                        let exploreData = ExploreData(data: dict)
                        self.groupDataArray.append(exploreData)
                    }
                }
            }
        }
    }
    
    //MARK: UICollectionViewDataSource & UICollectionViewDelegate.
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groupNameArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if (groupNameArray[indexPath.row] == "Editor's Picks") {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SliderCollectionViewCell", for: indexPath) as! SliderCollectionViewCell
            cell.tag = 1004
            cell.backgroundColor = editorBGColor
            cell.pageController.numberOfPages = self.editorDataArray.count
            cell.applyTopViewScrolling()
            cell.pageController.currentPage = 0
            cell.pageController.pageIndicatorTintColor = #colorLiteral(red: 0.7762596011, green: 0.7769804597, blue: 0.7835683227, alpha: 1)
            cell.pageController.currentPageIndicatorTintColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
            cell.headingLabel.text = NSLocalizedString(groupNameArray[indexPath.row], comment: "")
            cell.groupName =  groupNameArray[indexPath.row]
            cell.groupDataArray = self.editorDataArray
            cell.sliderCollectionView.reloadData()
            return cell
        }
        else if(groupNameArray[indexPath.row] == "Journey") {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SubscriptionCell", for: indexPath) as! SubscriptionCell
            cell.backgroundColor = journeyBGColor
            cell.tag = 1001
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                cell.trailViewWidth.constant = collectionView.frame.width - 240.0
                cell.trailViewHeight.constant = 80
            }
            else {
                cell.trailViewWidth.constant = collectionView.frame.width - 32.0
                cell.trailViewHeight.constant = 100
            }
            cell.trailView.layer.cornerRadius = 10.0
            
            cell.journeyLabel.text = NSLocalizedString("Your journey to relexation begins here", comment: "")
            
            if UIDevice.current.userInterfaceIdiom == .pad {
                cell.journeyButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 50, bottom: 6, right: 50)
            }
            else {
                cell.journeyButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)
            }
            cell.journeyButton.setTitle(NSLocalizedString("Start Trial", comment:""), for: .normal)
            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                cell.journeyButton.setTitle(NSLocalizedString("Start Now", comment: ""), for: UIControlState.normal)
            }
            cell.journeyButton.layer.cornerRadius = 15.0
            
            return cell
        }
        else if(groupNameArray[indexPath.row] == "Collections") {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionsCollectionViewCell", for: indexPath) as! CollectionsCollectionViewCell
            cell.tag = 1003
            cell.backgroundColor = collectionBGColor
            cell.headingLabel.text = NSLocalizedString(groupNameArray[indexPath.row], comment: "")
            cell.groupName =  groupNameArray[indexPath.row]
            cell.groupDataArray = self.collectionsDataArray
            cell.delegate = self
            cell.allCollectionsLabel.text = NSLocalizedString("View All Collections",comment:"")
            
            return cell
        }
        else {
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PopularRecentCell", for: indexPath) as! PopularRecentCell
            
            cell.headingLabel.text = NSLocalizedString(groupNameArray[indexPath.row], comment: "")
            cell.groupName =  groupNameArray[indexPath.row]
            
            if groupNameArray[indexPath.row] == "Popular" {
                cell.tag = 1002
                cell.backgroundColor = popularBGColor
                cell.groupDataArray = self.popularDataArray
            }
            else if groupNameArray[indexPath.row] == "Recent" {
                cell.tag = 1000
                cell.backgroundColor = RecentBGColor
                cell.groupDataArray = self.recentDataArray
            }
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if(groupNameArray[indexPath.row] == "Editor's Picks") {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: collectionView.frame.width, height: 373.5)
            }
            else {
                return CGSize(width: collectionView.frame.width, height: 293.5)
            }
        }
        else if(groupNameArray[indexPath.row] == "Journey") {
            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
            if  (isExpired == "YES" || isExpired == nil){
                return CGSize(width: collectionView.frame.width, height: 125)
            }
            else{
                return CGSize(width: collectionView.frame.width, height: 0)
            }
        }
        else  if(groupNameArray[indexPath.row] == "Collections") {
            if UIDevice.current.userInterfaceIdiom == .pad{
                return CGSize(width: collectionView.frame.width, height: 243.5)
            }
            else {
                return CGSize(width: collectionView.frame.width, height: 193.5)
            }
        }
        else {
            if UIDevice.current.userInterfaceIdiom == .pad {
                return CGSize(width: collectionView.frame.width, height: 242)
            }
            else{
                return CGSize(width: collectionView.frame.width, height: 162)
            }
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if(hasTopNotch){
            return UIEdgeInsets(top: -10, left: 0, bottom: 0, right: 0)
        }
        else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    var hasTopNotch: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
    //MARK: DailyGiftViewControllerDelegate.
    func dailyGiftCrossBtnDelegate() {
        self.appDelegate.checkForRemoteNotificationIsEnabled()
    }
    
    
    @IBAction func freeTrailButtonTapped(_ sender: UIButton) {
        
        //NotificationCenter.default.post(name: NSNotification.Name(rawValue: "free_Trial_Notification"), object: nil)
        //        self.isSubscriptionActive = "1"
        //        self.exploreCollectionView.reloadData()
        
        //if(isSubscriptionVC == false){
        print("button clicked")
        if(subscriptionVC == nil){
            print("inside if block")
            self.isSubscriptionVC = true
            self.launchSubscriptionType = 2
            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
            if(isExpired == "YES" || isExpired == nil){
                UserDefaults.standard.set(false, forKey: SHOW_SUBSCRIPTION)
                // self.appDelegate.logEvent(name: "Banner_Subscription_window", category: "Subscription", action: categoriesArray[selectedCategoryIndex])
                self.subscriptionVC = self.storyboard?.instantiateViewController(withIdentifier: "SubscriptionVC") as? SubscriptionVC
                self.subscriptionVC?.loadViewIfNeeded()
                self.isSubscriptionMode = true
                self.subscriptionVC?.isFromFreeButton = true
                self.addIAPSubscriptionView(mode: 1)
            }
        }
    }
    
    
    func takeToNewCategoryView()
    {
        if (isHintPaintVisible == 0 &&  UserDefaults.standard.integer(forKey: newWindow) == 1)
        {
            appDelegate.logEvent(name: "new_w", category: "New_window", action: "Show_New_window")
            
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
                    
                    width_white = height_white/1.436
                    height_white = self.view.frame.height * 0.75
                }
                fontSizeWithBold = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight(rawValue: 0.7))
                fontSizeWithNormal = UIFont.systemFont(ofSize: 18.0)
                
            }
            let x_white : CGFloat = (screenSize.width - width_white) / 2
            let y_white : CGFloat = (screenSize.height - height_white) / 2
            
            let whiteRect = CGRect(x: x_white, y: y_white, width: width_white, height: height_white)
            var crossButtonRect = CGRect(x: offset, y: offset, width: offset*3, height: offset*3)
            var tipsLblRect = CGRect(x: 0, y: (height_white + (offset*3)) / 2, width: width_white, height: offset*7)
            var watchButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 125, width: width_white - (offset*8), height: offset*6)
            var proButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 55, width: width_white - (offset*8), height: offset*6)
            
            var imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                crossButtonRect = CGRect(x: offset, y: offset, width: offset*4, height: offset*4)
                tipsLblRect = CGRect(x: 0, y: (height_white / 2) + 20, width: width_white, height: offset*9)
                watchButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 210, width: width_white - (offset*14), height: offset*9)
                // proButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 95, width: width_white - (offset*14), height: offset*9)
                proButtonRect = CGRect(x: offset*7, y: (height_white) - (offset*9 + 10), width: width_white - (offset*14), height: offset*9)
                imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
                
                if self.view.frame.width > self.view.frame.height{ // landscape
                    crossButtonRect = CGRect(x: offset*7, y: offset, width: offset*4, height: offset*4)
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
            var tipsTextString: String!
            
            bgImage = UIImage(named: "new_w-iphone")
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                if self.view.frame.height > self.view.frame.width{
                    print("potrait")
                    bgImage = UIImage(named: "new_w-ipad")
                }else{
                    print("lanscape")
                    bgImage = UIImage(named: "new_w-ipad")
                }
            }
            
            let str3 = NSLocalizedString("Take me to New Category", comment: "")
            tipsTextString =  str3
            
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
            retryButton.setTitle(NSLocalizedString("Go!", comment: ""), for: .normal)
            retryButton.setTitleColor(UIColor.white, for: .normal)
            retryButton.titleLabel?.font = fontSizeWithBold
            retryButton.titleLabel?.textAlignment  = NSTextAlignment.center
            retryButton.addTarget(self, action:#selector(presentModalController), for: .touchUpInside)
            whiteView.addSubview(retryButton)
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                                self.tipsView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
                            }, completion:  nil)
        }else{
            self.exploreCollectionView.isUserInteractionEnabled = true
        }
        
    }
    
    
    func takeToMysteryView() {
        if (ismystery_win_Visible == 0)
        {
            
            
            ismystery_win_Visible = 1
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
                    
                    width_white = height_white/1.436
                    height_white = self.view.frame.height * 0.75
                }
                fontSizeWithBold = UIFont.systemFont(ofSize: 22.0, weight: UIFont.Weight(rawValue: 0.7))
                fontSizeWithNormal = UIFont.systemFont(ofSize: 18.0)
                
            }
            let x_white : CGFloat = (screenSize.width - width_white) / 2
            let y_white : CGFloat = (screenSize.height - height_white) / 2
            
            let whiteRect = CGRect(x: x_white, y: y_white, width: width_white, height: height_white)
            var crossButtonRect = CGRect(x: offset, y: offset, width: offset*3, height: offset*3)
            var tipsLblRect = CGRect(x: 0, y: ((height_white + (offset*3)) / 2)+20, width: width_white, height: offset*7)
            var watchButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 125, width: width_white - (offset*8), height: offset*6)
            var proButtonRect = CGRect(x: offset*4, y: (height_white / 2) + 55, width: width_white - (offset*8), height: offset*6)
            
            var imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                crossButtonRect = CGRect(x: offset, y: offset, width: offset*4, height: offset*4)
                tipsLblRect = CGRect(x: 0, y: (height_white / 2) + 50, width: width_white, height: offset*9)
                watchButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 210, width: width_white - (offset*14), height: offset*9)
                // proButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 95, width: width_white - (offset*14), height: offset*9)
                proButtonRect = CGRect(x: offset*7, y: (height_white) - (offset*9 + 10), width: width_white - (offset*14), height: offset*9)
                imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
                
                if self.view.frame.width > self.view.frame.height{ // landscape
                    crossButtonRect = CGRect(x: offset*7, y: offset, width: offset*4, height: offset*4)
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
            var tipsTextString: String!
            
            bgImage = UIImage(named: "mystery-iphone")
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                if self.view.frame.height > self.view.frame.width{
                    print("potrait")
                    bgImage = UIImage(named: "mystery-ipad")
                }else{
                    print("lanscape")
                    bgImage = UIImage(named: "mystery-ipad")
                }
            }
            
            let str3 = NSLocalizedString("Get your daily mystery gift", comment: "")
            tipsTextString =  str3
            
            let tipsImageView = UIImageView(frame: imageRect)
            tipsImageView.image = bgImage
            tipsImageView.contentMode = .scaleAspectFit
            whiteView.addSubview(tipsImageView)
            
            //CancelButton
            let crossButton = UIButton(frame: crossButtonRect)
            crossButton.setImage(UIImage(named: "cancel_subs"), for: UIControlState.normal)
            crossButton.addTarget(self, action:#selector(self.removeMysteryView), for: .touchUpInside)
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
            retryButton.setTitle(NSLocalizedString("Claim", comment: ""), for: .normal)
            retryButton.setTitleColor(UIColor.white, for: .normal)
            retryButton.titleLabel?.font = fontSizeWithBold
            retryButton.titleLabel?.textAlignment  = NSTextAlignment.center
            retryButton.addTarget(self, action:#selector(presentMysteryModal), for: .touchUpInside)
            whiteView.addSubview(retryButton)
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                                self.tipsView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
                            }, completion:  nil)
        }else{
            self.exploreCollectionView.isUserInteractionEnabled = true
        }
        
    }
    
    //MARK:- Remove Tips View
    @objc func removeTipsAddNewWindowView()
    {
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
                            let screenSize: CGRect = UIScreen.main.bounds
                            self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                        }, completion: { (finished: Bool) in
                            self.isHintPaintVisible = 0
                            self.tipsView.removeFromSuperview()
                               self.takeToNewCategoryView()
                             
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
                            self.tipsView.removeFromSuperview()
                        })
                self.exploreCollectionView.isUserInteractionEnabled = true
                
    }
    
    
    //MARK:- Remove Tips View
    @objc func removeMysteryView()
    {
        
        self.saveMysteryClosingTime()
        self.exploreCollectionView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
                            let screenSize: CGRect = UIScreen.main.bounds
                            self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                        }, completion: { (finished: Bool) in
                            self.ismystery_win_Visible = 0
                            self.tipsView.removeFromSuperview()
                           
                            let alert = UIAlertController(title:  NSLocalizedString("Success!",comment:""), message: self.getMysteryReward(), preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                                self.exploreCollectionView.isUserInteractionEnabled = true
                                self.appDelegate.checkForRemoteNotificationIsEnabled()

                            }
                            alert.addAction(okayAction)
                            self.present(alert, animated: true, completion: nil)
                        })
              
       
                
    }
    
    
    @objc func saveMysteryClosingTime() {

        
        let mysteryClaimCount = UserDefaults.standard.integer(forKey: mysteryClaimCountValue)
        let currentValue = mysteryClaimCount+1
        UserDefaults.standard.set(currentValue, forKey: mysteryClaimCountValue)
        
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            formatter.timeZone = TimeZone.current
            formatter.locale = Locale.current
            let mysteryDisplayTimeString = formatter.string(from: Date())
            UserDefaults.standard.set("\(mysteryDisplayTimeString)", forKey: mysteryWindowsVisibleTime)
        
        self.mysteryEventLogs()

        }

    
    //    //MARK:- Retry button Clicked
    //    @objc func retryButtonClicked()
    //    {
    //        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
    //                        {
    //                            let screenSize: CGRect = UIScreen.main.bounds
    //                            self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
    //                        }, completion: { (finished: Bool) in
    //                            self.tipsView.removeFromSuperview()
    //                            self.isHintPaintVisible = 0
    //                        })
    //
    //    }
    //
    
    
    // Add subviews and set constraints
    func setupConstraints() {
        view.addSubview(containerStackView)
        containerStackView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11.0, *) {
            let safeArea = view.safeAreaLayoutGuide
        } else {
            // Fallback on earlier versions
        }
        // Call .activate method to enable the defined constraints
        NSLayoutConstraint.activate([
            // 6. Set containerStackView edges to superview with 24 spacing
            // containerStackView.topAnchor.constraint(equalTo: safeArea.topAnchor, constant: 24),
            // containerStackView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor, constant: -24),
            //containerStackView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor, constant: 24),
            // containerStackView.trailingAnchor.constraint(equalTo: safeArea.trailingAnchor, constant: -24),
            // 7. Set button height
            // registerButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    
    @objc func presentMysteryModal() {
        self.saveMysteryClosingTime()
        self.exploreCollectionView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
                            let screenSize: CGRect = UIScreen.main.bounds
                            self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                        }, completion: { [self] (finished: Bool) in
                            self.ismystery_win_Visible = 0
                            self.tipsView.removeFromSuperview()

                            let alert = UIAlertController(title:  NSLocalizedString("Success!",comment:""), message: getMysteryReward(), preferredStyle: .alert)
                            let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                                
                                self.exploreCollectionView.isUserInteractionEnabled = true
                                self.appDelegate.checkForRemoteNotificationIsEnabled()

                            }
                            alert.addAction(okayAction)
                            self.present(alert, animated: true, completion: nil)
                           
                        })
        
        
       
    }
    
    // To be updated
    @objc func presentModalController() {
        
        self.exploreCollectionView.isUserInteractionEnabled = true
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
                            let screenSize: CGRect = UIScreen.main.bounds
                            self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                        }, completion: { [self] (finished: Bool) in
                            self.isHintPaintVisible = 0
                            self.tipsView.removeFromSuperview()

                            appDelegate.logEvent(name: "New_go", category: "New_window", action: "Show_New_Category")
                            UserDefaults.standard.set(1, forKey: "SELECTED_CATEGORY_INDEX")
                            UserDefaults.standard.set("new", forKey: "SELECTED_CATEGORY_NAME")
                            UserDefaults.standard.synchronize()
                          
                            if(self.appDelegate.pagesVC == nil){
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "active_Pages_TabBar"), object: nil)
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1)
                                {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "show_selected_category"), object: nil)
                                }
                            }
                            else{
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1)
                                {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "show_selected_category"), object: nil)
                                }
                            }
                        })
        
    }
    
    //MARK:Show new paint bucket info popup!
    var isPaintBucketDisplay = false
    func showNewPaintBucketInfoPopup() {

        DispatchQueue.main.async { [weak self] in
            //self?.showBucketPopup()
           self?.takeToNewCategoryView()
            
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
            crossButton.addTarget(self, action:#selector(self.removeTipsAddNewWindowView), for: .touchUpInside)
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
        else{
            self.takeToNewCategoryView()
            
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
                self.takeToNewCategoryView()
                
        })
    }
    
    func getMysteryReward() -> String
    {
        
        let mystery_winValue = UserDefaults.standard.integer(forKey: mysteryWin)
        
        let paintCount = UserDefaults.standard.integer(forKey: "PAINT_COUNT")
        let hintCount = UserDefaults.standard.integer(forKey: "HINT_COUNT")
        let autoMoveCount = UserDefaults.standard.integer(forKey: "AUTOMOVE_COUNT")
        
        var message = NSLocalizedString("You got 5 Paint Buckets",comment:"")
        
        if(mystery_winValue == 1){
            UserDefaults.standard.set(paintCount + mysteryWin1Paint, forKey: "PAINT_COUNT")
            message = NSLocalizedString("You got 15 Paint Buckets",comment:"")
            message = message.replacingOccurrences(of: "15", with: "\(mysteryWin1Paint)")
        }
        else if(mystery_winValue == 2){
            UserDefaults.standard.set(paintCount + mysteryWin2Paint, forKey: "PAINT_COUNT")
            message = NSLocalizedString("You got a Booster",comment:"")
            //message = message.replacingOccurrences(of: "10", with: "\(mysteryWin2Paint)")
        }
        else if(mystery_winValue == 3){
            UserDefaults.standard.set(hintCount + mysteryWin3Hints, forKey: "HINT_COUNT")
            message = NSLocalizedString("You got 15 Hints",comment:"")
            message = message.replacingOccurrences(of: "15", with: "\(mysteryWin3Hints)")
        }
        else if(mystery_winValue == 4){
            UserDefaults.standard.set(hintCount + mysteryWin4Hints, forKey: "HINT_COUNT")
            message = NSLocalizedString("You got 10 Hints",comment:"")
            message = message.replacingOccurrences(of: "10", with: "\(mysteryWin4Hints)")
        }
        else if(mystery_winValue == 5){
            UserDefaults.standard.set(paintCount + mysteryWin5Reward, forKey: "PAINT_COUNT")
            UserDefaults.standard.set(hintCount + mysteryWin5Reward, forKey: "HINT_COUNT")
            UserDefaults.standard.set(autoMoveCount + mysteryWin5Reward, forKey: "AUTOMOVE_COUNT")
            message = NSLocalizedString("You got 15 Paint Buckets and 15 Hints!",comment:"")
            message = message.replacingOccurrences(of: "15", with: "\(mysteryWin5Reward)")
        }
        else if(mystery_winValue == 6){
            UserDefaults.standard.set(paintCount + mysteryWin6Reward, forKey: "PAINT_COUNT")
            UserDefaults.standard.set(hintCount + mysteryWin6Reward, forKey: "HINT_COUNT")
            UserDefaults.standard.set(autoMoveCount + mysteryWin6Reward, forKey: "AUTOMOVE_COUNT")
            message = NSLocalizedString("You got 10 Paint Buckets and 10 Hints!",comment:"")
            message = message.replacingOccurrences(of: "10", with: "\(mysteryWin6Reward)")
        }
        else if(mystery_winValue == 7){
            UserDefaults.standard.set(hintCount + mysteryWin7Hints, forKey: "HINT_COUNT")
            message = NSLocalizedString("You got 5 Hints",comment:"")
            message = message.replacingOccurrences(of: "5", with: "\(mysteryWin7Hints)")
        }
        else if(mystery_winValue == 8){
            UserDefaults.standard.set(paintCount + mysteryWin8Paint, forKey: "PAINT_COUNT")
            message = NSLocalizedString("You got 5 Paint Buckets",comment:"")
            message = message.replacingOccurrences(of: "5", with: "\(mysteryWin8Paint)")
        }
        return message
        
    }
    
    func mysteryEventLogs(){
        let mysteryClaimCount = UserDefaults.standard.integer(forKey: mysteryClaimCountValue)
        let mystery_d5past = UserDefaults.standard.bool(forKey: mystery_day_5_Past)
       
        if(mystery_d5past == true)
        {
            
            appDelegate.logEvent(name: "mystery_d5past", category: "Daily Mystery Window", action: "daily_mystery_claim")
        }
        else {
            if mysteryClaimCount == 1 {
               
                appDelegate.logEvent(name: "mystery_d1", category: "Daily Mystery Window", action: "daily_mystery_claim")
            }
            else if mysteryClaimCount == 2 {
                
                appDelegate.logEvent(name: "mystery_d2", category: "Daily Mystery Window", action: "daily_mystery_claim")
            }
            else if mysteryClaimCount == 3 {
               
                appDelegate.logEvent(name: "mystery_d3", category: "Daily Mystery Window", action: "daily_mystery_claim")
            }
            else if mysteryClaimCount == 4 {
                
                appDelegate.logEvent(name: "mystery_d4", category: "Daily Mystery Window", action: "daily_mystery_claim")
            }
            else if mysteryClaimCount == 5 {
                
                UserDefaults.standard.set(true, forKey: mystery_day_5_Past)
                appDelegate.logEvent(name: "mystery_d5", category: "Daily Mystery Window", action: "daily_mystery_claim")
            }
        }
    }
    
    func viewAllButtonTapped(currentOrientation: Bool) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AllCollectionsViewController") as! AllCollectionsViewController
        vc.groupDataArray = Array(self.groupDataArray.filter{$0.type == "collections"})
        vc.currentOrientationValue = currentOrientation
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
