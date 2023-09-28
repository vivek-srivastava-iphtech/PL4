//
//  HomeVC.swift
//  PL2
//
//  Created by iPHTech8 on 9/21/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit
import GraphicsRenderer
import CloudKit
import Foundation
import SystemConfiguration
import GoogleMobileAds
import SVProgressHUD
import FirebaseRemoteConfig
import AVFoundation

@objc enum ViewType: Int {
    case kViewTypeNoInternet, kViewTypeHint, kViewTypePaint, kViewTypeAutoMove
}

@objc enum PaintType: Int {
    case kPaintTypeNone, kPaintEnablePointsAvailable, kPaintEnableNoPointsAvailable
}
enum CurrentViewController: String {
    case kHome = "Home"
    case kWork = "Work"
    case kPage = "Page"
    case kPlay = "Play"
    case none = ""
}

enum PurchaseItemType: Int {
    case bucket = 1
    case hint = 2
    case picker = 3
    case none = 0
}

class HomeVC: UIViewController , UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, UIGestureRecognizerDelegate, UIWebViewDelegate,FaveButtonDelegate, RewardedAdHelperDelegate, AVAudioPlayerDelegate {
    
    
    //let loadingPhraseConfigKey = "loading_phrase"
    
    @IBOutlet weak var collectionColorView: UICollectionView!
    @IBOutlet weak var drawView:UIScrollView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundCenter: NSLayoutConstraint!
    //These Added By Devendra To Do
    @IBOutlet weak var colorAndPaintView: UIView!
    @IBOutlet weak var eraseButton: UIButton!
    @IBOutlet weak var paintButton: UIButton!
    @IBOutlet weak var hintButton: UIButton!
    @IBOutlet weak var paintCountLabel: UILabel!
    @IBOutlet weak var hintCountLabel: UILabel!
    @IBOutlet weak var autoMoveButton: UIButton!
    @IBOutlet weak var autoMoveCountLabel: UILabel!
    @IBOutlet weak var bottomViewHeightConstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var useBomLabel: UILabel!
    @IBOutlet weak var paintView: UIView!
    @IBOutlet weak var hintView: UIView!
    @IBOutlet weak var pickerView: UIView!
    
    fileprivate var rewardBasedVideo: GADRewardedAd?
    
    
    var paintType: PaintType = .kPaintTypeNone
    var adRequestInProgress = false
    var shouldShowRewardedVideo = false
    var isRemovingMemoryInstance = false
    var isZoomLevelSets = false
    var isHintPaintVisible = 0
    var isHelpViewVisible = 0
    var isSubscriptionViewVisible = 0
    var iapSubscriptionView : UIView!
    var helpView : UIView!
    var blackView : UIView!
    var ReminderView : UIView!
    let STARTER_PRODUCT_ID = "com.moomoolab.pl2sp"
    let WEEK_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2wk"
    var MONTH_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2mo"
    let YEAR_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2yr"
    //let HINT_UNIT_ID = "ca-app-pub-7682495659460581/5833651234"
    let PAINT_UNIT_ID = "ca-app-pub-7682495659460581/4072315560"
    //let TEST_UNIT_ID = "ca-app-pub-3940256099942544/1712485313"
    /*
     ---------------------------------------------------------------------------------------------------------
     
     DrawView         --> Superview of all views (Scroll View)
     viewInDrawView   --> SubView of DrawView (this view is inside scroll View)
     labelView        --> SubView of viewInDrawView view contains numbers in grid format
     imageDrawView    --> SubView of viewInDrawView contains a grayStyle image
     
     ----------------------------------------------------------------------------------------------------------
     */
    //    var mag:YPMagnifyingGlass?
    //    var shadowView:UIView?
    @IBOutlet weak var topSpaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var backgroundImgView: UIImageView!
    @IBOutlet var loveBtn : FaveButton?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    //  let tutKey = "is_viewed_tutorial"
    var tapGesture = UITapGestureRecognizer()
    var labelView:UIImageView?
    //var image:UIImage?
    var isJustCompleted = false
    var grayImageView :UIImageView?
    var labelImageView : UIImageView?
    var viewInDrawView: UIView?
    var widthInPixels = CGFloat()
    var heightInPixels = CGFloat()
    var grayScaleColors = [[UIColor]]()
    var imageColors = [[UIColor]]()
    var uniqueColorsArray = [UIColor]()
    var totalHorizontalgrids = Int()
    var totalVerticalGrids = Int()
    var cellWidth = CGFloat()
    var squareWidth:CGFloat = 8.0
    var imageDrawView:UIImageView?
    var pixelSquareWidth = CGFloat()
    var pixelSquareHeight = CGFloat()
    var gridSeperatorWidth:Int = 2
    var colorsOccurence: [UIColor: Int] = [:]
    var sortedColorsOccurenceWithNumber  = [ColorWithNumber]()
    var selectedColorWithNumber = ColorWithNumber()
    var imageOffsetYAxis:CGFloat = 40.0
    var selectedIndex = IndexPath(item: 0, section: 0)
    var colorImageDrawView:UIView?
    //  var pointLayerMap = NSMutableDictionary()
    var keyArray = [String]()
    var indexArray = [Int]()
    var imageName:String?
    var keyName:String?
    var whiteColorLocations:[CGPoint] = []
    var lastXDistance = Int()
    var lastYDistance = Int()
    var minimumScale:CGFloat = 0.2
    var singleTapScale:CGFloat = 0.983
    var doubleTapScale:CGFloat = 1.093
    var maximumScale:CGFloat = 2.5
    var capturedPoints = [String:Int]()
    var capturedColors = [NSNumber]()
    var occupiedPointsBasedonColorOder = [[(Int,Int)]]()
    var occupiedPointsUsedForPaintFeatureBasedonColorOder = [[CGPoint]]()
    var occupiedPointsIndexArray = [[String:Int]]()
    var pointsAndColorTouple : [(CGPoint, UIColor)] = []
    var labelArray = [[(String,UIColor,CGFloat)]]()
    var screenWidth = CGFloat()
    var screenHeight = CGFloat()
    var imageId: String?
    var myWorkImageName: String?
    var player: AVAudioPlayer!
    var playerLongTap: AVAudioPlayer!
    var animationComplete = false
    var singleTouch = true
    var checkPathComplete = true
    var soundPlayed = false

    
    //Gaurav Create Model Array insteadOf pointsAndColorTouple
    var pointAndColorArr = [PointAndColor]()
    var imageData = ImageData()
    var actualCellWidth = CGFloat()
    var totalBlocks = Int()
    var isComplete = false
    var prevX: Int?
    var prevY: Int?
    var selectedColor: UIColor?
    var textFontAttributes : [NSAttributedStringKey : Any]?
    var textFontAttributes2 : [NSAttributedStringKey : Any]?
    var lblText : NSString?
    var isSomethingWrong  = false
    var isPaintEnable = false
    var isAutoMoveEnable = false
    var processedPoints = [String:Int]()
    var coloredPoints = [CGPoint]()
    var isGoneVideoVC = false //Devendra To Do
    let hint_count = "HINT_COUNT"
    let giftHintCount = "GIFT_HINT_COUNT"
    let paint_count = "PAINT_COUNT"
    let autoMove_count = "AUTOMOVE_COUNT"
    var tipsView : UIView!
    var clikcedType : Int!
    var isVideoOpen : Bool!
    var lastOrientation : Int = 0
    var isTimerRunning : Bool!
    
    //Mark :- ReminderUI
    var reminderPaintBtn : UIButton!
    var reminderPaintLbl : UILabel!
    var lastReminderFor = 1
    var isReminderVideoOpen : Bool = false
    var isReminderVisible = 0
    var timer: Timer!
    var animationTimer: Timer!
    var blinkTimer: Timer!
    var previousView = ""
    // MARK:- set reminder time interval
    var counterTime = 660  // 11 mins
    var uiReminderSession = 0
    var reminderPaintCount: Int = 10
    
    var isVideoViewOpen = false
    var useToolArray : [String:Any] = ["paintCount" : 0, "hintCount" : 0, "autoFillCount" : 0]
    
    let userInterface = UIDevice.current.userInterfaceIdiom
    
    var isGifTutorialCloseTapped = false
    
    let colors = [
        DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
        DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
        DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
        DotColors(first: color(0xE9A966), second: color(0xF8C852)),
        DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
    ]
    
    
    //MARK: delay of Check Mark
    let delayCheckmark = 0.7 //0.7
    
    var categoryString = ""
    var isFirstLaunchDrawingScreenShow = false
    var isNeedToShowTipWithPurchase = false
    
    @IBOutlet weak var bombHintView: UIView!
    var colorNumber: Int = 0
    var colorNumberMax: Int = 30
    @IBOutlet weak var progressBar: CircularProgressBar!
    @IBOutlet weak var bombButton: UIButton!
    var progress:Double = 0
    var isBombEnable = false
    var isBombActive = false
    var selectedPurchaseType = 1
    var monthSubsView:UIView?
    var weekSubsView:UIView?
    var yearSubsView:UIView?
    //MARK: Reward Ad Helper
    private weak var rewardedAdHelper = RewardedAdHelper()
    
    //MARK: Inhetitance Ad Helper
    private var interstitialAdHelper = InterstitialAdHelper()
    
    //MARK:- Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        autoMoveCountLabel.isHidden = true
        autoMoveButton.isHidden = true
        UserDefaults.standard.set(buyPickerCountValue, forKey: autoMove_count)
        counterTime = reminderTime
        reminderPaintCount = rewardTools == 0 ? 5 : rewardTools
        
        self.setToolVariables()
        // Hide Scroll Lines
        self.drawView.showsHorizontalScrollIndicator = false
        self.drawView.showsVerticalScrollIndicator = false
        self.appDelegate.CheckisFirstSession()
        
        if isNotificationTap {
            isNotificationTap = false
            var _ = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(HomeVC.mysteryGiftReceive), userInfo: nil, repeats: true)
        }
        
        if(isGifTutorialCloseTapped)
        {
            backButton.isHidden = true
        }
        
        imageId = self.imageData.imageId
        imageName = self.imageData.name
        if let imgName = imageName{
            if let image = UIImage(named:imgName){
                totalHorizontalgrids = Int(image.size.width * image.scale)//Lekha Consider 1 pixel of image is equal to 1 block
                totalVerticalGrids = Int(image.size.height * image.scale) //Lekha Consider 1 pixel of image is equal to 1 block
                
            }
            else
            {
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName as String)
                
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: paths){
                    
                    let image = UIImage(contentsOfFile:paths)
                    totalHorizontalgrids = Int(image!.size.width * image!.scale)//Lekha Consider 1 pixel of image is equal to 1 block
                    totalVerticalGrids = Int(image!.size.height * image!.scale)
                }
            }
        }
        //let totalgrids = totalHorizontalgrids
        
        if(userInterface == .pad)
        {
            
            if(totalHorizontalgrids > 100 || totalVerticalGrids > 100)//For Blocks Greater than 100x100
            {
                maximumScale = 1.8
            }
            else if(totalHorizontalgrids <= 25 || totalVerticalGrids <= 25)
            {
                maximumScale = 1.8
                singleTapScale = 1.4
                doubleTapScale = 1.6
            }
            
        }
        else{
            
            if(totalHorizontalgrids <= 25 || totalVerticalGrids <= 25)
            {
                maximumScale = 1.8
            }
            
            if UIScreen.main.nativeBounds.height == 1136 {
                singleTapScale = 1.6
                doubleTapScale = 1.8
            }
            else {
                singleTapScale = 1.5
                doubleTapScale = 1.7
            }
            
        }
        
        var textFont =  UIFont()
        var linespace = 6.17 as CGFloat
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
        if UI_USER_INTERFACE_IDIOM() == .pad{
            
            textFont =  UIFont(name:"Avenir-Light", size:15.39)!
            linespace = 9.49  as CGFloat
            
            if(totalHorizontalgrids > 100 || totalVerticalGrids > 100)//For Blocks Greater than 100x100
            {
                textFont =  UIFont(name:"Avenir-Light", size:11.54)!
                linespace = 7.11  as CGFloat
            }
        }
        else{
            textFont =  UIFont(name:"Avenir-Light", size:10.0)!
        }
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2*linespace
        
        textFontAttributes = [NSAttributedStringKey.font: textFont, NSAttributedStringKey.paragraphStyle:style
        ] as [NSAttributedStringKey : Any]
        
        
        let style2 = NSMutableParagraphStyle()
        style2.alignment = .center
        
        textFontAttributes2 = [NSAttributedStringKey.font: textFont, NSAttributedStringKey.paragraphStyle:style2
        ] as [NSAttributedStringKey : Any]
        
        
        playButton.alpha = 1.0
        backButton.alpha = 1.0
        
        self.playButton.isHidden = true
        
        setNeedsStatusBarAppearanceUpdate()
        
        actualCellWidth = UIScreen.main.bounds.width/2
        // imageId = self.imageData.imageId
        //imageName = self.imageData.name
        
        //imageName = "ar4.png" //Testing
        
        UserDefaults.standard.set(imageName, forKey: "LastEditImageName")
        UserDefaults.standard.synchronize()
        
        if(imageName != nil){
            appDelegate.logScreen(name: imageName!)
        }
        
        selectedIndex = IndexPath(item: 0, section: 0)
        if (UI_USER_INTERFACE_IDIOM() == .pad){
            // shoaib
            
            squareWidth = 40
            topSpaceConstraint.constant = 20
            if(totalHorizontalgrids > 100 || totalVerticalGrids > 100)//For Blocks Greater than 100x100
            {
                squareWidth = 30
            }
            
            
        }
        else{
            topSpaceConstraint.constant = 0
            squareWidth = 26
        }
        self.view.layoutSubviews()
        drawView.minimumZoomScale = minimumScale
        drawView.maximumZoomScale = maximumScale
        drawView.delegate = self
        
        if let imgName = imageName{
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            self.backgroundImgView.image = appDelegate.getImage(imgName: imageData.name!, imageId: imageData.imageId!)
            
            //self.backgroundImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)//Devendra To Do
            let userInterface = UIDevice.current.userInterfaceIdiom
            if(userInterface == .pad)
            {
                
                if appDelegate.isLandscapeByMe()
                {
                    lastOrientation = 2
                    self.backgroundImgView.transform = CGAffineTransform(scaleX: 0.4, y: 0.4)
                }
                else
                {
                    lastOrientation = 1
                    self.backgroundImgView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                }
            }
            else
            {
                self.backgroundImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            }
            loaderAnimation()
            
            
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName as String)
            let fileManager = FileManager.default
            
            
            
            if fileManager.fileExists(atPath: paths){
                
                let image = UIImage(contentsOfFile:paths)
                self.initializeImageProperties(image:image!)
            }
            else if let image = UIImage(named:imgName){
                self.initializeImageProperties(image:image)
            }
            else
            {
                self.loadServerImage(name: imgName as NSString)
                if fileManager.fileExists(atPath: paths){
                    
                    let image = UIImage(contentsOfFile:paths)
                    self.initializeImageProperties(image:image!)
                }
                else
                {
                    appDelegate.logEvent(name: "Error_homevc", category: "parsing", action: "try_again")
                    
                    let callActionHandler = { (action:UIAlertAction!) -> Void in
                        // self.backToView()
                    }
                    
                    let alertController = UIAlertController(title: "Please try Again!", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion:nil)
                }
            }
        }
        
        if(self.isSomethingWrong == false)
        {
            // to do uncommnent after completing... Show Hint
            if (UserDefaults.standard.value(forKey:tutKey) == nil) && isGifTutorialCloseTapped == false{
                UserDefaults.standard.set("yes", forKey: tutKey)
                UserDefaults.standard.synchronize()
                
                //let vc = self.storyboard?.instantiateViewController(withIdentifier: "TutorialViewController") as! TutorialViewController
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GifTutorialVC") as! GifTutorialVC
                vc.loadFrom = "Home"
                vc.gifTutorialCloseTappedDelegate = self
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc,animated:true,completion:nil)
            }
            else if (UserDefaults.standard.value(forKey:newPicker) == nil){
                UserDefaults.standard.set("yes", forKey: newPicker)
                UserDefaults.standard.synchronize()
                let vc = self.storyboard?.instantiateViewController(withIdentifier: "GifTutorialVC") as! GifTutorialVC
                vc.loadFrom = "Existing"
                // vc.gifTutorialCloseTappedDelegate = self
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc,animated:true,completion:nil)
            }
        }
        
        //
        //  drawView.minimumZoomScale = minimumScale
        //Add by Devendra To Do
        self.roundedbuttonSet(button: eraseButton)
        self.roundedbuttonSet(button: paintButton)
        self.roundedbuttonSet(button: hintButton)
        self.roundedbuttonSet(button: autoMoveButton)
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        
        if(isExpired == "YES" || isExpired == nil){
            self.shouldShowRewardedVideo = false
        }
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.saveThumbnailAndPointsColorTest),name: NSNotification.Name.UIApplicationDidEnterBackground,object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadIAPHome(notification:)), name: NSNotification.Name(rawValue: "orientation_change_homevc"), object: nil)
        //Devendra Added to resolve driffting issue
        drawView.decelerationRate = UIScrollViewDecelerationRateFast
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.rotatedHome), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        //let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        //        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
        //        {
        //            useToolArray.removeAll()
        //        }
        //
        //        if(useToolArray != nil && useToolArray.count > 0)
        //        {
        //            self.ShowReminderUI()
        //        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(scrollToIndex), name: NSNotification.Name(rawValue: SCROLL_OBSERVER), object: nil)
        
        self.categoryString = self.imageData.category!
        
        NotificationCenter.default.addObserver(self, selector: #selector(rewardBasedVideoAdWillLeaveApplication), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
        if currentToolWindow ==  "tool_win_1" {
            isNeedToShowTipWithPurchase = false
        }
        else if currentToolWindow ==  "tool_win_2" {
            isNeedToShowTipWithPurchase = true
        }
        
        //   let bombCategory  = UserDefaults.standard.stringArray(forKey: selectedBombCategory) ?? []
        print("Start categoryString + totalHorizontalgrids")
        print(categoryString)
        print(totalHorizontalgrids)
        print(appDelegate.imagesCategoryArray)
        print("End categoryString + totalHorizontalgrids")
        
        let imageCat =  appDelegate.imagesCategoryArray.map { $0.lowercased()}
        if(((totalHorizontalgrids >= 78) && UserDefaults.standard.integer(forKey: bomb_s) == 1)){
            if(imageCat.contains(categoryString.lowercased())){
                hideShowBomb(isHidden: false)
            }
            else{
                hideShowBomb(isHidden: true)
            }
        }else{
            hideShowBomb(isHidden: true)
        }
        
        // hideShowBomb(isHidden: false) For Testing Purpose
        bombHintView.layer.cornerRadius = 10
        bombHintView.clipsToBounds = true
        bombHintView.alpha = 0.7
        
        progressBar.safePercent = 100
        progressBar.lineColor = UIColor(red: 74.0/255.0, green: 160.0/255.0, blue: 221.0/255.0, alpha: 1)
        progressBar.lineFinishColor = .red
        progressBar.lineBackgroundColor =  UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.00)
        bombButton.isEnabled = false
        colorNumberMax =  UserDefaults.standard.integer(forKey: color_number) == 0 ? 1 : UserDefaults.standard.integer(forKey: color_number)
        
        useBomLabel.text = NSLocalizedString("Use the bomb to color\neverything around", comment: "")
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        self.collectionColorView.collectionViewLayout = layout
        loadAd()
        
        NotificationCenter.default.addObserver(self,selector: #selector(self.releaseMemory), name: NSNotification.Name(rawValue: RELEASE_MEMORY),object: nil)
    }
    func loadAd() {
        rewardedAdHelper?.rewardId = DRAWING_SCREEN_REWARD_Id
        print("[---- Drawing Screen ----]")
        rewardedAdHelper?.loadRewardedAd(adId: DRAWING_SCREEN_REWARD_Id)
        rewardedAdHelper?.delegate = self
    }
    func showReward(rewardAmount: String, status: String) {
        if status == "Success" {
            print("[Reward ad received for Drawing View]")
            print("[Drawing Screen - RewardAD ID : \(DRAWING_SCREEN_REWARD_Id)]")
            DispatchQueue.main.async {
                if rewardAmount != "0" {
                    self.SetRewardPoint()
                    self.isSomethingWrong = false
                }
            }
            
        }
        else {
            print("Please try Again RW!")
            appDelegate.logEvent(name: "No_fill_hm", category: "homeVC", action: "Reward")
            appDelegate.logEvent(name: "No_Reward_Tool", category: "Ads", action: "HV")
            self.isSomethingWrong = false
            let callActionHandler = { (action:UIAlertAction!) -> Void in
                //  self.backToView()
            }
            let alertController = UIAlertController(title: "Please try Again!", message: nil, preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion:nil)
        }
    }
    
    func dismissRewardedAd() {
        print("[RewardDismiss]")
        self.isSomethingWrong = false
        loadAd()
    }
    
    func reloadPath(){
        self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
    }
    
    //MARK:- Add Bomb Reminders View
    func viewBombReminder() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3)  {
            UIView.animate(withDuration: 0.3) {
                self.bombHintView.transform = .identity
            } completion: { (isTrue) in
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    
                    UIView.animate(withDuration: 0.3) {
                        self.bombHintView.transform = CGAffineTransform(translationX: 210, y: 0)
                    }
                }
            }
        }
        
        
        
        
        
        
        //        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
        //                        {
        //                            self.bombHintView.transform = CGAffineTransform(translationX: 150, y: 0)
        //                        }, completion: { (finished: Bool) in
        //
        //                            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
        //                                            {
        //                                                self.bombHintView.transform = CGAffineTransform(translationX: -150, y: 0)
        //                                            })
        //
        //
        //                        })
    }
    
    func setToolVariables() {
        
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
        {
            useToolArray.removeAll()
        }
        
        if(useToolArray != nil && useToolArray.count > 0)
        {
            print(self.counterTime)
            print("[self.counterTime]")
            self.ShowReminderUI()
        }
        
    }
    
    @objc func mysteryGiftReceive() {
        self.showLabelWithCount(lbl: self.paintCountLabel, count: UserDefaults.standard.integer(forKey: self.paint_count))
        self.showLabelWithCount(lbl: self.hintCountLabel, count: UserDefaults.standard.integer(forKey: self.hint_count) + UserDefaults.standard.integer(forKey: self.giftHintCount))
        self.showLabelWithCount(lbl: self.autoMoveCountLabel, count: UserDefaults.standard.integer(forKey: self.autoMove_count))
    }
    
    fileprivate func ChangeButtonSizeForIPD() {
        
        self.zommInButoonForIPD(button: paintButton)
        self.zommInButoonForIPD(button: hintButton)
        self.zommInButoonForIPD(button: autoMoveButton)
        self.zommInButoonForIPD(button: eraseButton)
    }
    
    @objc func rotatedHome() {
        
        // Reload Gif  / shaib
        let interfaceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        if UIDevice.current.userInterfaceIdiom == .pad{
            if let rootViewController = UIApplication.topViewController() {
                if rootViewController is GifTutorialVC
                {
                    DispatchQueue.main.async {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "gif_Collection_View_ReLoad"), object: nil)
                    }
                }
            }
        }
        
        //        if self.gifTutorialVC != nil {
        //            self.gifTutorialVC.gifCollectionViewReLoad()
        //        }
        
        
        if UIDeviceOrientationIsLandscape(interfaceOrientation)
        {
            if UIDevice.current.userInterfaceIdiom == .pad{
                ChangeButtonSizeForIPD()
                if(self.tipsView != nil && lastOrientation == 1)
                {
                    lastOrientation = 2
                    DispatchQueue.main.async
                    {
                        self.tipsView.removeFromSuperview()
                        if(self.isHintPaintVisible == 1){
                            self.isHintPaintVisible = 0
                            self.addTipsView(type: self.clikcedType)
                        }
                    }
                    
                    
                }
                
            }
        }
        else if UIDeviceOrientationIsPortrait(interfaceOrientation)
        {
            
            if UIDevice.current.userInterfaceIdiom == .pad &&  lastOrientation == 2{
                lastOrientation = 1
                ChangeButtonSizeForIPD()
                if(self.tipsView != nil)
                {
                    DispatchQueue.main.async
                    {
                        self.tipsView.removeFromSuperview()
                        if(self.isHintPaintVisible == 1){
                            self.isHintPaintVisible = 0
                            self.addTipsView(type: self.clikcedType)
                        }
                    }
                    
                }
            }
            
        }
    }
    
    
    @objc func loadIAPHome(notification: NSNotification) {
        if isSubscriptionViewVisible == 1
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1)
            {
                self.iapSubscriptionView.removeFromSuperview()
                self.addIAPSubscriptionView()
            }
        }
    }
    
    func backToView()
    {
        self.navigationController?.popViewController(animated: true)
    }
    
    func initializeImageProperties(image:UIImage)
    {
        
        widthInPixels  = image.size.width * image.scale
        heightInPixels = image.size.height * image.scale
        
        totalHorizontalgrids = Int(widthInPixels)//Lekha Consider 1 pixel of image is equal to 1 block
        totalVerticalGrids = Int(heightInPixels) //Lekha Consider 1 pixel of image is equal to 1 block
        
        pixelSquareWidth  = widthInPixels/CGFloat(totalHorizontalgrids)
        pixelSquareHeight = heightInPixels/CGFloat(totalVerticalGrids)
        
        
        var fitSize = CGFloat()
        screenHeight = UIScreen.main.bounds.height
        screenWidth = UIScreen.main.bounds.width
        fitSize = self.view.bounds.width
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            if appDelegate.isLandscapeByMe()
            {
                screenWidth = UIScreen.main.bounds.height
                screenHeight = UIScreen.main.bounds.width
                fitSize = self.view.bounds.height - (colorAndPaintView.bounds.height + backButton.bounds.height + backButton.frame.origin.y)
            }
            else
            {
                screenHeight = UIScreen.main.bounds.height
                screenWidth = UIScreen.main.bounds.width
                fitSize = self.view.bounds.width
            }
        }
        /*if (UIDevice.current.orientation == .landscapeLeft) || (UIDevice.current.orientation == .landscapeRight){
         screenWidth = UIScreen.main.bounds.height
         screenHeight = UIScreen.main.bounds.width
         fitSize = self.view.bounds.height - 100
         }
         else{
         screenHeight = UIScreen.main.bounds.height
         screenWidth = UIScreen.main.bounds.width
         fitSize = self.view.bounds.width
         }*/
        minimumScale = fitSize/(squareWidth * CGFloat(totalHorizontalgrids))
        drawView.minimumZoomScale = minimumScale
        gridSeperatorWidth = (Int(widthInPixels) - totalHorizontalgrids)/totalHorizontalgrids
        
        
        self.perform(#selector(initializeDrawing), with:image, afterDelay: 0.001)
        
        //        else{
        //            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
        //                //                let alert = UIAlertController(title: "PL2", message: "Image Info not found!\n\n Please check image info in \"ImagesProperty.plist\" ", preferredStyle: .alert)
        //                //                let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        //                //                alert.addAction(action)
        //                //
        //                //                self.present(alert, animated: true, completion: nil)
        //            })
        //        }
    }
    
    //    override func viewDidLayoutSubviews() {
    //        super.viewDidLayoutSubviews()
    //        self.view.setNeedsDisplay()
    //
    //        if(drawView != nil)
    //        {
    //            let offsetY = max((drawView?.contentSize.height)! * 0.5, self.view.center.y - imageOffsetYAxis + drawView.frame.origin.y)
    //            backgroundCenter.constant =  offsetY - self.view.center.y
    //            backgroundImgView.setNeedsDisplay()
    //        }
    //        DispatchQueue.main.async { [weak self] in
    //            if UIDevice.current.userInterfaceIdiom == .pad{
    //                self?.bottomViewHeightConstraint.constant =  250
    //                self?.ChangeButtonSizeForIPD()
    //            }else{
    //                self?.bottomViewHeightConstraint.constant = 180
    //            }
    //        }
    //    }
    
    override func viewDidLayoutSubviews() {
        //        super.viewDidLayoutSubviews()
        if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                self.updateView()
            }
        }
        else {
            self.updateView()
        }
    }
    
    func updateView() {
        
        self.view.setNeedsDisplay()
        if(self.drawView != nil)
        {
            let offsetY = max((self.drawView?.contentSize.height)! * 0.5, self.view.center.y - self.imageOffsetYAxis + self.drawView.frame.origin.y)
            self.backgroundCenter.constant =  offsetY - self.view.center.y
            self.backgroundImgView.setNeedsDisplay()
        }
        DispatchQueue.main.async { [weak self] in
            if UIDevice.current.userInterfaceIdiom == .pad{
                self?.bottomViewHeightConstraint.constant =  150
                self?.ChangeButtonSizeForIPD()
            }else{
                self?.bottomViewHeightConstraint.constant = 100
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isUserInteractionEnabled = true
        UserDefaults.standard.set(true, forKey: "firstImageShow")
        backButton.isEnabled = false
        isFromHomeView = true
        currentView = CurrentViewController.kHome.rawValue
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
        isRemovingMemoryInstance = false
        self.isJustCompleted = false
        isGoneVideoVC = false
        appDelegate.logScreen(name: "Drawing Screen")
        startReminderTimer()
        self.bombHintView.transform = CGAffineTransform(translationX: 210, y: 0)
        // viewBombReminder()
        
    }
    
    @objc fileprivate func initializeImageDrawView() {
        if !self.isSomethingWrong {
            if grayImageView == nil{
                grayImageView = UIImageView()
                grayImageView?.frame = CGRect(x: 0  , y:0, width: Int(squareWidth) * totalHorizontalgrids, height: Int(squareWidth) * totalVerticalGrids )
                grayImageView?.image = getImageContent()
                
                viewInDrawView?.insertSubview(grayImageView!, belowSubview: labelView!)
                viewInDrawView?.isHidden = false
                // self.viewInDrawView?.alpha = 0.0
                
                self.backgroundImgView.layer.removeAllAnimations()
                
                if drawView.zoomScale <= minimumScale + 0.1{
                    paintButton.isEnabled = false
                    hintButton.isEnabled = false
                    autoMoveButton.isEnabled = false
                }
                else
                {
                    if(selectedIndex.item != -1)
                    {
                        
                        paintButton.isEnabled = true
                        hintButton.isEnabled = true
                        autoMoveButton.isEnabled = true
                        
                    }
                    
                }
                
                UIView.animate(withDuration: 0.3, delay:0.1, animations: {
                    self.backgroundImgView.alpha = 0.0
                    self.viewInDrawView?.alpha = 1.0
                    
                }, completion: { (finished) -> Void in
                    self.backgroundImgView.isHidden = true
                    
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
                        self.playButton.isHidden = false
                        if self.isDrawingComplete(){
                            self.playButton.setImage(UIImage(named:"ok_completed"), for: UIControlState.normal)
                        }
                        else{
                            self.playButton.setImage(UIImage(named:"ok"), for: UIControlState.normal)
                        }
                    }
                    
                })
                
                if colorAndPaintView.isHidden{
                    var frame = colorAndPaintView.frame
                    frame.origin.y = frame.origin.y + frame.size.height
                    colorAndPaintView.frame = frame
                    colorAndPaintView.isHidden = false
                    UIView.animate(withDuration: 0.8, delay:0.1, animations: {
                        var frame = self.colorAndPaintView.frame
                        frame.origin.y = frame.origin.y - frame.size.height
                        self.colorAndPaintView.frame = frame
                    })
                    
                    frame = collectionColorView.frame
                    frame.origin.y = frame.origin.y + frame.size.height
                    collectionColorView.frame = frame
                    collectionColorView.isHidden = false
                    
                    UIView.animate(withDuration: 0.8, delay:0.1, animations: {
                        var frame = self.collectionColorView.frame
                        frame.origin.y = frame.origin.y - frame.size.height
                        self.collectionColorView.frame = frame
                        self.eraseButton.isHidden = false
                        self.paintButton.isHidden = false
                        self.hintButton.isHidden = false
                        self.autoMoveButton.isHidden = false
                        self.showLabelWithCount(lbl: self.paintCountLabel, count: UserDefaults.standard.integer(forKey: self.paint_count))
                        self.showLabelWithCount(lbl: self.hintCountLabel, count: UserDefaults.standard.integer(forKey: self.hint_count) + UserDefaults.standard.integer(forKey: self.giftHintCount))
                        self.showLabelWithCount(lbl: self.autoMoveCountLabel, count: UserDefaults.standard.integer(forKey: self.autoMove_count))
                    })
                }
                
                let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                if (((self.appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (self.appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
                {
                    self.showLabelWithCount(lbl: (self.hintCountLabel)!  , count: 0)
                    self.showLabelWithCount(lbl: (self.paintCountLabel)!  , count: 0)
                    self.showLabelWithCount(lbl: (self.autoMoveCountLabel)!  , count: 0)
                }
            }
            else
            {
                var fitSize = CGFloat()
                screenHeight = UIScreen.main.bounds.height
                screenWidth = UIScreen.main.bounds.width
                fitSize = self.view.bounds.width
                let userInterface = UIDevice.current.userInterfaceIdiom
                if(userInterface == .pad)
                {
                    if appDelegate.isLandscapeByMe()
                    {
                        screenWidth = UIScreen.main.bounds.height
                        screenHeight = UIScreen.main.bounds.width
                        fitSize = self.view.bounds.height - (colorAndPaintView.bounds.height + backButton.bounds.height + backButton.frame.origin.y + 10)
                    }
                    else
                    {
                        screenHeight = UIScreen.main.bounds.height
                        screenWidth = UIScreen.main.bounds.width
                        fitSize = self.view.bounds.width
                    }
                }
                minimumScale = fitSize/(squareWidth * CGFloat(totalHorizontalgrids))
                drawView.minimumZoomScale = minimumScale
                //Only set first time:
                if !self.isZoomLevelSets
                {
                    self.drawView.setZoomScale(minimumScale, animated: true)
                    self.isZoomLevelSets = true
                }else if(isBackFromHome == true){
                    self.drawView.setZoomScale(minimumScale, animated: true)
                    isBackFromHome = false
                }
                drawView.delegate = self
            }
        }
        backButton.isEnabled = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //super.viewDidAppear(animated)
        if(self.imageDrawView  == nil){
            
            self.perform(#selector(initializeImageDrawView), with: nil, afterDelay: 0.1)
            
        }else{
            initializeImageDrawView()
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("didReceiveMemoryWarningHomeVC Shoaib")
        appDelegate.logEvent(name: "memorywarning_homevc", category: "error", action: "homeVC")
        // Dispose of any resources that can be recreated.
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @objc func initializeDrawing(image:UIImage){
        
        //        // get imageColors = getDataInDB
        //        if #available(iOS 10.0, *) {
        //            //imageColors = DBHelper.sharedInstance.fetchColorArr(imageId: imageId!, type: "source")
        //            //whiteColorLocations = DBHelper.sharedInstance.fetchWhiteColorArr(imageId: imageId!, type: "white")
        //        } else {
        //            // Fallback on earlier versions
        //        }
        if !(imageColors.count > 0) {
            setColorOfEachPixels(width: Int(totalHorizontalgrids), height: Int(totalVerticalGrids), image: image) //set imageColors
        }
        
        setGrayscaleColorsArray(width: Int(totalHorizontalgrids), height: Int(totalVerticalGrids))
        
        sortColorsOccurence()
        storeLabels()
        drawGridInGrayScale()
    }
    
    func loaderAnimation()
    {
        UIView.animate(withDuration:0.8, delay:0.1, options:[.curveEaseInOut,.repeat,.autoreverse],animations: { () -> Void in
            
            //self.backgroundImgView.transform = CGAffineTransform(scaleX: 1, y: 1)
            let userInterface = UIDevice.current.userInterfaceIdiom
            if(userInterface == .pad)
            {
                if self.appDelegate.isLandscapeByMe()
                {
                    self.backgroundImgView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                }
                else
                {
                    self.backgroundImgView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                }
            }
            else
            {
                self.backgroundImgView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }
        }, completion: { (finished) -> Void in
            
            //self.focusView.hidden = true
            self.viewInDrawView?.center = CGPoint(x:self.view.center.x, y:self.view.center.y - 70)
            UIView.animate(withDuration: 0.5, animations: {
                self.viewInDrawView?.layoutIfNeeded()
            })
        })
    }
    
    @objc func scrollToIndex() {
        self.collectionColorView.reloadData()
        if !(self.collectionColorView.indexPathsForVisibleItems.contains(selectedIndex)) {
            //self.collectionColorView.scrollToItem(at: selectedIndex, at: .left, animated: true)
        }
    }
    
    func prefillImage() {
        //  test to check data is fetching or not
        if #available(iOS 10.0, *) {
            let testGaurav = DBHelper.sharedInstance.fetchPointsAndColorTuple(imageId: imageId!, imageName: imageName!, isCallFromHome: true)
            if testGaurav.count > 0{
                autoreleasepool {
                    for prevFillVal in testGaurav {
                        self.pointAndColorArr.append(prevFillVal)
                        //print("pp-count: %d",pointAndColorArr.count)
                        prefillColorLayer(pointAndColor:prevFillVal)//ToDo testig
                    }
                }
            }
            else {
                print("Failure....")
            }
        } else {
        }
    }
    // Collecting and parsing colors of an image
    func setColorOfEachPixelsOld(width:Int,height:Int, image:UIImage){
        autoreleasepool {
            for xDistance in 0..<width {
                var colorArr = [UIColor]()
                for yDistance in 0..<height{
                    var pWidth =  pixelSquareWidth
                    var pHeight =  pixelSquareWidth
                    if (pWidth > 1){
                        pWidth = pixelSquareWidth/2.0
                        pHeight = pixelSquareHeight/2.0
                    }
                    else{
                        pWidth = 0
                        pHeight = 0
                    }
                    
                    let xPosition = (CGFloat(xDistance) * pixelSquareWidth) + pWidth
                    let yPosition = ( CGFloat(yDistance) * pixelSquareHeight) + pHeight
                    let color = image[ Int(xPosition) ,Int(yPosition)]
                    var red: CGFloat = 0.0
                    var green: CGFloat = 0.0
                    var blue: CGFloat = 0.0
                    var alpha: CGFloat = 0.0
                    color?.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
                    colorArr.append(color!)
                    
                    if ((red == 1) && (green == 1) && (blue == 1)){
                        whiteColorLocations.append(CGPoint(x: xDistance * Int(squareWidth),y: yDistance * Int(squareWidth)))
                    }
                }
                imageColors.append(colorArr)
            }
        }
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
                        whiteColorLocations.append(CGPoint(x: xDistance * Int(squareWidth),y: yDistance * Int(squareWidth)))
                    }
                }
                imageColors.append(colorArr)
            }
        }
        
        //call saveDataInDB in background - Todo
        if #available(iOS 10.0, *) {
            DBHelper.sharedInstance.insertColorArray(imageId: imageId!, colorArr: imageColors, type: "source")
            DBHelper.sharedInstance.insertWhiteColorArray(imageId: imageId!, colorArr: whiteColorLocations, type: "white")
        } else {
            // Fallback on earlier versions
        }
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        var fitSize = CGFloat()
        
        coordinator.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            
            let orient = UIApplication.shared.statusBarOrientation
            
            switch orient {
                
            case .portrait:
                print("Portrait")
                fitSize = self.view.bounds.width
                
            case .landscapeLeft,.landscapeRight :
                print("Landscape")
                fitSize = self.view.bounds.height - (self.colorAndPaintView.bounds.height + self.backButton.bounds.height + self.backButton.frame.origin.y + 10)
            default:
                print("Anything But Portrait")
                fitSize = self.view.bounds.width
            }
            
        }, completion: { (UIViewControllerTransitionCoordinatorContext) -> Void in
            //refresh view once rotation is completed not in will transition as it returns incorrect frame size.Refresh here
            self.minimumScale = fitSize/(self.squareWidth * CGFloat(self.totalHorizontalgrids))
            self.drawView.minimumZoomScale = self.minimumScale
            self.drawView.setZoomScale(self.minimumScale, animated: true)
            //            self.viewInDrawView?.frame = CGRect(x: xDistance, y: yDistance, width: (self.viewInDrawView?.frame.width)!, height: (self.viewInDrawView?.frame.width)!)
            // self.viewInDrawView?.center = CGPoint(x:self.view.center.x, y:self.view.center.y - 40) // shoaib 26 March
            self.viewInDrawView?.center = CGPoint(x:self.view.center.x, y:self.view.center.y - 70)
            UIView.animate(withDuration: 0.5, animations: {
                self.viewInDrawView?.layoutIfNeeded()
            })
        })
        super.viewWillTransition(to: size, with: coordinator)
        
    }
    
    // Collecting Gray scale colors from imageColors array
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
    
    
    @objc func screenShotMethod() {
        
        print("SAVING THUMBNAIL SCREENSHOT")
        let newSize = CGSize(width:2*actualCellWidth , height:2*actualCellWidth)
        
        //Create the UIImage
        if drawView != nil {
            UIGraphicsBeginImageContext(drawView.frame.size)
            drawView.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            guard let imgVal = image else {
                print("UIGraphicsGetImageFromCurrentImageContext fetch error")
                return
            }
            
            if viewInDrawView?.frame != nil {
                let croppedCGImage = imgVal.cgImage?.cropping(to: (viewInDrawView?.frame)!)
                
                //let croppedCGImage = image?.cgImage?.cropping(to: (viewInDrawView?.frame)!)
                let img = UIImage(cgImage: croppedCGImage!)
                
                // Actually do the resizing to the rect using the ImageContext stuff
                UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
                img.draw(in: CGRect(x:0,y:0,width:newSize.width,height:newSize.height))
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let dbHelper = DBHelper.sharedInstance
                dbHelper.saveThumbInDb(imageId: imageData.imageId, thumImg: newImage!, isUploadToiCloud:true, imageName: imageName!, isCallFromHome: true){ _ in
                    
                    UIGraphicsEndImageContext()
                    UIGraphicsEndImageContext()
                    UIGraphicsEndImageContext()
                    UIGraphicsEndImageContext()
                    //dbHelper.syncThumnailImage(imageId: imageData.imageId!, entityName: THUMBNAIL_ENTITY, zoneName: THUMBNAIL_ENTITY_ZONE){ _ in
                }
            }
            
        }
        
    }
    
    //    func saveImageDocumentDirectory(image: UIImage){
    //        let fileManager = FileManager.default
    //        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("t_"+self.imageData.name!)
    //        // let image = UIImage(named: "apple.jpg")
    //        print(paths)
    //        let dataObj = UIImageJPEGRepresentation(image, 0.5)
    //        fileManager.createFile(atPath: paths as String, contents: dataObj, attributes: nil)
    //    }
    
    // Collecting and displaying unique colors from image
    func sortColorsOccurence(){
        let byValue = {
            (elem1:(key: UIColor, val: Int), elem2:(key: UIColor, val: Int))->Bool in
            if elem1.val > elem2.val {
                return true
            } else {
                return false
            }
        }
        let  sortedColorsOccurence = colorsOccurence.sorted(by: byValue)
        autoreleasepool {
            for i in 0..<sortedColorsOccurence.count{
                var colorInfo = ColorWithNumber()
                colorInfo.key = sortedColorsOccurence[i].key
                colorInfo.value = sortedColorsOccurence[i].value
                colorInfo.number = i + 1
                sortedColorsOccurenceWithNumber.append(colorInfo)
                let arr = [(Int, Int)]()
                occupiedPointsBasedonColorOder.append(arr)
                
                let arr2 = [CGPoint]()
                occupiedPointsUsedForPaintFeatureBasedonColorOder.append(arr2)
                
                let arr3 = [String:Int]()
                occupiedPointsIndexArray.append(arr3)
            }
        }
        
        //self.colorAndPaintView.isHidden = true
        collectionColorView.reloadData()
    }
    
    
    func isColorCompleted(colorObj:ColorWithNumber) -> Bool
    {
        
        if colorObj.isComplete{
            return colorObj.isComplete
        }
        
        let valObj = colorObj.value
        let colorIDVal = NSNumber(value: colorObj.key.rgb()!)
        
        //pointAndColorArr
        
        let predicate = NSPredicate(format: "self == %@",colorIDVal)
        let tempArray = (capturedColors as NSArray).filtered(using: predicate)
        
        if valObj > tempArray.count {
            return false
        }
        
        return true
    }
    
    func getFilledColorCount(colorObj:ColorWithNumber) -> Int {
        let colorIDVal = NSNumber(value: colorObj.key.rgb()!)
        
        let predicate = NSPredicate(format: "self == %@",colorIDVal)
        let tempArray = (capturedColors as NSArray).filtered(using: predicate)
        return tempArray.count
        
    }
    
    func storeLabels(){
        
        lblText = ""
        let space: NSString = " "
        let size = space.size(withAttributes: textFontAttributes)
        print("***")
        print(size)
        
        //        var spaceSize  = 2.6
        //        let oneCharSpace = 2*spaceSize
        //        let twoCharSpace = 4*spaceSize
        //        let noOfSpaceRequiredForOneBox = 10
        
        let blockString = "          ";
        let oneDigitString = "    ";
        let twoDigitString = "   ";
        let threeDigitString = "  ";
        
        // "1" : 5.72
        // " ": 2.86
        //"21": 11.44
        //height: 15.026
        //\n - 27.32 = 2*13.66
        //(4.16, 21.856)
        
        let wd = Int(squareWidth)
        autoreleasepool {
            for x in 0..<imageColors.count{
                var lblArr1 = [(String,UIColor,CGFloat)]()
                for y in 0..<imageColors[0].count{
                    let result = getColorNumber(color: imageColors[x][y])
                    lblArr1.append(result)
                    let colorVal = result.0
                    if let val = Int(colorVal){
                        occupiedPointsBasedonColorOder[val-1].append((x, y))
                        occupiedPointsUsedForPaintFeatureBasedonColorOder[val-1].append(CGPoint(x: x*wd , y: y*wd))
                        let keyVal = keyForPoint(point: CGPoint(x: x*wd , y: y*wd))
                        occupiedPointsIndexArray[val-1][keyVal] = occupiedPointsUsedForPaintFeatureBasedonColorOder[val-1].count - 1
                    }
                }
                labelArray.append(lblArr1)
            }
        }
        
        for x in 0..<totalHorizontalgrids{
            autoreleasepool {
                for y in 0..<totalVerticalGrids{
                    
                    let touple = labelArray[y][x]
                    let colorVal = touple.0
                    
                    if let val = Int(colorVal){
                        
                        if(val < 10)
                        {
                            lblText = lblText?.appendingFormat("%@%@%@",oneDigitString,colorVal,oneDigitString)
                        }
                        else if(val < 100)
                        {
                            lblText = lblText?.appendingFormat("%@%@%@",twoDigitString,colorVal,twoDigitString)
                        }
                        else
                        {
                            lblText = lblText?.appendingFormat("%@%@%@",threeDigitString,colorVal,threeDigitString)
                        }
                    }
                    else
                    {
                        lblText = lblText?.appendingFormat("%@",blockString)
                    }
                }
            }
            lblText = lblText?.appendingFormat("\n")
        }
        
        //print("%s",lblText)
    }
    
    
    func getColorNumber(color:UIColor) -> (String,UIColor,CGFloat){
        for col in sortedColorsOccurenceWithNumber{
            if col.key == color{
                return ("\(col.number)",UIColor.gray,1.0)
            }
        }
        return ("",UIColor(white: 0.7, alpha: 0.5), 0.2)
    }
    
    // MARK:- Drawing image and label numbers
    
    func drawGridInGrayScale(){
        
        autoreleasepool {
            
            imageDrawView = UIImageView()
            viewInDrawView = UIView()
            viewInDrawView?.isHidden = true
            labelView = UIImageView()
            colorImageDrawView = UIView()
            
            // Setting views frame
            let width = Int(squareWidth) * totalHorizontalgrids
            let height = Int(squareWidth) * totalVerticalGrids
            viewInDrawView?.frame =  CGRect(x: 0  , y:0, width: width, height: height )
            imageDrawView?.frame = (viewInDrawView?.bounds)!
            labelView?.frame = (viewInDrawView?.bounds)!
            colorImageDrawView?.frame = (viewInDrawView?.bounds)!
            drawView.contentSize = (viewInDrawView?.bounds.size)!
            //        viewInDrawView?.backgroundColor = UIColor.red
            // Setting views background color
            
            colorImageDrawView?.backgroundColor = UIColor.clear
            viewInDrawView?.backgroundColor = UIColor.clear
            labelView?.backgroundColor = UIColor.clear
            imageDrawView?.backgroundColor = UIColor.clear
            
            imageDrawView?.image = getImage()
            // Adding views
            viewInDrawView?.addSubview(imageDrawView!)
            viewInDrawView?.addSubview(labelView!)
            viewInDrawView?.addSubview(colorImageDrawView!)
            drawView.addSubview(viewInDrawView!)
            // Drawing views
            //        imageDrawView?.colorArray = grayScaleColors
            //        imageDrawView?.squareWidth = squareWidth
            imageDrawView?.setNeedsDisplay()
            /*
             commented by Praveen on 18 Dec
             labelView?.coloredColors = imageColors
             labelView?.squareWidth = squareWidth
             labelView?.colorsNumber = sortedColorsOccurenceWithNumber
             labelView?.grayoutNumber = sortedColorsOccurenceWithNumber[0].number
             labelView?.labelArray = labelArray
             */
            labelView?.image = getLabelsImage(selectedIndex: 0)
            labelView?.setNeedsDisplay()
            
            // Adding Gestures
            //        let tapGestureRecognizer2 = UITapGestureRecognizer(target:self, action:#selector(doubleTap(touchRecognizer:)))
            //        drawView.addGestureRecognizer(tapGestureRecognizer2)
            
            tapGesture = UITapGestureRecognizer(target:self, action:#selector(doubleTap(touchRecognizer:)))
            tapGesture.numberOfTapsRequired = 2
            colorImageDrawView?.addGestureRecognizer(tapGesture)
            
            let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTouch(touchRecognizer:)))
            doubleTapGestureRecognizer.numberOfTapsRequired = 1
            //        doubleTapGestureRecognizer.numberOfTouchesRequired = 2
            colorImageDrawView?.addGestureRecognizer(doubleTapGestureRecognizer)
            doubleTapGestureRecognizer.require(toFail: tapGesture)
            
            let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPress(gesture:)))
            longPressGesture.delegate = self
            longPressGesture.minimumPressDuration = 0.1
            colorImageDrawView?.addGestureRecognizer(longPressGesture)
            
            colorImageDrawView?.isUserInteractionEnabled = true
            drawView.isUserInteractionEnabled = true
            
            // Setting initially selected color
            selectedColorWithNumber = sortedColorsOccurenceWithNumber[0]
            // let firstView = imageDrawView?.copy()
            // Setting initial zoom
            drawView.setZoomScale(minimumScale, animated: false)
            self.isZoomLevelSets = true
            //Gaurav
            //  DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.prefillImage()
            autoreleasepool {
                for x in 0..<self.sortedColorsOccurenceWithNumber.count{
                    self.sortedColorsOccurenceWithNumber[x].isComplete = self.isColorCompleted(colorObj: self.sortedColorsOccurenceWithNumber[x])
                    
                }
            }
            self.collectionColorView.reloadData()
            
            for whiteColorPosition in whiteColorLocations {
                prepareImageView(x: whiteColorPosition.x, y: whiteColorPosition.y, isWhiteImage: true)
            }
            
            //  }
        }
    }
    
    private func performDrawing<Context>(context: Context) where Context: RendererContext, Context.ContextType: CGContext {
        // let rect = context.format.bounds
        autoreleasepool {
            for x in 0..<totalHorizontalgrids{
                for y in 0..<totalVerticalGrids{
                    grayScaleColors[x][y].setFill()
                    context.fill(CGRect(x: x * Int(squareWidth), y: y * Int(squareWidth), width: Int(squareWidth), height: Int(squareWidth)))
                }
            }
        }
        /*
         UIColor.white.setFill()
         context.fill(rect)
         
         UIColor.blue.setStroke()
         let frame = CGRect(x: 10, y: 10, width: 40, height: 40)
         context.stroke(frame)
         
         UIColor.red.setStroke()
         context.stroke(rect.insetBy(dx: 5, dy: 5))
         */
    }
    
    
    
    func getImage() -> UIImage{
        let format = ImageRendererFormat.default()
        let image = ImageRenderer(size: labelView?.frame.size ?? CGSize(width: 0, height: 0), format: format).image{
            context in
            performDrawing(context: context)
        }
        return image
    }
    
    
    
    func getLabelsImage(selectedIndex:Int) -> UIImage{
        let format = ImageRendererFormat.default()
        let image = ImageRenderer(size: labelView?.frame.size ?? CGSize(width: 0, height: 0), format: format).image{
            context in
            drawLabels(context: context, selectedIndex:selectedIndex)
        }
        return image
    }
    
    
    private func drawLabels<Context>(context: Context, selectedIndex: Int) where Context: RendererContext, Context.ContextType: CGContext {
        
        UIColor(white: 0.7, alpha: 0.5).setStroke()
        
        for x in 0..<totalHorizontalgrids+1{
            
            let y = 0
            let yMax = totalVerticalGrids
            context.cgContext.move(to: CGPoint(x: x * Int(squareWidth), y: y * Int(squareWidth)))
            context.cgContext.addLine(to: CGPoint(x:x * Int(squareWidth), y:  yMax * Int(squareWidth)))
            context.cgContext.closePath()
            context.cgContext.strokePath()
        }
        for y in 0..<totalVerticalGrids+1{
            
            let x = 0
            let xMax = totalHorizontalgrids
            context.cgContext.move(to: CGPoint(x: x * Int(squareWidth), y: y * Int(squareWidth)))
            context.cgContext.addLine(to: CGPoint(x:xMax * Int(squareWidth), y:  y * Int(squareWidth)))
            context.cgContext.closePath()
            context.cgContext.strokePath()
        }
        
        
        if(selectedIndex != -1)
        {
            
            for t in 0..<occupiedPointsBasedonColorOder[selectedIndex].count{
                
                let x = occupiedPointsBasedonColorOder[selectedIndex][t].0
                let y = occupiedPointsBasedonColorOder[selectedIndex][t].1
                
                
                let rectangle = CGRect(origin:CGPoint(x:x * Int(squareWidth),y:y * Int(squareWidth)),size:CGSize(width:squareWidth,height: squareWidth))
                context.cgContext.addRect(rectangle)
                UIColor(white: 0.7, alpha: 0.5).setFill()
                context.cgContext.drawPath(using: .fill)
                
            }
            
        }
        
        
        for i in 0..<occupiedPointsBasedonColorOder.count{
            
            context.cgContext.setLineWidth(0.25)
            
            for t in 0..<occupiedPointsBasedonColorOder[i].count{
                
                let x = occupiedPointsBasedonColorOder[i][t].0
                let y = occupiedPointsBasedonColorOder[i][t].1
                
                let touple =  labelArray[x][y]
                
                let rectangle = CGRect(origin:CGPoint(x:x * Int(squareWidth),y:y * Int(squareWidth)),size:CGSize(width:squareWidth,height: squareWidth))
                context.cgContext.addRect(rectangle)
                touple.1.setStroke()
                context.cgContext.drawPath(using: .stroke)
                
            }
            
        }
        
        var offset = 7
        
        if UI_USER_INTERFACE_IDIOM() == .pad{
            //Before: offset = 10
            offset = 8
        }
        lblText?.draw(in: CGRect(x:0,y:offset,width:(Int(squareWidth) * totalVerticalGrids),height:(Int(squareWidth) * totalVerticalGrids)), withAttributes: textFontAttributes)
        
        /*for x in 0..<totalHorizontalgrids{
         for y in 0..<totalVerticalGrids{
         
         let touple =  labelArray[x][y]
         let number = touple.0 as NSString
         
         //                context.cgContext.move(to: CGPoint(x: x * Int(squareWidth), y: y * Int(squareWidth)))
         //                context.cgContext.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth), y: y * Int(squareWidth)))
         //                context.cgContext.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
         //                context.cgContext.addLine(to: CGPoint(x: x * Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
         //                context.cgContext.closePath()
         //
         //                touple.1.setStroke()
         //                context.cgContext.strokePath()
         
         // UIColor(white: 0.7, alpha: 0.5).setFill()
         // context.fill(CGRect(x:CGFloat(x) * squareWidth,y:CGFloat(y) * squareWidth,width:squareWidth,height:squareWidth))
         
         
         if grayoutNumber == Int(touple.0){
         
         let rectangle = CGRect(origin:CGPoint(x:x * Int(squareWidth),y:y * Int(squareWidth)),size:CGSize(width:squareWidth,height: squareWidth))
         context.cgContext.addRect(rectangle)
         UIColor(white: 0.7, alpha: 0.5).setFill()
         context.cgContext.drawPath(using: .fill)
         
         // let rectanglePath = UIBezierPath()
         
         //                    rectanglePath.lineWidth = 0.25
         //                    rectanglePath.move(to: CGPoint(x: x * Int(squareWidth), y: y * Int(squareWidth)))
         //                    rectanglePath.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth), y: y * Int(squareWidth)))
         //                    rectanglePath.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
         //                    rectanglePath.addLine(to: CGPoint(x: x * Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
         //                    rectanglePath.close()
         //                    UIColor(white: 0.7, alpha: 0.5).setFill()
         //                    rectanglePath.fill()
         }
         //number.draw(in: CGRect(x:CGFloat(x) * squareWidth,y:CGFloat(y) * squareWidth,width:squareWidth,height:squareWidth), withAttributes: textFontAttributes)
         number.drawVerticallyCentered(in: CGRect(x:CGFloat(x) * squareWidth,y:CGFloat(y) * squareWidth,width:squareWidth,height:squareWidth), withAttributes: textFontAttributes)
         }
         }*/
    }
    
    
    
    
    // MARK:- Gesture Recognizer function
    // Shoaib to do
    @objc func longPress(gesture:UILongPressGestureRecognizer){
        
        if(isBombEnable){  // this if condiontin is added when bomb is active
            
            let touchLocation: CGPoint = gesture.location(in: self.colorImageDrawView)
            let x = Int(touchLocation.x/self.squareWidth) * Int(self.squareWidth)
            let y = Int(touchLocation.y/self.squareWidth) * Int(self.squareWidth)
            if (x/Int(self.squareWidth) < self.imageColors.count)  && (x >= 0){
                if (y/Int(self.squareWidth) < self.imageColors[x/Int(self.squareWidth)].count ) && y >= 0 {
                    //                if !((x == lastXDistance) && (y == lastYDistance)  ){
                    if gesture.state == .began{
                        self.fillColor(x: x, y: y, isHold: true)
                    }
                    else if gesture.state == .changed{
                        
                        self.fillColor(x: x, y: y, isHold: false)
                    } else{
                        //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                        self.labelView?.setNeedsDisplay()
                        //                    }
                    }
                    self.lastXDistance = x
                    self.lastYDistance = y
                    //                }
                }
            }
        }
        
        else {
            if drawView.zoomScale <= (minimumScale + 0.2){
                // changed by shoaib
                // if(totalHorizontalgrids <= 25 || totalVerticalGrids <= 25){
                if(totalHorizontalgrids <= 40 || totalVerticalGrids <= 40){
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                        self.drawView.setZoomScale(self.singleTapScale, animated: true)
                    })
                }else{
                    
                    if self.isJustCompleted == false {
                        let touchLocation = gesture.location(in: gesture.view)
                        drawView.maximumZoomScale = 1.1
                        drawView.zoom(to: CGRect(x:touchLocation.x , y:touchLocation.y , width:10, height:10), animated: true)
                        drawView.maximumZoomScale = maximumScale
                    }
                    
                }
            }
            else{
                let touchLocation: CGPoint = gesture.location(in: colorImageDrawView)
                let x = Int(touchLocation.x/squareWidth) * Int(squareWidth)
                let y = Int(touchLocation.y/squareWidth) * Int(squareWidth)
                if (x/Int(squareWidth) < imageColors.count)  && (x >= 0){
                    if (y/Int(squareWidth) < imageColors[x/Int(squareWidth)].count ) && y >= 0 {
                        //                if !((x == lastXDistance) && (y == lastYDistance)  ){
                        if gesture.state == .began{
                            self.isAutoMoveEnable = true
                            soundPlayed = false
                            fillColor(x: x, y: y, isHold: true)
                        }
                        else if gesture.state == .changed{
                            self.isAutoMoveEnable = false
                            soundPlayed = true
                            checkPathComplete = true
                            fillColor(x: x, y: y, isHold: false)
                            player?.stop()
                        } else{
                            //                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.3) {
                            self.labelView?.setNeedsDisplay()
                            //                    }
                        }
                        lastXDistance = x
                        lastYDistance = y
                        //                }
                        //appDelegate.logEvent(name: "Paint_Picker", category: "paint", action: "long press gesture to paint")
                    }
                }
            }
        }
    }
    
    @objc func didMove(panGesture:UIPanGestureRecognizer){
        print("Pan Gesture : \(panGesture.state)")
        
    }
    
    @objc func doubleTap2(touchRecognizer:UITapGestureRecognizer){
        drawView.setZoomScale(minimumScale, animated: true)
    }
    
    
    @objc func doubleTap(touchRecognizer:UITapGestureRecognizer){
        // let touchLocation: CGPoint = touchRecognizer.location(in: colorImageDrawView)
        if (drawView.zoomScale <= maximumScale  && drawView.zoomScale >= 1.0){
            self.didTouch(touchRecognizer: touchRecognizer)
        }
        else{
            //drawView.zoom(to: CGRect(x:touchLocation.x, y:touchLocation.y, width: 10, height: 10), animated: true)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                self.drawView.setZoomScale(self.doubleTapScale, animated: true)
            })
            
        }
        //print("double tap : \(touchRecognizer.location(in:colorImageDrawView))")
    }
    
    
    @objc func didTouch(touchRecognizer:UITapGestureRecognizer){
        
        let touchLocation: CGPoint = touchRecognizer.location(in: colorImageDrawView)
        if(isBombEnable){  // this if condiontin is added when bomb is active
            let x = Int(touchLocation.x/squareWidth) * Int(squareWidth)
            let y = Int(touchLocation.y/squareWidth) * Int(squareWidth)
            
            if (x/Int(squareWidth) < imageColors.count) && (x >= 0){
                if (y/Int(squareWidth) < imageColors[x/Int(squareWidth)].count ){
                    //                    if !((x == lastXDistance) && (y == lastYDistance)  ){
                    if x >= 0 && y >= 0{
                        fillColor(x: x, y: y, isHold: true)
                        lastXDistance = x
                        lastYDistance = y
                    }
                }
            }
        }else{
            if drawView != nil {
                if drawView.zoomScale <= (minimumScale + 0.2){
                    //drawView.zoom(to: CGRect(x:touchLocation.x , y:touchLocation.y , width:10, height:10), animated: true)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                        self.drawView.setZoomScale(self.singleTapScale, animated: true)
                    })
                }
                else{
                    let x = Int(touchLocation.x/squareWidth) * Int(squareWidth)
                    let y = Int(touchLocation.y/squareWidth) * Int(squareWidth)
                    
                    if (x/Int(squareWidth) < imageColors.count) && (x >= 0){
                        if (y/Int(squareWidth) < imageColors[x/Int(squareWidth)].count ){
                            //                    if !((x == lastXDistance) && (y == lastYDistance)  ){
                            if x >= 0 && y >= 0{
                                singleTouch = true
                                soundPlayed = false
                                fillColor(x: x, y: y, isHold: true)
                                lastXDistance = x
                                lastYDistance = y
                            }
                        }
                    }
                }
            }
        }
    }
    
    func keyForPoint(point:CGPoint)->String{
        return "\(Int(point.x)):\(Int(point.y))"
    }
    
    
    func fillColor(x:Int, y:Int, isHold:Bool){
        
        if isBombEnable == true {
            fillWithBomb(x:x, y:y, isHold:isHold)
            self.colorNumber =  0
            let percent = findPercentageDividation(count: self.colorNumber)
            self.progressBar.setProgress(to: percent, withAnimation: true)
            self.isBombActive.toggle()
            bombEnableDisable()
            setProgressBarWithBomb()
                }
        else {
            fillWithOutBomb(x:x, y:y, isHold:isHold)
            setProgressBarWithoutBomb()
        }
//        DispatchQueue.main.async {
//            self.collectionColorView.reloadData()
//        }
    }
    
 
    func setProgressBarWithoutBomb() {
        if selectedIndex.item >= 0{
            let totalColorCount:Double = Double(sortedColorsOccurenceWithNumber[selectedIndex.item].value)
            let filledColorCount: Double = Double(self.getFilledColorCount(colorObj: sortedColorsOccurenceWithNumber[selectedIndex.item]))
            print("filledColorCount: \(filledColorCount), totalColorCount: \(totalColorCount), progress: \( Double(filledColorCount / totalColorCount))")
            var indexPath = IndexPath(item: self.selectedIndex.item, section: 0)
            DispatchQueue.main.async {
                if let cell = self.collectionColorView.cellForItem(at: indexPath) as? ChooseColorCollectionCell {
                    if cell.number.textColor == UIColor.black {
                        cell.colorProgressBar.lineColor = .gray
                    }
                    else {
                        cell.colorProgressBar.lineColor = .white
                    }
                    cell.colorProgressBar.makeBar()
                    cell.colorProgressBar.setProgress(to: filledColorCount / totalColorCount, withAnimation: true)
                    if totalColorCount == filledColorCount {
                        cell.colorCompleteImageView.isHidden = false
                    }
                }
            }
        }
    }
    
    func setProgressBarWithBomb() {
        if selectedIndex.item >= 0{
            for (index, item) in sortedColorsOccurenceWithNumber.enumerated() {
                if index == selectedIndex.row {
                    let totalColorCount:Double = Double(item.value)
                    let filledColorCount = Double(self.getFilledColorCount(colorObj: item))
                    var indexPath = IndexPath(item: self.selectedIndex.item, section: 0)
                    if let cell = self.collectionColorView.cellForItem(at: indexPath) as? ChooseColorCollectionCell {
                        if cell.number.textColor == UIColor.black {
                            cell.colorProgressBar.lineColor = .gray
                        }
                        else {
                            cell.colorProgressBar.lineColor = .white
                        }
                        cell.colorProgressBar.makeBar()
                        cell.colorProgressBar.setProgress(to: filledColorCount / totalColorCount, withAnimation: true)
                        if totalColorCount == filledColorCount {
                            cell.colorCompleteImageView.isHidden = false
                        }
                    }
                }
            }
        }
    }
    func fillWithOutBomb(x:Int, y:Int, isHold:Bool){
        if !(whiteColorLocations.contains(CGPoint(x: x, y: y))){
            let fillColor = imageColors[x/Int(squareWidth)][y/Int(squareWidth)]
            if let index =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                let indexPath = IndexPath(item: index, section: 0)
                if isHold{ // Delete or Stack Away Drawing Feature: hold to auto select the color for this version
                    if isAutoMoveEnable{
                        //////***********
                        /////////Devendra To Do
                        
                        //Start Check a box which is already colored, it should not auto-select the # color of that box.
                        let point = CGPoint(x: x, y: y)
                        for singleObjectt in self.pointAndColorArr
                        {
                            if (singleObjectt.points == point)
                            {
                                return
                            }
                        }
                        if isPaintEnable && UserDefaults.standard.integer(forKey: paint_count) != 0{
                            playSound(soundName: m4)
                            soundPlayed = true
                            checkPathComplete = false
                        print("sound_m4")
                        }
                        // End not auto-select
                        if sortedColorsOccurenceWithNumber[index].isComplete == false
                        {
                            if selectedIndex.item != index
                            {
                                // let autoMoveCount =  UserDefaults.standard.integer(forKey: autoMove_count)
                                let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                                if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
                                {
                                    self.showLabelWithCount(lbl: autoMoveCountLabel , count: 0)
                                }
                                //                                else
                                //                                {
                                //                                    UserDefaults.standard.set(autoMoveCount-1, forKey: autoMove_count)
                                //
                                //                                    if autoMoveCount-1 == 0 {
                                //                                        startTimer()
                                //                                    }
                                //
                                //                                    UserDefaults.standard.synchronize()
                                //                                    self.showLabelWithCount(lbl: autoMoveCountLabel  , count: autoMoveCount-1)
                                //                                    if autoMoveCount   <= 1
                                //                                    {
                                //                                        isAutoMoveEnable = false
                                //                                        self.autoMoveButton.setImage(UIImage(named: "paintpicker"), for: .normal)
                                //                                        self.zommInButoon(button: eraseButton)
                                //                                        self.zommInButoon(button: hintButton)
                                //                                        self.zommInButoon(button: paintButton)
                                //                                        self.zommInButoon(button: autoMoveButton)
                                //                                        self.roundedbuttonSet(button: autoMoveButton)
                                //                                    }
                                //                                }
                                //////*******
                                
                                selectedColorWithNumber = sortedColorsOccurenceWithNumber[index]
                                selectedIndex = indexPath
                                self.collectionColorView.reloadData()
                                //labelView?.grayoutNumber = selectedColorWithNumber.number
                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                                    self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
                                }
                                self.collectionColorView.scrollToItem(at: indexPath, at: .left, animated: true)//Devendra To Do
                                //Disable Paint Picker When Use Once
                                isAutoMoveEnable = false
                                self.autoMoveButton.setImage(UIImage(named: "paintpicker"), for: .normal)
                                
                                //                                self.zommInButoon(button: eraseButton)
                                //                                self.zommInButoon(button: hintButton)
                                //                                self.zommInButoon(button: paintButton)
                                self.zommInButoon(button: autoMoveButton)
                                self.roundedbuttonSet(button: autoMoveButton)
                                /////
                            }
                        }
                    }
                }
            }
            
            if checkPathComplete{
            let point = CGPoint(x: x, y: y)
                for singleObjectt in self.pointAndColorArr
                {
                    if (singleObjectt.points == point)
                    {
                        checkPathComplete = true
                        soundPlayed = false
                        return
                    }
                }
                soundPlayed = false
                checkPathComplete = false
            }
            if selectedIndex.item == -1 {
                
                let point = CGPoint(x: x, y: y)
                for singleObjectt in self.pointAndColorArr
                {
                    if (singleObjectt.points == point)
                    {
                        return
                    }
                }
                if (colorImageDrawView?.layer.sublayers != nil  ){
                    if let index =  colorImageDrawView?.layer.sublayers!.index(where: {(((($0 as! CAShapeLayer ).path?.boundingBox.origin)! == CGPoint(x:CGFloat(x), y: CGFloat(y))) && ((($0 as! CAShapeLayer ).path?.boundingBox.size)! ==  CGSize(width:squareWidth, height:squareWidth)))}){
                        colorImageDrawView?.layer.sublayers!.remove(at: index)
                    }
                }
                let keyVal = keyForPoint(point: point)
                if let _ = capturedPoints[keyVal]{
                    capturedPoints.removeValue(forKey: keyVal)
                    //print("cp: %d",capturedPoints.count)
                }
                
                let  obj = PointAndColor()
                obj.fillColor = fillColor
                obj.points = point
                
                let numObj = NSNumber(value:fillColor.rgb()!)
                // When user uses eraser and color the wrong boxes during Drawing screen
                //                if (capturedColors.contains(numObj)){
                //                    capturedColors.remove(at: capturedColors.index(of: numObj)!)
                //                }
                if (capturedColors.contains(numObj)){
                    capturedColors.remove(at: capturedColors.index(of: numObj)!)
                    let index =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor })
                    sortedColorsOccurenceWithNumber[index!].value -= 1
                }
                
                for singleObject in self.pointAndColorArr
                {
                    if (singleObject.points == point){
                        self.pointAndColorArr.remove(at: self.pointAndColorArr.index(of:singleObject)!)
                        self.playButton.setImage(UIImage(named:"ok"), for: UIControlState.normal)
                        break
                    }
                }
                //                if (pointAndColorArr.contains(obj)){
                //                    pointAndColorArr.remove(at: pointAndColorArr.index(of: obj)!)
                //                }
                
                if let index =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                    // let indexPath = IndexPath(item: index, section: 0)
                    sortedColorsOccurenceWithNumber[index].isComplete = false
                    self.collectionColorView.reloadData()
                    
                    // self.collectionColorView.scrollToItem(at: selectedIndex, at: .left, animated: false)
                }
                
                return
            }
            if fillColor == selectedColorWithNumber.key{
                switch(self.getPaintType())
                {
                case .kPaintEnableNoPointsAvailable:
                    clikcedType = 2
                    self.checkViewType(type: .kViewTypePaint)
                    break;
                case .kPaintEnablePointsAvailable:
                    self.processedPoints.removeAll()
                    self.processedPoints = self.occupiedPointsIndexArray[self.selectedIndex.item]
                    let point = CGPoint(x: x, y: y)
                    
                    self.coloredPoints.removeAll()
                    self.coloredPoints.append(point)
                    // self.processThePoint(point: point, fillColor: fillColor)
                    
                    let wd = Int(squareWidth)
                    
                    let path = UIBezierPath()
                    
                    /////////Devendra To Do  // if alrady fill no count should decrese  // shoaib 13-Dec
                    
                    let paintCount =  UserDefaults.standard.integer(forKey: paint_count)
                    let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                    if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
                    {
                        self.showLabelWithCount(lbl: paintCountLabel , count: 0)
                    }
                    else
                    {
                        let keyVal = keyForPoint(point: point)
                        if (capturedPoints[keyVal] == nil)
                        {
                            
                            UserDefaults.standard.set(paintCount-1, forKey: paint_count)
                            
                            if paintCount-1 == 0 {
                                startReminderTimer()
                            }
                            
                            UserDefaults.standard.synchronize()
                            self.showLabelWithCount(lbl: paintCountLabel  , count: paintCount-1)
                        }
                        
                        
                        if paintCount   <= 1
                        {
                            
                            //Lekha Added
                            /*isPaintEnable = false
                             self.paintButton.setImage(UIImage(named: "paintbucket"), for: .normal)
                             self.zommInButoon(button: eraseButton)
                             self.zommInButoon(button: hintButton)
                             self.zommInButoon(button: paintButton)
                             self.zommInButoon(button: autoMoveButton)
                             self.roundedbuttonSet(button: paintButton)*/
                        }
                    }
                    while(self.coloredPoints.count > 0)
                    {
                        
                        let pVal = self.coloredPoints[0]
                        
                        let keyVal = keyForPoint(point: pVal)
                        if let _ = processedPoints[keyVal]
                        {
                            processedPoints.removeValue(forKey: keyVal)
                            
                            let x = Int(pVal.x)
                            let y = Int(pVal.y)
                            
                            let pointV = CGPoint(x:x, y:y)
                            //
                            //self.doPaintFill(x: CGFloat(x), y: CGFloat(y),fillColor: fillColor)//Testing
                            
                            path.move(to: pointV)
                            path.addLine(to: CGPoint(x: (x + wd), y: y))
                            path.addLine(to: CGPoint(x: (x + wd), y: (y + wd)))
                            path.addLine(to: CGPoint(x: x, y: (y + wd)))
                            saveColorRecords(point: pointV, fillColor: fillColor)
                            //path.addLine(to: CGPoint(x: (x), y: (y - wd)))
                            
                            
                            let isPaintBucketExtended = UserDefaults.standard.bool(forKey: "isPaintBucketExtended")
                            if isPaintBucketExtended == true {
                                //                                print("Paint Bucket is Normal")
                                
                                //                                Old
                                self.coloredPoints.append(CGPoint(x: (x + wd), y: y))
                                self.coloredPoints.append(CGPoint(x: (x), y: (y + wd)))
                                self.coloredPoints.append(CGPoint(x: (x - wd), y: (y)))
                                self.coloredPoints.append(CGPoint(x: (x), y: (y - wd)))
                                
                            }
                            else {
                                //                                print("Paint Bucket is Extended")
                                
                                //                                New
                                self.coloredPoints.append(CGPoint(x: (x + wd), y: y))
                                self.coloredPoints.append(CGPoint(x: (x + wd), y: (y + wd)))
                                self.coloredPoints.append(CGPoint(x: (x), y: (y + wd)))
                                self.coloredPoints.append(CGPoint(x: (x - wd), y: (y + wd)))
                                self.coloredPoints.append(CGPoint(x: (x - wd), y: (y)))
                                self.coloredPoints.append(CGPoint(x: (x - wd), y: (y - wd)))
                                self.coloredPoints.append(CGPoint(x: (x), y: (y - wd)))
                                self.coloredPoints.append(CGPoint(x: (x + wd), y: (y - wd)))
                            }
                            
                        }
                        
                        self.coloredPoints.remove(at: 0)
                        
                        
                    }
                    
                    
                    self.addColorForPath(rectanglePath: path, opacity: 1.0)
                    path.close()
                    
                    if(self.isColorCompleted(colorObj: selectedColorWithNumber))
                    {
                        
                        //MARK: For delay complete color info
                        var indexPath = IndexPath(item: self.selectedIndex.item, section: 0)
                        guard let cell = self.collectionColorView.cellForItem(at: indexPath) as? ChooseColorCollectionCell else {
                            selectedColorWithNumber.isComplete = true
                            
                            if let indexVal =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                                sortedColorsOccurenceWithNumber[indexVal].isComplete = true
                                
                                if sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).count > 0{ //  get all incompleted
                                    let incompletedColors = sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).map({$0.number})
                                    let maxValue = incompletedColors.max()
                                    if selectedIndex.item == maxValue{ // last value is selected
                                        selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get first minimum value
                                    }else{
                                        if incompletedColors.filter({$0 - 1 > selectedIndex.item}).count > 0{ // get next value
                                            selectedIndex = NSIndexPath(item: incompletedColors.filter({$0 - 1 > selectedIndex.item}).min()! - 1, section: 0) as IndexPath
                                        }else{
                                            selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                                        }
                                    }
                                    selectedColorWithNumber = sortedColorsOccurenceWithNumber[selectedIndex.item]
                                }
                            }
                            animationComplete = true
                            
                            //MARK:  Show delay of Check Mark in color palette when last color is completed
                            // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                            // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                            self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
                            //}
                            // }
                            
                            if isDrawingComplete(){
                                didCompleteDrawing();
                            }
                            
                            self.collectionColorView.reloadData()
                            self.collectionColorView.scrollToItem(at: self.selectedIndex, at: .left, animated: true)
                            
                            return
                        }
                        setProgressBarWithoutBomb()
                        cell.colorCompleteImageView.image = UIImage(named:"color_complete")
                        //MARK:  for color plate animation
                        let viewTemp = loveBtn
                        var frame2 = viewTemp?.frame
                        let theAttributes:UICollectionViewLayoutAttributes! = collectionColorView.layoutAttributesForItem(at: indexPath)
                        let cellFrameInSuperview:CGRect!  = collectionColorView.convert(theAttributes.frame, to: collectionColorView.superview)
                        frame2?.origin.y = cellFrameInSuperview.origin.y + 2.5
                        frame2?.origin.x = cellFrameInSuperview.origin.x + cell.frame.width/2 - self.loveBtn!.frame.width/2
                        viewTemp?.frame = frame2!
                        viewTemp!.circleToColor = cell.colorView.backgroundColor!
                        
                        cell.colorView.backgroundColor = UIColor.white
                        cell.colorView.layer.borderColor = UIColor.clear.cgColor
                        cell.contentView.clipsToBounds = false
                        self.loveBtn?.animateSelect(true, duration: 1.0)
                        selectedColorWithNumber.isComplete = true
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                            self.collectionColorView.reloadData()
                        }
                        animationComplete = true
                        if let indexVal =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                            sortedColorsOccurenceWithNumber[indexVal].isComplete = true
                            
                            if sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).count > 0{ //  get all incompleted
                                let incompletedColors = sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).map({$0.number})
                                let maxValue = incompletedColors.max()
                                if selectedIndex.item == maxValue{ // last value is selected
                                    selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get first minimum value
                                }else{
                                    if incompletedColors.filter({$0 - 1 > selectedIndex.item}).count > 0{ // get next value
                                        selectedIndex = NSIndexPath(item: incompletedColors.filter({$0 - 1 > selectedIndex.item}).min()! - 1, section: 0) as IndexPath
                                    }else{
                                        selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                                    }
                                }
                                selectedColorWithNumber = sortedColorsOccurenceWithNumber[selectedIndex.item]
                            }
                        }
                        animationComplete = false
                        if singleTouch && !soundPlayed{
                            playSound(soundName: m4)
                            singleTouch = false
                            print("sound_m4")
                        }
                        //MARK:  Show delay of Check Mark in color palette when last color is completed
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                           // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                            self.playSound(soundName: m3)
                            print("sound_m3")
                                self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
                            self.collectionColorView.scrollToItem(at: self.selectedIndex, at: .left, animated: true)
                            
                            // }
                        }
                        
                    }else{
                        if !checkPathComplete && !soundPlayed{
                            playSound(soundName: m4)
                            print("sound_m4")
                            checkPathComplete = true
                        }
                    }
                    
                    if isDrawingComplete(){
                        didCompleteDrawing();
                    }
                    
                    break;
                default:
                    doCorrectFill(x: CGFloat(x), y: CGFloat(y),fillColor: fillColor)
                    
                }
                
            }
            else{
                playerLongTap?.stop()
                let point = CGPoint(x: x, y: y)
                //print("p-x: %d p-y: %d",x,y)
                let keyVal = keyForPoint(point: point)
                if (capturedPoints[keyVal] == nil){
                    if (colorImageDrawView?.layer.sublayers != nil  ){
                        if let index =  colorImageDrawView?.layer.sublayers!.index(where: {(((($0 as! CAShapeLayer ).path?.boundingBox.origin)! == CGPoint(x:CGFloat(x), y: CGFloat(y))) && ((($0 as! CAShapeLayer ).path?.boundingBox.size)! ==  CGSize(width:squareWidth, height:squareWidth)))}){
                            colorImageDrawView?.layer.sublayers!.remove(at: index)
                        }
                    }
                    addColorLayer(x: CGFloat(x), y: CGFloat(y), opacity: 0.5)
                }
            }
        }
    }
    
    func fillWithBomb(x:Int, y:Int, isHold:Bool)
    {
        playSound(soundName: m5)
        print("sound_m5")
        if currentXValue == 1 {
            fillWithOutBombIgnoreSelection(x: x, y: y, isHold: isHold)
        }
        else if currentXValue >= 2 {
            
            let initialCoordinate = Int(CGFloat((currentXValue-1))*squareWidth)
            
            let initialPoint = CGPoint(x: x-initialCoordinate, y: y-initialCoordinate)
            let topRightPoint = CGPoint(x: x+initialCoordinate, y: y-initialCoordinate)
            let bottomLeftPoint = CGPoint(x: x-initialCoordinate, y: y+initialCoordinate)
            
            var pointArray = [CGPoint]()
            
            let initialXValue = Int(initialPoint.x)
            let initialYValue = Int(initialPoint.y)
            
            //            for x in 0...(2*currentXValue-2) {
            //                for y in 0...(2*currentXValue-2) {
            //                    let point = CGPoint(x: initialXValue+(x*Int(squareWidth)), y: initialYValue+(y*Int(squareWidth)))
            //                    if point.x >= 0 && point.x <= drawView.contentSize.width && point.y >= 0 && point.y <= drawView.contentSize.height {
            //                        pointArray.append(point)
            //                    }
            //                }
            //            }
            
            for x in 0...(2*currentXValue-2) {
                for y in 0...(2*currentXValue-2) {
                    let point = CGPoint(x: initialXValue+(x*Int(squareWidth)), y: initialYValue+(y*Int(squareWidth)))
                    pointArray.append(point)
                }
            }
            
            if pointArray.count > 0 {
                pointArray.removeLast()
            }
            if pointArray.count > 0 {
                pointArray.removeFirst()
            }
            
            for point in pointArray {
                if !(Int(point.x) == Int(topRightPoint.x) && Int(point.y) == Int(topRightPoint.y)) && !(Int(point.x) == Int(bottomLeftPoint.x) && Int(point.y) == Int(bottomLeftPoint.y)) {
                    // to do shoaib minum zoom level
                    //if point.x >= 0 && point.x <= drawView.contentSize.width && point.y >= 0 && point.y <= drawView.contentSize.height {
                    fillWithOutBombIgnoreSelection(x: Int(point.x), y: Int(point.y), isHold: isHold)
                    //}
                }
                //                else if (Int(point.x) == x && Int(point.y) == y) {
                //                    fillWithOutBombIgnoreSelection(x: Int(point.x), y: Int(point.y), isHold: isHold)
                //                }
            }
        }
        
    }
    
    func hideShowBomb(isHidden:Bool){
        self.progressBar.isHidden = isHidden
        self.bombButton.isHidden = isHidden
    }
    
    
    func fillWithOutBombIgnoreSelection(x:Int, y:Int, isHold:Bool) {
        
        if !(whiteColorLocations.contains(CGPoint(x: x, y: y))){
            let xIndex = x/Int(squareWidth)
            let yIndex = y/Int(squareWidth)
            if xIndex <= imageColors.count - 1 && yIndex <= imageColors.count - 1 {
                if(xIndex < 0 || yIndex < 0){
                    return
                }
                
                let fillColor = imageColors[xIndex][yIndex]
                if fillColor != selectedColorWithNumber.key{
                    selectedColorWithNumber = sortedColorsOccurenceWithNumber.filter({$0.key == fillColor})[0]
                }
                
                if fillColor == selectedColorWithNumber.key{
                    switch(self.getPaintType())
                    {
                    case .kPaintEnableNoPointsAvailable:
                        clikcedType = 2
                        self.checkViewType(type: .kViewTypePaint)
                        break;
                    case .kPaintEnablePointsAvailable:
                        self.processedPoints.removeAll()
                        self.processedPoints = self.occupiedPointsIndexArray[self.selectedIndex.item]
                        let point = CGPoint(x: x, y: y)
                        
                        self.coloredPoints.removeAll()
                        self.coloredPoints.append(point)
                        
                        // self.processThePoint(point: point, fillColor: fillColor)
                        
                        let wd = Int(squareWidth)
                        
                        let path = UIBezierPath()
                        
                        let paintCount =  UserDefaults.standard.integer(forKey: paint_count)
                        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
                        {
                            self.showLabelWithCount(lbl: paintCountLabel , count: 0)
                        }
                        else
                        {
                            let keyVal = keyForPoint(point: point)
                            if (capturedPoints[keyVal] == nil)
                            {
                                
                                UserDefaults.standard.set(paintCount-1, forKey: paint_count)
                                
                                if paintCount-1 == 0 {
                                    startReminderTimer()
                                }
                                
                                UserDefaults.standard.synchronize()
                                self.showLabelWithCount(lbl: paintCountLabel  , count: paintCount-1)
                            }
                            
                            
                            if paintCount   <= 1
                            {
                                
                                //Lekha Added
                                /*isPaintEnable = false
                                 self.paintButton.setImage(UIImage(named: "paintbucket"), for: .normal)
                                 self.zommInButoon(button: eraseButton)
                                 self.zommInButoon(button: hintButton)
                                 self.zommInButoon(button: paintButton)
                                 self.zommInButoon(button: autoMoveButton)
                                 self.roundedbuttonSet(button: paintButton)*/
                            }
                        }
                        
                        while(self.coloredPoints.count > 0)
                        {
                            
                            let pVal = self.coloredPoints[0]
                            
                            let keyVal = keyForPoint(point: pVal)
                            if let _ = processedPoints[keyVal]
                            {
                                processedPoints.removeValue(forKey: keyVal)
                                
                                let x = Int(pVal.x)
                                let y = Int(pVal.y)
                                
                                let pointV = CGPoint(x:x, y:y)
                                //
                                //self.doPaintFill(x: CGFloat(x), y: CGFloat(y),fillColor: fillColor)//Testing
                                
                                path.move(to: pointV)
                                path.addLine(to: CGPoint(x: (x + wd), y: y))
                                path.addLine(to: CGPoint(x: (x + wd), y: (y + wd)))
                                path.addLine(to: CGPoint(x: x, y: (y + wd)))
                                saveColorRecords(point: pointV, fillColor: fillColor)
                                //path.addLine(to: CGPoint(x: (x), y: (y - wd)))
                                
                                self.coloredPoints.append(CGPoint(x: (x + wd), y: y))
                                self.coloredPoints.append(CGPoint(x: (x), y: (y + wd)))
                                self.coloredPoints.append(CGPoint(x: (x - wd), y: (y)))
                                self.coloredPoints.append(CGPoint(x: (x), y: (y - wd)))
                                
                            }
                            
                            self.coloredPoints.remove(at: 0)
                            
                        }
                        
                        self.addColorForPath(rectanglePath: path, opacity: 1.0)
                        path.close()
                        
                        if(self.isColorCompleted(colorObj: selectedColorWithNumber))
                        {
                            
                            //MARK: For delay complete color info
                            var indexPath = IndexPath(item: self.selectedIndex.item, section: 0)
                            guard let cell = self.collectionColorView.cellForItem(at: indexPath) as? ChooseColorCollectionCell else {
                                selectedColorWithNumber.isComplete = true
                                
                                if let indexVal =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                                    sortedColorsOccurenceWithNumber[indexVal].isComplete = true
                                    
                                    if sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).count > 0{ //  get all incompleted
                                        let incompletedColors = sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).map({$0.number})
                                        let maxValue = incompletedColors.max()
                                        if selectedIndex.item == maxValue{ // last value is selected
                                            selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get first minimum value
                                        }else{
                                            if incompletedColors.filter({$0 - 1 > selectedIndex.item}).count > 0{ // get next value
                                                selectedIndex = NSIndexPath(item: incompletedColors.filter({$0 - 1 > selectedIndex.item}).min()! - 1, section: 0) as IndexPath
                                            }else{
                                                selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                                            }
                                        }
                                        selectedColorWithNumber = sortedColorsOccurenceWithNumber[selectedIndex.item]
                                    }
                                }
                                
                                //MARK:  Show delay of Check Mark in color palette when last color is completed
                                //  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                                //  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                                //  self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
                                // }
                                // }
                                
                                if isDrawingComplete(){
                                    didCompleteDrawing();
                                }
                                
                                self.collectionColorView.reloadData()
                                self.collectionColorView.scrollToItem(at: self.selectedIndex, at: .left, animated: true)
                                
                                return
                            }
                            cell.colorCompleteImageView.isHidden = false
                            cell.colorCompleteImageView.image = UIImage(named:"color_complete")
                            //MARK:  for color plate animation
                            let viewTemp = loveBtn
                            var frame2 = viewTemp?.frame
                            let theAttributes:UICollectionViewLayoutAttributes! = collectionColorView.layoutAttributesForItem(at: indexPath)
                            let cellFrameInSuperview:CGRect!  = collectionColorView.convert(theAttributes.frame, to: collectionColorView.superview)
                            frame2?.origin.y = cellFrameInSuperview.origin.y + 2.5
                            frame2?.origin.x = cellFrameInSuperview.origin.x + cell.frame.width/2 - self.loveBtn!.frame.width/2
                            viewTemp?.frame = frame2!
                            viewTemp!.circleToColor = cell.colorView.backgroundColor!
                            
                            cell.colorView.backgroundColor = UIColor.white
                            cell.colorView.layer.borderColor = UIColor.clear.cgColor
                            cell.contentView.clipsToBounds = false
                            self.loveBtn?.animateSelect(true, duration: 1.0)
                            
                            selectedColorWithNumber.isComplete = true
                            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                                self.collectionColorView.reloadData()
                            }
                            if let indexVal =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                                sortedColorsOccurenceWithNumber[indexVal].isComplete = true
                                
                                if sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).count > 0{ //  get all incompleted
                                    let incompletedColors = sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).map({$0.number})
                                    let maxValue = incompletedColors.max()
                                    if selectedIndex.item == maxValue{ // last value is selected
                                        selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get first minimum value
                                    }else{
                                        if incompletedColors.filter({$0 - 1 > selectedIndex.item}).count > 0{ // get next value
                                            selectedIndex = NSIndexPath(item: incompletedColors.filter({$0 - 1 > selectedIndex.item}).min()! - 1, section: 0) as IndexPath
                                        }else{
                                            selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                                        }
                                    }
                                    selectedColorWithNumber = sortedColorsOccurenceWithNumber[selectedIndex.item]
                                }
                            }
                            
                            //MARK:  Show delay of Check Mark in color palette when last color is completed
                            //DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                            // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                            self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
                            // }
                            //}
                            
                        }
                        
                        if isDrawingComplete(){
                            didCompleteDrawing();
                        }
                        
                        break;
                    default:
                        doCorrectFill(x: CGFloat(x), y: CGFloat(y),fillColor: fillColor)
                    }
                }
            }
        }
    }
    
    public func findPercentageDividation(count:Int) -> Double {
        if count <= 0{
            bombButton.isEnabled = false
            bombButton.setImage(UIImage(named: "graybomb"), for: .normal)
            return 0
        }
        else{
            let percentage = Double((count*100)/colorNumberMax) / 100
            if(percentage >= 1){
                bombButton.isEnabled = true
                
                if (bombButton.currentImage == UIImage(named: "graybomb")) {
                    appDelegate.logEvent(name: "bomb_circle", category: "bomb", action: "bomb completes circle")
                }
                bombButton.setImage(UIImage(named: "bomb"), for: .normal)
                
                if(UserDefaults.standard.value(forKey: isBombBecomesActivefirstTime) == nil){
                    UserDefaults.standard.setValue(true,forKey: isBombBecomesActivefirstTime)
                    UserDefaults.standard.synchronize()
                    viewBombReminder()
                }
            }
            return percentage
        }
    }
    
    func isPointValid(point:CGPoint) -> Bool
    {
        if (Int(point.x) >= 0 && Int(point.x) < totalHorizontalgrids * Int(squareWidth)) && (Int(point.y) >= 0 && Int(point.y) < totalVerticalGrids * Int(squareWidth)){
            return true
        }
        return false
    }
    
    func processThePoint(point:CGPoint, fillColor:UIColor)
    {
        
        let keyVal = keyForPoint(point: point)
        if let _ = processedPoints[keyVal]
        {
            processedPoints.removeValue(forKey: keyVal)
            let wd = Int(squareWidth)
            let x = Int(point.x)
            let y = Int(point.y)
            
            let pointV = CGPoint(x:x, y:y)
            self.coloredPoints.append(pointV)
            //
            //self.doPaintFill(x: CGFloat(x), y: CGFloat(y),fillColor: fillColor)
            
            let isPaintBucketExtended = UserDefaults.standard.bool(forKey: "isPaintBucketExtended")
            if isPaintBucketExtended == true {
                //                print("Paint Bucket is Normal")
                
                //Old
                let point1 = CGPoint(x: (x + wd), y: y)
                self.processThePoint(point: point1, fillColor: fillColor)
                
                let point3 = CGPoint(x: (x), y: (y + wd))
                self.processThePoint(point: point3, fillColor: fillColor)
                
                let point5 = CGPoint(x: (x - wd), y: (y))
                self.processThePoint(point: point5, fillColor: fillColor)
                
                let point7 = CGPoint(x: (x), y: (y - wd))
                self.processThePoint(point: point7, fillColor: fillColor)
            }
            else {
            
                let point1 = CGPoint(x: (x + wd), y: y)
                self.processThePoint(point: point1, fillColor: fillColor)
                
                let point2 = CGPoint(x: (x + wd), y: (y + wd))
                self.processThePoint(point: point2, fillColor: fillColor)
                
                let point3 = CGPoint(x: (x), y: (y + wd))
                self.processThePoint(point: point3, fillColor: fillColor)
                
                let point4 = CGPoint(x: (x - wd), y: (y + wd))
                self.processThePoint(point: point4, fillColor: fillColor)
                
                let point5 = CGPoint(x: (x - wd), y: (y))
                self.processThePoint(point: point5, fillColor: fillColor)
                
                let point6 = CGPoint(x: (x - wd), y: (y - wd))
                self.processThePoint(point: point6, fillColor: fillColor)
                
                let point7 = CGPoint(x: (x), y: (y - wd))
                self.processThePoint(point: point7, fillColor: fillColor)
                
                let point8 = CGPoint(x: (x + wd), y: (y - wd))
                self.processThePoint(point: point8, fillColor: fillColor)
            }
            
            
            //print("after3")
            
        }
        
        
    }
    
    
    @IBAction func bombButtonClicked(_ sender: Any) {
        let percentage = Double((colorNumber*100)/colorNumberMax) / 100
        if(percentage >= 1){
            self.isBombActive.toggle()
            bombEnableDisable()
            
        }
    }
    func bombEnableDisable() {
        let percentage = Double((colorNumber*100)/colorNumberMax) / 100
        if isBombEnable {
            if(percentage >= 1){
                //DispatchQueue.main.async {
                if(self.isBombActive){
                    self.isBombEnable = true
                    self.bombButton.setImage(UIImage(named: "bomb-ready"), for: .normal)
                    self.bombButton.isEnabled = true
                    appDelegate.logEvent(name: "bomb_paint", category: "bomb", action: "taps bomb to paint")
                }else{
                    self.bombButton.setImage(UIImage(named: "bomb"), for: .normal)
                    self.bombButton.isEnabled = true
                    self.isBombEnable = false
                    // appDelegate.logEvent(name: "bomb_circle", category: "bomb", action: "bomb completes circle")
                }
                //// }
            }
            else{
                isBombEnable = false
                self.bombButton.setImage(UIImage(named: "graybomb"), for: .normal)
                self.bombButton.isEnabled = false
                // Shoaib to Do Manage bomb last color should be change with selected color
                self.zommInButoon(button: self.eraseButton)
                self.zommInButoon(button: self.eraseButton)
                self.zommInButoon(button: self.hintButton)
                self.roundedbuttonSet(button: self.eraseButton)
                self.labelViewTimer?.invalidate()
                self.labelViewTimer = nil
                if(selectedIndex.item != -1)
                {
                    self.selectedColorWithNumber = self.sortedColorsOccurenceWithNumber[self.selectedIndex.item]
                    self.collectionColorView.reloadData()
                    self.labelViewTimer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(self.setLabelViewImage), userInfo: nil, repeats: false)
                    paintButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
                    hintButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
                    autoMoveButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
                    
                }
            }
            
        }
        else {
            
            if(percentage >= 1){
                
                if(self.isBombActive){
                    self.isBombEnable = true
                    self.bombButton.setImage(UIImage(named: "bomb-ready"), for: .normal)
                    self.bombButton.isEnabled = true
                    appDelegate.logEvent(name: "bomb_paint", category: "bomb", action: "taps bomb to paint")
                }else{
                    self.bombButton.setImage(UIImage(named: "bomb"), for: .normal)
                    self.bombButton.isEnabled = true
                    self.isBombEnable = false
                    //appDelegate.logEvent(name: "bomb_circle", category: "bomb", action: "bomb completes circle")
                }
            }
            
        }
        
    }
    
    
    var labelViewTimer: Timer!
    @objc func setLabelViewImage() {
        labelViewTimer.invalidate()
        labelViewTimer = nil
        DispatchQueue.main.async {
            self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
        }
    }
    
    func doCorrectFill(x: CGFloat, y: CGFloat, fillColor:UIColor) {
        
        if (colorImageDrawView?.layer.sublayers != nil  ){
            if let index =  colorImageDrawView?.layer.sublayers!.index(where: {(((($0 as! CAShapeLayer ).path?.boundingBox.origin)! == CGPoint(x:CGFloat(x), y: CGFloat(y))) && ((($0 as! CAShapeLayer ).path?.boundingBox.size)! ==  CGSize(width:squareWidth, height:squareWidth)))}){
                colorImageDrawView?.layer.sublayers!.remove(at: index)
            }
        }
        
        self.addColorLayer(x: CGFloat(x), y: CGFloat(y), opacity: 1.0)
        
        let point = CGPoint(x: x, y: y)
        //print("p-x: %d p-y: %d",x,y)
        
        let keyVal = keyForPoint(point: point)
        if (capturedPoints[keyVal] == nil){
            capturedPoints[keyVal] = 1
            //print("cp: %d",capturedPoints.count)
            
            let  obj = PointAndColor()
            obj.fillColor = fillColor
            obj.points = point
            
            if UI_USER_INTERFACE_IDIOM() == .pad{
                obj.coloringDevice = 2
            }
            else{
                obj.coloringDevice = 1
            }
            if !isBombEnable{
            playSound(soundName: m2)
            print("sound_m2")
            }
            capturedColors.append(NSNumber(value:fillColor.rgb()!))
            self.pointAndColorArr.append(obj)
            
            if(self.isColorCompleted(colorObj: selectedColorWithNumber))
            {
                
                //MARK: For delay complete color info
                let indexPath = IndexPath(item: self.selectedIndex.item, section: 0)
                guard let cell = self.collectionColorView.cellForItem(at: indexPath) as? ChooseColorCollectionCell else {
                    
                    selectedColorWithNumber.isComplete = true
                    
                    if let indexVal =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                        sortedColorsOccurenceWithNumber[indexVal].isComplete = true
                        if sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).count > 0{ //  get all incompleted
                            let incompletedColors = sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).map({$0.number})
                            let maxValue = incompletedColors.max()
                            if selectedIndex.item == maxValue{ // last value is selected
                                selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                            }else{
                                if incompletedColors.filter({$0 - 1 > selectedIndex.item}).count > 0{ // get next value
                                    selectedIndex = NSIndexPath(item: incompletedColors.filter({$0 - 1 > selectedIndex.item}).min()! - 1, section: 0) as IndexPath
                                }else{
                                    selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                                }
                            }
                            selectedColorWithNumber = sortedColorsOccurenceWithNumber[selectedIndex.item]
                        }
                    }
                    
                    animationComplete = false
                    //MARK:  Show delay of Check Mark in color palette when last color is completed
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                        self.playSound(soundName: m3)
                        print("sound_m3")
                       // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
                          //  self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
                        }
                   // }
                    
                    if isDrawingComplete(){
                        didCompleteDrawing();
                    }
                    self.collectionColorView.reloadData()
                    self.collectionColorView.scrollToItem(at: self.selectedIndex, at: .left, animated: true)
                    
                    return
                }
                setProgressBarWithoutBomb()
                cell.colorCompleteImageView.image = UIImage(named:"color_complete")
                
                //MARK:  for color plate animation
                let viewTemp = loveBtn
                var frame2 = viewTemp?.frame
                let theAttributes:UICollectionViewLayoutAttributes! = collectionColorView.layoutAttributesForItem(at: indexPath)
                let cellFrameInSuperview:CGRect!  = collectionColorView.convert(theAttributes.frame, to: collectionColorView.superview)
                print("Y of Cell is: \(cellFrameInSuperview.origin.y)")
                frame2?.origin.y = cellFrameInSuperview.origin.y + 2.5
                frame2?.origin.x = cellFrameInSuperview.origin.x + cell.frame.width/2 - self.loveBtn!.frame.width/2
                viewTemp?.frame = frame2!
                viewTemp!.circleToColor = cell.colorView.backgroundColor!
                
                cell.colorView.backgroundColor = UIColor.white
                cell.colorView.layer.borderColor = UIColor.clear.cgColor
                cell.contentView.clipsToBounds = false
                self.loveBtn?.animateSelect(true, duration: 1.0)
                
                
                selectedColorWithNumber.isComplete = true
                if !isBombEnable {
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                        self.reloadPath()
                        self.collectionColorView.reloadData()
                    }
                }
                if let indexVal =  sortedColorsOccurenceWithNumber.index(where: { $0.key == fillColor }){
                    sortedColorsOccurenceWithNumber[indexVal].isComplete = true
                    if sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).count > 0{ //  get all incompleted
                        let incompletedColors = sortedColorsOccurenceWithNumber.filter({$0.isComplete == false}).map({$0.number})
                        let maxValue = incompletedColors.max()
                        if selectedIndex.item == maxValue{ // last value is selected
                            selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                        }else{
                            if incompletedColors.filter({$0 - 1 > selectedIndex.item}).count > 0{ // get next value
                                selectedIndex = NSIndexPath(item: incompletedColors.filter({$0 - 1 > selectedIndex.item}).min()! - 1, section: 0) as IndexPath
                            }else{
                                selectedIndex = NSIndexPath(item: incompletedColors.min()! - 1, section: 0) as IndexPath // get minimum value
                            }
                        }
                        selectedColorWithNumber = sortedColorsOccurenceWithNumber[selectedIndex.item]
                    }
                }
                animationComplete = false
                //MARK:  Show delay of Check Mark in color palette when last color is completed
                if !isBombEnable{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayCheckmark) {
                    self.playSound(soundName: m3)
                    print("sound_m3")
                    self.labelView?.image = self.getLabelsImage(selectedIndex: self.selectedIndex.item)
                    self.collectionColorView.scrollToItem(at: self.selectedIndex, at: .left, animated: true)
                    
                }
                }
            }
        }
        //print("val....: %d",self.isColorCompleted(colorObj: selectedColorWithNumber))
        //print("done-count: %d",pointAndColorArr.count+whiteColorLocations.count)
        //print("total-count: %d",totalVerticalGrids*totalHorizontalgrids)
        
        if isDrawingComplete(){
            didCompleteDrawing();
        }
        
        if(progressBar.isHidden == false){
            self.colorNumber =  self.colorNumber + 1
            // print("colorNumber\(self.colorNumber)")
            let percent = findPercentageDividation(count: self.colorNumber)
            self.progressBar.setProgress(to: percent, withAnimation: true)
        }
    }
    
    func doPaintFill(x: CGFloat, y: CGFloat, fillColor:UIColor) {
        
        // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) {
        self.addColorLayer(x: CGFloat(x), y: CGFloat(y), opacity: 1.0)
        //  }
        
        let point = CGPoint(x: x, y: y)
        //print("p-x: %d p-y: %d",x,y
        saveColorRecords(point: point, fillColor: fillColor)
    }
    
    func saveColorRecords(point: CGPoint, fillColor:UIColor) {
        
        let keyVal = keyForPoint(point: point)
        if (capturedPoints[keyVal] == nil){
            capturedPoints[keyVal] = 1
            
            let  obj = PointAndColor()
            obj.fillColor = fillColor
            obj.points = point
            
            if UI_USER_INTERFACE_IDIOM() == .pad{
                obj.coloringDevice = 2
            }
            else{
                obj.coloringDevice = 1
            }
            
            capturedColors.append(NSNumber(value:fillColor.rgb()!))
            self.pointAndColorArr.append(obj)
            
            if(progressBar.isHidden == false){
                self.colorNumber =  self.colorNumber + 1
                // print("colorNumber\(self.colorNumber)")
                let percent = findPercentageDividation(count: self.colorNumber)
                self.progressBar.setProgress(to: percent, withAnimation: true)
            }
        }
    }
    
    func isDrawingComplete() -> Bool {
        //4356
        if self.pointAndColorArr.count + whiteColorLocations.count >= totalHorizontalgrids*totalVerticalGrids
        {
            isComplete = true
        }
        else
        {
            isComplete = false
        }
        return isComplete
        
    }
    
    func didCompleteDrawing(){
        
        if isGoneVideoVC == false
        {
            if(!appDelegate.sessionImageArray.contains(imageName!)){
                
                // user completes 1 image in one session
                appDelegate.sessionImageArray.append(imageName!)
                if(appDelegate.sessionImageArray.count == 1){
                    appDelegate.logEvent(name: "completion_1", category: "Drawing", action: "complete  image one session")
                }else if(appDelegate.sessionImageArray.count == 2){
                    appDelegate.logEvent(name: "completion_2", category: "Drawing", action: "complete  image one session")
                }else if(appDelegate.sessionImageArray.count == 3){
                    appDelegate.logEvent(name: "completion_3", category: "Drawing", action: "complete  image one session")
                }else if(appDelegate.sessionImageArray.count == 4){
                    appDelegate.logEvent(name: "completion_4", category: "Drawing", action: "complete  image one session")
                }else if(appDelegate.sessionImageArray.count == 5){
                    appDelegate.logEvent(name: "completion_5", category: "Drawing", action: "complete  image one session")
                }
            }
            
            appDelegate.logEvent(name: "Drawing_complete", category: categoryString, action: imageName!)
            playButton.setImage(UIImage(named:"ok_completed"), for: UIControlState.normal)
            if(isGifTutorialCloseTapped == true)
            {
                appDelegate.logEvent(name: "Tutorial_Coloring", category: "Drawing", action: "Coloring tutorial image")
            }
            isJustCompleted = true
            isGoneVideoVC = true
            drawView.zoomScale = minimumScale
            self.perform(#selector(gotoNextView), with: nil, afterDelay: 0.1)
        }
    }
    
    @objc func gotoNextView(){
        drawView.zoomScale = minimumScale
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1){
            //self.playButtonClicked(self)
            
            self.playaction(t: 2.0)
        }
        
    }
    
    func fillCompleteImage(){
        autoreleasepool {
            for x in 0..<totalHorizontalgrids{
                for y in 0..<totalVerticalGrids{
                    fillColor(x: x, y: y, isHold: false)
                }
            }
        }
    }
     
    func prepareImageView(x: Double, y: Double, isWhiteImage: Bool) {
          //image for whiote color grid
          var yourImage: UIImage = UIImage(named: "canvas") ?? UIImage()
          if !isWhiteImage {
              //image for numbered grid
              yourImage = UIImage(named: "yarn") ?? UIImage()
          }
          let pixelBoxFrame = CGRect(x: x, y: y, width: squareWidth, height: squareWidth)
          // Create a UIImageView for the fillImage
          let imageView = UIImageView(frame: pixelBoxFrame)
          imageView.image = yourImage
          
          // Add the UIImageView to your view or pixel box container
          self.viewInDrawView!.addSubview(imageView)
          
      }
    
    func addColorLayer(x:CGFloat, y:CGFloat, opacity:Float){
        // Create a UIImage with your desired image
        let image = UIImage(named: "yarn")
       
        let imageLayer = CALayer()
        imageLayer.contents = image?.cgImage
        imageLayer.frame = CGRect(x: x, y: y, width: squareWidth, height: squareWidth)
       
        let rectanglePath = UIBezierPath(roundedRect: CGRect(x:x , y:y , width: squareWidth , height: squareWidth), cornerRadius: 0)
        let a = CAShapeLayer()
        a.path = rectanglePath.cgPath
        a.lineWidth = 0
        a.strokeColor = selectedColorWithNumber.key.cgColor
        a.fillColor = selectedColorWithNumber.key.cgColor
        a.opacity = opacity
        
        a.addSublayer(imageLayer)
        
        var atIndex = 1
        if isPaintEnable
        {
            if ((self.colorImageDrawView?.layer.sublayers?.count)  != nil)
            {
                if ((self.colorImageDrawView?.layer.sublayers?.count)!  > 1)
                {
                    atIndex = (self.colorImageDrawView?.layer.sublayers?.count)!
                }
            }
        }
        self.colorImageDrawView?.layer.insertSublayer(a, at: UInt32(atIndex))
    }
    
    func addColorForPath(rectanglePath:UIBezierPath, opacity:Float){
        // let rectanglePath = UIBezierPath(roundedRect: CGRect(x:x , y:y , width: squareWidth , height: squareWidth), cornerRadius: 0)
        let a = CAShapeLayer()
        a.path = rectanglePath.cgPath
        a.lineWidth = 0
        a.strokeColor = selectedColorWithNumber.key.cgColor
        a.fillColor = selectedColorWithNumber.key.cgColor
        a.opacity = opacity
        
        var atIndex = 1
        if isPaintEnable
        {
            if ((self.colorImageDrawView?.layer.sublayers?.count)  != nil)
            {
                if ((self.colorImageDrawView?.layer.sublayers?.count)!  > 1)
                {
                    atIndex = (self.colorImageDrawView?.layer.sublayers?.count)!
                }
            }
        }
        self.colorImageDrawView?.layer.insertSublayer(a, at: UInt32(atIndex))
    }
    
    func prefillColorLayer(pointAndColor: PointAndColor){
        autoreleasepool {
            let x = pointAndColor.points.x
            let y = pointAndColor.points.y
            let color = pointAndColor.fillColor
            
            let point = pointAndColor.points
            let keyVal = keyForPoint(point: point!)
            if (capturedPoints[keyVal] == nil){
                capturedPoints[keyVal] = 1
                capturedColors.append(NSNumber(value:(color?.rgb())!))
                //print("cp: %d",capturedPoints.count)
            }
            
            let rectanglePath = UIBezierPath(roundedRect: CGRect(x:x , y:y , width: squareWidth , height: squareWidth), cornerRadius: 0)
            let a = CAShapeLayer()
            a.path = rectanglePath.cgPath
            a.lineWidth = 0
            a.strokeColor = color?.cgColor
            a.fillColor = color?.cgColor
            a.opacity = 1.0
            self.colorImageDrawView?.layer.insertSublayer(a, at: 1)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first?.location(in: self.view) as Any)
        if let touch = touches.first{
            let touchLocation = touch.location(in: colorImageDrawView)
            print(touchLocation)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        print(touches.first?.location(in: self.view) as Any)
    }
    
    
    
    // MARK:- Scroll view delegates
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        view?.contentScaleFactor = scale
        
        if drawView.zoomScale <= minimumScale + 0.1{
            paintButton.isEnabled = false
            hintButton.isEnabled = false
            autoMoveButton.isEnabled = false
            //  Need to change 29 March shoaib
            self.viewInDrawView?.center = CGPoint(x:self.view.center.x, y:self.view.center.y - 70)
            UIView.animate(withDuration: 0.5, animations: {
                self.viewInDrawView?.layoutIfNeeded()
            })
        }
        else
        {
            if(selectedIndex.item != -1)
            {
                
                paintButton.isEnabled = true
                hintButton.isEnabled = true
                autoMoveButton.isEnabled = true
                
            }
            
        }
        if drawView.zoomScale <= minimumScale + 0.1{
            tapGesture.removeTarget(self, action: #selector(didTouch(touchRecognizer:)))
            tapGesture.numberOfTapsRequired = 2
            tapGesture.addTarget(self, action: #selector(doubleTap(touchRecognizer:)))
        }
        else if drawView.zoomScale >= (maximumScale - minimumScale)/4 {
            tapGesture.removeTarget(self, action: #selector(doubleTap(touchRecognizer:)))
            tapGesture.numberOfTapsRequired = 1
            tapGesture.addTarget(self, action: #selector(didTouch(touchRecognizer:)))
        }
        
        
        
    }
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return viewInDrawView
    }
    // update zoom
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        var zoomScale =  ((scrollView.zoomScale - minimumScale) < 0 ? 0:(scrollView.zoomScale - minimumScale))
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            print("minimumScale")
            print(minimumScale)
            if(scrollView.zoomScale >= singleTapScale)//singleTapScale)
            {
                zoomScale = 1.363
            }
        }
        if(CGFloat(zoomScale) > 0){
            if(zoomScale > 1){
                labelView?.alpha = CGFloat(zoomScale)
            }else{
                labelView?.alpha =  CGFloat(1.0 + zoomScale)}
        }else{
            labelView?.alpha = CGFloat(zoomScale)
        }
        grayImageView?.alpha = CGFloat(1.0 - 2*zoomScale)
        self.playButton?.alpha = CGFloat(1.0 - 2*zoomScale)
        self.backButton?.alpha = CGFloat(1.0 - 2*zoomScale)
        
        let offsetX = max((drawView?.contentSize.width)! * 0.5, self.view.center.x );
        let offsetY = max((drawView?.contentSize.height)! * 0.5, self.view.center.y - imageOffsetYAxis);
        viewInDrawView?.center = CGPoint(x:offsetX  , y:  offsetY)
        
    }
    
    func eraseColor() -> ColorWithNumber
    {
        var colorVal = ColorWithNumber()
        colorVal.key = UIColor.white
        colorVal.number = 0
        colorVal.value = 0
        
        return colorVal
    }
    
    //MARK: - Collection View Delegates and Datasource
    //Task 283
    //    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    //            return 5
    //        }
    //
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return sortedColorsOccurenceWithNumber.count//To Do Devendra//Add 1 count for eraser
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ChooseColorCollectionCell", for: indexPath) as! ChooseColorCollectionCell
        cell.contentView.clipsToBounds = true
        cell.colorCompleteImageView.image = UIImage(named:"color_complete")
        let color = sortedColorsOccurenceWithNumber[indexPath.item].key
        cell.colorCompleteImageView.isHidden = !sortedColorsOccurenceWithNumber[indexPath.item].isComplete
        
        if(selectedIndex.item != -1)
        {
            hintButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
            paintButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
            //autoMoveButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
        }
        
        if(drawView.zoomScale <= minimumScale + 0.1)
        {
            hintButton.isEnabled = false
            paintButton.isEnabled = false
            autoMoveButton.isEnabled = false
        }
        
        cell.colorView.backgroundColor = color
        
        
        cell.colorProgressBar.layer.cornerRadius = cell.colorProgressBar.frame.size.height / 2
        
        let colorValue = sortedColorsOccurenceWithNumber[indexPath.item].key //color
        
        cell.number.text = "\(sortedColorsOccurenceWithNumber[indexPath.item].number)"
        
       
        var grayscale: CGFloat = 0
        var alpha: CGFloat = 0
        if color.getWhite(&grayscale, alpha: &alpha) {
            if grayscale >= 0 && grayscale <= 0.5{
                grayscale = 1
            }
            else if grayscale >= 0.5 && grayscale <= 1{
                grayscale = 0
            }
            else{
                grayscale =  1 - grayscale
            }
            let grayscaleColor = UIColor(white: grayscale, alpha: alpha)
            cell.number.textColor = grayscaleColor
        }
        
        for constraint in cell.colorProgressBar.constraints {
            if constraint.identifier == "progressBarHeightConstraint" || constraint.identifier == "progressBarWidthConstraint"{
                if UIDevice.current.userInterfaceIdiom == .phone {
                    constraint.constant = 50
                } else if UIDevice.current.userInterfaceIdiom == .pad {
                    constraint.constant = 60
                }
            }
        }
        cell.colorProgressBar.layoutIfNeeded()
//
        let totalColorCount = Double(sortedColorsOccurenceWithNumber[indexPath.item].value)
        let filledColorCount = Double(self.getFilledColorCount(colorObj: sortedColorsOccurenceWithNumber[indexPath.item]))

        let progress = Double(filledColorCount / totalColorCount)
        print("filledColorCount: \(filledColorCount), totalColorCount: \(totalColorCount), progress: \(progress)")

        let progressBeckgroundColor = color.lighter() ?? UIColor()
        cell.colorProgressBar.lineBackgroundColor = progressBeckgroundColor
       // if !cell.colorProgressBar.isProgressBarMade{
//            var grayscale: CGFloat = 0
//            var alpha: CGFloat = 0
//            if color.getWhite(&grayscale, alpha: &alpha) {
//                if grayscale >= 0 && grayscale <= 0.5{
//                    grayscale = 1
//                }
//                else if grayscale >= 0.5 && grayscale <= 1{
//                    grayscale = 0
//                }
//                else{
//                    grayscale =  1 - grayscale
//                }
                let grayscaleColor = UIColor(white: grayscale, alpha: alpha)
                if grayscaleColor == UIColor.black {
                    cell.colorProgressBar.lineColor = .gray
                }
                else {
                    cell.colorProgressBar.lineColor = .white
                }
//            }
           
            cell.colorProgressBar.makeBar()
            cell.colorProgressBar.isProgressBarMade = true
       // }
        
        
        if indexPath == selectedIndex{
            if sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete == false {
                cell.colorView.layer.borderColor = color.cgColor
                cell.colorView.layer.borderWidth = 4.0
                cell.colorProgressBar.isHidden = false

                cell.colorProgressBar.setProgress(to: filledColorCount / totalColorCount, withAnimation: true)
            }
            else {
                cell.colorView.layer.borderColor = UIColor.clear.cgColor
            }
        }
        else{
            cell.colorView.layer.borderColor = UIColor.clear.cgColor
            cell.colorProgressBar.isHidden = true
        }
     
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        //print("\nColor choosed --> :\(indexPath.item + 1) : \(sortedColorsOccurenceWithNumber[indexPath.item])")
        playSound(soundName: m1)
        print("sound_m1")
        self.zommInButoon(button: eraseButton)
        self.zommInButoon(button: eraseButton)
//        self.zommInButoon(button: hintButton)
        self.roundedbuttonSet(button: eraseButton)
        selectedColorWithNumber = sortedColorsOccurenceWithNumber[indexPath.item]
        //        labelView?.grayoutNumber = sortedColorsOccurenceWithNumber[indexPath.item].number
        //TO DO
        if selectedIndex != indexPath{
            selectedIndex = indexPath
            DispatchQueue.main.async {
                self.collectionColorView.reloadData()
            }
        }
        
        //self.collectionColorView.scrollToItem(at: indexPath, at: .left, animated: true)
       // DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.001) {
            self.labelView?.image = self.getLabelsImage(selectedIndex: indexPath.item)
      //  }
        
        if(selectedIndex.item != -1)
        {
            paintButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
            hintButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
            autoMoveButton.isEnabled = !sortedColorsOccurenceWithNumber[selectedIndex.item].isComplete
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsetsMake(0, 0, 0, 1 * UIScreen.main.scale)
        } else {
            return UIEdgeInsets.zero
        }
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if self.sortedColorsOccurenceWithNumber[indexPath.item].isComplete == true{
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                return CGSize(width: 0 , height: 50)
            }else{
                return CGSize(width: 0 , height: 40)
            }
        }
        
        if indexPath == selectedIndex{
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                return CGSize(width: 70 , height: 65)
            }else{
                return CGSize(width: 60 , height: 55)
            }
        }
        else{
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                return CGSize(width: 55 , height: 50)
            }else{
                return CGSize(width: 45 , height: 40)
            }
        }
    }
    
    @available(iOS 9.0, *)
    func collectionView(_ collectionView: UICollectionView, shouldUpdateFocusIn context: UICollectionViewFocusUpdateContext) -> Bool {
        return true
    }
    
    func playaction(t:Any)
    {
        if imageName != nil {
            appDelegate.logEvent(name: "Drawing_video_1", category: "Drawing", action: imageName!)
        }
        drawView.zoomScale = minimumScale
        self.perform(#selector(playerScreen), with: nil, afterDelay: t as! TimeInterval)
    }
    
    //MARK: Play Sound
    func playSound(soundName:String) {
        
        if UserDefaults.standard.bool(forKey: isSoundEnabled){
            guard let audioData = NSDataAsset(name: soundName)?.data else {
                fatalError(assestError)
            }
            do {
                if !isBombEnable{
                    playerLongTap = try AVAudioPlayer(data: audioData)
                    playerLongTap.delegate = self
                    playerLongTap.play()
                } else{
                    player = try AVAudioPlayer(data: audioData)
                    player.delegate = self
                    player.play()
                }
                
            } catch {
                fatalError(error.localizedDescription)
            }
        }else{
            print("Sound has been Muted")
        }
    }
    
    //MARK: Last color complete Sound
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        player.delegate = nil
        if animationComplete {
            
            playSound(soundName: m3)
            animationComplete = false
            print("sound_m3")
        }
        
    }
    //MARK:- Button actions
    @IBAction func playButtonClicked(_ sender: Any) {
        
        if(isGifTutorialCloseTapped){
            
            if(self.isDrawingComplete())
            {
                if imageName != nil {
                    appDelegate.logEvent(name: "Drawing_video_click", category: "Drawing", action: imageName!)
                }
                self.playaction(t: 0.01)
            }
            
        }else{
            if imageName != nil {
                appDelegate.logEvent(name: "Drawing_video_click", category: "Drawing", action: imageName!)
            }
            self.playaction(t: 0.01)
        }
        
        print("[---- Drawing Screen Exit ----]")
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        
        self.stopTimer()
        isRemovingMemoryInstance = true
        print("[---- Drawing Screen Exit ----]")
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func playerScreen() {
        
        self.stopTimer()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "PlayVideoVC") as! PlayVideoVC
        let imageSet = grayImageView?.image?.changeImageOposity(0.2)
        if grayImageView != nil{
            let imagesetView = UIImageView(image: imageSet!)
            imagesetView.frame = CGRect(x: (grayImageView?.frame.origin.x)!, y: (grayImageView?.frame.origin.y)!, width: (grayImageView?.frame.size.width)!, height: (grayImageView?.frame.size.height)!)
            viewInDrawView?.insertSubview(imagesetView, belowSubview: grayImageView!)
            let cView = imagesetView.snapshotView(afterScreenUpdates: true)
            vc.capturedView2 = cView
            vc.capturedViewRecording2 = cView
            vc.pointAndColorArrayRecording = self.pointAndColorArr
            //To Do Shoaib
            vc.countArray = self.pointAndColorArr
            vc.squareWidth = squareWidth
            vc.pointAndColorArray = self.pointAndColorArr
            //To Do Shoaib
            vc.countArray = self.pointAndColorArr
            vc.scale = minimumScale
            vc.isComplete = self.isComplete
            vc.isJustCompleted = self.isJustCompleted
            vc.imageData = self.imageData
            vc.sizeOfImage = totalHorizontalgrids
            //Create the UIImage
            UIGraphicsBeginImageContext(imagesetView.frame.size)
            imagesetView.layer.render(in: UIGraphicsGetCurrentContext()!)
            vc.backImg = UIGraphicsGetImageFromCurrentImageContext()!
            UIGraphicsEndImageContext()
            UIGraphicsEndImageContext()
            //UIGraphicsEndImageContext()
            //UIGraphicsEndImageContext()
            imagesetView.removeFromSuperview()
        }
        vc.isGifTutorialImage = isGifTutorialCloseTapped
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - ViewDid DisAppear
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    //self.removeReminderView()  // Shoaib
    override func viewWillDisappear(_ animated: Bool) {
        // complete checkmark
        isFromHomeView = false
        
        self.saveThumbnailAndPointsColor()
        
        if self.isComplete
        {
            var arrayCompleted = getCompletedImagesIDArray()
            if !arrayCompleted.contains(self.imageId!)
            {
                arrayCompleted.append(self.imageId!)
                saveCompletedImagesIDArray(array: arrayCompleted)
            }
        }
        if self.isJustCompleted
        {
            //Reset Timer - TODO
            // the image used for tutorial should NOT be counted towards completions for displaying Review, Reward windows -- TODO
            if(self.isGifTutorialCloseTapped == false)
            {
                
                UserDefaults.standard.set("yes", forKey: "is_first_image_completed")
                UserDefaults.standard.synchronize()
            }
        }
        if isRemovingMemoryInstance == true{
            self.releaseMemory()
        }
        super.viewWillDisappear(animated)
    }
    
    
    @objc func releaseMemory() {
    
        print("REMOVING")
        
        //Clear observer
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationDidEnterBackground)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIDeviceOrientationDidChange)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: SCROLL_OBSERVER))
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationWillResignActive)
        NotificationCenter.default.removeObserver(NSNotification.Name(rawValue: RELEASE_MEMORY))
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationWillEnterForeground)
        NotificationCenter.default.removeObserver(NSNotification.Name.UIApplicationDidEnterBackground)
        
        //Removing All values
        
        grayImageView =  nil
        labelImageView =  nil
        viewInDrawView =  nil
        widthInPixels = CGFloat()
        heightInPixels = CGFloat()
        grayScaleColors = [[UIColor]]()
        imageColors = [[UIColor]]()
        uniqueColorsArray = [UIColor]()
        totalHorizontalgrids = Int()
        totalVerticalGrids = Int()
        cellWidth = CGFloat()
        //squareWidth:CGFloat = 8.0
        imageDrawView =  nil
        pixelSquareWidth = CGFloat()
        pixelSquareHeight = CGFloat()
        //gridSeperatorWidth:Int = 2
        //colorsOccurence: [UIColor: Int] = [:]
        sortedColorsOccurenceWithNumber  = [ColorWithNumber]()
        selectedColorWithNumber = ColorWithNumber()
        //imageOffsetYAxis:CGFloat = 40.0
        ///selectedIndex = IndexPath(item: 0, section: 0)
        colorImageDrawView =  nil
        //pointLayerMap = NSMutableDictionary()
        keyArray = [String]()
        indexArray = [Int]()
        imageName =  nil
        keyName =  nil
        //whiteColorLocations:[CGPoint] = []
        lastXDistance = Int()
        lastYDistance = Int()
        //minimumScale:CGFloat = 0.2
        //maximumScale:CGFloat = 1.5
        capturedPoints = [String:Int]()
        capturedColors = [NSNumber]()
        occupiedPointsBasedonColorOder = [[(Int,Int)]]()
        occupiedPointsUsedForPaintFeatureBasedonColorOder = [[CGPoint]]()
        occupiedPointsIndexArray = [[String:Int]]()
        //pointsAndColorTouple : [(CGPoint, UIColor)] = []
        labelArray = [[(String,UIColor,CGFloat)]]()
        screenWidth = CGFloat()
        screenHeight = CGFloat()
        imageId = nil
        myWorkImageName = nil
        pointAndColorArr = [PointAndColor]()
        imageData = ImageData()
        actualCellWidth = CGFloat()
        totalBlocks = Int()
        isComplete = false
        prevX = nil
        prevY = nil
        selectedColor = nil
        textFontAttributes = nil
        textFontAttributes2 = nil
        lblText = nil
        isPaintEnable = false
        processedPoints = [String:Int]()
        coloredPoints = [CGPoint]()
        isGoneVideoVC = false
        tipsView = nil
        clikcedType = nil
        
        drawView?.zoomScale = CGFloat(0)
        labelView?.image = nil
        imageDrawView?.image = nil
        
        colorImageDrawView = nil
        grayImageView?.removeFromSuperview()
        imageDrawView?.removeFromSuperview()
        drawView?.removeFromSuperview()
        
        grayImageView?.image = nil
    }
    
    //MARK:- Change selected category index
    @objc func saveThumbnailAndPointsColorTest(notification: NSNotification) {
        // self.stopTimer()
        self.saveThumbnailAndPointsColor(isBackground: true)
    }
    //MARK:- SAVE THUMBANAIL AND POINTS & COLOR ARRAY
    @objc func saveThumbnailAndPointsColor(isBackground:Bool = false)
    {
        print("SAVING POINTS COLOR")
        if(!self.isSomethingWrong){
            drawView?.zoomScale = minimumScale
            //            if #available(iOS 13.0, *) {
            //                if(isBackground == true){
            //                    let defaults = UserDefaults.standard
            //                    let data = NSKeyedArchiver.archivedData(withRootObject: self.pointAndColorArr)
            //                    defaults.set(data, forKey: "pointAndColorArr")
            //                    defaults.set(self.imageId, forKey: "imageId")
            //                    defaults.synchronize()
            //                }
            //            }
            self.perform(#selector(self.screenShotMethod), on: Thread.main, with: nil, waitUntilDone: true)
            
            //            DispatchQueue.main.async {
            //                self.screenShotMethod()
            //            }
            
            if self.pointAndColorArr.count > 0 {
                if #available(iOS 10.0, *) {
                    DBHelper.sharedInstance.updateTuple(imageId: self.imageId!, pointColorTuple: self.pointAndColorArr, imageName: self.imageName!, isCallFromHome: true)
                    
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
    //These Added by Devendra To Do
    @IBAction func eraseButtonClicked(_ sender: Any)
    {
        appDelegate.logEvent(name: "Eraser", category: "Drawing", action: imageName!)
        //        self.zommInButoon(button: paintButton)
        //        self.zommInButoon(button: hintButton)
        self.zommInButoon(button: autoMoveButton)
        self.zoomButton(button: eraseButton)
        self.roundedbuttonWithBorderSet(button: eraseButton)
        self.roundedbuttonSet(button: paintButton)
        self.roundedbuttonSet(button: hintButton)
        self.roundedbuttonSet(button: autoMoveButton)
        selectedColorWithNumber = eraseColor()
        selectedIndex = IndexPath(item: -1, section: 0)
        //isPaintEnable = false
        isAutoMoveEnable = false
        self.collectionColorView.reloadData()
        paintButton.isEnabled = false
        hintButton.isEnabled = false
        autoMoveButton.isEnabled = false
        self.labelView?.image = self.getLabelsImage(selectedIndex: -1)
    }
    
    @IBAction func paintButtonClicked(_ sender: Any)
    {
        
        self.saveActionCount(paintCountLabel)
        if imageName != nil {
            appDelegate.logEvent(name: "Paint_Buckets", category: "Drawing", action: imageName!)
        }
        appDelegate.logEvent(name: "Drawing_video", category: "Drawing", action: "Paint Button")
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        let paintCount =  UserDefaults.standard.integer(forKey: paint_count)
        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable) || (paintCount > 0))
        {
            if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
            {
                self.showLabelWithCount(lbl: paintCountLabel , count: 0)
            }
            else
            {
                self.showLabelWithCount(lbl: paintCountLabel  , count: paintCount)
            }
            /*isAutoMoveEnable = false
             if(isPaintEnable == false)
             {
             if UIDevice.current.userInterfaceIdiom == .pad{
             self.paintButton.setImage(UIImage(named: "coloredBucketiPad"), for: .normal)
             }else{
             self.paintButton.setImage(UIImage(named: "coloredBucketiPhone"), for: .normal)
             }
             self.hintButton.setImage(UIImage(named: "hint"), for: .normal)
             self.autoMoveButton.setImage(UIImage(named: "paintpicker"), for: .normal)
             self.zommInButoon(button: eraseButton)
             self.zommInButoon(button: hintButton)
             self.zommInButoon(button: autoMoveButton)
             self.roundedbuttonSet(button: eraseButton)
             self.roundedbuttonSet(button: hintButton)
             self.roundedbuttonSet(button: autoMoveButton)
             self.zoomButton(button: paintButton)
             isPaintEnable = true
             }
             else
             {
             self.paintButton.setImage(UIImage(named: "paintbucket"), for: .normal)
             self.zommInButoon(button: eraseButton)
             self.zommInButoon(button: hintButton)
             self.zommInButoon(button: paintButton)
             self.zommInButoon(button: autoMoveButton)
             self.roundedbuttonSet(button: paintButton)
             isPaintEnable = false
             }*/
        }
        else
        {
            
            self.showLabelWithCount(lbl: paintCountLabel , count: 0)
            clikcedType = 2
            //self.checkViewType(type: .kViewTypePaint)
            
            //            if self.isInternetAvailable()
            //            {
            //                self.checkViewType(type: .kViewTypePaint)
            //            }
            //            else
            //            {
            //                self.checkViewType(type: .kViewTypeNoInternet)
            //            }
        }
        
        isAutoMoveEnable = false
        if(isPaintEnable == false)
        {
            if UIDevice.current.userInterfaceIdiom == .pad{
                self.paintButton.setImage(UIImage(named: "coloredBucketiPad"), for: .normal)
            }else{
                self.paintButton.setImage(UIImage(named: "coloredBucketiPhone"), for: .normal)
            }
            self.hintButton.setImage(UIImage(named: "hint"), for: .normal)
            self.autoMoveButton.setImage(UIImage(named: "paintpicker"), for: .normal)
            //            self.zommInButoon(button: eraseButton)
            //            self.zommInButoon(button: hintButton)
            self.zommInButoon(button: autoMoveButton)
            self.roundedbuttonSet(button: eraseButton)
            self.roundedbuttonSet(button: hintButton)
            self.roundedbuttonSet(button: autoMoveButton)
            self.zoomButton(button: paintButton)
            isPaintEnable = true
        }
        else
        {
            self.paintButton.setImage(UIImage(named: "paintbucket"), for: .normal)
            //            self.zommInButoon(button: eraseButton)
            //            self.zommInButoon(button: hintButton)
            self.zommInButoon(button: paintButton)
            self.zommInButoon(button: autoMoveButton)
            self.roundedbuttonSet(button: paintButton)
            
            if #available(iOS 13.0, *) {
                //Do nothing
            }
            else{
                var frame = paintButton.frame
                frame.size.height = 43
                frame.size.width = 43
                paintButton.frame = frame
            }
            isPaintEnable = false
            
            let paintCount =  UserDefaults.standard.integer(forKey: paint_count)
            if paintCount == 0 {
                purchaseItemSelectedType = .none
            }
            
            if purchaseItemSelectedType == .bucket {
                purchaseItemSelectedType = .none
                setPaintButton()
            }
            
        }
    }
    
    func getPaintType() -> PaintType
    {
        if(isBombEnable){
            return .kPaintTypeNone
        }
        if(isPaintEnable)
        {
            let paintCount =  UserDefaults.standard.integer(forKey: paint_count)
            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
            if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
            {
                return .kPaintEnablePointsAvailable
            }
            else if(paintCount > 0)
            {
                return .kPaintEnablePointsAvailable
            }
            return .kPaintEnableNoPointsAvailable
        }
        else
        {
            return .kPaintTypeNone
        }
    }
    
    @IBAction func hintButtonClicked(_ sender: Any)
    {
        self.saveActionCount(hintCountLabel)
        appDelegate.logEvent(name: "Hints", category: "Drawing", action: imageName!)
        appDelegate.logEvent(name: "Drawing_video", category: "Drawing", action: "Hint Button")
        //        self.zommInButoon(button: eraseButton)
        //        self.zommInButoon(button: paintButton)
        self.zommInButoon(button: autoMoveButton)
        self.roundedbuttonSet(button: eraseButton)
        //self.roundedbuttonSet(button: paintButton)//Lekha Added
        self.roundedbuttonSet(button: autoMoveButton)
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.hintButton.setImage(UIImage(named: "coloredhintIpad"), for: .normal)
        }else{
            self.hintButton.setImage(UIImage(named: "coloredHintIphone"), for: .normal)
        }
        // self.paintButton.setImage(UIImage(named: "paintbucket"), for: .normal)
        self.autoMoveButton.setImage(UIImage(named: "paintpicker"), for: .normal)
        
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        let hintCount =  UserDefaults.standard.integer(forKey: hint_count)
        let giftHintCountValue =  UserDefaults.standard.integer(forKey: giftHintCount)
        //        if hintCount <= 1{
        //            self.hintButton.setImage(UIImage(named: "hint"), for: .normal)
        //        }
        
        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable) || (hintCount+giftHintCountValue > 0))
        {
            if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
            {
                self.showLabelWithCount(lbl: hintCountLabel  , count: 0)
            }
            else
            {
                if giftHintCountValue != 0 {
                    UserDefaults.standard.set(giftHintCountValue-1, forKey: giftHintCount)
                }
                else {
                    UserDefaults.standard.set(hintCount-1, forKey: hint_count)
                }
                let countValue = UserDefaults.standard.integer(forKey: self.hint_count) + UserDefaults.standard.integer(forKey: self.giftHintCount)
                UserDefaults.standard.synchronize()
                self.showLabelWithCount(lbl: hintCountLabel  , count: countValue)
                if hintCount <= 1{
                    self.hintButton.setImage(UIImage(named: "hint"), for: .normal)
                }
            }
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations:
                            {
                var frame = self.hintButton.frame
                frame.size.height = 32
                frame.size.width = 32
                self.hintButton.frame = frame
                
            }, completion: { (finished: Bool) in
                
                UIView.animate(withDuration: 0.2, delay:0.01, animations: {
                    var frame = self.hintButton.frame
                    frame.size.height = 40
                    frame.size.width = 40
                    self.hintButton.frame = frame
                })//
                
            })
            
            //isPaintEnable = false //Lekha Added
            isAutoMoveEnable = false
            
            if(selectedIndex.item != -1)
            {
                var selectIndexVal = 0
                let pointArray = occupiedPointsUsedForPaintFeatureBasedonColorOder[selectedIndex.item]
                let width = drawView.contentSize.width/CGFloat(totalHorizontalgrids)
                
                for t in 0..<pointArray.count{
                    let point = pointArray[t]
                    
                    let keyVal = keyForPoint(point: point)
                    if (capturedPoints[keyVal] == nil)
                    {
                        selectIndexVal = t
                        break;
                    }
                }
                var x = (pointArray[selectIndexVal].x/squareWidth) * width
                
                if x != 0
                {
                    x = x-1
                }
                var y = (pointArray[selectIndexVal].y/squareWidth) * width
                if y != 0
                {
                    y = y-1
                }
                
                //                var pt = CGPoint(x:x, y:y)
                let pt = CGPoint(x:x+pixelSquareWidth/2.0, y:y+pixelSquareWidth/2.0)
                
                drawView.scrollRectToVisible(CGRect(x: pt.x - drawView.frame.width/2.0 , y: pt.y - drawView.frame.height/2.0, width: drawView.frame.width, height: drawView.frame.height), animated: true)
                
            }
        }
        else
        {
            self.showLabelWithCount(lbl: hintCountLabel , count: 0)
            clikcedType = 1
            self.checkViewType(type: .kViewTypeHint)
            //            if self.isInternetAvailable()
            //            {
            //                 self.checkViewType(type: .kViewTypeHint)
            //            }
            //            else
            //            {
            //                self.checkViewType(type: .kViewTypeNoInternet)
            //            }
        }
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.2){
            self.hintButton.setImage(UIImage(named: "hint"), for: .normal)
        }
    }
    
    
    //MARK:- Auto Move Button Clicked Action
    @IBAction func autoMoveButtonClicked(_ sender: Any)
    {
        self.saveActionCount(autoMoveCountLabel)
        self.zommInButoon(button: eraseButton)
        self.zommInButoon(button: paintButton)
        self.zommInButoon(button: autoMoveButton)
        self.roundedbuttonSet(button: eraseButton)
        //self.roundedbuttonSet(button: paintButton)
        self.roundedbuttonSet(button: autoMoveButton)
        
        appDelegate.logEvent(name: "Paint_Picker", category: "Drawing", action: imageName!)
        appDelegate.logEvent(name: "Drawing_video", category: "Drawing", action: "Auto Move Button")
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        let autoMoveCount =  UserDefaults.standard.integer(forKey: autoMove_count)
        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable) || (autoMoveCount > 0))
        {
            if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
            {
                self.showLabelWithCount(lbl: autoMoveCountLabel , count: 0)
            }
            else
            {
                self.showLabelWithCount(lbl: autoMoveCountLabel  , count: autoMoveCount)
            }
            //isPaintEnable = false
            UIView.animate(withDuration: 0.2, delay: 0.0, options: [], animations:
                            {
                var frame = self.autoMoveButton.frame
                frame.size.height = 32
                frame.size.width = 32
                self.autoMoveButton.frame = frame
                
            }, completion: { (finished: Bool) in
                
                UIView.animate(withDuration: 0.2, delay:0.01, animations: {
                    var frame = self.autoMoveButton.frame
                    frame.size.height = 30
                    frame.size.width = 30
                    self.autoMoveButton.frame = frame
                })//
                
            })
            
            if(isAutoMoveEnable == false)
            {
                if UIDevice.current.userInterfaceIdiom == .pad{
                    self.autoMoveButton.setImage(UIImage(named: "coloredPickerIpad"), for: .normal)
                }else{
                    self.autoMoveButton.setImage(UIImage(named: "coloredPickerIphone"), for: .normal)
                }
                //self.paintButton.setImage(UIImage(named: "paintbucket"), for: .normal)
                self.hintButton.setImage(UIImage(named: "hint"), for: .normal)
                self.zommInButoon(button: eraseButton)
                self.zommInButoon(button: hintButton)
                self.zommInButoon(button: paintButton)
                //self.roundedbuttonWithBorderSet(button: autoMoveButton)
                self.roundedbuttonSet(button: eraseButton)
                self.roundedbuttonSet(button: hintButton)
                self.roundedbuttonSet(button: paintButton)
                self.zoomButton(button: autoMoveButton)
                isAutoMoveEnable = true
            }
            else
            {
                self.autoMoveButton.setImage(UIImage(named: "paintpicker"), for: .normal)
                self.zommInButoon(button: eraseButton)
                self.zommInButoon(button: hintButton)
                self.zommInButoon(button: paintButton)
                self.zommInButoon(button: autoMoveButton)
                self.roundedbuttonSet(button: autoMoveButton)
                isAutoMoveEnable = false
            }
            
        }
        else
        {
            clikcedType = 3
            self.showLabelWithCount(lbl: autoMoveCountLabel , count: 0)
            self.checkViewType(type: .kViewTypeAutoMove)
        }
    }
    
    
    func roundedbuttonSet(button: UIButton)
    {
        button.clipsToBounds = true
        button.layer.cornerRadius = 2
        button.layer.borderColor = UIColor.clear.cgColor
        button.layer.borderWidth = 0.0
    }
    
    func roundedbuttonWithBorderSet(button: UIButton)
    {
        button.clipsToBounds = true
        button.layer.cornerRadius = 4
        button.layer.borderWidth = 2.0
        if(button == self.eraseButton)
        {
            button.layer.cornerRadius = 9
            button.layer.borderWidth = 3.0
        }
        button.layer.borderColor = UIColor(red: 74.0/255.0, green: 160.0/255.0, blue: 221.0/255.0, alpha: 1).cgColor
    }
    
    func zoomButton(button: UIButton)
    {
        UIView.animate(withDuration: 0.5, delay:0.01, animations: {
            var frame = button.frame
            //            frame.origin.x = 14
            //            if button == self.paintButton{
            //                frame.origin.x = 23.5
            //            }
            //            else if button == self.hintButton
            //            {
            //                frame.origin.x = 14.5
            //            }
            //            else if button == self.autoMoveButton
            //            {
            //                frame.origin.x = 14.5
            //            }
            frame.size.height = 33
            frame.size.width = 33
            button.frame = frame
        })//
    }
    
    func zommInButoon(button: UIButton)
    {
        UIView.animate(withDuration: 0.5, delay:0.01, animations: {
            var frame = button.frame
            //            frame.origin.x = 14
            //            if button == self.paintButton{
            //                frame.origin.x = 26.5
            //            }
            //            if button == self.hintButton
            //            {
            //                frame.origin.x = button.frame.origin.x
            //            }
            //            else if button == self.autoMoveButton
            //            {
            //                frame.origin.x = 14.5
            //            }
            
            if (UIDevice.current.userInterfaceIdiom == .pad)
            {
                frame.size.height = 40
                frame.size.width = 40
            }
            else
            {
                
                
                frame.size.height = 30
                frame.size.width = 30
                button.frame = frame
                
            }
        })//
    }
    
    
    func zommInButoonForIPD(button: UIButton)
    {
        var frame = button.frame
        frame.size.height = 35
        frame.size.width = 35
        button.frame = frame
    }
    fileprivate func saveActionCount(_ lbl: UILabel) {
        if(paintCountLabel == lbl)
        {
            let paintCount = UserDefaults.standard.integer(forKey: PAINTCOUNT)
            UserDefaults.standard.set(paintCount + 1, forKey: PAINTCOUNT)
            return
        }
        else if(autoMoveCountLabel == lbl)
        {
            let autoCount = UserDefaults.standard.integer(forKey: AUTOMOVECOUNT)
            UserDefaults.standard.set(autoCount + 1, forKey: AUTOMOVECOUNT)
            return
        }
        else if(hintCountLabel == lbl)
        {
            let hintCount = UserDefaults.standard.integer(forKey: HINTCOUNT)
            UserDefaults.standard.set(hintCount + 1, forKey: HINTCOUNT)
            return
        }
    }
    
    func showLabelWithCount(lbl: UILabel, count:Int)
    {
        if (lbl == self.paintCountLabel && count > 0 && paintButton.isEnabled)
        {
            appDelegate.logEvent(name: "Paint_Buckets", category: "Drawing", action: "Paint Button")
        }
        if count <= 0
        {
            lbl.isHidden = true
        }
        else
        {
            let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
            if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
            {
                lbl.isHidden = true
                useToolArray.removeAll()
            }
            else
            {
                lbl.clipsToBounds = true
                lbl.layer.cornerRadius = lbl.frame.size.width/2
                lbl.backgroundColor = UIColor.red
                lbl.textColor = UIColor.white
                lbl.text = "\(count)"
                lbl.isHidden = false
            }
        }
        
        // Reminder UI Add used tool in useToolArray //
        if(useToolArray.count > 0)
        {
            var  toolCount = 0
            if(paintCountLabel == lbl)
            {
                toolCount =  useToolArray["paintCount"] as! Int
                useToolArray.updateValue(toolCount + 1, forKey: "paintCount")
            }
            else if(autoMoveCountLabel == lbl)
            {
                toolCount =  useToolArray["autoFillCount"] as! Int
                useToolArray.updateValue(toolCount + 1, forKey: "autoFillCount")
            }
            else if(hintCountLabel == lbl)
            {
                
                toolCount =  useToolArray["hintCount"] as! Int
                useToolArray.updateValue(toolCount + 1, forKey: "hintCount")
            }
        }
        
        if(autoMoveCountLabel == lbl)
        {
            lbl.isHidden = true
            autoMoveButton.isHidden = true
        }
        
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
    
    
    //MARK:- Show View With Its Type
    func checkViewType(type: ViewType)
    {
        switch type {
        case .kViewTypeNoInternet:
            print("NO INTERNET")
            self.appDelegate.logEvent(name: "No_Internet_tools", category: "No_Internet", action: "Show_Ads")
            self.addTipsView(type: 0)
            break;
        case .kViewTypeHint:
            print("HINT")
            if(isNeedToShowTipWithPurchase == false){
                self.appDelegate.logEvent(name: "HintWindow", category: "Tools", action: imageName!)
                self.appDelegate.logEvent(name: "ToolWindow", category: "Tools", action: "hint")
            }
            self.addTipsView(type: 1)
            break;
        case .kViewTypePaint:
            print("PAINT")
            if(isNeedToShowTipWithPurchase == false){
                self.appDelegate.logEvent(name: "PaintBucketWindow", category: "Tools", action: imageName!)
                self.appDelegate.logEvent(name: "ToolWindow", category: "Tools", action: "paintbucket")
            }
            self.addTipsView(type: 2)
        case .kViewTypeAutoMove:
            print("AUTO MOVE")
            if(isNeedToShowTipWithPurchase == false){
                self.appDelegate.logEvent(name: "PaintPickerWindow", category: "Tools", action: imageName!)
                self.appDelegate.logEvent(name: "ToolWindow", category: "Tools", action: "paintpicker")
            }
            self.addTipsView(type: 3)
            break;
        }
    }
    
    func logCategoryEvent(name: String, action: String) {
        
        let categoryStringValue = self.categoryString.capitalized
        print("Color_\(categoryStringValue)")
        self.appDelegate.logEvent(name: "Color_\(categoryStringValue)", category: name, action: action)
        
    }
    
    
    
    //MARK:- IAP Subscription View
    func addTipsView(type: Int)
    {
        if isNeedToShowTipWithPurchase == true {
            appDelegate.logEvent(name: "Tool_Win_2", category: "Tool window 2", action: "Tool_win_2")
            addTipsViewWithPurchaseButton(type: type)
            
        }
        else {
            addTipsViewWithOutPurchaseButton(type: type)
        }
        
    }
    
    
    
    func addTipsViewWithPurchaseButton(type: Int) {
        if(isReminderVisible == 1)
        {
            isReminderVisible = 0
            if(self.ReminderView != nil){
                self.ReminderView.removeFromSuperview()
            }
        }
        if isHintPaintVisible == 0 && isReminderVisible == 0
            
        {
            isHintPaintVisible = 1
            let screenSize: CGRect = UIScreen.main.bounds
            self.tipsView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
            self.tipsView.backgroundColor = UIColor.clear
            self.tipsView.alpha = 1.0
            self.view.addSubview(self.tipsView)
            self.view.bringSubview(toFront: self.view)
            
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
            
            var proButtonRect = CGRect(x: offset*4, y: (height_white / 2) - 15, width: width_white - (offset*8), height: offset*6)
            
            var buyProductButtonRect = CGRect(x: offset*4 , y: (height_white / 2) + 65, width: width_white - (offset*8), height: offset*6)
            
            var watchButtonRect = CGRect(x: offset*6, y: (height_white / 2) + 140, width: width_white - (offset*12), height: offset*5)
            
            
            var imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                crossButtonRect = CGRect(x: offset, y: offset, width: offset*4, height: offset*4)
                tipsLblRect = CGRect(x: 0, y: height_white / 2, width: width_white, height: offset*9)
                imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
                
                proButtonRect = CGRect(x: offset*7, y: (height_white / 2) - 20, width: width_white - (offset*14), height: offset*9)
                buyProductButtonRect = CGRect(x: offset*7 , y: (height_white / 2) + 115, width: width_white - (offset*14), height: offset*9)
                watchButtonRect = CGRect(x: offset*10, y: (height_white / 2) + 240, width: width_white - (offset*20), height: offset*6)
                
                if self.view.frame.width > self.view.frame.height{ // landscape
                    crossButtonRect = CGRect(x: offset*6, y: offset, width: offset*4, height: offset*4)
                    
                    proButtonRect = CGRect(x: offset*7, y: (height_white * 0.46), width: width_white - (offset*14), height: offset*9)
                    buyProductButtonRect = CGRect(x: offset*10 , y: (height_white * 0.64), width: width_white - (offset*20), height: offset*9)
                    watchButtonRect = CGRect(x: offset*10, y: (height_white * 0.84), width: width_white - (offset*20), height: offset*6)
                }
            }
            
            //TransParent View
            blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
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
            var suggestionString: String!
            if type == 0
            {
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
            }
            else if type == 1
            {
                bgImage = UIImage(named: "hint-iphone")
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    bgImage = UIImage(named: "hint-ipadh")
                }
                tipsTextString = NSLocalizedString("Out of tips", comment: "")
                suggestionString = NSLocalizedString("To get 3 Tips", comment: "")
                purchaseItemSelectedType = .hint
            }
            else if type == 2
            {
                bgImage = UIImage(named: "paintbucket-iphone")
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    bgImage = UIImage(named: "paintbucket-ipadh")
                }
                tipsTextString = NSLocalizedString("Out of Paint Buckets", comment: "")
                suggestionString = NSLocalizedString("To get 5 Paint Buckets", comment: "")
                purchaseItemSelectedType = .bucket
            }
            else if type == 3
            {
                bgImage = UIImage(named: "paintpicker-iphone")
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    bgImage = UIImage(named: "paintpicker-ipad")
                }
                tipsTextString = NSLocalizedString("Out of Color Pickers", comment: "")
                suggestionString = NSLocalizedString("To get 5 Color Pickers", comment: "")
                purchaseItemSelectedType = .picker
            }
            let tipsImageView = UIImageView(frame: imageRect)
            tipsImageView.image = bgImage
            tipsImageView.contentMode = .scaleAspectFit
            whiteView.addSubview(tipsImageView)
            
            //CancelButton
            let crossButton = UIButton(frame: crossButtonRect)
            crossButton.setImage(UIImage(named: "cancel_subs_block"), for: UIControlState.normal)
            crossButton.addTarget(self, action:#selector(self.removeTipsView), for: .touchUpInside)
            whiteView.addSubview(crossButton)
            whiteView.bringSubview(toFront: crossButton)
            //TextLabel
            //            let tipsLabel = UILabel(frame: tipsLblRect)
            //            tipsLabel.text = tipsTextString
            //            tipsLabel.textAlignment = NSTextAlignment.center
            //            tipsLabel.textColor = UIColor.black
            //            tipsLabel.numberOfLines = 3
            //            tipsLabel.font = fontSizeWithBold
            //            whiteView.addSubview(tipsLabel)
            
            if type == 0
            {
                
                
                //RetryButton
                let retryButton = UIButton(frame: watchButtonRect)
                retryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
                retryButton.setTitleColor(UIColor.white, for: .normal)
                retryButton.titleLabel?.font = fontSizeWithBold
                retryButton.titleLabel?.textAlignment  = NSTextAlignment.center
                retryButton.addTarget(self, action:#selector(retryButtonClicked), for: .touchUpInside)
                whiteView.addSubview(retryButton)
            }
            else
            {
                
                //Buy product button
                let buyProductButton = UIButton(frame: buyProductButtonRect)
                let buttonLabelAttrs = [
                    NSAttributedStringKey.font : fontSizeWithNormal,
                    NSAttributedStringKey.foregroundColor : UIColor.white
                ] as [NSAttributedStringKey : Any]
                let buttonPriceAtts = [
                    NSAttributedStringKey.font : fontSizeWithBold,
                    NSAttributedStringKey.foregroundColor : UIColor.white
                ] as [NSAttributedStringKey : Any]
                
                let buttonAttString = NSMutableAttributedString()
                
                var weekPriceString = ""
                //"        for \(val as! String)"
                
                var weekPrice = ""
                
                if purchaseItemSelectedType == .bucket
                {
                    if let val = UserDefaults.standard.value(forKey: "Paint_Buckets_30"){
                        weekPrice = val as! String
                    }
                }
                else if purchaseItemSelectedType == .hint
                {
                    if let val = UserDefaults.standard.value(forKey: "Hints_30"){
                        weekPrice = val as! String
                    }
                }
                else if purchaseItemSelectedType == .picker
                {
                    if let val = UserDefaults.standard.value(forKey: "Paint_Pickers_30"){
                        weekPrice = val as! String
                    }
                }
                
                let forString = NSLocalizedString("for", comment: "")
                let getString = NSLocalizedString("Get x ", comment: "")
                
                weekPriceString = "        \(forString) \(weekPrice)"
                
                if purchaseItemSelectedType == .bucket
                {
                    buttonAttString.append(NSAttributedString(string: NSLocalizedString("\(getString)\(buyBucketCountValue)", comment: ""), attributes: buttonPriceAtts))
                }
                else if purchaseItemSelectedType == .hint
                {
                    buttonAttString.append(NSAttributedString(string: NSLocalizedString("\(getString)\(buyHintCountValue)", comment: ""), attributes: buttonPriceAtts))
                }
                else if purchaseItemSelectedType == .picker
                {
                    buttonAttString.append(NSAttributedString(string: NSLocalizedString("\(getString)\(buyPickerCountValue)", comment: ""), attributes: buttonPriceAtts))
                }
                
                var newFontSizeWithNormal : UIFont = UIFont.systemFont(ofSize: 15.0, weight: .semibold)
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    newFontSizeWithNormal = UIFont.systemFont(ofSize: 22.0, weight: .semibold)
                }
                let newButtonLabelAttrs = [
                    NSAttributedStringKey.font : newFontSizeWithNormal,
                    NSAttributedStringKey.foregroundColor : UIColor.white
                ] as [NSAttributedStringKey : Any]
                
                buttonAttString.append(NSAttributedString(string: weekPriceString, attributes: newButtonLabelAttrs))
                
                
                buyProductButton.setAttributedTitle(buttonAttString, for: .normal)
                buyProductButton.titleLabel?.numberOfLines = 0
                buyProductButton.titleLabel?.textAlignment  = NSTextAlignment.center
                buyProductButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                buyProductButton.addTarget(self, action:#selector(buy30PaintItems), for: .touchUpInside)
                //                buyProductButton.backgroundColor = #colorLiteral(red: 0.376288712, green: 0.8051891923, blue: 0.204441458, alpha: 1)
                buyProductButton.backgroundColor = UIColor.clear
                buyProductButton.layer.cornerRadius = buyProductButton.frame.height/2.0
                buyProductButton.clipsToBounds = true
                whiteView.addSubview(buyProductButton)
                
                //Watch Video button
                let watchButton = UIButton(frame: watchButtonRect)
                let attrs = [
                    NSAttributedStringKey.font : fontSizeWithNormal,
                    NSAttributedStringKey.foregroundColor : UIColor.black
                ] as [NSAttributedStringKey : Any]
                let attrs2 = [
                    NSAttributedStringKey.font : fontSizeWithBold,
                    NSAttributedStringKey.foregroundColor : UIColor.black
                ] as [NSAttributedStringKey : Any]
                
                
                let attString = NSMutableAttributedString()
                let strNewLine = NSLocalizedString("\n", comment: "")
                let strForFree = NSLocalizedString("Unlimited", comment: "")
                attString.append(NSAttributedString(string: NSLocalizedString("Watch a video", comment: ""), attributes: attrs2))
                attString.append(NSAttributedString(string: strNewLine + suggestionString, attributes: attrs))
                watchButton.setAttributedTitle(attString, for: .normal)
                watchButton.titleLabel?.numberOfLines = 0
                watchButton.titleLabel?.textAlignment  = NSTextAlignment.center
                watchButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                watchButton.addTarget(self, action:#selector(videoButtonClicked), for: .touchUpInside)
                whiteView.addSubview(watchButton)
                
                //PixelPro Button
                let proButton = UIButton(frame: proButtonRect)
                let attString2 = NSMutableAttributedString()
                //                attString2.append(NSAttributedString(string: NSLocalizedString("Start Free Trial", comment: ""), attributes: attrs2))
                //                attString2.append(NSAttributedString(string: strNewLine + strForFree, attributes: attrs))
                //                proButton.setAttributedTitle(attString2, for: .normal)
                
                
                
                let fontSizeWithMedium = UIFont.systemFont(ofSize: 17.0, weight: .regular)
                var attrs3 = [
                    NSAttributedStringKey.font : fontSizeWithMedium,
                    NSAttributedStringKey.foregroundColor :   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                ] as [NSAttributedStringKey : Any]
                
                let fontSizeWithSemiBold = UIFont.systemFont(ofSize: 12.0, weight: .bold)
                var attrs4 = [
                    NSAttributedStringKey.font : fontSizeWithSemiBold,
                    NSAttributedStringKey.foregroundColor :   #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
                ] as [NSAttributedStringKey : Any]
                
                if UIDevice.current.userInterfaceIdiom == .pad {
                    
                    attrs3 = [
                        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 24.0, weight: .regular),
                        NSAttributedStringKey.foregroundColor :   #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                    ] as [NSAttributedStringKey : Any]
                    
                    attrs4 = [
                        NSAttributedStringKey.font : UIFont.systemFont(ofSize: 16.0, weight: .bold),
                        NSAttributedStringKey.foregroundColor :   #colorLiteral(red: 0.1960784314, green: 0.1960784314, blue: 0.1960784314, alpha: 1)
                    ] as [NSAttributedStringKey : Any]
                    
                }
                
                let attString3 = NSMutableAttributedString()
                attString3.append(NSAttributedString(string: NSLocalizedString("Unlimited", comment: ""), attributes: attrs3))
                //                NSLocalizedString("Free Trial", comment: "")
                attString3.append(NSAttributedString(string: strNewLine + NSLocalizedString("Start Now", comment: ""), attributes: attrs4))
                proButton.setAttributedTitle(attString3, for: .normal)
                
                proButton.titleLabel?.numberOfLines = 0
                proButton.titleLabel?.textAlignment  = NSTextAlignment.center
                proButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                proButton.addTarget(self, action:#selector(pixelProButtonClicked), for: .touchUpInside)
                whiteView.addSubview(proButton)
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                self.tipsView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            }, completion:  nil)
        }
    }
    
    func addTipsViewWithOutPurchaseButton(type: Int) {
        if(isReminderVisible == 1)
        {
            isReminderVisible = 0
            if(self.ReminderView != nil){
                self.ReminderView.removeFromSuperview()
            }
        }
        if isHintPaintVisible == 0 && isReminderVisible == 0
            
        {
            isHintPaintVisible = 1
            let screenSize: CGRect = UIScreen.main.bounds
            self.tipsView = UIView(frame: CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height))
            self.tipsView.backgroundColor = UIColor.clear
            self.tipsView.alpha = 1.0
            self.view.addSubview(self.tipsView)
            self.view.bringSubview(toFront: self.view)
            
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
                proButtonRect = CGRect(x: offset*7, y: (height_white / 2) + 95, width: width_white - (offset*14), height: offset*9)
                imageRect = CGRect(x: 0, y: 0, width: width_white, height: height_white)
                
                if self.view.frame.width > self.view.frame.height{ // landscape
                    crossButtonRect = CGRect(x: offset*6, y: offset, width: offset*4, height: offset*4)
                    watchButtonRect = CGRect(x: offset*7, y: (height_white * 0.78), width: width_white - (offset*14), height: offset*9)
                    proButtonRect = CGRect(x: offset*7, y: (height_white * 0.61), width: width_white - (offset*14), height: offset*9)
                }
            }
            
            //TransParent View
            blackView = UIView(frame: CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height))
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
            var suggestionString: String!
            if type == 0
            {
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
            }
            else if type == 1
            {
                bgImage = UIImage(named: "hint1_iphone")
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    bgImage = UIImage(named: "hint1_ipad_v")
                }
                tipsTextString = NSLocalizedString("Out of tips", comment: "")
                suggestionString = NSLocalizedString("To get 3 Tips", comment: "")
            }
            else if type == 2
            {
                bgImage = UIImage(named: "paint1_iphone")
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    bgImage = UIImage(named: "paint1_ipad_v")
                }
                tipsTextString = NSLocalizedString("Out of Paint Buckets", comment: "")
                suggestionString = NSLocalizedString("To get 5 Paint Buckets", comment: "")
            }
            else if type == 3
            {
                bgImage = UIImage(named: "paintpicker1_iphone")
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    bgImage = UIImage(named: "paintpicker1_ipad_v")
                }
                tipsTextString = NSLocalizedString("Out of Color Pickers", comment: "")
                suggestionString = NSLocalizedString("To get 5 Color Pickers", comment: "")
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
            //TextLabel
            let tipsLabel = UILabel(frame: tipsLblRect)
            tipsLabel.text = tipsTextString
            tipsLabel.textAlignment = NSTextAlignment.center
            tipsLabel.textColor = UIColor.black
            tipsLabel.numberOfLines = 3
            tipsLabel.font = fontSizeWithBold
            whiteView.addSubview(tipsLabel)
            
            if type == 0
            {
                
                
                //RetryButton
                let retryButton = UIButton(frame: watchButtonRect)//proButtonRect)
                retryButton.setTitle(NSLocalizedString("Retry", comment: ""), for: .normal)
                retryButton.setTitleColor(UIColor.white, for: .normal)
                retryButton.titleLabel?.font = fontSizeWithBold
                retryButton.titleLabel?.textAlignment  = NSTextAlignment.center
                retryButton.addTarget(self, action:#selector(retryButtonClicked), for: .touchUpInside)
                whiteView.addSubview(retryButton)
            }
            else
            {
                
                //Watch Video button
                let watchButton = UIButton(frame: watchButtonRect)
                let attrs = [
                    NSAttributedStringKey.font : fontSizeWithNormal,
                    NSAttributedStringKey.foregroundColor : UIColor.black
                ] as [NSAttributedStringKey : Any]
                let attrs2 = [
                    NSAttributedStringKey.font : fontSizeWithBold,
                    NSAttributedStringKey.foregroundColor : UIColor.black
                ] as [NSAttributedStringKey : Any]
                
                
                let attString = NSMutableAttributedString()
                let strNewLine = NSLocalizedString("\n", comment: "")
                let strForFree = NSLocalizedString("Start Now", comment: "")
                attString.append(NSAttributedString(string: NSLocalizedString("Watch a video", comment: ""), attributes: attrs2))
                attString.append(NSAttributedString(string: strNewLine + suggestionString, attributes: attrs))
                watchButton.setAttributedTitle(attString, for: .normal)
                watchButton.titleLabel?.numberOfLines = 0
                watchButton.titleLabel?.textAlignment  = NSTextAlignment.center
                watchButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                watchButton.addTarget(self, action:#selector(videoButtonClicked), for: .touchUpInside)
                whiteView.addSubview(watchButton)
                
                //PixelPro Button
                let proButton = UIButton(frame: proButtonRect)
                let attString2 = NSMutableAttributedString()
                attString2.append(NSAttributedString(string: NSLocalizedString("Unlimited", comment: ""), attributes: attrs2))
                attString2.append(NSAttributedString(string: strNewLine + strForFree, attributes: attrs))
                proButton.setAttributedTitle(attString2, for: .normal)
                proButton.titleLabel?.numberOfLines = 0
                proButton.titleLabel?.textAlignment  = NSTextAlignment.center
                proButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                proButton.addTarget(self, action:#selector(pixelProButtonClicked), for: .touchUpInside)
                whiteView.addSubview(proButton)
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                self.tipsView.frame = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
            }, completion:  nil)
        }
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
            if self.clikcedType == 2
            {
                if(self.isPaintEnable == true)
                {
                    self.paintButtonClicked(self.paintButton)
                }
            }
        })
        
        
        
    }
    
    //MARK:- Video button Clicked
    @objc func videoButtonClicked()
    {
        if isNeedToShowTipWithPurchase == true {
            appDelegate.logEvent(name: "Tool_Win_2_v", category: "Tool window 2", action: "Tool_win2_video")
        }
        
        if(timer != nil && timer.isValid)
        {
            timer.invalidate()
            timer = nil
        }
        if(isReminderVisible == 1)
        {
            isReminderVisible = 0
            if(self.ReminderView != nil){
                self.ReminderView.removeFromSuperview()
            }
        }
        self.isVideoViewOpen = true
        self.isReminderVideoOpen = false
        if self.isInternetAvailable()
        {
            if self.clikcedType == 1
            {
                if(isNeedToShowTipWithPurchase == false){
                    appDelegate.logEvent(name: "Hint_Window", category: "Video", action: imageName!)
                    appDelegate.logEvent(name: "Tool_Window", category: "Video", action: "Hint")
                    appDelegate.logEvent(name: "Reward_video", category: "Video", action: "Hint")
                }
            }
            else if self.clikcedType == 2
            {
                if(isNeedToShowTipWithPurchase == false){
                    appDelegate.logEvent(name: "Paint_Bucket_Window", category: "Video", action: imageName!)
                    appDelegate.logEvent(name: "Tool_Window", category: "Video", action: "PaintBucket")
                    appDelegate.logEvent(name: "Reward_video", category: "Video", action: "PaintBucket")
                }
            }
            else if self.clikcedType == 3
            {
                if(isNeedToShowTipWithPurchase == false){
                    appDelegate.logEvent(name: "Paint_Picker_Window", category: "Video", action: imageName!)
                    appDelegate.logEvent(name: "Tool_Window", category: "Video", action: "PaintPicker")
                    appDelegate.logEvent(name: "Reward_video", category: "Video", action: "PaintPicker")
                }
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                
                let screenSize: CGRect = UIScreen.main.bounds
                if(self.tipsView != nil){
                    self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                }
            }, completion: { (finished: Bool) in
                if(self.tipsView != nil){
                    self.tipsView.removeFromSuperview()
                }
                self.isHintPaintVisible = 0
                if self.rewardedAdHelper.self != nil
                {
                    print("[**Ad is ready to load]")
                    if self.rewardedAdHelper?.rewardedAd != nil {
                        self.isSomethingWrong = true
                        self.rewardedAdHelper?.showRewardedAd(viewController: self)
                    }
                    else {
                        print("Please try Again RW!")
                        self.appDelegate.logEvent(name: "No_Fill_hm", category: "homeVC", action: "vButton")
                        self.appDelegate.logEvent(name: "No_Reward_Tool", category: "Ads", action: "HV")
                        let callActionHandler = { (action:UIAlertAction!) -> Void in
                            //  self.backToView()
                        }
                        let alertController = UIAlertController(title: "Please try Again!", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                }
                
                
            })
        }
        else
        {
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                let screenSize: CGRect = UIScreen.main.bounds
                self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
            }, completion: { (finished: Bool) in
                self.tipsView.removeFromSuperview()
                self.isHintPaintVisible = 0
                self.appDelegate.logEvent(name: "No_Internet_tools", category: "No_Internet", action: "Show_Ads")
                self.addTipsView(type: 0)
            })
        }
    }
    
    
    
    //MARK:- Video button Clicked
    @objc func reminderVideoButtonClicked()
    {
        
        appDelegate.logEvent(name: "Reminder_Tap", category: "reminder", action: imageName!)
        appDelegate.logEvent(name: "Reward_video", category: "Video", action: "reminder")
        if(timer != nil && timer.isValid)
        {
            timer.invalidate()
            timer = nil
        }
        if(isReminderVisible == 1)
        {
            isReminderVisible = 0
            if(self.ReminderView != nil){
                self.ReminderView.removeFromSuperview()
            }
        }
        self.isVideoViewOpen = true
        self.isReminderVideoOpen = true
        if self.isInternetAvailable()
        {
            if self.clikcedType == 1
            {
                appDelegate.logEvent(name: "Reminder_Window", category: "reminder", action: "Hint")
            }
            else if self.clikcedType == 2
            {
                appDelegate.logEvent(name: "Reminder_Window", category: "reminder", action: "PaintBucket")
            }
            else if self.clikcedType == 3
            {
                appDelegate.logEvent(name: "Reminder_Window", category: "reminder", action: "PaintPicker")
            }
            
            if (GADRewardedAd.self != nil)
                
            {
                print("[**Pre Load]")
                self.shouldShowRewardedVideo = true
                appDelegate.logEvent(name: "Complete_Watching", category: "homeVC", action: "Reminder")
                self.isVideoViewOpen = false
                self.ShowReminderUI()
            }
            
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                
                let screenSize: CGRect = UIScreen.main.bounds
                if(self.tipsView != nil){
                    self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                }
            }, completion: { (finished: Bool) in
                if(self.tipsView != nil){
                    self.tipsView.removeFromSuperview()
                }
                self.isHintPaintVisible = 0
                
                if (GADRewardedAd.self != nil)
                {
                    print("[**Ad is ready to load]")
                    //                                    if let rootViewController = UIApplication.topViewController() {
                    //                                        if rootViewController is HomeVC
                    //                                        {
                    if self.rewardedAdHelper?.rewardedAd != nil {
                        self.isSomethingWrong = true
                        self.rewardedAdHelper?.showRewardedAd(viewController: self)
                    }
                    else {
                        print("[Please try Again RW!]")
                        self.appDelegate.logEvent(name: "No_Fill_hm", category: "homeVC", action: "Reminder")
                        self.appDelegate.logEvent(name: "No_Reward_Reminder", category: "Ads", action: "HV")
                        let callActionHandler = { (action:UIAlertAction!) -> Void in
                            //  self.backToView()
                        }
                        let alertController = UIAlertController(title: "Please try Again!", message: nil, preferredStyle: .alert)
                        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: callActionHandler)
                        alertController.addAction(defaultAction)
                        self.present(alertController, animated: true, completion:nil)
                    }
                    //                                        }
                    //                                    }
                    
                }
            })
        }
        else
        {
            UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                            {
                let screenSize: CGRect = UIScreen.main.bounds
                self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
            }, completion: { (finished: Bool) in
                self.tipsView.removeFromSuperview()
                self.isHintPaintVisible = 0
                self.addTipsView(type: 0)
            })
        }
    }
    
    //MARK:- Pixel Pro button Clicked
    @objc func pixelProButtonClicked()
    {
        if isNeedToShowTipWithPurchase == true {
            appDelegate.logEvent(name: "Tool_Win_2_Sub", category: "Tool window 2", action: "Tool_win2_sub")
        }
        
        if self.clikcedType == 1
        {  if(isNeedToShowTipWithPurchase == false){
            appDelegate.logEvent(name: "Hint_Window_pro", category: "Subscription", action: imageName!)
            appDelegate.logEvent(name: "Window_pro", category: "Subscription", action: "Hint")
        }
        }
        else if self.clikcedType == 2
        {
            if(isNeedToShowTipWithPurchase == false){
                appDelegate.logEvent(name: "Paint_Bucket_Window_pro", category: "Subscription", action: imageName!)
                appDelegate.logEvent(name: "Window_pro", category: "Subscription", action: "PaintBucket")
            }
        }
        else if self.clikcedType == 3
        {
            if(isNeedToShowTipWithPurchase == false){
                appDelegate.logEvent(name: "Paint_Picker_Window_pro", category: "Subscription", action: imageName!)
                appDelegate.logEvent(name: "Window_pro", category: "Subscription", action: "PaintPicker")
            }
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
            let screenSize: CGRect = UIScreen.main.bounds
            self.tipsView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
        }, completion: { (finished: Bool) in
            self.tipsView.removeFromSuperview()
            self.isHintPaintVisible = 0
            if self.isSubscriptionViewVisible == 0
            {
                self.isSubscriptionViewVisible = 1
                self.addIAPSubscriptionView()
            }
        })
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
                if self.clikcedType == 1
                {
                    self.checkViewType(type: .kViewTypeHint)
                }
                else if self.clikcedType == 2
                {
                    self.checkViewType(type: .kViewTypePaint)
                }
                else if self.clikcedType == 3
                {
                    self.checkViewType(type: .kViewTypeAutoMove)
                }
            }
            else
            {
                self.checkViewType(type: .kViewTypeNoInternet)
            }
        })
    }
    
    @objc func rewardBasedVideoAdWillLeaveApplication() {
        print("[Reward based video ad will leave application.]")
        self.ShowReminderUI()
        self.isSomethingWrong = false
        self.isVideoViewOpen = false
        if self.isComplete
        {
            var arrayCompleted = getCompletedImagesIDArray()
            if self.imageId != nil{
                if !arrayCompleted.contains(self.imageId!)
                {
                    arrayCompleted.append(self.imageId!)
                    saveCompletedImagesIDArray(array: arrayCompleted)
                }
            }
        }
        if self.isJustCompleted
        {
            //Reset Timer - TODO
            // the image used for tutorial should NOT be counted towards completions for displaying Review, Reward windows -- TODO
            if(self.isGifTutorialCloseTapped == false)
            {
                
                UserDefaults.standard.set("yes", forKey: "is_first_image_completed")
                UserDefaults.standard.synchronize()
                
            }
            
        }
    }
    
    
    fileprivate func SetRewardPoint() {
        if self.clikcedType == 1
        {
            if(self.isReminderVideoOpen)
            {
                UserDefaults.standard.set(self.reminderPaintCount, forKey: hint_count)
                
            }else{
                UserDefaults.standard.set(5, forKey: hint_count)
            }
            
            UserDefaults.standard.synchronize()
            self.showLabelWithCount(lbl: self.hintCountLabel, count: UserDefaults.standard.integer(forKey: self.hint_count) + UserDefaults.standard.integer(forKey: giftHintCount) )
        }
        else if self.clikcedType == 2
        {
            if(self.isReminderVideoOpen)
            {
                UserDefaults.standard.set(self.reminderPaintCount, forKey: paint_count)
                
            }else{
                UserDefaults.standard.set(10, forKey: paint_count)
            }
            UserDefaults.standard.synchronize()
            self.showLabelWithCount(lbl: self.paintCountLabel, count: UserDefaults.standard.integer(forKey: self.paint_count))
        }
        else if self.clikcedType == 3
        {
            if(self.isReminderVideoOpen)
            {
                UserDefaults.standard.set(self.reminderPaintCount, forKey: autoMove_count)
                
            }else{
                UserDefaults.standard.set(10, forKey: self.autoMove_count)
            }
            
            UserDefaults.standard.synchronize()
            self.showLabelWithCount(lbl: self.autoMoveCountLabel, count: UserDefaults.standard.integer(forKey: self.autoMove_count))
        }
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
                }
                else  if (type == .purchasedWeek) || (type == .restoredWeek)
                {
                    if (type == .purchasedWeek)
                    {
                        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                            self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "Updated_tool")
                            self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                        }else {
                            self?.appDelegate.logEvent(name: "weekly_subscription_complete", category: "Subscription", action: "homeVC")
                            self?.appDelegate.logEvent(name: "weekly_sub_comp_HV", category: "Subscription", action: "homeVC")
                            self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "weekly")
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeWeekSubscription)
                }
                else  if (type == .purchasedMonth) || (type == .restoredMonth)
                {
                    if (type == .purchasedMonth)
                    {
                        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                            self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "Updated_tool")
                            self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                        }else {
                            self?.appDelegate.logEvent(name: "monthly_subscription_complete", category: "Subscription", action: "homeVC")
                            self?.appDelegate.logEvent(name: "monthly_sub_comp_HV", category: "Subscription", action: "homeVC")
                            self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "monthly")
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeMonthSubscription)
                }
                else  if (type == .purchasedYear) || (type == .restoredYear)
                {
                    if (type == .purchasedYear)
                    {
                        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                            self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "Updated_tool")
                            self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                        }else {
                            self?.appDelegate.logEvent(name: "yearly_subscription_complete", category: "Subscription", action: "homeVC")
                            self?.appDelegate.logEvent(name: "yearly_sub_comp_HV", category: "Subscription", action: "homeVC")
                            self?.appDelegate.logEvent(name: "subscription_active", category: "Subscription", action: "yearly")
                        }
                    }
                    self?.appDelegate.savePurchase(purchaseType: .kPurchaseTypeYearSubscription)
                }
                
                let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                if (((self?.appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (self?.appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
                {
                    self?.showLabelWithCount(lbl: (self?.hintCountLabel)!  , count: 0)
                    self?.showLabelWithCount(lbl: (self?.paintCountLabel)!  , count: 0)
                    self?.showLabelWithCount(lbl: (self?.autoMoveCountLabel)!  , count: 0)
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
        var longmsg_lbl_yVal : CGFloat = 430
        
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
            
            if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
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
        
        var updatePurchaseMargin:CGFloat = 0
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            updatePurchaseMargin = 15
            if UIDevice.current.userInterfaceIdiom == .pad{
                updatePurchaseMargin = -10
            }
        }
        
        let buttonYearRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*2)+(button_offset*2) + updatePurchaseMargin , width: button_width, height: button_height)
        
        var buttonRestoreRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*3)+(button_offset*2)+button_offset/2+8, width: button_width, height: button_height)
        
        let longMsgRect = CGRect(x: 0, y: longmsg_lbl_yVal, width:whiteRect.width, height: longmsg_lbl_height)
        
        //        var termsButtonRect = CGRect(x: (screenSize.width - button_width) / 2, y: screenSize.height - (offsetHelp) - button_height, width: button_width, height: button_height)
        var termsButtonRect = CGRect(x: (screenSize.width - button_width) / 2, y: screenSize.height - (offsetHelp) - (20), width: button_width, height: 30)
        
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
            {
                //                termsButtonRect = CGRect(x: (screenSize.width - button_width) / 2, y: screenSize.height - (offsetHelp) - help_btn_width-10, width: button_width, height: button_height)
                termsButtonRect = CGRect(x: (screenSize.width - 170), y: screenSize.height - (offsetHelp) - help_btn_width-10, width: 150, height: button_height)
                buttonRestoreRect = CGRect(x: (whiteRect.width - button_width) / 2, y: button_yVal+(button_height*3)+(button_offset*2), width: button_width, height: button_height)
            }
        }
        let whiteView = UIView(frame: whiteRect)
        whiteView.backgroundColor = UIColor.white
        whiteView.alpha = 1.0
        whiteView.clipsToBounds = true
        whiteView.layer.cornerRadius = 15
        self.iapSubscriptionView.addSubview(whiteView)
        //bgImage
        let bgImage = UIImageView(frame: bgImageRect)
        if UIDevice.current.userInterfaceIdiom == .phone
        {
            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                bgImage.image = UIImage(named: "subs_updated_iphone")
            }else{
                bgImage.image = UIImage(named: "subs_iphone")}
        }
        else if UIDevice.current.userInterfaceIdiom == .pad
        {
            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                bgImage.image = UIImage(named: "subs_updated_ipad")
                if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
                {
                    bgImage.image = UIImage(named: "subs_updated_ipadh")
                }
            }else{
                bgImage.image = UIImage(named: "subs_ipad")
                if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
                {
                    bgImage.image = UIImage(named: "subs_ipadh")
                }
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
        helpButton.isHidden = true
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
            {
                helpButton.isHidden = false
                
            }
        }
        iapSubscriptionView.addSubview(helpButton)
        //termsButton
        let termsButton = UIButton(frame: termsButtonRect)
        termsButton.setTitle(NSLocalizedString("Terms & Privacy", comment: ""), for: UIControlState.normal)
        termsButton.addTarget(self, action:#selector(self.presentTermsView), for: .touchUpInside)
        termsButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        termsButton.titleLabel?.textAlignment  = NSTextAlignment.center
        termsButton.titleLabel?.font = .systemFont(ofSize: 14)
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
            if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
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
        print("[HomeVC]")
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
        
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            //  yearView.backgroundColor = UIColor(red: 0.94, green: 0.44, blue: 0.39, alpha: 1.00)
            yearButton.setTitle(NSLocalizedString("Continue", comment: ""),for: .normal)
            yearButton.titleLabel!.textColor = UIColor.red
            yearButton.addTarget(self, action:#selector(self.subscriptionPurchase), for: .touchUpInside)
            yearButton.titleLabel!.adjustsFontSizeToFitWidth = true;
            yearButton.titleLabel!.minimumScaleFactor = 0.5;
            if UIDevice.current.userInterfaceIdiom == .pad {
                yearButton.titleLabel!.font = UIFont.systemFont(ofSize: 30.0)
            }
            else {
                yearButton.titleLabel!.font = UIFont.systemFont(ofSize: 20.0)
            }
            
        }else{
            
            let attString3 = NSMutableAttributedString()
            yearButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
            attString3.append(NSAttributedString(string: yearPrice+yearStr+newLineStr, attributes: topLabelAttributes))
            attString3.append(NSAttributedString(string: NSLocalizedString("1 year subscription", comment: ""), attributes: attrs))
            yearButton.setAttributedTitle(attString3, for: .normal)
            yearButton.titleLabel?.numberOfLines = 0
            yearButton.titleLabel?.textAlignment  = NSTextAlignment.center
            yearButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
            yearButton.addTarget(self, action:#selector(self.subscriptionYearPurchase), for: .touchUpInside)
        }
        whiteView.addSubview(yearButton)
        //
        
        
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            monthButton.isHidden = true
            weekButton.isHidden = true
            
            var boxSize:CGFloat = 100
            var fontSize:CGFloat = 10
            var height:CGFloat = 40
            var topMargin:CGFloat = 5
            var fontTitleSize:CGFloat = 13
            var subscriptionUIView = UIView(frame: CGRect(x: 0,
                                                          y: msgLabel.frame.maxY + 10.0,
                                                          width: whiteView.frame.width,
                                                          height: 120))
            if UIDevice.current.userInterfaceIdiom == .pad {
                subscriptionUIView = UIView(frame: CGRect(x: 0,
                                                          y: msgLabel.frame.maxY + 10.0,
                                                          width: whiteView.frame.width,
                                                          height: 160))
                if (UIDevice.current.orientation.isLandscape || (screenSize.width > screenSize.height))
                {
                    subscriptionUIView = UIView(frame: CGRect(x: 0,
                                                              y: msgLabel.frame.maxY - 10.0,
                                                              width: whiteView.frame.width,
                                                              height: 160))
                }
            }
            
            subscriptionUIView.backgroundColor = .clear
            // subscriptionUIView.backgroundColor = .systemPink
            
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
                                            y: subscriptionUIView.bounds.midY-10)
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
            // oneMonthLabel.font = oneMonthLabel.font.withSize(fontSize+4)
            
            
            //oneMonthAmountLabel
            //oneWeekLabel
            
            let oneMonthAmountLabel = UILabel(frame: CGRect(x: 10,
                                                            y: monthSubsView!.frame.maxY-45,
                                                            width:boxSize - 20,
                                                            height: 25))
            oneMonthAmountLabel.font = oneMonthAmountLabel.font.withSize(fontSize+1)
            oneMonthAmountLabel.text = monthPrice+monthStr
            oneMonthAmountLabel.adjustsFontSizeToFitWidth = true
            oneMonthAmountLabel.textAlignment = .center
            monthSubsView!.addSubview(oneMonthAmountLabel)
            
            var monthOffPrice = ""
            if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
                
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER_MODS"){
                    monthOffPrice = val as! String
                }
            }else {
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"){
                    monthOffPrice = val as! String
                }
            }
            //            if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"){
            //                monthOffPrice = val as! String
            //            }
            let monthStr = NSLocalizedString("/ Month", comment: "")
            let oneMonthInitialAmountLabel = UILabel(frame: CGRect(x: 10,
                                                                   y:monthSubsView!.frame.maxY-20,
                                                                   width:boxSize - 20,
                                                                   height: 15))
            oneMonthInitialAmountLabel.font = oneMonthInitialAmountLabel.font.withSize(fontSize+1)
            let offString = monthOffPrice+monthStr
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: offString)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            
            if #available(iOS 14, *) {
                attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            } else {
                attributeString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
                attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
                
            }
            
            oneMonthInitialAmountLabel.attributedText = attributeString
            oneMonthInitialAmountLabel.adjustsFontSizeToFitWidth = true
            oneMonthInitialAmountLabel.textAlignment = .center
            monthSubsView!.addSubview(oneMonthInitialAmountLabel)
            
            //            let offerView = UIView(frame: CGRect(x: monthSubsView!.frame.origin.x + monthSubsView!.frame.size.width - height + 10,
            //                                                 y: monthSubsView!.frame.size.height - height + 15,
            //                                                 width: height,
            //                                                 height: height))
            //            offerView.layer.cornerRadius = height / 2
            //            offerView.backgroundColor = .yellow
            //            subscriptionUIView.addSubview(offerView)
            //            let offerLabel = UILabel(frame: CGRect(x: 5,
            //                                                   y: 5,
            //                                                   width: offerView.frame.size.width - 10,
            //                                                   height: height - 10))
            //            offerLabel.text = NSLocalizedString("50%\nOff", comment: "")
            //            offerLabel.numberOfLines = 0
            //            offerLabel.textColor = .red
            //            offerLabel.lineBreakMode = .byWordWrapping
            //            offerLabel.textAlignment = .center
            //            offerView.addSubview(offerLabel)
            //            offerLabel.font = offerLabel.font.withSize(fontSize+1)
            
            let image = UIImage(named: "monds_ipad")
            let ratioFactor = (image?.size.height)! / (image?.size.width)!
            var yValue = oneMonthInitialAmountLabel.frame.maxY - 12
            if UIDevice.current.userInterfaceIdiom == .pad {
                yValue = oneMonthInitialAmountLabel.frame.maxY - 28
            }
            var heightValue = 116 - yValue
            if UIDevice.current.userInterfaceIdiom == .pad {
                heightValue = 45 // heightValue = 135 - yValue
            }
            let widthValue = heightValue * ratioFactor
            
            var xValue = monthSubsView!.frame.origin.x + monthSubsView!.frame.size.width + 2 - widthValue
            if UIDevice.current.userInterfaceIdiom == .pad {
                xValue = monthSubsView!.frame.origin.x + monthSubsView!.frame.size.width + 11 - widthValue
            }
            
            let  offerImage = UIImageView(frame: CGRect(x: xValue, y: yValue, width: heightValue, height: heightValue))
            offerImage.image = image
            subscriptionUIView.addSubview(offerImage)
            
            //weekSubscptionLabel
            let oneWeekLabel = UILabel(frame: CGRect(x: 5,
                                                     y: topMargin,
                                                     width: weekSubsView!.frame.size.width - 10,
                                                     height: height))
            oneWeekLabel.text = (NSLocalizedString("Weekly Subscription", comment: ""))
            //"\(NSLocalizedString("Weekly", comment: ""))\n\(NSLocalizedString("Subscription", comment: ""))"
            oneWeekLabel.numberOfLines = 0
            oneWeekLabel.lineBreakMode = .byWordWrapping
            oneWeekLabel.textAlignment = .center
            weekSubsView!.addSubview(oneWeekLabel)
            oneWeekLabel.font = oneWeekLabel.font.withSize(fontTitleSize)
            
            
            //oneWeekAmountLabel
            
            let oneWeekAmountLabel = UILabel(frame: CGRect(x: 10,
                                                           y: monthSubsView!.frame.maxY-45,
                                                           width:boxSize - 20,
                                                           height: 25))
            oneWeekAmountLabel.font = oneWeekAmountLabel.font.withSize(fontSize+1)
            oneWeekAmountLabel.text = weekPrice+weekStr//"$8.99/\(NSLocalizedString("Month", comment: ""))"
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
            // oneMonthLabel.font = oneMonthLabel.font.withSize(fontSize+4)
            // oneYearLabel.font = oneYearLabel.font.withSize(fontSize+4)
            
            
            //oneYearAmountLabel
            
            let oneYearAmountLabel = UILabel(frame: CGRect(x: 10,
                                                           y: monthSubsView!.frame.maxY-45,
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
            
            
            
            
            whiteView.backgroundColor = .white
            
            whiteView.addSubview(subscriptionUIView)
            
            appDelegate.logEvent(name: "Updated_Tool_Subscription", category: "Subscription", action: "View Updated Tool Subscription")
        }
        //end vivek code
        
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
    
    func selectSubscriptionType(_ sView:UIView){
        weekSubsView!.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        monthSubsView!.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        yearSubsView!.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        sView.layer.borderColor =  UIColor(red: 0.91, green: 0.49, blue: 0.45, alpha: 1.00).cgColor
        selectedPurchaseType = sView.tag
        print("selectedPurchaseType \(selectedPurchaseType)")
    }
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        print("did tap view", sender.view?.tag)
        selectSubscriptionType(sender.view!)
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
        appDelegate.logEvent(name: "info", category: "Subscription", action: "HomeVC")
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
            
            let webViewRect = CGRect(x: offset, y: offset+cross_btn_width, width: screenSize.width-(2*offset), height: screenSize.height - (offset+cross_btn_width + 10)) //(3offset))
            
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
        appDelegate.logEvent(name: "restore_purchase", category: "Subscription", action: "HomeVC")
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
        appDelegate.logEvent(name: "weekly_subscription_hm", category: "Subscription", action: "HomeVC")
        appDelegate.logEvent(name: "weekly_subscription", category: "Subscription", action: "HomeVC")
        IAPHandler.shared.purchaseMyProduct(product_identifier: WEEK_SUBSCRIPTION_PRODUCT_ID)
    }
    // MARK: - SUBSCRIPTION MONTH PURCHASE
    @objc func subscriptionMonthPurchase()
    {
        SVProgressHUD.show()
        appDelegate.logEvent(name: "monthly_subscription_hm", category: "Subscription", action: "HomeVC")
        appDelegate.logEvent(name: "monthly_subscription", category: "Subscription", action: "HomeVC")
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            MONTH_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2mods"
        }
        IAPHandler.shared.purchaseMyProduct(product_identifier: MONTH_SUBSCRIPTION_PRODUCT_ID)
    }
    // MARK: - SUBSCRIPTION YEAR PURCHASE
    @objc func subscriptionYearPurchase()
    {
        SVProgressHUD.show()
        appDelegate.logEvent(name: "yearly_subscription_hm", category: "Subscription", action: "HomeVC")
        appDelegate.logEvent(name: "yearly_subscription", category: "Subscription", action: "HomeVC")
        IAPHandler.shared.purchaseMyProduct(product_identifier: YEAR_SUBSCRIPTION_PRODUCT_ID)
    }
    
    // MARK: - SUBSCRIPTION YEAR PURCHASE
    @objc func subscriptionPurchase()
    {
        if(selectedPurchaseType == 0){
            subscriptionWeekPurchase()
        }
        else if(selectedPurchaseType == 1){
            subscriptionMonthPurchase()
        }else {
            subscriptionYearPurchase()
        }
        
    }
    
    
    //MARK: - Buy 30 Paint Buckets, 30 Hints, 30 Paint Pickers.
    var purchaseItemSelectedType: PurchaseItemType = .none
    @objc func buy30PaintItems() {
        
        SVProgressHUD.show()
        appDelegate.logEvent(name: "IAP_Tool", category: "Tools", action: "Click")
        
        IAPHandlerForTools.shared.purchaseStatusBlock = {[weak self] (type) in
            //            guard let strongSelf = self else{ return }
            //
            //            let alertView = UIAlertController(title: "", message: type.message(), preferredStyle: .alert)
            //            let action = UIAlertAction(title: "OK", style: .default, handler: { (alert) in
            //            })
            //            alertView.addAction(action)
            
            DispatchQueue.main.async(execute: {
                //                strongSelf.present(alertView, animated: true, completion: nil)
                
                if type == .buyBucket30 || type == .buyHint20 || type == .buyPicker40 {
                    self!.setPurchasePoint()
                }
                else {
                    self!.removeTipsView()
                }
            })
        }
        
        let Hints_30_PRODUCT_ID = "com.moomoolab.pl2hints40"
        let Paint_Buckets_30_PRODUCT_ID = "com.moomoolab.pl2paints80"
        let Paint_Pickers_30_PRODUCT_ID = "com.moomoolab.30PaintPickers"
        
        if purchaseItemSelectedType == .bucket {
            IAPHandlerForTools.shared.purchaseMyProduct(product_identifier: Paint_Buckets_30_PRODUCT_ID)
            appDelegate.logEvent(name: "IAP_Paint", category: "Tools", action: "Click")
        }
        else if purchaseItemSelectedType == .hint {
            IAPHandlerForTools.shared.purchaseMyProduct(product_identifier: Hints_30_PRODUCT_ID)
            appDelegate.logEvent(name: "IAP_Hint", category: "Tools", action: "Click")
        }
        else if purchaseItemSelectedType == .picker {
            IAPHandlerForTools.shared.purchaseMyProduct(product_identifier: Paint_Pickers_30_PRODUCT_ID)
            appDelegate.logEvent(name: "IAP_Picker", category: "Tools", action: "Click")
        }
        
    }
    
    let buyBucketCountValue = 80
    let buyHintCountValue = 40
    let buyPickerCountValue = 40
    
    fileprivate func setPurchasePoint() {
        
        if purchaseItemSelectedType == .bucket
        {
            appDelegate.logEvent(name: "IAP_PaintBucket", category: "Purchase of paint buckets", action: "pb30_comp")
            UserDefaults.standard.set(buyBucketCountValue, forKey: paint_count)
            showLabelCount(lbl: paintCountLabel, count: buyBucketCountValue)
        }
        else if purchaseItemSelectedType == .hint
        {
            purchaseItemSelectedType = .none
            appDelegate.logEvent(name: "IAP_Hints", category: "Purchase of hints", action: "hint20_comp")
            UserDefaults.standard.set(buyHintCountValue, forKey: hint_count)
            showLabelCount(lbl: hintCountLabel, count: buyHintCountValue)
        }
        else if purchaseItemSelectedType == .picker
        {
            purchaseItemSelectedType = .none
            appDelegate.logEvent(name: "IAP_Picker", category: "Purchase of paint pickers", action: "picker40_comp")
            UserDefaults.standard.set(buyPickerCountValue, forKey: autoMove_count)
            showLabelCount(lbl: autoMoveCountLabel, count: buyPickerCountValue)
        }
        
    }
    
    func showLabelCount(lbl: UILabel, count: Int) {
        
        lbl.clipsToBounds = true
        lbl.layer.cornerRadius = lbl.frame.size.width/2
        lbl.backgroundColor = UIColor.red
        lbl.textColor = UIColor.white
        lbl.text = "\(count)"
        lbl.isHidden = false
        
        removeTipsView()
        
    }
    
    func setPaintButton() {
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.paintButton.setImage(UIImage(named: "coloredBucketiPad"), for: .normal)
        }else{
            self.paintButton.setImage(UIImage(named: "coloredBucketiPhone"), for: .normal)
        }
        self.hintButton.setImage(UIImage(named: "hint"), for: .normal)
        self.autoMoveButton.setImage(UIImage(named: "paintpicker"), for: .normal)
        self.zommInButoon(button: eraseButton)
        self.zommInButoon(button: hintButton)
        self.zommInButoon(button: autoMoveButton)
        self.roundedbuttonSet(button: eraseButton)
        self.roundedbuttonSet(button: hintButton)
        self.roundedbuttonSet(button: autoMoveButton)
        self.zoomButton(button: paintButton)
        isPaintEnable = true
        
    }
    //Buy 30 Paint Buckets, 30 Hints, 30 Paint Pickers
    
    //MARK :- Will Enter Foreground notification
    @objc func willEnterForeground(_ notification: NSNotification!){
        self.startReminderTimer()
        
        guard self.collectionColorView != nil else {
            return
        }
        if !(self.collectionColorView.indexPathsForVisibleItems.contains(selectedIndex)){
            // self.collectionColorView.scrollToItem(at: selectedIndex, at: .left, animated: true)
        }
    }
    
    
    func startReminderTimer(previousReminderFailed: Bool?=false) {
        stopTimer()
        guard self.timer == nil else { return }
        
        
        let isFirstLaunch = UserDefaults.standard.bool(forKey: "isFirstSession")
        print(isFirstLaunch)
        
        
        let counterTimeForFirstLaunch = reminderTime1
        
        let paintCount =  UserDefaults.standard.integer(forKey: paint_count)
        let hintCount =  UserDefaults.standard.integer(forKey: hint_count)
        let autoMoveCount =  UserDefaults.standard.integer(forKey: autoMove_count)
        
        if isFirstLaunchDrawingScreenShow == false && (paintCount == 0 || hintCount == 0 || autoMoveCount == 0 || previousReminderFailed == true) { //&& isFirstLaunch == true {
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(counterTimeForFirstLaunch ), target: self, selector: #selector(self.completed), userInfo: nil, repeats: false)
        }
        else {
            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(self.counterTime ), target: self, selector: #selector(self.completed), userInfo: nil, repeats: true)
        }
        
        print("startTimer \(self.counterTime)")
    }
    
    func stopTimer() {
        guard timer != nil else { return }
        timer?.invalidate()
        timer = nil
        print("stopTimer")
    }
    
    func setPaintCount() {
        self.showLabelWithCount(lbl: self.paintCountLabel, count: UserDefaults.standard.integer(forKey: self.paint_count))
    }
    //MARK:- Add Reminders View
    fileprivate func viewReminder() {
        self.isReminderVisible = 1
        let screenSize: CGRect = UIScreen.main.bounds
        let viewSize = 70
        UIView.animate(withDuration: 1, animations: {
            self.ReminderView.frame = CGRect(x: 20, y: Int(screenSize.height/2), width: viewSize, height: viewSize)
        }) { (_) in
            self.view.layoutIfNeeded()
            self.animationTimer = Timer.scheduledTimer(withTimeInterval: 10, repeats: false) {
                (_) in
                DispatchQueue.main.async
                {
                    self.ReminderView.addDashedBorder()
                    if( self.animationTimer != nil){
                        self.animationTimer?.invalidate()
                        self.animationTimer = nil
                    }
                }
            }
            self.blinkTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false) {
                (_) in
                UIView.animate(withDuration: 1, delay:0, animations: {
                    self.ReminderView.frame = CGRect(x: -(viewSize + 30), y: Int(screenSize.height/2), width: viewSize, height: viewSize)
                }) { (_) in
                    self.view.layoutIfNeeded()
                    self.removeReminderView()
                    if( self.blinkTimer != nil ){
                        self.blinkTimer?.invalidate()
                        self.blinkTimer = nil
                    }
                }
            }
            
        }
        
    }
    fileprivate func setImageType(ipadImg:String,iphone:String,clickType:Int) {
        lastReminderFor += 1
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.reminderPaintBtn.setImage(UIImage(named: ipadImg), for: .normal)
        }else{
            self.reminderPaintBtn.setImage(UIImage(named: iphone ), for: .normal)
        }
        self.clikcedType = clickType
        self.reminderPaintBtn.addTarget(self, action:#selector(reminderVideoButtonClicked), for: .touchUpInside)
        if(lastReminderFor > 2)
        {
            lastReminderFor = 1
        }
        print(lastReminderFor)
    }
    // paintCountLabel hintCountLabel autoMoveCountLabel
    fileprivate func SetReminderImage()
    {
        if(paintCountLabel.isHidden && hintCountLabel.isHidden)
        {
            if(lastReminderFor == 1)
            {
                previousView = "CB"
                setImageType(ipadImg: "coloredBucketiPad", iphone: "coloredBucketiPhone", clickType: 2)
                return
            }
            else if(lastReminderFor == 2)
            {
                previousView = "CH"
                setImageType(ipadImg: "coloredhintIpad", iphone: "coloredHintIphone", clickType: 1)
                return
            }
        }
        else if(paintCountLabel.isHidden == false && hintCountLabel.isHidden)
        {
            previousView = "CH"
            setImageType(ipadImg: "coloredhintIpad", iphone: "coloredHintIphone", clickType: 1)
            return
            
            
        }
        else if(paintCountLabel.isHidden  && hintCountLabel.isHidden == false)
        {
            
            
            previousView = "CB"
            setImageType(ipadImg: "coloredBucketiPad", iphone: "coloredBucketiPhone", clickType: 2)
            return
            
            
        }
    }
    
    @objc func AddRemindersView()
    {
        if(self.isReminderVisible == 0)
        {
            self.isReminderVisible = 1
            let screenSize: CGRect = UIScreen.main.bounds
            let viewSize = 70
            //self.ReminderView = uiReminderView()
            
            self.ReminderView = UIView(frame: CGRect(x:-viewSize, y: Int(screenSize.height/2), width: viewSize, height: viewSize))
            
            self.reminderPaintBtn = UIButton(frame: CGRect(x:5, y: 5, width: viewSize - 10, height: viewSize - 10))
            reminderPaintLbl = UILabel(frame: CGRect(x:40, y: 12, width: 20, height: 20))
            reminderPaintLbl.text  = String(self.reminderPaintCount) //"10"
            reminderPaintLbl.textColor = UIColor.white
            reminderPaintLbl.backgroundColor = .red
            reminderPaintLbl.clipsToBounds = true
            self.ReminderView.isUserInteractionEnabled = true
            reminderPaintLbl.layer.cornerRadius = 10
            reminderPaintLbl.font.withSize(8)
            reminderPaintLbl.adjustsFontSizeToFitWidth = true
            reminderPaintLbl.textAlignment = NSTextAlignment.center
            SetReminderImage()
            self.reminderPaintBtn.addTarget(self, action:#selector(reminderVideoButtonClicked), for: .touchUpInside)
            
            self.ReminderView.addSubview(reminderPaintBtn)
            self.ReminderView.addSubview(reminderPaintLbl)
            
            self.ReminderView.backgroundColor = UIColor.white
            self.ReminderView.alpha = 1.0
            if self.drawView != nil {
                self.ReminderView.bringSubview(toFront: self.drawView)
            }
            self.ReminderView.layer.cornerRadius = ReminderView.frame.height/2
            self.ReminderView.layer.borderWidth = 4
            self.ReminderView.layer.borderColor = UIColor.gray.cgColor
            if self.ReminderView != nil {
                self.view.addSubview(self.ReminderView)
            }
            if imageName != nil {
                appDelegate.logEvent(name: "Reminder_View", category: "reminder", action: imageName!)
            }
        }
        //appDelegate.window?.addSubview((self.ReminderView)!)
        
        
        
        
    }
    
    
    @objc func removeReminderView()
    {
        self.isReminderVisible = 0
        DispatchQueue.main.async
        {
            if(self.ReminderView != nil)
            {
                SVProgressHUD.dismiss()
                UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                                {
                    let screenSize: CGRect = UIScreen.main.bounds
                    self.ReminderView.frame = CGRect(x: -100, y: screenSize.height/2, width: 20, height: 20)
                }, completion: { (finished: Bool) in
                    
                    if(self.ReminderView != nil){
                        self.ReminderView.removeFromSuperview()
                    }
                    
                })
            }
        }
    }
    
    
    // var counter = 1
    @objc func ShowReminderUI()
    {
        //  var ddd  = self.counterTime
        // Check low internet
        print(self.counterTime)
        print("counterTime...")
        self.startReminderTimer()
    }
    
    
    @objc func completed() {
        timer.invalidate()
        timer = nil
        var reminderFailed = false
        if((paintCountLabel.isHidden || hintCountLabel.isHidden || autoMoveCountLabel.isHidden) && self.isReminderVisible == 0 &&
           self.isInternetAvailable() && self.isHintPaintVisible == 0 && self.isSubscriptionViewVisible == 0 && useToolArray.count > 0 && self.isVideoViewOpen == false) {
            self.isFirstLaunchDrawingScreenShow = true
        }
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if (((appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (appDelegate.purchaseType() == .kPurchaseTypeNonConsumable))
        {
            print("IS_EXPIRED No")
        }
        else{
            if((paintCountLabel.isHidden || hintCountLabel.isHidden) && self.isReminderVisible == 0 &&
               self.isInternetAvailable() && self.isHintPaintVisible == 0 && self.isSubscriptionViewVisible == 0 && useToolArray.count > 0 && self.isVideoViewOpen == false)
            {
                DispatchQueue.main.async
                {
                    let loadAd = UserDefaults.standard.bool(forKey: REWARD_LOAD)
                    
                    if self.rewardedAdHelper?.rewardedAd != nil && loadAd != false  {
                        self.AddRemindersView()
                        self.viewReminder()
                        
                    } else {
                        self.loadAd()
                        reminderFailed = true
                    }
                }
            }
            self.startReminderTimer(previousReminderFailed: reminderFailed)
        }
        
    }
    
    
    
    func loadServerImage(name: NSString)
    {
        let recordID2 = CKRecordID(recordName:name.deletingPathExtension)
        
        CKContainer.default().publicCloudDatabase.fetch(withRecordID: recordID2) { record, error in
            guard let record = record, error == nil else {
                // show off your error handling skills
                return
            }
            print("\n\n\n  saving image to Server image\n\n\n")
            let fileData = record.object(forKey: "data") as! Data
            let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(name as String)
            let fileManager = FileManager.default
            if !fileManager.fileExists(atPath: paths){
                fileManager.createFile(atPath: paths, contents: fileData, attributes: nil)
            }
            //print("The user record is: \(record)")
        }
        
    }
    
    //MARK: FaveButton Delegate.
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if(faveButton === loveBtn){
            return colors
        }
        return nil
    }

}
extension UIView {
    func addDashedBorder() {
        let color = UIColor.red.cgColor
        let shapeLayer:CAShapeLayer = CAShapeLayer()
        let frameSize = self.frame.size
        let shapeRect = CGRect(x: 0, y: 0, width: frameSize.width, height: frameSize.height)
        
        shapeLayer.bounds = shapeRect
        //shapeLayer.bounds = (shapeLayer.path?.boundingBox)!
        shapeLayer.position = CGPoint(x: frameSize.width/2, y: frameSize.height/2)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.strokeColor = color
        shapeLayer.lineWidth = 4
        shapeLayer.lineJoin = kCALineJoinRound
        shapeLayer.lineDashPattern = [15,3]
        shapeLayer.path = UIBezierPath(roundedRect: shapeRect, cornerRadius: frameSize.height/2).cgPath
        var repeated = true
        var timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) {
            (_) in
            if(repeated){
                self.layer.addSublayer(shapeLayer)
                repeated = false
                self.layer.borderColor = UIColor.clear.cgColor
                
            }
            else{
                repeated = true
                self.layer.sublayers?.popLast()
                self.layer.borderColor = UIColor.gray.cgColor
            }
        }
        
    }
}

// Need to Comments out To-do shoaib
let screenSize: CGRect = UIScreen.main.bounds
var preActiveIndex = -1
extension HomeVC:GifTutorialCloseTappedDelegate {
    func GifTutorialCloseTapped() {
        self.hideShowTool(activeView:self.hintView,isHidden:false)
        preActiveIndex = -1
        appDelegate.logEvent(name: "Tutorial_p2", category: "Tutorial", action: "Viewing tutorial 5-7")
    }
    
    func hideShowTool(activeView:UIView,isHidden:Bool)
    {
        self.hintView.isHidden = false
        self.paintView.isHidden = false
        self.pickerView.isHidden = false
        activeView.isHidden = isHidden
    }
    func GifTutorialGetActiveIndex(activeIndex: Int, toolImage:UIImageView ){
        
        
        
        let hintBtnFram = self.hintView.frame
        let paintBtnFram = self.paintView.frame
        let autoMoveBtnFram = self.pickerView.frame
        let diff = hintBtnFram.origin.x - paintBtnFram.origin.x
        let automoveDiff = autoMoveBtnFram.origin.x - hintBtnFram.origin.x
        
        var r : CGRect = toolImage.frame;
        
        var offsetY_iPhoneX: CGFloat = 4
        
        if (screenSize.height == 812)
        {
            offsetY_iPhoneX = 24
            r.origin.y =  self.view.frame.size.height-(self.colorAndPaintView.frame.size.height+offsetY_iPhoneX);
        }
        else{
            r.origin.y =  (self.view.frame.size.height-self.colorAndPaintView.frame.size.height)+offsetY_iPhoneX;
        }
        if UIDevice.current.userInterfaceIdiom == .pad{
            r.origin.x =  (self.view.frame.size.width / 2 ) - 25;
        }else{
            r.origin.x =  (self.view.frame.size.width / 2 ) - 15;
        }
        
        
        toolImage.frame = r;
        if (activeIndex == 0 )
        {
            
            preActiveIndex = 0
            toolImage.isHidden = false
            if (UI_USER_INTERFACE_IDIOM() == .pad){
                r.origin.x -= 50;
            } else{
                r.origin.x -= 40;
            }
            toolImage.frame = r;
            UIView.transition(with: toolImage,
                              duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: {  toolImage.image = UIImage(named: "coloredBucketiPad") },
                              completion: nil)
            
            self.hideShowTool(activeView:self.paintView,isHidden:true)
            
        }
        else if (activeIndex == 1 )
        {
            
            preActiveIndex = 1
            toolImage.isHidden = false
            if (UI_USER_INTERFACE_IDIOM() == .pad){
                r.origin.x += 50;
            } else{
                r.origin.x += 30;
            }
            
            toolImage.frame = r;
            UIView.transition(with: toolImage,
                              duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: {  toolImage.image = UIImage(named: "coloredhintIpad") },
                              completion: nil)
            
            self.hideShowTool(activeView:self.hintView,isHidden:true)
        }
        else  if (activeIndex == 2)
        {
            
            preActiveIndex = 2
            toolImage.isHidden = false
            r.origin.x += automoveDiff;
            toolImage.frame = r;
            UIView.transition(with: toolImage,
                              duration:0.5,
                              options: .transitionCrossDissolve,
                              animations: {  toolImage.image = UIImage(named: "coloredPickerIpad") },
                              completion: nil)
            self.hideShowTool(activeView:self.pickerView,isHidden:true)
            
        }
        
    }
    
}

extension UIImageView {
    func maskWith(color: UIColor) {
        guard let tempImage = image?.withRenderingMode(.alwaysTemplate) else { return }
        image = tempImage
        tintColor = color
    }
    
}

extension UIColor {
    func lighter(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: abs(percentage))?.withAlphaComponent(0.3)
    }

    func darker(by percentage: CGFloat = 30.0) -> UIColor? {
        return self.adjust(by: -1 * abs(percentage))?.withAlphaComponent(0.3)
    }

    func adjust(by percentage: CGFloat = 30.0) -> UIColor? {
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if self.getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            let adjustedRed = min(max(red + percentage / 100, 0.0), 1.0)
            let adjustedGreen = min(max(green + percentage / 100, 0.0), 1.0)
            let adjustedBlue = min(max(blue + percentage / 100, 0.0), 1.0)

            return UIColor(red: adjustedRed, green: adjustedGreen, blue: adjustedBlue, alpha: alpha)
        } else {
            return nil
        }
    }
}




