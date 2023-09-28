//
//  MyWorkVC.swift
//  PL2
//
//  Created by iPHTech8 on 11/1/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit
import SVProgressHUD
import SystemConfiguration
import CloudKit
import GoogleMobileAds
import AVFoundation
import GraphicsRenderer

class MyWorkVC: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIWebViewDelegate, RewardedAdHelperDelegate, InterstitialAdHelperDelegate {
    
    @IBOutlet weak var myworkLbl: UILabel!
    @IBOutlet weak var infoBtn: UIButton!
    var activityIndicator  = UIActivityIndicatorView()
    var dullView = UIView()
    let convert = ConvertImageToGreyScale()
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isHelpViewVisible = 0
    var isSubscriptionViewVisible = 0
    var iapSubscriptionView : UIView!
    var helpView : UIView!
    var pointAndColorArrMyWork = [PointAndColor]()
    var grayImageViewMyWork :UIImageView?
    var squareWidthMyWork:CGFloat = 8.0
    var minimumScaleMyWork:CGFloat = 0.2
    
    var isreward :Bool = true;
    
    let STARTER_PRODUCT_ID = "com.moomoolab.pl2sp"
    let WEEK_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2wk"
    let MONTH_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2mo"
    let YEAR_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2yr"
    
    
    let TEST_UNIT_ID = "ca-app-pub-3940256099942544/1712485313"
    let REWARDED_AD_ID = "ca-app-pub-7682495659460581/8735943137"

    //MARK: Reward Ad Helper
    private var rewardedAdHelper = RewardedAdHelper()
    
    //MARK: Inhetitance Ad Helper
    private var interstitialAdHelper = InterstitialAdHelper()
    // Replace this with new Add-Id
    let INTERSTITIAL_AD_ID = "ca-app-pub-7682495659460581/7313761854"
    
    
    //NEW:"ca-app-pub-7682495659460581~6281920678"
    //OLD:"ca-app-pub-7682495659460581/4701355397"
    fileprivate var rewardBasedVideo: GADRewardedAd?

    var adRequestInProgress = false
    var shouldShowRewardedVideo = false
    var currentDate :Date!
    var _imageData : ImageData!
    var _selectedIndex : Int!
    
    
    @IBOutlet var collectionView: UICollectionView!
    
    var completedID = [String]()


    //Lekha updated
    var imageArray = [ImageData]()
    var nonCompletedArr = [ImageData]()
    var completedArr = [ImageData]()
    
    //Saddam Added.
    var imageDrawView:UIImageView?
    var grayScaleColors = [[UIColor]]()
    var imageColors = [[UIColor]]()
    var colorsOccurence: [UIColor: Int] = [:]
    var whiteColorLocations:[CGPoint] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        if (UserDefaults.standard.object(forKey: "FIRST_RECEIPT") == nil)
        {
            // IAPHandler.shared.receiptValidation()
        }
        //Configure Collection View
        self.collectionView.delegate   = self
        self.collectionView.dataSource = self
        
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: (self.tabBarController?.tabBar.frame.size.height)!, right: 0)
        self.collectionView.register(UINib(nibName : "MyWorkCell" , bundle : nil), forCellWithReuseIdentifier:"MyWorkCell" )
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadList(notification:)), name: NSNotification.Name(rawValue: "myWorkSynced"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadIAPMYWork(notification:)), name: NSNotification.Name(rawValue: "orientation_change_mywork"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadCollectionView(notification:)), name: NSNotification.Name(rawValue: "orientation_change_pages"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(rewardBasedVideoAdWillLeaveApplication), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            
            navigationController?.navigationBar.tintColor = .black
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
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
                self.perform(#selector(self.loadRewardedAd), with: nil, afterDelay: 0.1)
            }
            else {
                self.perform(#selector(self.loadIntersialAd), with: nil, afterDelay: 0.1)
            }
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.imageDrawView = nil
    }
    
    @objc func loadIntersialAd() {
        print("---- My Work Screen ----")
        interstitialAdHelper.loadInterstitial()
        interstitialAdHelper.delegate = self
    }
    
    @objc func loadRewardedAd() {
        print("---- My Work Screen ----")
        rewardedAdHelper.rewardId = PAGES_MY_WORK_REWARD_Id
        rewardedAdHelper.loadRewardedAd(adId: PAGES_MY_WORK_REWARD_Id)
        rewardedAdHelper.delegate = self
    }
    
    func dismissRewardedAd() {
    
    }
    
    func dismissIntersialAd() {
       
    }
    
     func showReward(rewardAmount: String, status: String) {
         if status == "Success" {
             print("Reward ad received for My Work Screen")
             print("My WorkVC - RewardAD ID : \(PAGES_MY_WORK_REWARD_Id)")

         }
         else {
//             let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//             vc.imageData =  self.appDelegate.selectedImageData
//
//             //self.imageArray[index]
//             self.navigationController?.pushViewController(vc, animated: true);

             
             print("Please try Again MY RW!")
             self.appDelegate.logEvent(name: "No_Reward_MW", category: "Ads", action: "MW")
//             let callActionHandler = { (action:UIAlertAction!) -> Void in
//                 //  self.backToView(
//             }
//             let alertController = UIAlertController(title: "Please try Again MY RW!", message: nil, preferredStyle: .alert)
//             let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
//             alertController.addAction(defaultAction)
//             self.present(alertController, animated: true, completion:nil)
         }
     }
     
     func showInterstitialMessage(message: String, status: String) {
         if status == "Success" {
             print("Intersial ad received for My Work Screen")
             print("MyWork VC - IntersialAD ID : \(INTERSIAL_AD_Unit_Id)")

         }
         else {
             print("Please try Again MY IT!")
             self.appDelegate.logEvent(name: "No_IN_MW", category: "Ads", action: "MW")
//             let callActionHandler = { (action:UIAlertAction!) -> Void in
//               //  self.backToView()
//             }
//             let alertController = UIAlertController(title: "Please try Again MY IT!", message: nil, preferredStyle: .alert)
//             let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
//             alertController.addAction(defaultAction)
//             self.present(alertController, animated: true, completion:nil)
         }
     }
//    override var prefersStatusBarHidden: Bool {
//        return true
//    }

    //func showAlert() {
        
        //SVProgressHUD.setMinimumDismissTimeInterval(1.0)
        //SVProgressHUD.setMaximumDismissTimeInterval(3.0)
        //SVProgressHUD.showInfo(withStatus: "Current rewardTime value = \(rewardTime)\nCurrent interstitialTime value = \(interstitialTime)")

    //}
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }

    
    @objc func loadCollectionView(notification: NSNotification) {
        DispatchQueue.main.async {
            self.reloadOrientationChange()
        }
    }
    
    
    @objc func loadIAPMYWork(notification: NSNotification) {
        if isSubscriptionViewVisible == 1
        {
            self.iapSubscriptionView.removeFromSuperview()
            self.addIAPSubscriptionView()
        }
        
    }
    
    @objc func loadList(notification: NSNotification) {
        if #available(iOS 10.0, *) {
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                //Devendra to do
                self.getAllCompletedImagesFromDB()
                self.reloadArrays()
            }
        } else {
            // Fallback on earlier versions
        }
        
    }
    
    fileprivate func  reloadOrientationChange() {
        //let height = (self.collectionView.frame.size.height - 40 )/3
        
        /*let layout = self.collectionView.collectionViewLayout as! UICollectionViewFlowLayout
         var width  = (self.collectionView.frame.size.width)/2
         var height = width - 20//Height should be equal to width as Square //Lekha
         
         var offset = 0
         let max_width = 280
         let userInterface = UIDevice.current.userInterfaceIdiom
         offset = Int(height) > Int(max_width) ? (Int(height) - Int(max_width)) : 0
         width = width - CGFloat(offset)
         height = width - 20
         
         if(userInterface == .pad)
         {
         if UIDevice.current.orientation.isLandscape {
         width  = (self.collectionView.frame.size.width-168)/3
         height = width - 20
         offset = 84
         }
         }
         
         layout.sectionInset = UIEdgeInsets(top: 0, left: CGFloat(offset), bottom: 10, right: CGFloat(offset))
         layout.itemSize = CGSize(width: width, height: height)
         self.collectionView.collectionViewLayout = layout
         layout.invalidateLayout()*/
        
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        
        layout.minimumLineSpacing = 10.0
        layout.minimumInteritemSpacing = 0.0
        
        var noOfRows:CGFloat = 2.0
        
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            if appDelegate.isLandscapeByMe() {
                noOfRows = 4.0
            }
            else {
                noOfRows = 3.0
            }
            
        }
        
        
        var width  = UIScreen.main.bounds.size.width/noOfRows
        
        var height = width - 20
        var offset = 0
        let max_width = 280
        offset = Int(height) > Int(max_width) ? (Int(height) - Int(max_width)) : 0
        width = width - CGFloat(offset)
        height = width - 20
        let margin:CGFloat = (CGFloat(offset)*noOfRows)/2
        layout.sectionInset = UIEdgeInsets(top: 10, left: margin, bottom: 10, right: margin)
        layout.itemSize = CGSize(width: width, height: height)
        self.collectionView.collectionViewLayout = layout
        layout.invalidateLayout()
      
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
        
        
        self.view.backgroundColor = UIColor.white
        self.tabBarController?.tabBar.isHidden = false
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        
        appDelegate.logScreen(name: "My Work")
        navigationController?.navigationBar.barTintColor = UIColor.white
        navigationController?.navigationBar.isTranslucent = false
        self.title = NSLocalizedString("My Work", comment: "")
        let titleDict: NSDictionary = [NSAttributedStringKey.foregroundColor: UIColor.gray]
        navigationController?.navigationBar.titleTextAttributes = titleDict as? [NSAttributedStringKey : Any]
        if #available(iOS 10.0, *) {
            //Devendra to do
            self.getAllCompletedImagesFromDB()
        } else {
            // Fallback on earlier versions
        }
        completedID = getCompletedImagesIDArray()
        reloadOrientationChange()
        if #available(iOS 10.0, *) {
            //Devendra to do
            
            self.reloadArrays()
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    func getAllCompletedImagesFromDB()
    {
        let dbHelper = DBHelper.sharedInstance
        let imageArrayTemp = dbHelper.getMyWorkImages()
        
        let defaults = UserDefaults.standard
        if defaults.array(forKey: Completed_ID_Key) == nil
        {
            // SVProgressHUD.show()
            for imgDataTemp in imageArrayTemp
            {
                var completeImage = UIImage()
                if let image = UIImage(named:imgDataTemp.name!)
                {
                    //Set
                    completeImage = image
                }
                else
                {
                    let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgDataTemp.name!)
                    let fileManager = FileManager.default
                    if fileManager.fileExists(atPath: paths){
                        let image = UIImage(contentsOfFile:paths)
                        //Set
                        completeImage = image!
                    }
                    else
                    {
                        //Something went Wrong
                    }
                }
                let isCompleteCheck = self.isDrawingCompleteMyWork(image: completeImage, imageID: imgDataTemp.imageId!, grayImage:appDelegate.getImage(imgName: imgDataTemp.name!, imageId:imgDataTemp.imageId!)!, imageName: imgDataTemp.name!, isCallBySelect: "0")
                if isCompleteCheck == true
                {
                    var arrayCompleted = getCompletedImagesIDArray()
                    if !arrayCompleted.contains(imgDataTemp.imageId!)
                    {
                        arrayCompleted.append(imgDataTemp.imageId!)
                        saveCompletedImagesIDArray(array: arrayCompleted)
                    }
                }
            }
        }
        
    }
    func reloadArrays()  {
        
        do {
            imageArray.removeAll()
            completedArr.removeAll()
            nonCompletedArr.removeAll()
            SVProgressHUD.dismiss()
        } catch {
            print("SVProgressHUD not be loaded")
        }
        
        let dbHelper = DBHelper.sharedInstance
        let imageArrayTemp = dbHelper.getMyWorkImages()
        
        for imgDataTemp in imageArrayTemp
        {
            if completedID.contains(imgDataTemp.imageId!)
            {
                completedArr.append(imgDataTemp)
            }
            else
            {
                nonCompletedArr.append(imgDataTemp)
            }
        }
        
        var lastEditImageName = ""
        if(UserDefaults.standard.value(forKey: "LastEditImageName") != nil)
        {
            lastEditImageName = (UserDefaults.standard.value(forKey: "LastEditImageName") as? String)!
        }
        
        for imgDataTemp1 in nonCompletedArr
        {
            
            if(imgDataTemp1.name == lastEditImageName)
            {
                imageArray.insert(imgDataTemp1, at: 0)
            }
            else{
                imageArray.append(imgDataTemp1 )
            }
            
            
        }
        for imgDataTemp2 in completedArr
        {
            
            if(imgDataTemp2.name == lastEditImageName)
            {
                imageArray.insert(imgDataTemp2, at: nonCompletedArr.count)
            }
            else{
                imageArray.append(imgDataTemp2)
            }
            
        }
        
        myWorkLogEvent()
        collectionView.reloadData()
        
    }
    
    
    func myWorkLogEvent()
    {
        if(imageArray.count == 0 ){
            return
        }
        else if(imageArray.count <= 5 )
        {
            self.appDelegate.logEvent(name: "mywork_L1", category: "Results_MyWork", action: "MyWork")
        }
        else if(imageArray.count > 5 && imageArray.count <= 10 )
        {
            self.appDelegate.logEvent(name: "mywork_L2", category: "Results_MyWork", action: "MyWork")
        }
        else if(imageArray.count > 10 && imageArray.count <= 15 )
        {
            self.appDelegate.logEvent(name: "mywork_L3", category: "Results_MyWork", action: "MyWork")
        }
        else if(imageArray.count > 15 && imageArray.count <= 20 )
        {
            self.appDelegate.logEvent(name: "mywork_L4", category: "Results_MyWork", action: "MyWork")
        }
        else{
            self.appDelegate.logEvent(name: "mywork_L5", category: "Results_MyWork", action: "MyWork")
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarningMyWork Shoaib")
        appDelegate.logEvent(name: "memorywarning_mywork", category: "error", action: "mywork")
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - CollectionView DataSource and Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellIdentifier = "MyWorkCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier,for: indexPath) as! MyWorkCell
        
        cell.backImageView.backgroundColor = UIColor.white

        let userInterface = UIDevice.current.userInterfaceIdiom
        let orientDevice = appDelegate.isLandscapeByMe()
        if(userInterface == .pad && orientDevice == true)
        {
            cell.updateOffSetForiPadLandscape(indexPath.row%3)
        }
        else
        {
            switch indexPath.row%2 {
            case 0:
                cell.updateOffSet(true)
            default:
                cell.updateOffSet(false)
            }
        }
        //cell.imageView.image = convert.convertImageToGrayScale(image:UIImage(named: imageArray[indexPath.item].name!)!)
        //        cell.loader.stopAnimating()
        if let img = appDelegate.getImage(imgName: imageArray[indexPath.item].name!, imageId:imageArray[indexPath.item].imageId! )
        {
            cell.imageView.image = img
        }
        else
        {
            self.loadServerImage(indexPath: indexPath, name: imageArray[indexPath.item].name! as NSString)
        }
        
        cell.lockView.isHidden = true
        
        let dataSource = completedID
        let searchString = imageArray[indexPath.item].name!
        let predicate = NSPredicate(format: "SELF contains %@", searchString)
        let searchDataSource = dataSource.filter { predicate.evaluate(with: $0) }

        if searchDataSource.count > 0//completedID.contains(imageArray[indexPath.item].imageId!)
        {
            cell.completeIcon.isHidden = false
        }
        else
        {
            cell.completeIcon.isHidden = true
        }
        
        let imgData = imageArray[indexPath.item] as ImageData
        
        if let val = imgData.purchase{
            if val != 0 {
                let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                if ((imgData.purchase == 0) || ((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (imgData.purchase == 1 && (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable)))
                {
                    cell.lockView.isHidden = true
                    
                }
                else
                {
                    //cell.lockView.isHidden = false
                    cell.lockView.isHidden = true
                }
                //
            }
        }
        
        return cell
    }
    
    func loadServerImage(indexPath:IndexPath, name: NSString)
    {
        let thumName = NSString(format:"t_%@",name)
        
        let recordID = CKRecordID(recordName:thumName.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            
            let fileData = record.object(forKey: "data") as! Data
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(thumName as String)
            
            let fileManager = FileManager.default
            
            if !fileManager.fileExists(atPath: paths){
                fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            }
            
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.00001 , execute: {
                self.collectionView.reloadItems(at: [indexPath])
            })
            
            //print("The user record is: \(record)")
        }
        
        let recordID2 = CKRecordID(recordName:name.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID2) { record, error in
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
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //self.collectionView.layoutIfNeeded()
        var noOfRows:CGFloat = 2.0
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            if appDelegate.isLandscapeByMe() {
                noOfRows = 4.0
            }
            else {
                noOfRows = 3.0
            }
        }
        var width  = UIScreen.main.bounds.size.width/noOfRows
        var height = width - 20
        var offset = 0
        let max_width = 280
        offset = Int(height) > Int(max_width) ? (Int(height) - Int(max_width)) : 0
        width = width - CGFloat(offset)
        height = width - 20
        return CGSize(width: width, height: height)
        //  return CGSize(width: width, height: height)
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        //showAlert()

        _selectedIndex = indexPath.row
        let imgData = imageArray[indexPath.row] as ImageData
        self.appDelegate.selectedImageData = imgData
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        // if ((imgData.purchase == 0) || ((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (imgData.purchase == 1 && (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable)))
        //{
        var completeImage = UIImage()
        if let image = UIImage(named:imageArray[indexPath.row].name!)
        {
            //Set
            completeImage = image
        }
        else
        {
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageArray[indexPath.row].name! as String)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: paths){
                let image = UIImage(contentsOfFile:paths)
                //Set
                completeImage = image!
            }
            else
            {
                //Something went Wrong
            }
        }
        
        let dataSource = completedID
        let searchString = imageArray[indexPath.item].name!
        let predicate = NSPredicate(format: "SELF contains %@", searchString)
        let searchDataSource = dataSource.filter { predicate.evaluate(with: $0) }
        var isCallBySelect = "0"
        if searchDataSource.count > 0//completedID.contains(imageArray[indexPath.item].imageId!)
        {
            isCallBySelect = "1"
        }

        let isCompleteCheck = self.isDrawingCompleteMyWork(image: completeImage, imageID: imageArray[indexPath.row].imageId!, grayImage:appDelegate.getImage(imgName: imageArray[indexPath.item].name!, imageId:imageArray[indexPath.item].imageId! )!, imageName: imageArray[indexPath.item].name!, isCallBySelect: isCallBySelect)
        //print("IS COMPLETE==",isCompleteCheck)
        if isCompleteCheck == true
        {
            self.openActionSheetWithOptions(name: NSLocalizedString("Share", comment: ""), index: indexPath.row, isComplete:true)
        }
        else
        {
            _imageData = imgData
            self.appDelegate.selectedImageData = _imageData
            // _selectedIndex = indexPath.row
//            var shouldShowAds = self.adsShouldBeCalled()
//            var isreward :Bool = true;
//            if UserDefaults.standard.value(forKey: "sessionTime") != nil
//            {
//                //Manage session time checks of 5 and 10 minutes to show Ads
//                let sessionTime: Int = (UserDefaults.standard.value(forKey: "sessionTime") as? Int)!
//                //                if(sessionTime >= 0 && sessionTime < 10 )
//                //                {
//                //                    isreward = false
//                //                }
//                //                else if(sessionTime < 5 || sessionTime >= 10){
//                //                    isreward = false
//                //                    //isreward = true
//                //                }
//
//                //#120. A/B testing: revert to prior ad logics
//                if(sessionTime >= interstitialTime && sessionTime <= rewardTime )
//                {
//                    isreward = false
//
//                }else if(sessionTime >= rewardTime){
//                    isreward = true
//                }
//                else if(sessionTime < interstitialTime) || (sessionTime >= rewardTime){
//                    shouldShowAds = false
//                }
//
//            }
//
//            if (shouldShowAds && self.isInternetAvailable())
//            {       print("SHOW ADS TRUEEE")
//                self.showInterstialAndRewardedAds(isreward:isreward)
//
//                return
//            }
//            else
//            {
                self.openActionSheetWithOptions(name: NSLocalizedString("Continue", comment: ""), index: indexPath.row, isComplete:false)
//            }
        }
        
    }
    
    func showActivityIndicator(){
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .whiteLarge
        activityIndicator.center = self.view.center
        activityIndicator.frame = CGRect(x: self.view.frame.midX, y: self.view.frame.midY, width: 40, height: 40)
        activityIndicator.startAnimating()
        dullView.frame = self.view.frame
        dullView.backgroundColor = UIColor.black
        dullView.alpha = 0.5
        
        dullView.isUserInteractionEnabled = false
        self.view.addSubview(dullView)
        self.view.addSubview(activityIndicator)
    }
    
    //Gaurav
    
    @IBAction func infoBtnPressed(_ sender: Any) {
        
        
    }
    
    /////////////////IAP/////////
    //MARK:- IAP Subscription View
    func addIAPSubscriptionView()
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

                self?.removeIAPSubscriptionView()
                
                if (type == .purchased) || (type == .restored)
                {
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeNonConsumable)
                    self?.collectionView.reloadData()
                }
                else  if (type == .purchasedWeek) || (type == .restoredWeek)
                {
                    if (type == .purchasedWeek)
                    {
                        self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "MyWork")
                        self?.appDelegate.logEvent(name: "weekly_sub_comp_MW", category: "Subscription", action: "MyWork")
                        self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeWeekSubscription)
                    self?.collectionView.reloadData()
                }
                else  if (type == .purchasedMonth) || (type == .restoredMonth)
                {
                    if (type == .purchasedMonth)
                    {
                        self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "MyWork")
                        self?.appDelegate.logEvent(name: "monthly_sub_comop_MW", category: "Subscription", action: "MyWork")
                        self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeMonthSubscription)
                    self?.collectionView.reloadData()
                }
                else  if (type == .purchasedYear) || (type == .restoredYear)
                {
                    if (type == .purchasedYear)
                    {
                        self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "MyWork")
                        self?.appDelegate.logEvent(name: "yearly_sub_comp_MW", category: "Subscription", action: "MyWork")
                        self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeYearSubscription)
                    self?.collectionView.reloadData()
                }
            })
        }
        
        
        let screenSize: CGRect = UIScreen.main.bounds
        self.iapSubscriptionView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
        self.iapSubscriptionView.backgroundColor = UIColor.white
        self.iapSubscriptionView.alpha = 1.0
        UIApplication.shared.keyWindow?.addSubview(self.iapSubscriptionView)
        
        
        var width_white : CGFloat = 320
        var height_white : CGFloat = 568
        var cross_btn_width : CGFloat = 40
        var msg_lbl_height : CGFloat = 40
        var msg_lbl_yVal : CGFloat = 195
        var button_yVal : CGFloat = 240
        var button_width : CGFloat = 198
        var button_height : CGFloat = 42
        var help_btn_width : CGFloat = 40
        var offsetHelp : CGFloat = 15
        
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
        let helpButtonRect = CGRect(x: offsetHelp*2, y: screenSize.height - (offsetHelp) - help_btn_width, width: help_btn_width, height: help_btn_width)
        
        let whiteRect = CGRect(x: xVal_white, y: yVal_white-50, width: width_white, height: height_white)
        let bgImageRect = CGRect(x: 0, y: 0, width: whiteRect.width, height: whiteRect.height)
        let msgLabelRect = CGRect(x: 0, y: msg_lbl_yVal, width:whiteRect.width, height: msg_lbl_height)
        let buttonWeekRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal, width: button_width, height: button_height)
        let buttonMonthRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+button_height+button_offset , width: button_width, height: button_height)
        let buttonYearRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*2)+(button_offset*2) , width: button_width, height: button_height)
        var buttonRestoreRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*3)+(button_offset*2)+button_offset/2, width: button_width, height: button_height)
        let longMsgRect = CGRect(x: 0, y: longmsg_lbl_yVal, width:whiteRect.width, height: longmsg_lbl_height)
        var termsButtonRect = CGRect(x: (screenSize.width - button_width) / 2, y: screenSize.height - (offsetHelp) - button_height, width: button_width, height: button_height)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if UIDevice.current.orientation.isLandscape
            {
                termsButtonRect = CGRect(x: (screenSize.width - 170), y: screenSize.height - (offsetHelp) - help_btn_width-10, width: 150, height: button_height)
                buttonRestoreRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*3)+(button_offset*2), width: button_width, height: button_height)
            }
        }
        
        
        let whiteView = UIView(frame: whiteRect)
        whiteView.backgroundColor = UIColor.clear
        whiteView.alpha = 1.0
        whiteView.clipsToBounds = true
        whiteView.layer.cornerRadius = 15
        self.iapSubscriptionView.addSubview(whiteView)
        //bgImage
        let bgImage = UIImageView(frame: bgImageRect)
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            bgImage.image = UIImage(named: "subs_iphone")
        }
        else if UIDevice.current.userInterfaceIdiom == .pad
        {
            bgImage.image = UIImage(named: "subs_ipad")
            if UIDevice.current.orientation.isLandscape
            {
                bgImage.image = UIImage(named: "subs_ipadh")
            }
        }
        bgImage.contentMode = .scaleAspectFill
        whiteView.addSubview(bgImage)
        
        //crossButton
        let crossButton = UIButton(frame: crossButtonRect)
        crossButton.setImage(UIImage(named: "cancel_subs"), for: UIControlState.normal)
        crossButton.addTarget(self, action:#selector(self.removeIAPSubscriptionView), for: .touchUpInside)
        iapSubscriptionView.addSubview(crossButton)
        //HelpButton
        let helpButton = UIButton(frame: helpButtonRect)
        helpButton.setImage(UIImage(named: "help"), for: UIControlState.normal)
        helpButton.addTarget(self, action:#selector(self.presentHelpView), for: .touchUpInside)
        iapSubscriptionView.addSubview(helpButton)
        //termsButton
        let termsButton = UIButton(frame: termsButtonRect)
        termsButton.setTitle(NSLocalizedString("Terms & Privacy", comment: ""), for: UIControlState.normal)
        termsButton.addTarget(self, action:#selector(self.presentTermsView), for: .touchUpInside)
        termsButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        termsButton.titleLabel?.textAlignment  = NSTextAlignment.center
        iapSubscriptionView.addSubview(termsButton)
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
        whiteView.addSubview(msgLabel)
        //longMsgLabel
        let longMsgLabel = UILabel(frame: longMsgRect)
        longMsgLabel.text = NSLocalizedString("Subscription may be managed by the user and auto-renewal\nmay be turned off by going to the user’s Account Settings\nafter purchase. Any unused portion of a free trial period, if\noffered, will be forfeited when the user purchases a subscription\nto that publication, where applicable. Payment will be charged to\niTunes Account at confirmation of purchase. Subscription\nautomatically renews unless auto-renew is turned off at least \n24-hours before the end of the current period. Account will \nbe charged for renewal within 24-hour prior to the \nend of the current period, and identify the cost of the renewal.", comment: "")
        longMsgLabel.textAlignment = NSTextAlignment.center
        longMsgLabel.textColor = UIColor.lightGray
        longMsgLabel.font = UIFont.systemFont(ofSize: 10.0)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if UIDevice.current.orientation.isLandscape
            {
                longMsgLabel.text = NSLocalizedString("Subscription may be managed by the user and auto-renewal may be turned off by\n going to the user’s Account Settings after purchase. Any unused portion of a free trial period,\n if offered, will be forfeited when the user purchases a subscription to that publication,\n where applicable. Payment will be charged to iTunes Account at confirmation of purchase.\n Subscription automatically renews unless auto-renew is turned off at least 24-hours\n before the end of the current period. Account will be charged for renewal within 24-hour\n prior to the end of the current period, and identify the cost of the renewal.", comment: "")
                longMsgLabel.font = UIFont.systemFont(ofSize: 13.0)
            }
        }
        longMsgLabel.numberOfLines = 15
        whiteView.addSubview(longMsgLabel)
        //weekButton
        let weekButton = UIButton(frame: buttonWeekRect)
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
        
        var weekPrice = ""
        if let val = UserDefaults.standard.value(forKey: "WEEKLY_PRICE"){
            weekPrice = val as! String
        }//"$ 2.99 "
        
        print(weekStr)
        
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
        
        let yearStr = NSLocalizedString("/ Year", comment: "")
        
        var yearPrice = ""
        if let val = UserDefaults.standard.value(forKey: "YEARLY_PRICE"){
            yearPrice = val as! String
        }
        var freeTrialAttrs = [
            NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16, weight: .heavy),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            freeTrialAttrs = [
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 28, weight: .heavy),
                NSAttributedStringKey.foregroundColor : UIColor.white
            ]
        }
        attString.append(NSAttributedString(string: NSLocalizedString("FREE TRIAL", comment: "") + newLineStr, attributes:freeTrialAttrs ))
        attString.append(NSAttributedString(string: NSLocalizedString("3 days free trial then", comment: "") + weekPrice+weekStr, attributes: attrs))
        // attString.append(NSAttributedString(string: weekPrice+weekStr+newLineStr, attributes: nil))
        weekButton.setAttributedTitle(attString, for: .normal)
        weekButton.titleLabel?.numberOfLines = 0
        weekButton.titleLabel?.textAlignment  = NSTextAlignment.center
        weekButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        weekButton.addTarget(self, action:#selector(self.subscriptionWeekPurchase), for: .touchUpInside)
        whiteView.addSubview(weekButton)
        //monthButton
        let monthButton = UIButton(frame: buttonMonthRect)
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
        whiteView.addSubview(monthButton)
        //yearButton
        let yearButton = UIButton(frame: buttonYearRect)
        let attString3 = NSMutableAttributedString()
        yearButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        attString3.append(NSAttributedString(string: yearPrice+yearStr+newLineStr, attributes: topLabelAttributes))
        attString3.append(NSAttributedString(string: NSLocalizedString("1 year subscription", comment: ""), attributes: attrs))
        yearButton.setAttributedTitle(attString3, for: .normal)
        yearButton.titleLabel?.numberOfLines = 0
        yearButton.titleLabel?.textAlignment  = NSTextAlignment.center
        yearButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        yearButton.addTarget(self, action:#selector(self.subscriptionYearPurchase), for: .touchUpInside)
        whiteView.addSubview(yearButton)
        //restoreButton
        let restoreButton = UIButton(frame: buttonRestoreRect)
        restoreButton.setTitle(NSLocalizedString("Restore", comment: ""), for: UIControlState.normal)
        restoreButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        restoreButton.addTarget(self, action:#selector(self.restorePurchase), for: .touchUpInside)
        whiteView.addSubview(restoreButton)
        whiteView.bringSubview(toFront: self.iapSubscriptionView)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
            {
                self.iapSubscriptionView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
        }, completion:  nil)
    }
    
    //MARK:- Remove IAP Subscription View
    @objc func removeIAPSubscriptionView()
    {
        isSubscriptionViewVisible = 0
        SVProgressHUD.dismiss()
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
            {
                let screenSize: CGRect = UIScreen.main.bounds
                self.iapSubscriptionView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        }, completion: { (finished: Bool) in
            self.iapSubscriptionView.removeFromSuperview()
        })
    }
    
    //MARK:- Present Help View View
    @objc func presentHelpView()
    {
        appDelegate.logEvent(name: "info", category: "Subscription", action: "MyWork")
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
            let webViewRect = CGRect(x: offset, y: offset+cross_btn_width, width: screenSize.width-(2*offset), height: screenSize.height-(2*offset))
            //crossButton
            let crossButton = UIButton(frame: crossButtonRect)
            crossButton.setImage(UIImage(named: "cancel"), for: UIControlState.normal)
            crossButton.addTarget(self, action:#selector(self.removeHelpView), for: .touchUpInside)
            helpView.addSubview(crossButton)
            //webView
            let webView = UIWebView(frame: webViewRect)
            webView.loadRequest(URLRequest(url: URL(fileURLWithPath: Bundle.main.path(forResource: openThisString, ofType: "docx")!)))
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
        appDelegate.logEvent(name: "restore_purchase", category: "Subscription", action: "MyWork")
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
        appDelegate.logEvent(name: "weekly_subscription_my", category: "Subscription", action: "MyWork")
        IAPHandler.shared.purchaseMyProduct(product_identifier: WEEK_SUBSCRIPTION_PRODUCT_ID)
    }
    // MARK: - SUBSCRIPTION MONTH PURCHASE
    @objc func subscriptionMonthPurchase()
    {
        SVProgressHUD.show()
        appDelegate.logEvent(name: "monthly_subscription_my", category: "Subscription", action: "MyWork")
        IAPHandler.shared.purchaseMyProduct(product_identifier: MONTH_SUBSCRIPTION_PRODUCT_ID)
    }
    // MARK: - SUBSCRIPTION YEAR PURCHASE
    @objc func subscriptionYearPurchase()
    {
        SVProgressHUD.show()
        appDelegate.logEvent(name: "yearly_subscription_my", category: "Subscription", action: "MyWork")
        IAPHandler.shared.purchaseMyProduct(product_identifier: YEAR_SUBSCRIPTION_PRODUCT_ID)
    }
    
    //MARK:- Check Picture completetion
    func isDrawingCompleteMyWork(image:UIImage, imageID:String, grayImage:UIImage, imageName: String, isCallBySelect: String) -> Bool
    {
        let widthInPixels : CGFloat = image.size.width * image.scale
        let heightInPixels : CGFloat = image.size.height * image.scale
        let totalHorizontalgrids : Int = Int(widthInPixels)
        let totalVerticalGrids : Int = Int(heightInPixels)
        
        if (UI_USER_INTERFACE_IDIOM() == .pad){
            
            squareWidthMyWork = 40
            if(totalHorizontalgrids > 100 || totalVerticalGrids>100)
            {
                squareWidthMyWork = 30
            }
        }
        else{
            squareWidthMyWork = 26
        }
        
        var fitSize = CGFloat()
        fitSize = self.view.bounds.width
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            if appDelegate.isLandscapeByMe()
            {
                fitSize = self.view.bounds.height - 179
            }
        }

        if isCallBySelect == "0" {

            let grayImage2 = convert.convertImageToGrayScale(image:grayImage)
            grayImageViewMyWork = UIImageView()
            grayImageViewMyWork?.frame = CGRect(x: 0  , y:0, width: Int(squareWidthMyWork) * totalHorizontalgrids, height: Int(squareWidthMyWork) * totalVerticalGrids)
            grayImageViewMyWork?.image = grayImage2

        }
        else {

            grayImageViewMyWork = UIImageView()
            grayImageViewMyWork?.frame = CGRect(x: 0  , y:0, width: Int(squareWidthMyWork) * totalHorizontalgrids, height: Int(squareWidthMyWork) * totalVerticalGrids)

            self.imageColors.removeAll()
            self.grayScaleColors.removeAll()
            self.colorsOccurence.removeAll()
            self.whiteColorLocations.removeAll()
            
            self.totalHorizontalgridsValue = Int(totalHorizontalgrids)
            self.totalVerticalGridsValue = Int(totalVerticalGrids)
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imageName as String)
            let fileManager = FileManager.default
            
            if fileManager.fileExists(atPath: paths){
                let image = UIImage(contentsOfFile:paths)
                self.setColorOfEachPixels(width: Int(totalHorizontalgrids), height: Int(totalVerticalGrids), image: image!)
            }
            else if let image = UIImage(named:imageName){
                setColorOfEachPixels(width: Int(totalHorizontalgrids), height: Int(totalVerticalGrids), image: image)
            }
            else
            {
                if fileManager.fileExists(atPath: paths){
                    let image = UIImage(contentsOfFile:paths)
                    self.setColorOfEachPixels(width: Int(totalHorizontalgrids), height: Int(totalVerticalGrids), image: image!)
                }
            }
            setGrayscaleColorsArray(width: Int(totalHorizontalgrids), height: Int(totalVerticalGrids))
            
            imageDrawView = UIImageView()
            imageDrawView?.frame = (grayImageViewMyWork?.bounds)!
            imageDrawView?.backgroundColor = UIColor.clear
            imageDrawView?.image = getImage()
            imageDrawView?.tag = 10000
            for allView in view.subviews where allView.tag == 10000 {
                allView.removeFromSuperview()
            }
            self.view?.addSubview(imageDrawView!)
            
            grayImageViewMyWork?.image = getImageContent()

        }

        minimumScaleMyWork = fitSize/(squareWidthMyWork * CGFloat(totalHorizontalgrids))
        
        //////
        
        //minimumScaleMyWork = self.view.bounds.width/(squareWidthMyWork * CGFloat(totalHorizontalgrids))
        
        pointAndColorArrMyWork = DBHelper.sharedInstance.fetchPointsAndColorTuple(imageId: imageID, imageName: imageName, isCallFromHome: false)
        let whiteColorLocations : [CGPoint] = DBHelper.sharedInstance.fetchWhiteColorArr(imageId: imageID, type: "white")
        if pointAndColorArrMyWork.count + whiteColorLocations.count >= totalHorizontalgrids*totalVerticalGrids
        {
            return true
        }
        return false
    }
    
    func setColorOfEachPixels(width:Int,height:Int, image:UIImage){
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        autoreleasepool {
            for xDistance in 0..<width {
                var colorArr = [UIColor]()
                for yDistance in 0..<height{
                    let color = image[ Int(xDistance) ,Int(yDistance)]
                    color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    colorArr.append(color!)
                    if ((red == 1) && (green == 1) && (blue == 1)){
                        whiteColorLocations.append(CGPoint(x: xDistance * Int(squareWidthMyWork),y: yDistance * Int(squareWidthMyWork)))
                    }
                }
                imageColors.append(colorArr)
            }
        }
        
    }

    func setGrayscaleColorsArray(width:Int, height:Int){
        autoreleasepool {
            for row in 0..<width{
                var colors = [UIColor]()
                for column in 0..<height{
                    let color = imageColors[row][column]
                    var grayscale: CGFloat = 0
                    var alpha: CGFloat = 0
                    let red = color.red()
                    let green = color.green()
                    let blue = color.blue()
                    let nAlpha = color.alpha()
                    if !( (red == 1 || red < 0) && (green == 1 || green <  0) && (blue == 1 || blue < 0)){
                        if nAlpha != 0{
                            colorsOccurence[color] = (colorsOccurence[color] ?? 0) + 1
                        }
                        
                    }
                    if color.getWhite(&grayscale, alpha: &alpha) {
                        let grayscaleColor = UIColor(white: grayscale, alpha: alpha - 0.5)
                        colors.append(grayscaleColor)
                    }
                }
                grayScaleColors.append(colors)
            }
        }
    }

    func getImage() -> UIImage{
        let format = ImageRendererFormat.default()
        let image = ImageRenderer(size: (imageDrawView?.frame.size)!, format: format).image { context in
            performDrawing(context: context)
        }
        return image
    }
    
    var totalHorizontalgridsValue = 8
    var totalVerticalGridsValue = 8

    private func performDrawing<Context>(context: Context) where Context: RendererContext, Context.ContextType: CGContext {
        // let rect = context.format.bounds
        autoreleasepool {
            for x in 0..<totalHorizontalgridsValue{
                for y in 0..<totalVerticalGridsValue{
                    grayScaleColors[x][y].setFill()
                    context.fill(CGRect(x: x * Int(squareWidthMyWork), y: y * Int(squareWidthMyWork), width: Int(squareWidthMyWork), height: Int(squareWidthMyWork)))
                }
            }
        }

    }

    func getImageContent() -> UIImage {
            return autoreleasepool { () -> UIImage in
                let viewSize = (self.imageDrawView?.frame.size)!
                UIGraphicsBeginImageContext(viewSize)
                imageDrawView?.layer.render(in: UIGraphicsGetCurrentContext()!)
                let firstView = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                self.imageDrawView?.isHidden = true
                //self.imageDrawView?.removeFromSuperview()
                //self.imageDrawView = nil
                return firstView!
            }
    }

    //MARK:- Options Action Sheet
    func openActionSheetWithOptions(name:String, index:Int, isComplete:Bool)
    {
        var actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            actionsheet = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        }
        actionsheet.addAction(UIAlertAction(title: name, style: UIAlertActionStyle.default, handler: { (action) -> Void in
            if isComplete == true
            {
                //Play Video Screen
                self.appDelegate.logEvent(name: "Share", category: "MyWork", action: "Share Click")
                self.appDelegate.logEvent(name: "Share_Social", category: "Share", action: "MyWork")
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
                vc.imageData =  self.appDelegate.selectedImageData//self.imageArray[index]
                let imageSet = self.grayImageViewMyWork?.image?.changeImageOposity(0.2)
                if self.grayImageViewMyWork != nil{
                    let imagesetView = UIImageView(image: imageSet!)
                    imagesetView.frame = CGRect(x: (self.grayImageViewMyWork?.frame.origin.x)!, y: (self.grayImageViewMyWork?.frame.origin.y)!, width: (self.grayImageViewMyWork?.frame.size.width)!, height: (self.grayImageViewMyWork?.frame.size.height)!)
                    self.view?.insertSubview(imagesetView, belowSubview: self.grayImageViewMyWork!)
                    let cView = imagesetView.snapshotView(afterScreenUpdates: true)
                    vc.capturedView2 = cView
                    vc.capturedViewRecording2 = cView
                    vc.pointAndColorArrayRecording = self.pointAndColorArrMyWork
                    vc.squareWidth = self.squareWidthMyWork
                    vc.pointAndColorArray = self.pointAndColorArrMyWork
                    //Shoaib
                    vc.countArray = self.pointAndColorArrMyWork
                    vc.scale = self.minimumScaleMyWork
                    vc.isComplete = isComplete
                    vc.isJustCompleted = false
                    //Create the UIImage
                    UIGraphicsBeginImageContext(imagesetView.frame.size)
                    imagesetView.layer.render(in: UIGraphicsGetCurrentContext()!)
                    vc.backImg = UIGraphicsGetImageFromCurrentImageContext()!
                    UIGraphicsEndImageContext()
                    imagesetView.removeFromSuperview()
                }
                for allView in self.view.subviews where allView.tag == 10000 {
                    allView.removeFromSuperview()
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            else
            {
                var shouldShowAds = self.adsShouldBeCalled()
                var isreward :Bool = true;
                if UserDefaults.standard.value(forKey: "sessionTime") != nil
                {
                    //Manage session time checks of 5 and 10 minutes to show Ads
                    let sessionTime: Int = (UserDefaults.standard.value(forKey: "sessionTime") as? Int)!
                    //                if(sessionTime >= 0 && sessionTime < 10 )
                    //                {
                    //                    isreward = false
                    //                }
                    //                else if(sessionTime < 5 || sessionTime >= 10){
                    //                    isreward = false
                    //                    //isreward = true
                    //                }
                    
                    //#120. A/B testing: revert to prior ad logics
                    if(sessionTime >= interstitialTime && sessionTime < rewardTime )
                    {
                        isreward = false
                        
                    }else if(sessionTime >= rewardTime){
                        isreward = true
                    }
                    else if(sessionTime < interstitialTime){
                        shouldShowAds = false
                    }
                   
                    
                }
                //Continue to Home Screen
                // UserDefaults.standard.set(0, forKey: "sessionTime")
                //  UserDefaults.standard.synchronize()
                self.appDelegate.logEvent(name: "Continue", category: "MyWork", action: self.imageArray[index].name!)
//                let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
//                vc.imageData =  self.appDelegate.selectedImageData
//
//                //self.imageArray[index]
//                self.navigationController?.pushViewController(vc, animated: true);
              
                
                
                if (shouldShowAds && self.isInternetAvailable())
                {       print("SHOW ADS TRUEEE")

                    self.showInterstialAndRewardedAds(isreward:isreward)
                    return
                }
                else{
                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
                    vc.imageData =  self.appDelegate.selectedImageData

                    //self.imageArray[index]
                    self.navigationController?.pushViewController(vc, animated: true);
                }
            }
        }))
        
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: UIAlertActionStyle.destructive, handler: { (action) -> Void in
            //Remove Stored Colored points Array Of Selected image & Delete Thumbnail
            self.appDelegate.logEvent(name: "Delete", category: "MyWork", action: "Delete Click")
            self.removePointsAndColorTuple(index: index)
            self.deleteMyWorkImage(index: index)
            self.deleteThumbnail(index: index)
            deleteCompletedImagesIDArray(imageId:self.imageArray[index].imageId!)
            self.reloadArrays()
        }))
        actionsheet.addAction(UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: UIAlertActionStyle.cancel, handler: { (action) -> Void in
            //Cancel
            self.appDelegate.logEvent(name: "Cancel", category: "MyWork", action: "Cancel Click")
        }))
        actionsheet.view.layoutIfNeeded()
        self.present(actionsheet, animated: true, completion: nil)
    }
    
    //MARK:-Remove Stored Colored points Array Of Selected image
    func removePointsAndColorTuple(index:Int)
    {
        let imageColors = [[UIColor]]()
        let whiteColorLocations = [CGPoint]()
        let pointAndColorArr = [PointAndColor]()
        DBHelper.sharedInstance.insertColorArray(imageId: self.imageArray[index].imageId!, colorArr: imageColors, type: "source")
        DBHelper.sharedInstance.insertWhiteColorArray(imageId: self.imageArray[index].imageId!, colorArr: whiteColorLocations, type: "white")
        DBHelper.sharedInstance.updateTuple(imageId: self.imageArray[index].imageId!, pointColorTuple: pointAndColorArr, imageName: self.imageArray[index].name!, isCallFromHome: false)
    }
    
    //MARK:-Delete Thumbnail of selected Image
    func deleteMyWorkImage(index:Int)
    {
        DBHelper.sharedInstance.deleteImageFromDb(imgData: self.imageArray[index], isUploadToiCloud: false, imageName: self.imageArray[index].name!)
    }
    
    func deleteThumbnail(index:Int)
    {
        DBHelper.sharedInstance.deleteThumbInDb(imageId: self.imageArray[index].imageId, isUploadToiCloud: false, imageName: self.imageArray[index].name!)
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
        
        return compValue

    }
    
    
    // for video play
    
    // adsShouldBeCalled
    func adsShouldBeCalled() -> Bool
    {
        let launchCount = UserDefaults.standard.integer(forKey: LAUNCH_COUNT)
        var isFirstSession:Bool = false
        if(UserDefaults.standard.value(forKey: "isFirstSession") != nil)
        {
            isFirstSession = (UserDefaults.standard.value(forKey: "isFirstSession") as? Bool)!
        }
        // self.appDelegate.CheckisFirstSession()
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        
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
    
    
    
    //MARK: Show Ads
    @objc func showIntertialAds()
    {
        print("-- My Work Screen--")
        interstitialAdHelper.loadInterstitial()
        interstitialAdHelper.delegate = self
        interstitialAdHelper.showIntersialAd(viewController: self)

        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.imageData =  self.appDelegate.selectedImageData
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    @objc func showRewardedAds()
    {
        self.rewardedAdHelper.rewardId = PAGES_MY_WORK_REWARD_Id
        print("---- My Work Screen ----")
        self.rewardedAdHelper.loadRewardedAd(adId: PAGES_MY_WORK_REWARD_Id)
        self.rewardedAdHelper.delegate = self
        self.rewardedAdHelper.showRewardedAd(viewController: self)
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        vc.imageData =  self.appDelegate.selectedImageData
        self.navigationController?.pushViewController(vc, animated: true);
    }
    
    func didFailToLoadWithError(error: Error) {
        adRequestInProgress = false
        
        if(self.shouldShowRewardedVideo)
        {
            appDelegate.logEvent(name: "No_Fill_mw", category: "Video", action: "MyWork")
            appDelegate.logEvent(name: "No_Reward_mw", category: "Video", action: "MW")
            
            self.shouldShowRewardedVideo = false
            print("Reward based video ad failed to load: \(error.localizedDescription)")
            
            
            if let rootViewController = UIApplication.topViewController() {
                if rootViewController is MyWorkVC
                {
                    let alertController = UIAlertController(title: "Try again!", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: self.GotoHome )
                    alertController.addAction(defaultAction)
                    UIApplication.shared.keyWindow?.rootViewController!.present(alertController, animated: true, completion:nil)
                }
            }

        }
        
    }

    @objc func rewardBasedVideoAdWillLeaveApplication() {
        print("Reward based video ad will leave application.")
    }
  

    func GotoHome(action: UIAlertAction){
        
        self.RedirectToHome()
    }

    func RedirectToHome() {
        DispatchQueue.main.async {
            self.openActionSheetWithOptions(name: NSLocalizedString("Continue", comment: ""), index: self._selectedIndex, isComplete:false)
        }
    }
    
 
    // end video
    
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
    
    //MARK: Setting click.
        @IBAction func settingButtonTapped(_ sender: UIButton) {
             let vc = self.storyboard?.instantiateViewController(withIdentifier: "SettingsViewController") as! SettingsViewController
            self.navigationController?.pushViewController(vc, animated: true);

            
        }
}


extension UIColor {
    class func color(withData data:Data) -> [[UIColor]] {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as! [[UIColor]]
    }
    
    func encode() -> Data {
        return NSKeyedArchiver.archivedData(withRootObject: self)
    }
}


extension UIImage {
    func changeImageOposity(_ value:CGFloat) -> UIImage {
        return autoreleasepool { () -> UIImage in
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            draw(at: CGPoint.zero, blendMode: .normal, alpha: value)
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return newImage!
        }
    }
}
