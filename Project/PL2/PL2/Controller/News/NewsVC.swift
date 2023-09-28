//
//  NewsVC.swift
//  PL2
//
//  Created by iPHTech2 on 04/02/19.
//  Copyright © 2019 IPHS Technologies. All rights reserved.
//

import UIKit
import FBSDKShareKit
import UserNotifications
import FirebaseDynamicLinks
import FirebaseMessaging

class NewsVC: UIViewController,UITableViewDelegate , UITableViewDataSource,SharingDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    @IBOutlet var newsTableView: UITableView!
    var newsList = [[String:String]]()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let paint_count = "PAINT_COUNT"
    // check again by Shoaib
    var pagesVC: PagesVC!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.newsTableView.register(UINib(nibName: "iPDTableViewCell", bundle: nil), forCellReuseIdentifier: "iPDTableViewCell")
        }
        else{
            self.newsTableView.register(UINib(nibName: "newsCell", bundle: nil), forCellReuseIdentifier: "newsCell")
        }
        
        self.newsTableView.delegate = self
        self.newsTableView.dataSource = self
        
        self.newsTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.newsTableView.showsVerticalScrollIndicator = false
        InitList()
        self.newsTableView.reloadData()
        self.newsTableView.backgroundColor = UIColor.clear
        self.view.backgroundColor = UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0)
        
        
        appDelegate.logScreen(name: "News")
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        self.title = NSLocalizedString("news", comment: "")
        let titleDict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.gray]
        navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedStringKey : Any]
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.checkNotificationStatus(_:)), name:NSNotification.Name(rawValue: "checkNotificationStatus"), object: nil)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            navigationController?.navigationBar.tintColor = .black
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
        }
        
    }
    
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appDelegate.logScreen(name: "News")
        self.appDelegate.checkPushNotification {  (isEnable) in
            UserDefaults.standard.set(isEnable, forKey:isNotificationAllow)
            DispatchQueue.main.async {
                self.newsTableView.reloadData()
            }
        }
       // self.newsTableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIDeviceOrientationDidChange)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: "checkNotificationStatus"))
    }
    
    fileprivate func InitList() {
        newsList.append(["Title": NSLocalizedString("Booster Pack for friends", comment: ""), "SubTitle": NSLocalizedString("Daily booster pack for  friends",comment:""), "Image": "new6", "Id": "6", "Url": " " ])
        
        newsList.append(["Title": NSLocalizedString("Don't miss out on new design", comment: ""), "SubTitle": NSLocalizedString("Sign up for notifications",comment:""), "Image": "new5", "Id": "5", "Url": " " ])
        
        newsList.append(["Title": NSLocalizedString("Join our facebook community", comment: ""), "SubTitle": NSLocalizedString("find exclusive images",comment:""), "Image": "new1", "Id": "1", "Url": "https://www.facebook.com/PIXELCOLORAPP/" ])
        newsList.append(["Title": NSLocalizedString("Join our Instagram community",comment:""), "SubTitle": NSLocalizedString("Share your work",comment:""), "Image": "new2", "Id": "2", "Url": "https://www.instagram.com/pixelcolorapp/" ])
        newsList.append(["Title": NSLocalizedString("Share with Friends",comment:""), "SubTitle": NSLocalizedString("Both of you get bonus images",comment:""), "Image": "new4", "Id": "4", "Url": "https://www.facebook.com/PIXELCOLORAPP/" ])
        newsList.append(["Title": NSLocalizedString("Vote on future design",comment:""), "SubTitle": NSLocalizedString("We are listening",comment:""), "Image": "new3", "Id": "3", "Url": "https://docs.google.com/forms/d/e/1FAIpQLSetTTitwRIhREppVEfRT3335nXRqk5uXppLpn6N6ypAxfQRSw/viewform" ])
        
        
    }
    //MARK:- Tableview Delegate
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return newsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let news = self.newsList[indexPath.row]
        var imgName:String = ""
        let imgPre = news["Image"]
        let id = news["Id"]
        
        switch appDelegate.getLayoutType() {
        case .kPadLandscape  :
            let imgSuff = "-ipadh"
            imgName = imgPre! + imgSuff
            break;
        case .kPadPortrait  :
            let imgSuff = "-ipadv"
            imgName = imgPre! + imgSuff
            break;
        default:
            imgName = news["Image"]!
        }
        
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            
            let cell =
                self.newsTableView.dequeueReusableCell(withIdentifier: "iPDTableViewCell") as! iPDTableViewCell
            
            cell.selectionStyle = .none
            cell.lblTitle.text = news["Title"]
            cell.lblSubTitle.text = NSLocalizedString(news["SubTitle"]!, comment: "")
            cell.btnOpen.tag = indexPath.row
            cell.btnOpen.addTarget(self,action:#selector(buttonClicked(sender:)), for: .touchUpInside)
            cell.imgProfile.image = UIImage(named:imgName)
            
            for state: UIControlState in [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved] {
                
                cell.btnOpen.setTitle(NSLocalizedString(id == "6" ? "Send" : id == "5" ? "CLAIM" : "Open", comment: "").lowercased().capitalizingFirstLetter(), for: state)
            }
            cell.backgroundColor = UIColor.clear
            if indexPath.row == 1
            {
                let isNotification = UserDefaults.standard.bool(forKey: isNotificationAllow)
                if(isNotification == true){
                    cell.isHidden = true
                    
                }
                else
                {
                    self.appDelegate.checkPushNotification {  (isEnable) in
                        if(isEnable == true){
                            UserDefaults.standard.set(isEnable, forKey:isNotificationAllow)
                            DispatchQueue.main.async {
                                cell.isHidden = true
                            }
                            
                        }
                    }
                }
            }
            return cell
        }
        else{
            let cell =
                self.newsTableView.dequeueReusableCell(withIdentifier: "newsCell") as! newsCell
            cell.selectionStyle = .none
            cell.lblTitle.text = news["Title"]
            cell.lblSubTitle.text = NSLocalizedString(news["SubTitle"]!, comment: "")
            cell.btnOpen.tag = indexPath.row
            cell.lblSubTitle.adjustsFontSizeToFitWidth = true
            cell.lblTitle.font = cell.lblTitle.font.withSize(12)
            cell.lblSubTitle.font = cell.lblSubTitle.font.withSize(12)
            cell.btnOpen.addTarget(self,action:#selector(buttonClicked(sender:)), for: .touchUpInside)
            cell.imgProfile.image = UIImage(named:imgName)
            
            for state: UIControlState in [.normal, .highlighted, .disabled, .selected, .focused, .application, .reserved] {
                cell.btnOpen.setTitle(NSLocalizedString(id == "6" ? "Send" : id == "5" ? "CLAIM" : "Open", comment: "").lowercased().capitalizingFirstLetter(), for: state)
            }
            cell.backgroundColor = UIColor.clear
            if indexPath.row == 1
            {
                
                let isNotification = UserDefaults.standard.bool(forKey: isNotificationAllow)
                if(isNotification == true){
                    cell.isHidden = true
                    
                }
                else
                {
                    self.appDelegate.checkPushNotification {  (isEnable) in
                        if(isEnable == true){
                            UserDefaults.standard.set(isEnable, forKey:isNotificationAllow)
                            DispatchQueue.main.async {
                                cell.isHidden = true
                            }
                            
                        }
                    }
                }
                
            }
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 1 {
            let isPermissionCodeExecuteCheck = UserDefaults.standard.bool(forKey: isPermissionCodeExecute)
            //var isNotificationEnabled = UIApplication.shared.currentUserNotificationSettings?.types.contains(UIUserNotificationType.alert)
            if isPermissionCodeExecuteCheck {
                let isNotification = UserDefaults.standard.bool(forKey:isNotificationAllow)
                if isNotification {
                    return 0
                }
            }
            
        }
        
        switch appDelegate.getLayoutType() {
        case .kPadLandscape  :
            return 178
        case .kPadPortrait  :
            return 178
        default:
            return 137
        }
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        
        if(indexPath.row == 0)
        {
            // self.appDelegate.logEvent(name: "News_BP", category: "Booster Pack", action: "Booster Button")
            //  appDelegate.texting()
            if(isBoosterShare()){
                shareLink()
            }else {
                let alert = UIAlertController(title: NSLocalizedString("You have reached the daily limit. Try again tomorrow", comment:""), message: NSLocalizedString("", comment:""), preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                  
                    self.appDelegate.logEvent(name: "booster_s_limit", category: "Booster News", action: "Booster Button")
                }
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
        else if(indexPath.row == 1)
        {
            self.appDelegate.logEvent(name: "News_NT", category: "FB News", action: "Notification")
            openNotificationSetting()
            
        }
        else if(indexPath.row == 2)
        {
            self.appDelegate.logEvent(name: "News_FB", category: "FB News", action: "FB Button")
            self.openFacebookPage()
        }
        else if(indexPath.row == 3)
        {
            self.appDelegate.logEvent(name: "News_IN", category: "Instagram News", action: "Instagram Button")
            self.openInstagramPage()
        }
        else if(indexPath.row == 4)
        {
            self.appDelegate.logEvent(name: "News_FR", category: "Instagram News", action: "Friends")
            guard let url = URL(string: "https://bonus.pixelcolorapp.com/bns-099") else { return }
            let content = ShareLinkContent()
            content.contentURL = url
            showShareDialog(content, mode: .automatic)
        }
        else{
            
            self.appDelegate.logEvent(name: "News_VT", category: "Vote News", action: "Vote Button")
            
            let vc        = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC
            let news       = self.newsList[indexPath.row]
            vc?.webViewUrl = news["Url"]!
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.pushViewController(vc!, animated: false)
            
        }
    }
    
    func showShareDialog<C: SharingContent>(_ content: C, mode: ShareDialog.Mode = .automatic) {
        let dialog = ShareDialog(fromViewController: self, content: content, delegate: self)
        dialog.mode = mode
        dialog.show()
    }
    
    func openFacebookPage() {
        let facebookURL = URL(string: "fb://page?id=183847442569336")!
        if UIApplication.shared.canOpenURL(facebookURL as URL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(facebookURL as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(facebookURL as URL)
            }
            
        } else {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(NSURL(string: "https://www.facebook.com/PIXELCOLORAPP")! as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(NSURL(string: "https://www.facebook.com/PIXELCOLORAPP")! as URL)
            }
        }
    }
    
    func openInstagramPage() {
        let instagramURL = URL(string: "instagram://user?username=pixelcolorapp")!
        if UIApplication.shared.canOpenURL(instagramURL) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(instagramURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(instagramURL)
            }
            
        } else {
            
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(NSURL(string: "https://www.instagram.com/pixelcolorapp/")! as URL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(NSURL(string: "https://www.instagram.com/pixelcolorapp/")! as URL)
            }
        }
    }
    //Change by shoaib
    private func openNotificationSetting() {
        // let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
        let isPermissionCodeExecuteCheck = UserDefaults.standard.bool(forKey: isPermissionCodeExecute)
        
       
        
        
        if  isPermissionCodeExecuteCheck == true {
            let alert = UIAlertController(title: NSLocalizedString("Alert:", comment:""), message: NSLocalizedString("You need to update notification permission, Go to Settings and choose to allow access to your location.", comment:""), preferredStyle: .alert)
            
            let okayAction = UIAlertAction(title: NSLocalizedString("Cancel" ,comment:""), style: .default) { (UIAlertAction) in
               
            }
            
            let settingAction = UIAlertAction(title: NSLocalizedString("Open Setting", comment:""), style: .cancel) { (UIAlertAction) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UserDefaults.standard.set(true, forKey: isOpenSettingForNotificationExecute)
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }
            }
            alert.addAction(okayAction)
            alert.addAction(settingAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        else {
            UserDefaults.standard.set(true, forKey: isPermissionCodeExecute)
            self.appDelegate.logEvent(name: "News_Notification", category: "Notification News", action: "Notification Button")
            pushNotificationAlert(application: UIApplication.shared)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3){
                self.appDelegate.checkPushNotification {  (isEnable) in
                    UserDefaults.standard.set(isEnable, forKey:isNotificationAllow)
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title:  NSLocalizedString("Success!",comment:""), message: NSLocalizedString("You got 15 Paint Buckets.", comment:""), preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                            if(UserDefaults.standard.bool(forKey: firstRegisterNotification) == false){
                                UserDefaults.standard.setValue(true,forKey: firstRegisterNotification)
                                UserDefaults.standard.set((UserDefaults.standard.integer(forKey: self.paint_count)+15), forKey: self.paint_count)
                                
                                self.appDelegate.logEvent(name: "note_enable", category: " notification", action: " notification enable")
                            }
                        }
                        alert.addAction(okayAction)
                        self.present(alert, animated: true, completion: nil)
                        self.newsTableView.reloadData()
                    }
                   
                }
            }
            self.newsTableView.reloadData()
        }
    }
    func pushNotificationAlert(application:UIApplication) {
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
                                    self.appDelegate.logEvent(name: "note_enable", category: " notification", action: " notification enable")
                                    UserDefaults.standard.setValue(1,forKey: notificationStatus)
                                    UserDefaults.standard.synchronize()
                                }

                            case .denied:
                                let notiStaus = UserDefaults.standard.integer(forKey: notificationStatus)
                                print("setting has been disabled :- \(notiStaus)")
                                if(notiStaus == 1 || notiStaus == 0){
                                    self.appDelegate.logEvent(name: "note_disable", category: " notification", action: " notification disable")
                                    UserDefaults.standard.setValue(2,forKey: notificationStatus)
                                    UserDefaults.standard.synchronize()
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
                            

                        }else{
                            print("setting has been disabled")

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
    @objc func buttonClicked(sender:UIButton) {
        
        let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "WebViewVC") as? WebViewVC
        
        let buttonRow = sender.tag
        
        
        
        if(buttonRow == 0)
        {
            // shareLink()
            
            if(isBoosterShare()){
                shareLink()
            }else {
                let alert = UIAlertController(title: NSLocalizedString("You have reached the daily limit. Try again tomorrow", comment:""), message: NSLocalizedString("", comment:""), preferredStyle: .alert)
                
                let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                   
                    self.appDelegate.logEvent(name: "booster_s_limit", category: "Booster News", action: "Booster Button")
                }
                alert.addAction(okayAction)
                self.present(alert, animated: true, completion: nil)
            }
            
        }
        else if(buttonRow == 1)
        {
            openNotificationSetting()
            
        }
        else if(buttonRow == 2)
        {
            self.appDelegate.logEvent(name: "News_FB", category: "FB News", action: "FB Button")
            self.openFacebookPage()
        }
        else if(buttonRow == 3)
        {
            self.appDelegate.logEvent(name: "News_IN", category: "Instagram News", action: "Instagram Button")
            self.openInstagramPage()
        }
        else if(buttonRow == 4)
        {
            guard let url = URL(string: "https://bonus.pixelcolorapp.com/bns-099") else { return }
            let content = ShareLinkContent()
            content.contentURL = url
            showShareDialog(content, mode: .automatic)
        }
        else{
            
            self.appDelegate.logEvent(name: "News_VT", category: "Vote News", action: "Vote Button")
            
            let news = self.newsList[buttonRow]
            vc?.webViewUrl = news["Url"]!
            navigationItem.backBarButtonItem = UIBarButtonItem(title: NSLocalizedString("news", comment: ""), style: .plain, target: nil, action: nil)
            self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
            self.navigationController?.pushViewController(vc!, animated: false)
            
        }
        
    }
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        
        var array = UserDefaults.standard.stringArray(forKey: BONUS_NOT_CLAIMED) ?? [String]()
        array.append("BNS099")
        UserDefaults.standard.set(array, forKey: BONUS_NOT_CLAIMED)
        UserDefaults.standard.synchronize()
        
        DispatchQueue.main.async {
            //            let alertController = UIAlertController(title: NSLocalizedString("Congratulations!", comment: ""), message: "Bonus pack has been\n unlocked! Check it out at\n Bonus section.", preferredStyle: .alert)
            //            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: self.GotoBonus)
            //            alertController.addAction(defaultAction)
            //            self.present(alertController, animated: true, completion: nil)
            self.tabBarController?.selectedIndex = 0
        }
        
    }
    
    func sharer(_ sharer: Sharing, didFailWithError error: Error) {
        
    }
    
    func sharerDidCancel(_ sharer: Sharing) {
        
        
        
    }
    
    func GotoBonus(action: UIAlertAction){
        self.tabBarController?.selectedIndex = 0
    }
    
    
    func shareLink(){
        
        
        let uuid = UIDevice.current.identifierForVendor!.uuidString
        let last4 = String(UUID().uuidString.suffix(4))
        let shareCode = last4  + "_" + uuid
        guard let link = URL(string: "http://bonus.pixelcolorapp.com/booster1/?Link=https://pixelcolorapp.page.link&ibi=com.moomoolab.pl3&ifl=https://itunes.apple.com/in/app/pixel-colour-pixel-art-book/id1277229792?mt=8&isi=1277229792&boost=b\(shareCode)")
        else {
            return
        }
        let dynamicLinksDomainURIPrefix = "https://pixelcolorapp.page.link"
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        linkBuilder!.iOSParameters = DynamicLinkIOSParameters(bundleID: "com.moomoolab.pl3")
        
        linkBuilder!.socialMetaTagParameters?.title = "Booster Pack"
        linkBuilder!.socialMetaTagParameters?.descriptionText = "Daily booster pack for friends"
        linkBuilder!.socialMetaTagParameters?.imageURL = URL(string: "http://bonus.pixelcolorapp.com/wp-content/uploads/2021/03/boosterfriends.jpg")
        
        linkBuilder!.shorten() { url, warnings, error in
            guard let myURL = url else { return }
            let deepLink = String(describing: myURL)
           // print("The short URL is: \(deepLink)")
            let myWebsite = NSURL(string:deepLink as String)
            let objectsToShare = [ myWebsite ?? ""] as [Any] //image!,text ,
            
            let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityViewController.excludedActivityTypes =   [
                UIActivityType.assignToContact,
                UIActivityType.print,
                UIActivityType.addToReadingList,
                UIActivityType.saveToCameraRoll,
                UIActivityType.openInIBooks,
                UIActivityType.saveToCameraRoll
            ]
            // activityViewController.excludedActivityTypes = []
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            
            if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                activityViewController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                activityViewController.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
                
            }
            
            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed {
                    if(error == nil)
                    {
                        let date = Date()
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd-MM-yyyy"
                        let result = formatter.string(from: date)
                        
                        let prevShareCount = UserDefaults.standard.value(forKey: previousBoostShareCount) as? Int
                        UserDefaults.standard.set(prevShareCount!+1,forKey: previousBoostShareCount)
                        UserDefaults.standard.set(result, forKey: boosterShareDate)
                        UserDefaults.standard.synchronize()
                        self.appDelegate.logEvent(name: "booster_s", category: "booster", action: "Shared booster")
                        
                    }else{
                        
                    }
                }
            }
            
            self.present(activityViewController, animated: true, completion: nil)
        }
        
    }
    
    func isBoosterShare() -> Bool
    {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd-MM-yyyy"
        formatter.timeZone = .current
        formatter.locale = .current
        let result = formatter.string(from: date)
        
        if UserDefaults.standard.value(forKey: boosterShareDate) != nil{
            let prevDateString = UserDefaults.standard.value(forKey: boosterShareDate) as? String
            if prevDateString != result
            {
                UserDefaults.standard.set(0,forKey: previousBoostShareCount)
                UserDefaults.standard.set(result, forKey: boosterShareDate)
                return true
            }
            else{
                
                let prevShareCount = UserDefaults.standard.value(forKey: previousBoostShareCount) as? Int
                if(prevShareCount != nil){
                    if(prevShareCount! < maxBoosterShareCount){
                        return true
                    }
                    else {
                        return false
                    }
                }else {
                    return true
                }
            }
            
        }
        else
        {
            UserDefaults.standard.set(0,forKey: previousBoostShareCount)
            UserDefaults.standard.set(result, forKey: boosterShareDate)
            UserDefaults.standard.synchronize()
        }
        
        return true
    }
    
    
    @objc func orientationChanged(_ notification: Notification) {
        let orientation = UIDevice.current.orientation
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return
        }
        if orientation == .landscapeLeft {
            self.newsTableView.reloadData()
            print("orientation => landscapeLeft")
        }
        else if orientation == .landscapeRight {
            self.newsTableView.reloadData()
            print("orientation => landscapeRight")
        }
        else if(orientation == .portraitUpsideDown){
            self.newsTableView.reloadData()
            print("orientation => portraitUpsideDown")
        }
        else if(orientation == .portrait){
            print("orientation => portrait")
            self.newsTableView.reloadData()
        }
        else if(orientation == .faceUp){
            print("orientation => faceUp")
           // self.newsTableView.reloadData()
        }
        else if(orientation == .faceDown){
            print("orientation => faceDown")
           // self.newsTableView.reloadData()
        }
        else if(orientation == .unknown){
            print("orientation => unknown")
           // self.newsTableView.reloadData()
        }
        
        
    }
    
    
    @objc func checkNotificationStatus(_ notification: Notification) {
        self.appDelegate.checkPushNotification {  (isEnable) in
            UserDefaults.standard.set(isEnable, forKey:isNotificationAllow)
            DispatchQueue.main.async {
                let isOpenSettingForNotification = UserDefaults.standard.bool(forKey: isOpenSettingForNotificationExecute)
                if(isOpenSettingForNotification && isEnable){
                    let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                    if(isExpired == "YES"){
                        let alert = UIAlertController(title:  NSLocalizedString("Success!",comment:""), message: NSLocalizedString("You got 10 Paint Buckets!", comment:""), preferredStyle: .alert)
                        let okayAction = UIAlertAction(title: NSLocalizedString("OK" ,comment:""), style: .default) { (UIAlertAction) in
                            
                            UserDefaults.standard.set((UserDefaults.standard.integer(forKey: self.paint_count)+10), forKey: self.paint_count)
                            UserDefaults.standard.set(false, forKey: isOpenSettingForNotificationExecute)
                        }
                        alert.addAction(okayAction)
                        self.present(alert, animated: true, completion: nil)
                    }
                    else{
                        UserDefaults.standard.set(false, forKey: isOpenSettingForNotificationExecute)
                    }
                    
                }
            }
        }
    }
    
}
