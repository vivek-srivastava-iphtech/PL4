//
//  PlayVideoVC.swift
//  PL2
//
//  Created by iPHTech8 on 10/6/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit
import CoreMedia
import Photos
import SVProgressHUD
import StoreKit
import Social
import FBSDKShareKit
import FBSDKCoreKit
import GoogleMobileAds
import SystemConfiguration

enum kButtonType {
    case kButtonTypeSave
    case kButtonTypeShare
    case kButtonTypeInstagram
    case kButtonTypeFacebook
}

class PlayVideoVC: UIViewController, UIDocumentInteractionControllerDelegate,customAwardViewDelegate,awardView,SharingDelegate, RateViewControllerDelegate, RewardedAdHelperDelegate, InterstitialAdHelperDelegate {
    
    
    let APP_STORE_ID : String = "id1277229792"
    let reviewKey : String = "store_review"
    let paint_count = "PAINT_COUNT"
    
    var shoudReviewApp = true
    var recorderDev = Recorder()
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var isFinished = false
    var scale : CGFloat = 0.2
    var isScaleChange: Bool = false
    var captureViewHeight:CGFloat = 0.2
    var isComplete = false
    var isJustCompleted = false
    var isSharingClicked = false
    var isRedirected = false
    var capturedView2:UIView?
    var capturedViewRecording2:UIView?
    var currentHeight : CGFloat = 0.0
    //    var capturedView2:UIView?{
    //        didSet{
    //            capturedView = capturedView2
    //        }
    //    }
    //    var capturedViewRecording2:UIView?{
    //        didSet{
    //            capturedViewRecording = capturedViewRecording2
    //        }
    //    }
    //var capturedView:UIView?
    var pointsArray : [(CGPoint,UIColor)] = []
    var pointAndColorArray = [PointAndColor]()
    var pointAndColorArrayRecording = [PointAndColor]()
    //Shoib
    var countArray = [PointAndColor]()
    var squareWidth = CGFloat()
    
    var sharingEnable = false
    var recordingStarted = false
    var recordingEnded = false
    var isVideoSharing = true
    
    var isSharedOnInstagram = false
    var isRewardActive = false
    
    var draw_point_count = 1
    var videoFileURL:URL?
    var imageFileURL:URL?
    var localIdentifier:String?
    var localIdentifierVideo:String?
    var localIdentifierImage:String?
    
    
    //var viewForVideo = UIView()
    var backImg = UIImage()
    var sharingView = UIView()
    var buttonTypeSharing = 0//1-Save||2-insta||3-facebook||4-Other
    
    // Ads
    
    //MARK: Reward Ad Helper
    private var rewardedAdHelper = RewardedAdHelper()
    
    //MARK: Inhetitance Ad Helper
    private var interstitialAdHelper = InterstitialAdHelper()
    // Replace this with new Add-Id
    let INTERSTITIAL_AD_ID = "ca-app-pub-7682495659460581/7313761854"
    
    
    var sharingViewAlreadyOpen = false
    var sharableImage = UIImage()
    var isWatermarkAdded : Bool = false
    var imageData = ImageData()
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var instagramButton: UIButton!
    @IBOutlet weak var facebookButton: UIButton!
    @IBOutlet weak var backView: UIView!
    @IBOutlet weak var toolView: UIView!
    @IBOutlet weak var shareSwitch: UISwitch!
    
    @IBOutlet weak var pictureShareImg: UIImageView!
    @IBOutlet weak var videoShareImg: UIImageView!
    
    @IBOutlet var viewForVideo: UIView!
    @IBOutlet weak var viewForVideoRecording: UIView!
    @IBOutlet var capturedView: UIView!
    @IBOutlet weak var capturedViewRecording: UIView!
    @IBOutlet var btnHasTag: UIButton!
    @IBOutlet var lblCopyHasTag: UILabel!
    @IBOutlet weak var rewardw1View: UIView!
    @IBOutlet weak var shareToGetButton: UIButton!
    
    ////Shoib
    @IBOutlet weak var progressBar: CircularProgressBar!
    @IBOutlet weak var instaProgressBar: CircularProgressBar!
    @IBOutlet weak var saveProgressBar: CircularProgressBar!
    @IBOutlet weak var ShareProgressBar: CircularProgressBar!
    var percent = 0.0
    var cnt = 0
    var fromFB:Bool = false
    var fromInsta:Bool = false
    var fromShare:Bool = false
    var fromSave:Bool = false
    
    //var displayLinkTemp : CADisplayLink?
    var isGifTutorialImage = false
    var totalHorizontalgrids = Int()
    
    var rateViewController: RateViewController!
    
    var sizeOfImage = 0
    var type:kButtonType = .kButtonTypeSave
    
    var isreward :Bool = true;
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("---- Play Video Screen ----")
        setNeedsStatusBarAppearanceUpdate()
        
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground(_:)), name: .UIApplicationWillEnterForeground, object: nil)
        let imageName = self.imageData.name
        if let imgName = imageName{
            if let image = UIImage(named:imgName){
                totalHorizontalgrids = Int(image.size.width * image.scale)//Lekha Consider 1 pixel of image is equal to 1 block
                
                
            }
            else
            {
                let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent(imgName as String)
                
                let fileManager = FileManager.default
                
                if fileManager.fileExists(atPath: paths){
                    
                    let image = UIImage(contentsOfFile:paths)
                    totalHorizontalgrids = Int(image!.size.width * image!.scale)//Lekha Consider 1 pixel of image is equal to 1 block
                    
                }
            }
        }
        
        
        laodConfiguration()
        recorderDev.getVideoPath=self
        lblCopyHasTag.text = NSLocalizedString("copy hashtag", comment: "")
        self.rewardw1View.isHidden = true
        
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(userInterface == .pad)
        {
            NotificationCenter.default.addObserver(self, selector: #selector(self.rotated), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        }
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        currentHeight = self.view.frame.size.height
        
        //To do Shoaib
        self.shareButton.layer.cornerRadius = 0.5 * shareButton.bounds.size.width
        self.saveButton.layer.cornerRadius = self.saveButton.frame.size.height/2.0
        self.instagramButton.layer.cornerRadius = self.instagramButton.layer.frame.height/2
        self.facebookButton.layer.cornerRadius = self.facebookButton.layer.frame.height/2
        
        
        //To do Shoaib
        self.setupProgressBar()
        
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
        
        if(shouldShowAds){
            self.adLoadCall(isreward: isreward)
        }
        else {
            print("--- Ad should not called ----")
        }
    }
    
    func adLoadCall(isreward: Bool) {
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if(isExpired == "YES" || isExpired == nil){
            
            if isreward
            {
                rewardedAdHelper.rewardId = PAGES_MY_WORK_REWARD_Id
                rewardedAdHelper.loadRewardedAd(adId: PAGES_MY_WORK_REWARD_Id)
                rewardedAdHelper.delegate = self
            }
            else {
                interstitialAdHelper.loadInterstitial()
                interstitialAdHelper.delegate = self
            }
        }
    }
    
    func dismissRewardedAd() {
        DispatchQueue.main.async {
            self.view.isHidden = true
        }
    }
    
    func dismissIntersialAd() {
        DispatchQueue.main.async {
            self.view.isHidden = true
        }
    }
    
    func showReward(rewardAmount: String, status: String) {
        if status == "Success" {
            print("Reward ad received for Play Video View")
            print("Play VideoVC - RewardAD ID : \(PLAY_VIDEO_SCREEN_REWARD_Id)")

        }
        else {
            print("Please try Again PV!")
            appDelegate.logEvent(name: "No_Reward_Video", category: "Ads", action: "VC")
        }
    }
    
    func showInterstitialMessage(message: String, status: String) {
        if status == "Success" {
            print("Intersial ad received for Play Video View")
            print("PlayVideo VC - IntersialAD ID : \(INTERSIAL_AD_Unit_Id)")

        }
        else {
            print("Please try Again PV IT!!")
            appDelegate.logEvent(name: "No_IN_Video", category: "Ads", action: "VC")
        }
    }
    
    func setupProgressBar(){
        progressBar.safePercent = 100
        progressBar.lineColor = UIColor(red: 74.0/255.0, green: 160.0/255.0, blue: 221.0/255.0, alpha: 1)
        progressBar.lineFinishColor = .red
        progressBar.lineBackgroundColor =  UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.00)
        
        instaProgressBar.safePercent = 100
        instaProgressBar.lineColor = UIColor(red: 74.0/255.0, green: 160.0/255.0, blue: 221.0/255.0, alpha: 1)
        instaProgressBar.lineFinishColor = .red
        instaProgressBar.lineBackgroundColor =  UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.00)
        
        ShareProgressBar.safePercent = 100
        ShareProgressBar.lineColor = UIColor(red: 74.0/255.0, green: 160.0/255.0, blue: 221.0/255.0, alpha: 1)
        ShareProgressBar.lineFinishColor = .red
        ShareProgressBar.lineBackgroundColor =  UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.00)
        
        saveProgressBar.safePercent = 100
        saveProgressBar.lineColor = UIColor(red: 74.0/255.0, green: 160.0/255.0, blue: 221.0/255.0, alpha: 1)
        saveProgressBar.lineFinishColor = .red
        saveProgressBar.lineBackgroundColor =  UIColor(red: 0.69, green: 0.69, blue: 0.69, alpha: 1.00)
        
        self.progressBar.isHidden = true
        self.saveProgressBar.isHidden = true
        self.ShareProgressBar.isHidden = true
        self.instaProgressBar.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tabBarController?.tabBar.isHidden = true
        self.recordingEnded = false
        self.recordingStarted = false
        
        appDelegate.logScreen(name: "Video Screen")
        
    }
    
    @objc func rotated() {
        
        let interfaceOrientation: UIDeviceOrientation = UIDevice.current.orientation
        if UIDeviceOrientationIsLandscape(interfaceOrientation) || view.frame.height < view.frame.width
        {
            if(currentHeight != view.frame.height){
                currentHeight = view.frame.height
                self.getScale()
                capturedView?.transform = CGAffineTransform(scaleX:  scale, y: scale)
                capturedViewRecording?.transform = CGAffineTransform(scaleX:  scale, y: scale)//Dev Added
                
                self.rewardw1View.translatesAutoresizingMaskIntoConstraints = false
                self.rewardw1View.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
                UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
                    
                    self.rewardw1View.frame.origin.y -= 10
                })
            }
        }
        else if UIDeviceOrientationIsPortrait(interfaceOrientation)  || view.frame.height > view.frame.width
        {
            if(currentHeight != view.frame.height){
                
                currentHeight = view.frame.height
                getScale()
                capturedView?.transform = CGAffineTransform(scaleX:  scale, y: scale)
                capturedViewRecording?.transform = CGAffineTransform(scaleX:  scale, y: scale)//Dev Added
                guard let capturedViewheight = capturedView?.frame.size.height else { return }
                let yVal = (backView.frame.size.height - (capturedViewheight))///2
                viewForVideoRecording.frame = CGRect(x: (backView.frame.size.width - (capturedViewRecording?.frame.size.height)!)/2, y: yVal, width: (capturedViewRecording?.frame.size.width)! , height: (capturedViewRecording?.frame.size.height)!)
                capturedViewRecording?.frame.origin = CGPoint(x: 0, y: 0)
                
                viewForVideo?.frame = CGRect(x: (backView.frame.size.width - ((capturedView?.frame.size.height)!))/2, y: yVal, width: (capturedView?.frame.size.width)! , height: (capturedView?.frame.size.height)!)
                capturedView?.frame.origin = CGPoint(x: 0, y: 0)
                self.rewardw1View.translatesAutoresizingMaskIntoConstraints = false
                self.rewardw1View.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
                UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
                    self.rewardw1View.frame.origin.y -= 10
                })
                
            }
        }
    }
    
    
    //MARK:  Didload Configuration
    func laodConfiguration()
    {
        if(isGifTutorialImage == true || isComplete == true  ){
            backButton.isHidden = true
        }else
        {
            backButton.isHidden = false
            
        }
        
        capturedView.frame = CGRect(x:0,y:0,width:((capturedView2?.frame.size.width)!),height:(capturedView2?.frame.size.height)!)
        capturedViewRecording.frame = CGRect(x:0,y:0,width:(capturedViewRecording2?.frame.size.width)!,height:(capturedViewRecording2?.frame.size.height)!)
        captureViewHeight = (capturedView?.frame.height)!
        print(captureViewHeight)
        print("captureViewHeight")
        if let _ = capturedView{
            
            getScale()
            
            if (capturedView?.frame.width)! < self.view.bounds.width{
                if (capturedView?.frame.height)! < self.view.bounds.height - 140{
                    scale = 1.0
                }
            }
            capturedView?.transform = CGAffineTransform(scaleX: scale, y: scale)
            capturedViewRecording?.transform = CGAffineTransform(scaleX: scale, y: scale)//Dev Added
            
            var yVal = (backView.frame.size.height - (capturedView?.frame.size.height)!)/2
            viewForVideoRecording.frame = CGRect(x: (backView.frame.size.width - (capturedViewRecording?.frame.size.height)!)/2, y: yVal, width: (capturedViewRecording?.frame.size.width)! , height: (capturedViewRecording?.frame.size.height)!)
            capturedViewRecording?.frame.origin = CGPoint(x: 0, y: 0)
            capturedViewRecording?.backgroundColor = UIColor(patternImage: backImg)
            viewForVideoRecording.backgroundColor = UIColor.white
            viewForVideo.frame = CGRect(x: (backView.frame.size.width - (capturedView?.frame.size.height)!)/2, y: yVal, width: (capturedView?.frame.size.width)! , height: (capturedView?.frame.size.height)!)
            capturedView?.frame.origin = CGPoint(x: 0, y: 0)
            capturedView?.backgroundColor = UIColor(patternImage: backImg)
            viewForVideo.backgroundColor = UIColor.white
        }
        
        if let isReviewed = UserDefaults.standard.value(forKey: reviewKey){
            
            shoudReviewApp = !(isReviewed as! (Bool))
        }
        
        if(isGifTutorialImage)
        {
            shoudReviewApp = false
        }
        
        
        // self.disableSharing()
        if self.pointAndColorArray.count > 0{
            let val = self.pointAndColorArray.count/400
            if self.pointAndColorArray.count < 120
            {
                draw_point_count = 1
            }
            else
            {
                draw_point_count = val + 2
            }
        }
        
        self.perform(#selector(timeLapseStart), with: nil, afterDelay: 0.1)
        self.perform(#selector(videoRecordingStart), with: nil, afterDelay: 0.1)//Dev Added
        
        
        shareSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
        let pictureTap = UITapGestureRecognizer(target: self, action: #selector(pictureTapDetected))
        pictureShareImg.isUserInteractionEnabled = true
        pictureShareImg.addGestureRecognizer(pictureTap)
        
        let videoTap = UITapGestureRecognizer(target: self, action: #selector(videoTapDetected))
        videoShareImg.isUserInteractionEnabled = true
        videoShareImg.addGestureRecognizer(videoTap)
    }
    
    //MARK: picture tap action
    @objc func pictureTapDetected()
    {
        if shareSwitch.isOn {
            shareSwitch.setOn(false, animated: true)
            isVideoSharing = false
            appDelegate.logEvent(name: "Picture_tap", category: "Video Screen", action: "Picture Click")
        }
    }
    
    //MARK: video tap action
    @objc func videoTapDetected()
    {
        if !shareSwitch.isOn {
            shareSwitch.setOn(true, animated: true)
            isVideoSharing = true
            appDelegate.logEvent(name: "Video_tap", category: "Video Screen", action: "Video Click")
        }
    }
    //MARK: Sharing Awitch Action
    
    @objc func switchValueDidChange(_ sender: UISwitch)  {
        if sender.isOn {
            //Video
            isVideoSharing = true
            appDelegate.logEvent(name: "Video_Switch", category: "Video Screen", action: "Video Click")
            
        } else {
            //Picture
            isVideoSharing = false
            appDelegate.logEvent(name: "Picture_Switch", category: "Video Screen", action: "Picture Click")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUpdate()
        
    }
    
    func layoutUpdate()
    {
        if(capturedView != nil){
            var yVal = (backView.frame.size.height - ((capturedViewRecording?.frame.size.height)!))
            if UIDevice.current.userInterfaceIdiom == .pad
            {
                if(yVal > 0){
                    
                }
                else
                {
                    yVal = (backView.frame.size.height - (capturedViewRecording?.frame.size.height)!)/2
                }
            }
            else
            {
                let screenSize: CGRect = UIScreen.main.bounds
                if (screenSize.height == 812)
                {
                    yVal = (backView.frame.size.height - ((capturedViewRecording?.frame.size.height)! + 25))
                }
            }
            
            viewForVideoRecording.frame = CGRect(x: (backView.frame.size.width - (capturedViewRecording?.frame.size.height)!)/2, y: yVal, width: (capturedViewRecording?.frame.size.width)! , height: (capturedViewRecording?.frame.size.height)!)//Dev Added
            if viewForVideo != nil
            {
                viewForVideo.frame = CGRect(x: (backView.frame.size.width - (capturedView?.frame.size.height)!)/2, y: yVal, width: (capturedView?.frame.size.width)! , height: (capturedView?.frame.size.height)!)
            }
            viewForVideoRecording.setNeedsDisplay()
            viewForVideo.setNeedsDisplay()
        }
    }
    
    
    
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.isFinished = true
        self.rewardedAdHelper.rewardedAd = GADRewardedAd()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if(isExpired == "YES" || isExpired == nil){
          

        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        self.recorderDev.stop(input: "pl",isVideo: false, completion: { fileOutpurURL,imageUrl  -> Void in
            DispatchQueue.main.async {self.recorderDev = Recorder()}
        })
        
        if (self.isMovingFromParentViewController || self.isBeingDismissed) {
            self.clearPL2Folder()
        }
        
        sharingView.removeFromSuperview()
        viewForVideo.removeFromSuperview()
    }
    
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    
    func getScale(){
        var fitSize = self.view.bounds.width
        if(UIDevice.current.userInterfaceIdiom == .pad){
            if appDelegate.isLandscapeByMe()
            {
                fitSize = self.view.bounds.height - (toolView.bounds.height + backButton.bounds.height + (backButton.frame.origin.y))
            }
            else
            {
                fitSize = self.view.bounds.height - (toolView.bounds.height + backButton.bounds.height + (backButton.frame.origin.y + 50))
            }
            //
            //            fitSize = self.view.bounds.width
            //            fitSize = self.view.bounds.height - (toolView.bounds.height + backButton.bounds.height + (backButton.frame.origin.y + 50))
            //            scale = fitSize/captureViewHeight
            //            print(scale)
            // print("scale shoaib")
        }
        else {
            let modelName = UIDevice.modelName
            if(modelName.contains("iPhone 5"))
            {
                fitSize -= 5
            }
        }
        self.scale = fitSize/(squareWidth * CGFloat(totalHorizontalgrids))
    }
    
    
    //MARK:- Custom Methods
    
    func clearPL2Folder()
    {
        let fileManager = FileManager.default
        let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let appPath = documentsPath1.appendingPathComponent("PL2")
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: (appPath?.path)!)
            for filePath in filePaths
            {
                let pPath = "\((appPath?.path)!)/"
                try fileManager.removeItem(atPath: pPath + filePath)
            }
        } catch
        {
            //print("Could not clear PL2 folder: \(error)")
        }
    }
    
    @objc func timeLapseStart()
    {
        if self.pointAndColorArray.count > 0{
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.00001 , execute: {
                self.drawView()
            })
        }
    }
    
    
    func drawFirstPoint() {
        if let point = self.pointAndColorArray.first{
            let x = point.points.x
            let y = point.points.y
            let rectanglePath = UIBezierPath(roundedRect: CGRect(x:x, y:y , width: self.squareWidth - 0.5, height: self.squareWidth - 0.5), cornerRadius: 0)
            
            let a = CAShapeLayer()
            a.path = rectanglePath.cgPath
            a.strokeColor = point.fillColor.cgColor
            a.fillColor   = point.fillColor.cgColor
            a.opacity = 1.0
            if self.capturedView != nil
            {
                self.capturedView?.layer.insertSublayer(a, at: 1)
                self.view.bringSubview(toFront: capturedView)
            }
            
            //To do Shoaib
            let val = self.countArray.count - self.pointAndColorArray.count
            self.cnt = val
            self.pointAndColorArray.removeFirst()
        }
    }
    
    func drawView(){
        let dispatchTime = DispatchTime.now() +  0.06
        DispatchQueue.main.asyncAfter(deadline: dispatchTime , execute: {
            [weak self] in
            guard let self = self else { return }
            for _ in 0 ..< self.draw_point_count {
                
                self.drawFirstPoint()
                self.drawFirstPoint()
                self.drawFirstPoint()
                let tempPercent = self.findPercentageDividation(count: self.cnt)
                if(tempPercent > self.percent){
                    self.percent = tempPercent
                 self.setProgressOfView()
                }
                
            }
            
            //To do Shoaib
            
            
            
            if self.pointAndColorArray.count == 0{
                
                self.isFinished = true
                
                var arrayCompleted = [String]()
                let defaults = UserDefaults.standard
                if defaults.array(forKey: Completed_ID_Key) != nil
                {
                    
                    arrayCompleted = getCompletedImagesIDArray()
                    if arrayCompleted.count == reviewWindowX && self.isComplete == true && self.isJustCompleted == true {
                        self.openRatePopupView(value: true)
                    }
                    else if (arrayCompleted.count >= (reviewWindowX + reviewWindowY)) && ((arrayCompleted.count - reviewWindowX) % reviewWindowY == 0) {
                        if self.isComplete == true && self.isJustCompleted == true {
                            self.openRatePopupView(value: true)
                        }
                    }
                }
                
                if(self.isSharingClicked == false)
                {
                    if self.shoudReviewApp && self.isComplete && self.isJustCompleted{
                        self.openRatePopupView()
                    }
                }
                else if(self.isSharingClicked && (self.buttonTypeSharing == 0 || self.buttonTypeSharing == 1))
                {
                    if self.shoudReviewApp && self.isComplete && self.isJustCompleted{
                        self.openRatePopupView()
                    }
                }
                
                let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
                
                if !(((self.appDelegate.purchaseType() == .kPurchaseTypeWeekSubscription) && isExpired == "NO") || (self.appDelegate.purchaseType() == .kPurchaseTypeNonConsumable)) // No subscription
                {
                    // #141 Task
                    if (self.isComplete && self.isJustCompleted && self.isGifTutorialImage){
                        self.showAmazingOption()
                    }
                    
                    else if (self.isComplete && self.isJustCompleted && !(self.isFirstImage()) && self.checkIfAlreadyShared() && self.checkSessionLimitForPopUp()){
                        let arrayCompleted = getCompletedImagesIDArray()
                        if(arrayCompleted.count > 1){
                            
                            // shoaib
                            //self.showRewardOption()
                            
                            self.shareToGetButton.setTitle(NSLocalizedString("share to get 10 Paint Buckets", comment: ""), for: .normal)
                            self.rewardw1View.isHidden = false
                            
                            //                                UIView.animate(withDuration: 1, animations: {
                            //                                    self.rewardw1View.frame.size.width += 50
                            //                                    self.rewardw1View.frame.size.height += 20
                            self.rewardw1View.center.x += 0
                            
                            //                                }) { _ in
                            self.rewardw1View.translatesAutoresizingMaskIntoConstraints = false
                            let height = Int(self.view.frame.height)
                            switch height {
                            case 812:
                                self.rewardw1View.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
                            case 896:
                                self.rewardw1View.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -60).isActive = true
                            default:
                                self.rewardw1View.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -20).isActive = true
                            }
                            
                            UIView.animate(withDuration: 1, delay: 0.25, options: [.autoreverse, .repeat], animations: {
                                self.rewardw1View.frame.origin.y -= 10
                            })
                            //}
                            
                            self.appDelegate.logEvent(name: "Reward_w1", category: "Reward Screen", action: self.imageData.name!)
                            self.isRewardActive = true
                            let sessionLimit = UserDefaults.standard.integer(forKey: SESSION_LIMIT)
                            UserDefaults.standard.set(sessionLimit - 1, forKey: SESSION_LIMIT)
                        }
                    }
                }
            }
            else
            {
                self.drawView()
            }
        })
    }
    
    ////Dev Added
    //MARK: Video Recording Start videoRecordingStart
    @objc func videoRecordingStart()
    {
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.00001 , execute: {//
            
            if self.recordingStarted == false
            {
                self.recordingStarted = true
                self.recorderDev.view = self.viewForVideoRecording
                self.recorderDev.imageDataR = self.imageData
                self.recorderDev.start()
                print("recorderDev.start")
                
                
            }
            self.drawViewRecording()
        })
    }
    
    //MARK: draw View For recording
    func drawViewRecording(){
        var isIphoneXFamilyDeivce = false
        let height = Int(self.view.frame.height)
        switch height {
        case 812:
            isIphoneXFamilyDeivce = true
        case 896:
            isIphoneXFamilyDeivce = true
        default:
            isIphoneXFamilyDeivce = false
        }
        
        
        let dispatchTime = DispatchTime.now() + 0.06
        DispatchQueue.main.asyncAfter(deadline: dispatchTime , execute:
                                        {
                                            for _ in 0 ..< self.draw_point_count {
                                                
                                                if isIphoneXFamilyDeivce {
                                                    
                                                    if self.sizeOfImage >= 60 {
                                                        
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                    }
                                                    else {
                                                        
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                    }
                                                }
                                                else {
                                                    
                                                    if self.sizeOfImage >= 60 {
                                                        
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                    }
                                                    else {
                                                        
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                        self.drawFirstPointForRecording()
                                                    }
                                                    
                                                }
                                            }
                                            
                                            if self.pointAndColorArrayRecording.count == 0{
                                                
                                                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.001, execute:
                                                                                {
                                                                                    if self.recordingEnded == false
                                                                                    {
                                                                                        print("recorderDev.stop")
                                                                                        self.recordingEnded = true
                                                                                        self.recorderDev.stop(input: "pl",isVideo: true
                                                                                                              ,completion: { fileOutpurURL,imageUrl  -> Void in
                                                                                                                // print(imageUrl.path)
                                                                                                              })
                                                                                    }
                                                                                })
                                            }
                                            else
                                            {
                                                self.drawViewRecording()
                                            }
                                        })
        

    }
    
    //MARK: Draw Pixels for recordings
    func drawFirstPointForRecording() {
        
        DispatchQueue.main.async {
            if let point = self.pointAndColorArrayRecording.first{
                let x = point.points.x
                let y = point.points.y
                let rectanglePath = UIBezierPath(roundedRect: CGRect(x:x, y:y , width: self.squareWidth - 0.5, height: self.squareWidth - 0.5), cornerRadius: 0)
                
                let a = CAShapeLayer()
                a.path = rectanglePath.cgPath
                a.strokeColor = point.fillColor.cgColor
                a.fillColor   = point.fillColor.cgColor
                a.opacity = 1.0
                self.capturedViewRecording?.layer.insertSublayer(a, at: 1)
                self.pointAndColorArrayRecording.removeFirst()
                
            }
        }
    }//Dev Added
    
    func removeAllAnimationsForControls() {
        self.shareButton.layer.removeAllAnimations()
        self.saveButton.layer.removeAllAnimations()
        self.instagramButton.layer.removeAllAnimations()
        self.facebookButton.layer.removeAllAnimations()
    }
    
    func loaderAnimation(btn:UIButton, type:kButtonType)
    {
        self.removeAllAnimationsForControls()
        self.type = type
        // btn.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration:0.3, delay:0.0, options:[.curveEaseInOut,.repeat,.autoreverse],animations: { () -> Void in
            //  btn.transform = CGAffineTransform(scaleX: 1, y: 1)
            
            switch type {
            case kButtonType.kButtonTypeShare:
                self.shareHide()
                self.ShareProgressBar.setProgress(to: self.percent, withAnimation: true)
                break;
            case kButtonType.kButtonTypeInstagram:
                self.instaHide()
                self.instaProgressBar.setProgress(to: self.percent, withAnimation: true)
                break;
            case kButtonType.kButtonTypeFacebook:
                self.faceHide()
                self.progressBar.setProgress(to: self.percent, withAnimation: true)
                break;
            case kButtonType.kButtonTypeSave:
                self.saveHide()
                self.saveProgressBar.setProgress(to: self.percent, withAnimation: true)
                break;
//            default:
//                print("")
            }
            
        }, completion: { (finished) -> Void in
            if self.sharingEnable {
                switch type {
                case kButtonType.kButtonTypeShare:
                    self.shareButtonClicked(self.shareButton)
                    break;
                case kButtonType.kButtonTypeInstagram:
                    self.instagramShareButtonClicked(self.instagramButton)
                    break;
                case kButtonType.kButtonTypeFacebook:
                    self.facebookShareButtonClicked(self.facebookButton)
                    break;
                case kButtonType.kButtonTypeSave:
                    self.saveButtonClicked(self.saveButton)
                    break;
//                default:
//                    self.saveButtonClicked(self.saveButton)
                }
            }
        })
        
    }
    
    //Shoib
    func faceHide(){
        self.ShareProgressBar.isHidden = true
        self.instaProgressBar.isHidden = true
        self.progressBar.isHidden = false
        self.saveProgressBar.isHidden = true
        self.fromShare = false
        self.fromInsta = false
        self.fromFB = true
        self.fromSave = false
        
    }
    
    func instaHide(){
        self.ShareProgressBar.isHidden = true
        self.instaProgressBar.isHidden = false
        self.progressBar.isHidden = true
        self.saveProgressBar.isHidden = true
        self.fromShare = false
        self.fromInsta = true
        self.fromFB = false
        self.fromSave = false
    }
    
    func saveHide(){
        self.ShareProgressBar.isHidden = true
        self.instaProgressBar.isHidden = true
        self.progressBar.isHidden = true
        self.saveProgressBar.isHidden = false
        self.fromShare = false
        self.fromInsta = false
        self.fromFB = false
        self.fromSave = true
    }
    
    func shareHide(){
        self.ShareProgressBar.isHidden = false
        self.instaProgressBar.isHidden = true
        self.progressBar.isHidden = true
        self.saveProgressBar.isHidden = true
        self.fromShare = true
        self.fromInsta = false
        self.fromFB = false
        self.fromSave = false
    }
    
    //Shoib
    public func findPercentageDividation(count:Int) -> Double {
        if count <= 0{
            return 0
        }
        else{
            
            let percentage = (Double((count*100)/(self.countArray.count*2)) / 100)
            return percentage
        }
    }
    
    //Shoaib
    var temp = 0.50
    func setProgressOfView(){
        
        if self.fromFB {
            if pointAndColorArray.count != 0{
                self.progressBar.setProgress(to: self.percent, withAnimation: true)
            }
        }
        if self.fromInsta{
            
            if pointAndColorArray.count != 0{
                self.instaProgressBar.setProgress(to: self.percent, withAnimation: true)
            }
        }
        if self.fromShare{
            
            if pointAndColorArray.count != 0{
                self.ShareProgressBar.setProgress(to: self.percent, withAnimation: true)
            }
        }
        if self.fromSave{
            if pointAndColorArray.count != 0{
                self.saveProgressBar.setProgress(to: self.percent, withAnimation: true)
                
            }
            
        }
    }
    
    func saveVideo(shareOption:kButtonType)
    {
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            self.save(shareOption: shareOption)
        } else {
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    self.save(shareOption: shareOption)
                }
            })
        }
    }
    
    func save(shareOption:kButtonType)
    {
        if isVideoSharing
        {
            if let videoLink = videoFileURL{
                
                if(self.localIdentifierVideo != nil)
                {
                    switch shareOption {
                    case kButtonType.kButtonTypeInstagram:
                        self.localIdentifier = self.localIdentifierVideo
                        self.shareOnInstagram(videoLink: videoLink)
                        break;
                    default:
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: NSLocalizedString("Your video is successfully saved", comment: ""), message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in self.hideProgressBar()
                                
                            })
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }else{
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoLink)
                    }) { saved, error in
                        if saved {
                            //get Local identifier
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                            let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                            self.localIdentifier = fetchResult!.localIdentifier
                            self.localIdentifierVideo = self.localIdentifier
                            //
                            switch shareOption {
                            case kButtonType.kButtonTypeInstagram:
                                self.shareOnInstagram(videoLink: videoLink)
                                break;
                            default:
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: NSLocalizedString("Your video is successfully saved", comment: ""), message: nil, preferredStyle: .alert)
                                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: { _ in self.hideProgressBar()})
                                    alertController.addAction(defaultAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                            }
                        }
                    }
                }
            }
            
        }
        else
        {
            // Vaibhav Code: Start
            //             addWaterMark()
            //Vaibhav Code: End
            
            if let imageLink = imageFileURL{
                if(self.localIdentifierImage != nil)
                {
                    switch shareOption {
                    case kButtonType.kButtonTypeInstagram:
                        self.localIdentifier = self.localIdentifierImage
                        self.shareOnInstagram(videoLink: imageLink)
                        break;
                    default:
                        DispatchQueue.main.async {
                            let alertController = UIAlertController(title: NSLocalizedString("Your image is successfully saved", comment: ""), message: nil, preferredStyle: .alert)
                            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {_ in self.hideProgressBar()})
                            alertController.addAction(defaultAction)
                            self.present(alertController, animated: true, completion: nil)
                        }
                    }
                }else{
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: imageLink)
                    }) { saved, error in
                        if saved {
                            //get Local identifier
                            let fetchOptions = PHFetchOptions()
                            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                            let fetchResult = PHAsset.fetchAssets(with: .image, options: fetchOptions).lastObject
                            self.localIdentifier = fetchResult!.localIdentifier
                            //
                            self.localIdentifierImage = self.localIdentifier
                            switch shareOption {
                            case kButtonType.kButtonTypeInstagram:
                                self.shareOnInstagram(videoLink: imageLink)
                                break;
                            default:
                                DispatchQueue.main.async {
                                    let alertController = UIAlertController(title: NSLocalizedString("Your image is successfully saved", comment: ""), message: nil, preferredStyle: .alert)
                                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {_ in self.hideProgressBar()})
                                    alertController.addAction(defaultAction)
                                    self.present(alertController, animated: true, completion: nil)
                                }
                                
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    // Added by Vaibhav, for watermark over the images
    func addWaterMark()
    {
        do {
            let imageData = try Data(contentsOf: imageFileURL!)
            let image = UIImage(data: imageData)
            
            if let img = image, let _ = UIImage(named: self.getLocalizedWaterMarkImageIphone()) {
                //Added By devendra
                var waterMarkImage = UIImage(named: self.getLocalizedWaterMarkImageIphone())
                var bottomOffset : CGFloat = 0.0
                if UIDevice.current.userInterfaceIdiom == .pad
                {
                    waterMarkImage = UIImage(named: self.getLocalizedWaterMarkImageIpad())
                    bottomOffset = 0.0
                }
                let widthDraw  = img.size.width / 3
                let heightDraw = widthDraw  / 3.5
                let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
                
                UIGraphicsBeginImageContextWithOptions(img.size, false, 1)
                let context = UIGraphicsGetCurrentContext()
                
                context!.setFillColor(UIColor.clear.cgColor)
                context!.fill(rect)
                
                img.draw(in: rect, blendMode: .normal, alpha: 1)
                //waterMarkImage?.draw(in: CGRect(x: img.size.width-(waterMarkImage?.size.width)!, y: img.size.height-20-(waterMarkImage?.size.height)!, width: (waterMarkImage?.size.width)!, height: (waterMarkImage?.size.height)!), blendMode: .normal, alpha: 1.0)
                waterMarkImage?.draw(in: CGRect(x: img.size.width - widthDraw, y: img.size.height-(heightDraw+bottomOffset), width: widthDraw, height: heightDraw), blendMode: .normal, alpha: 1.0)
                
                let result = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                UIGraphicsEndImageContext()
                UIGraphicsEndImageContext()
                if let imageData = UIImageJPEGRepresentation(result!, 0.5) {
                    try? imageData.write(to: imageFileURL!, options: .atomic)
                }
            }
        } catch {
            print("Error loading image : \(error)")
        }
    }
    //Vaibhav - CODE: Start
    
    
    //MARK:- Button actions
    
    @IBAction func shareButtonClicked(_ sender: Any) {
        //Devendra To Do
        self.isSharingClicked = true
        if self.sharingEnable{
            self.shareHide()
            self.ShareProgressBar.setProgress(to: 1, withAnimation: true)
            buttonTypeSharing = 4
            if sharingViewAlreadyOpen == false
            {
                appDelegate.logEvent(name: "V_Share", category: "Video_Screen", action: self.imageData.name!)
                appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "SM")
                appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "SM")
                sharingViewAlreadyOpen = true
                //self.shareVideoAndPhotoView()
                if isVideoSharing
                {
                    self.videoSharingAction()
                }
                else
                {
                    self.pictureSharingAction()
                }
            }
        }
        else
        {
            //self.loaderAnimation(btn: self.facebookButton, type: .kButtonTypeShare)
            self.loaderAnimation(btn: self.shareButton, type: .kButtonTypeShare)
            
        }
    }
    
    @IBAction func backButtonClicked(_ sender: Any) {
        isBackFromHome = true
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func redirectToForward() {
        
        if (isRedirected == false)
        {
            appDelegate.logEvent(name: "Forward_Arrow", category: "Video Screen", action: "Forward Click")
            for vc in (self.navigationController?.viewControllers ?? []) {
                if vc is PagesVC {
                    
                    // When user taps "forward" arrow after viewing Tutorial 1-4, direct user to see "Popular" category
                    if(isGifTutorialImage){
                        UserDefaults.standard.set(0, forKey: "SELECTED_CATEGORY_INDEX")
                        UserDefaults.standard.set("Popular", forKey: "SELECTED_CATEGORY_NAME")
                        UserDefaults.standard.synchronize()
                    }
                    let transition:CATransition = CATransition()
                    transition.duration = 0.5
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    self.navigationController!.view.layer.add(transition, forKey: kCATransition)
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "show_selected_category"), object: nil)
                    _ = self.navigationController?.popToViewController(vc, animated: false)
                    isRedirected = true
                    break
                }
                else if vc is MyWorkVC {
                    let transition:CATransition = CATransition()
                    transition.duration = 0.5
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    self.navigationController!.view.layer.add(transition, forKey: kCATransition)
                    _ = self.navigationController?.popToViewController(vc, animated: false)
                    isRedirected = true
                    break
                }
                else if vc is ExploreViewController {
                    let transition:CATransition = CATransition()
                    transition.duration = 0.5
                    transition.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
                    transition.type = kCATransitionPush
                    transition.subtype = kCATransitionFromRight
                    self.navigationController!.view.layer.add(transition, forKey: kCATransition)
                    _ = self.navigationController?.popToViewController(vc, animated: false)
                    isRedirected = true
                    break
                }
            }
        }
    }
    
    @IBAction func forwordButtonClicked(_ sender: Any)
    {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "release_memory"), object: nil)
        let isExpired = UserDefaults.standard.value(forKey: "IS_EXPIRED") as? String
        if(isExpired == "YES" || isExpired == nil){
            let sessionTime: Int = (UserDefaults.standard.value(forKey: "sessionTime") as? Int)!
            if(sessionTime >= interstitialTime)
            {
                self.redirectToForward()
                var shouldShowAds = self.adsShouldBeCalled()
                var isreward :Bool = true;
                if UserDefaults.standard.value(forKey: "sessionTime") != nil
                {
                    //Manage session time checks of 5 and 10 minutes to show Ads
                    let sessionTime: Int = (UserDefaults.standard.value(forKey: "sessionTime") as? Int)!
    
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
                
                if(shouldShowAds){
                    self.showInterstialAndRewardedAds(isreward: isreward)
                }
            }
            else {
                self.redirectToForward()
            }
        }
        else {
            self.redirectToForward()
        }
        print("---- Play Video Screen Exit----")
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        //Devendra To Do
        self.isSharingClicked = true
        if self.sharingEnable{
            if self.fromSave{
                self.saveHide()
                self.saveProgressBar.setProgress(to: 1, withAnimation: true)
            }
            buttonTypeSharing = 1
            if sharingViewAlreadyOpen == false
            {
                appDelegate.logEvent(name: "V_Download", category: "Video_Screen", action: self.imageData.name!)
                appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "DL")
                sharingViewAlreadyOpen = true
                //self.shareVideoAndPhotoView()
                if isVideoSharing
                {
                    self.videoSharingAction()
                }
                else
                {
                    self.pictureSharingAction()
                }
            }
        }
        else
        {
            self.loaderAnimation(btn: self.saveButton, type: .kButtonTypeSave)
            
        }
    }
    
    @IBAction func instagramShareButtonClicked(_ sender: Any) {
        //Devendra To Do
        
        self.isSharingClicked = true
        if self.sharingEnable{
            self.instaHide()
            self.instaProgressBar.setProgress(to: 1, withAnimation: true)
            buttonTypeSharing = 2
            if sharingViewAlreadyOpen == false
            {
                appDelegate.logEvent(name: "V_Instagram", category: "Video_Screen", action: self.imageData.name!)
                appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "IG")
                appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "IG")
                sharingViewAlreadyOpen = true
                //self.shareVideoAndPhotoView()
                if isVideoSharing
                {
                    self.videoSharingAction()
                }
                else
                {
                    self.pictureSharingAction()
                }
            }
        }
        else
        {
            self.loaderAnimation(btn: self.instagramButton, type: .kButtonTypeInstagram)
            
        }
    }
    
    //MARK:- Facebook Share Button actions
    fileprivate func hideProgressBar() {
          self.instaProgressBar.isHidden = true
            self.saveProgressBar.isHidden = true
            self.ShareProgressBar.isHidden = true
            self.progressBar.isHidden = true
       
    }
    
    @IBAction func facebookShareButtonClicked(_ sender: Any)
    {//Devendra To Do
        self.isSharingClicked = true
        if self.sharingEnable
        {
            self.faceHide()
            self.progressBar.setProgress(to: 1, withAnimation: true)
            buttonTypeSharing = 3
            if sharingViewAlreadyOpen == false
            {
                let facebookURL = URL(string: "fb://app")!
                if UIApplication.shared.canOpenURL(facebookURL as URL) {
                    appDelegate.logEvent(name: "V_FB", category: "Video_Screen", action: self.imageData.name!)
                    appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "FB")
                    appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "FB")
                    sharingViewAlreadyOpen = true
                    //self.shareVideoAndPhotoView()
                    if isVideoSharing
                    {
                        self.videoSharingAction()
                    }
                    else
                    {
                        self.pictureSharingAction()
                    }
                }
                else
                {
                    hideProgressBar()
                    let alertController = UIAlertController(title: "facebook not installed", message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
        else
        {
            self.loaderAnimation(btn: self.facebookButton, type: .kButtonTypeFacebook)
        }
    }
    
    //MARK - Store Review Methods-
    
    func shareOnInstagram(videoLink:URL){
        let instagramURL = NSURL(string: "instagram://app")!
        //let instagramURL2 = NSURL(string: "instagram://library?AssetPath=\(videoLink.absoluteString)")!
        let instagramURL2 = NSURL(string: "instagram://library?LocalIdentifier=\(self.localIdentifier!)")!
        DispatchQueue.main.async {
            
            if UIApplication.shared.canOpenURL(instagramURL as URL)
            {
                
                
                UIApplication.shared.open(instagramURL2 as URL, options: [:], completionHandler:
                                            { (finished:Bool) in
                                                
                                                self.hideProgressBar()
                                                if self.isRewardActive{
                                                    self.isSharedOnInstagram = true
                                                    self.addInSharedImages()
                                                    var paintCount =  UserDefaults.standard.integer(forKey: self.paint_count)
                                                    paintCount = paintCount + 10
                                                    UserDefaults.standard.set(paintCount, forKey: self.paint_count)
                                                }
                                            })
            }
            else
            {
               
                let alertController = UIAlertController(title: "Instagram not installed", message: nil, preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .default, handler: {_ in self.hideProgressBar()})
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
            
        }
    }
    
    
    @objc func requestReview()
    {
        //TO DO DEVENDRA
        //        let alertController = UIAlertController(title: "Congratulations!", message: " Enjoying Color by Number? Give 5 stars to support free updates", preferredStyle: .alert)
        //        let yesAction = UIAlertAction(title: "YES", style: .default, handler: yesButtonclickedAction)
        //        let noAction = UIAlertAction(title: "NO", style: .cancel, handler: nil)
        //        alertController.addAction(yesAction)
        //        alertController.addAction(noAction)
        //        self.present(alertController, animated: true, completion: nil)
        //    }
        
        //MARK: YES BUTTON CLICKED FROM ALERT
        //    func yesButtonclickedAction(action: UIAlertAction) {
        if #available(iOS 10.3, *)
        {
            //Tap a star to rate it on the\nApp Store
            SKStoreReviewController.requestReview()
            
        }
        else
        {
            // Fallback on earlier versions
            self.reiviewAlertController()
        }
        // self.isJustCompleted = false
    }
    
    func reiviewAlertController()
    {
        let appName = Bundle.main.infoDictionary![kCFBundleNameKey as String] as! String
        var suffix = " App"
        let fullAppName = appName + suffix
        
        var titlestr = "\nRate "
        titlestr = titlestr + fullAppName
        
        var messagestr = "If you enjoy using "
        suffix = ",\nwould you mind taking a moment to\nrate it? It won't take more than a\nminute. Thanks for your support!"
        messagestr = messagestr + fullAppName + suffix
        
        var btnStr = "Rate "
        btnStr = btnStr + fullAppName
        
        let alert = UIAlertController(title: titlestr,  message:messagestr, preferredStyle: UIAlertControllerStyle.alert)
        let imagex = (alert.view.frame.size.width/3)-30
        let imageView = UIImageView(frame: CGRect(x: imagex, y: 10, width: 60, height: 60))
        imageView.image = UIImage(named: "AppIcon")
        alert.view.addSubview(imageView)
        let cancelAction = UIAlertAction(title: "Remind me later", style: .default, handler: reiviewAlertActionCancel)
        let okayAction = UIAlertAction(title: btnStr, style: .default, handler: reiviewAlertActionSubmit)
        let noThanksAction = UIAlertAction(title: "No, thanks", style: .default, handler: reiviewAlertActionNoThanks)
        alert.addAction(okayAction)
        alert.addAction(cancelAction)
        alert.addAction(noThanksAction)
        
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func reiviewAlertActionCancel(action: UIAlertAction)
    {
        //print("Cancel")
        appDelegate.logEvent(name: "Review2_remind", category: "Review 2", action: "Remind Me Later")
    }
    func reiviewAlertActionSubmit(action: UIAlertAction)
    {
        //print("Submit")
        appDelegate.logEvent(name: "Review2_rate", category: "Review 2", action: "Rate App")
        let url = URL(string: "itms-apps:itunes.apple.com/us/app/apple-store/id\(APP_STORE_ID)?mt=8&action=write-review")!
        UIApplication.shared.openURL(url)
        
        self.shoudReviewApp = false
        UserDefaults.standard.set(true, forKey: self.reviewKey)
        UserDefaults.standard.synchronize()
    }
    func reiviewAlertActionNoThanks(action: UIAlertAction)
    {
        appDelegate.logEvent(name: "Review2_no", category: "Review 2", action: "No, thanks")
        self.shoudReviewApp = false
        UserDefaults.standard.set(true, forKey: self.reviewKey)
        UserDefaults.standard.synchronize()
    }
    
    func disableSharing() {
        self.saveButton.isEnabled = false
        self.instagramButton.isEnabled = false
        self.facebookButton.isEnabled = false
        self.shareButton.isEnabled = false
    }
    
    func enableSharing() {
        
        self.sharingEnable = true
        self.saveButton.isEnabled = true
        self.instagramButton.isEnabled = true
        self.facebookButton.isEnabled = true
        self.shareButton.isEnabled = true
    }
    
    //MARK: Video & Picture Sharing View
    func shareVideoAndPhotoView()
    {
        let mainScreena = UIScreen.main.bounds
        //Main View
        sharingView = UIView(frame: CGRect(x: 0, y: mainScreena.height, width: mainScreena.width, height: mainScreena.height))
        sharingView.backgroundColor = UIColor.clear
        self.view.addSubview(sharingView)
        //Transparent View
        let transparentView = UIView(frame: CGRect(x: 0, y: 0, width: mainScreena.width, height: mainScreena.height))
        transparentView.backgroundColor = UIColor.black  // shoaib
        transparentView.alpha = 0.5
        sharingView.addSubview(transparentView)
        //Buttons View
        let offset : CGFloat = 10
        let viewHeight : CGFloat = 140
        let viewWidth : CGFloat = 170
        let buttonsView = UIView(frame: CGRect(x: (mainScreena.width - viewWidth)/2, y: (mainScreena.height - viewHeight)/2, width: viewWidth, height: viewHeight))
        buttonsView.backgroundColor = UIColor.clear
        sharingView.addSubview(buttonsView)
        //Photo
        let photoButton = UIButton(frame: CGRect(x: offset, y: offset, width: offset*15, height: offset*4))
        photoButton.backgroundColor = UIColor.white
        photoButton.clipsToBounds = true
        photoButton.layer.cornerRadius = 20.0
        photoButton.setBackgroundImage(UIImage(named:"picture1_iphone"), for: .normal)
        photoButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 40,bottom: 0,right: 0)
        photoButton.setTitle(NSLocalizedString("picture", comment: ""), for: UIControlState.normal)
        photoButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        photoButton.addTarget(self, action:#selector(self.pictureSharingAction), for: .touchUpInside)
        buttonsView.addSubview(photoButton)
        //Video
        let videoButton = UIButton(frame: CGRect(x: offset, y: offset*9, width: offset*15, height: offset*4))
        videoButton.backgroundColor = UIColor.white
        videoButton.clipsToBounds = true
        videoButton.layer.cornerRadius = 20.0
        videoButton.setBackgroundImage(UIImage(named:"video1_iphone"), for: .normal)
        videoButton.titleEdgeInsets = UIEdgeInsets(top: 0,left: 40,bottom: 0,right: 0)
        videoButton.setTitle(NSLocalizedString("video", comment: ""), for: UIControlState.normal)
        videoButton.setTitleColor(UIColor.darkGray, for: UIControlState.normal)
        videoButton.addTarget(self, action:#selector(self.videoSharingAction), for: .touchUpInside)
        buttonsView.addSubview(videoButton)
        
        let tapRemove =  UITapGestureRecognizer(target: self, action: #selector(self.removeShareView(_:)))
        tapRemove.delegate = self as? UIGestureRecognizerDelegate
        transparentView.addGestureRecognizer(tapRemove)
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
                            self.sharingView.frame = CGRect(x: 0, y: 0, width: mainScreena.width, height: mainScreena.height)
                        }, completion:  nil)
    }
    
    //MARK: Remove Video & Picture Sharing View
    @objc func removeShareView(_ sender: UITapGestureRecognizer)
    {
        self.removeShareViewMethod()
    }
    
    //MARK:- Remove share view function
    func removeShareViewMethod()
    {
        UIView.animate(withDuration: 0.6, delay: 0.1, options: [], animations:
                        {
                            let screenSize: CGRect = UIScreen.main.bounds
                            self.sharingView.frame = CGRect(x: 0, y: screenSize.height, width: screenSize.width, height: screenSize.height)
                        }, completion: { (finished: Bool) in
                            self.sharingViewAlreadyOpen = false
                            self.sharingView.removeFromSuperview()
                        })
    }
    
    
    //MARK: Manage rewardView
    
    func showRewardOption(){
        
        let customView = CustomAwardView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 142/*self.view.frame.height*0.4*/))
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            customView.frame.size.height = 142
        }else {
            customView.frame.size.height = 140
        }
        
        customView.toplabel.text = NSLocalizedString("Congratulations!", comment: "") /*+ "\n" + NSLocalizedString("You did it!", comment: "")*/
        
        customView.leftLabel.text = NSLocalizedString("Share your artwork", comment: "")
        customView.rightLabel.text = NSLocalizedString("and get 5 more", comment: "")
        // #141 Task
        customView.sharefbinImageView.isHidden = true
        customView.delegate = self
        let sessionLimit = UserDefaults.standard.integer(forKey: SESSION_LIMIT)
        UserDefaults.standard.set(sessionLimit - 1, forKey: SESSION_LIMIT)
        self.view.addSubview(customView)
        
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.setConstraint(customView: customView)
        }else {
            
        }
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.8, delay: 0.3, options: [], animations:{
                //                let height = self.view.frame.height*0.25
                let height = customView.frame.height
                customView.frame =  CGRect(x:0, y:self.view.frame.maxY - height , width:self.view.frame.width,height: height);
            }, completion:{(finished) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    [weak self] in
                    guard let self = self else { return }
                    self.hideRewardShowOption(customAwardView: customView)
                }
            }
            )
        }
    }
    
    
    
    //MARK: Manage AmazingView  #141 Task
    
    func showAmazingOption(){
        
        let customView = CustomAwardView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height: 142/*self.view.frame.height*0.4*/))
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            customView.frame.size.height = 142
        }else {
            customView.frame.size.height = 140
        }
        customView.toplabel.text = NSLocalizedString("Amazing!", comment: "") /*+ "\n" + NSLocalizedString("You did it!", comment: "")*/
        customView.leftLabel.text = NSLocalizedString("Let's try some more", comment: "")
        customView.rightLabel.text = ""
        customView.coloredBucketiPadImage.isHidden = true
        customView.sharefbinImageView.isHidden = true
        customView.delegate = self
        //let sessionLimit = UserDefaults.standard.integer(forKey: SESSION_LIMIT)
        // UserDefaults.standard.set(sessionLimit - 1, forKey: SESSION_LIMIT)
        self.view.addSubview(customView)
        
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.setConstraint(customView: customView)
        }else {
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 0.8, delay: 0.3, options: [], animations:{
                //                let height = self.view.frame.height*0.25
                let height = customView.frame.height
                customView.frame =  CGRect(x:0, y:self.view.frame.maxY - height , width:self.view.frame.width,height: height);
            }, completion:{(finished) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                    [weak self] in
                    guard let self = self else { return }
                    self.hideRewardShowOption(customAwardView: customView)
                }
            }
            )
        }
    }
    
    func setConstraint(customView: UIView) {
        
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 200).isActive = true
        customView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        customView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        
    }
    
    
    func hideRewardShowOption(customAwardView:UIView){
        UIView.animate(withDuration: 1.0, delay: 0.3, options: [], animations:{
            //let height = self.view.frame.height*0.25
            let height = customAwardView.frame.height
            customAwardView.frame =  CGRect(x:0, y:self.view.frame.maxY, width:self.view.frame.width,height: height);
        }, completion:  {
            (finished) in
            customAwardView.removeFromSuperview()
        })
    }
    
    func dismissBtnofCustomAwardViewClicked(view: UIView) {
        self.hideRewardShowOption(customAwardView: view)
    }
    
    
    //Manage Awarded View
    
    func showAwardedView(){
        self.rewardw1View.isHidden = true
        let customView:AwardedView = AwardedView(frame: CGRect(x: 0, y: self.view.frame.height, width: self.view.frame.width, height:142)) //self.view.frame.height*0.25))
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            customView.frame.size.height = 142
        }else {
            customView.frame.size.height = 140
        }
        customView.toplabel.text = NSLocalizedString("You got 10 Paint Buckets.", comment: "")
        customView.delegate = self
        
        self.view.addSubview(customView)
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            self.setConstraint(customView: customView)
        }else {
            
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            [weak self] in
            guard let self = self else { return }
            UIView.animate(withDuration: 1.0, delay: 0.3, options: [], animations:{
                let height = customView.frame.height //self.view.frame.height*0.25
                customView.frame =  CGRect(x:0, y:self.view.frame.maxY - height , width:self.view.frame.width,height: height);
            }, completion:{(finished) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    [weak self] in
                    guard let self = self else { return }
                    self.hideAwardedView(customView: customView)
                }
            }
            )
        }
    }
    
    func hideAwardedView(customView:UIView){
        UIView.animate(withDuration: 1.0, delay: 0.3, options: [], animations:{
            let height = self.view.frame.height
            customView.frame =  CGRect(x:0, y:self.view.frame.maxY, width:self.view.frame.width,height: height);
        }, completion:  {
            (finished) in
            customView.removeFromSuperview()
        })
    }
    
    func awardViewDismissBtnClicked(view: UIView) {
        self.hideAwardedView(customView: view)
    }
    
    //MARK:- Picture shaing action
    @objc func pictureSharingAction()
    {
        if !isWatermarkAdded{
            //vaibhav - CODE: Start
            addWaterMark()
            sharableImage = UIImage(contentsOfFile: (imageFileURL?.path)!)!
            //vaibhav - CODE: End
            isWatermarkAdded = true
        }
        
        if buttonTypeSharing == 1
        {
            //Save
            appDelegate.logEvent(name: "Picture_Download", category: "Picture Share", action: self.imageData.name!)
            self.removeShareViewMethod()
            self.saveVideo(shareOption: .kButtonTypeSave)
        }
        else if buttonTypeSharing == 2
        {
            //Insta
            appDelegate.logEvent(name: "Picture_Instagram", category: "Picture Share", action: self.imageData.name!)
            self.removeShareViewMethod()
            self.saveVideo(shareOption: .kButtonTypeInstagram)
        }
        else if buttonTypeSharing == 3
        {
            //FB
            appDelegate.logEvent(name: "Picture_FB", category: "Picture Share", action: self.imageData.name!)
            self.removeShareViewMethod()
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                self.facebookPictureSharing()
            } else {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized {
                        self.facebookPictureSharing()
                    }
                })
            }
            self.hideProgressBar()
        }
        else if buttonTypeSharing == 4
        {
           // self.hideProgressBar()
            
            //Other
            appDelegate.logEvent(name: "Picture_Share", category: "Picture Share", action: self.imageData.name!)
            self.removeShareViewMethod()
            let objectsToShare = [sharableImage]
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
                // actionSheet.popoverPresentationController?.sourceView = self.view
                //            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.rightDownPlusBtn.frame.minX - 160, y: self.rightDownPlusBtn.frame.minY - 60, width: 0, height: 0)
            }
            
            activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                if completed {
                    if(error == nil)
                    {
                        self.hideProgressBar()
                        if self.isRewardActive{
                            var paintCount =  UserDefaults.standard.integer(forKey: self.paint_count)
                            // paintCount = paintCount + 10  // need to comfirm 10 points
                            paintCount = paintCount + 10
                            UserDefaults.standard.set(paintCount, forKey: self.paint_count)
                            self.addInSharedImages()
                            self.showAwardedView()
                            self.appDelegate.logEvent(name: "Reward_w2", category: "Reward Screen", action: "picture share")
                            if(self.isVideoSharing){
                                self.appDelegate.logEvent(name: "Share_V_Complete", category: "Share Video", action: self.imageData.name!)
                                self.appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "Vreward")
                                self.appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "Vreward")
                            }
                            else{
                                self.appDelegate.logEvent(name: "Share_P_Complete", category: "Share Picture", action: self.imageData.name!)
                                self.appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "Preward")
                                self.appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "Preward")
                            }
                            self.isRewardActive = false
                        }
                    }else{
                        self.hideProgressBar()
                        print("activity: \(String(describing: activityType)), success: \(access), items: \(String(describing: returnedItems)), error: \(String(describing: error))")
                    }
                }
                
            }
            self.present(activityViewController, animated: true, completion: nil)
            self.hideProgressBar()
        }
    }
    
    //MARK: Facebook picture sharing
    func facebookPictureSharing()
    {
        DispatchQueue.main.async() {
            let photo = SharePhoto()
            photo.image = self.sharableImage
            photo.isUserGenerated = false
            let photoContent = SharePhotoContent()
            photoContent.photos = [photo]
            ShareDialog.init(fromViewController:self,content:photoContent,delegate:self).show()
            // ShareDialog.init(fromViewController: self, content: photoContent, delegate: self as SharingDelegate)
        }
    }
    
    //MARK:- Video shaing action
    @objc func videoSharingAction()
    {
        if buttonTypeSharing == 1
        {
            //Save
            appDelegate.logEvent(name: "Video_Download", category: "Video Share", action: self.imageData.name!)
            appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "DL")
            self.removeShareViewMethod()
            self.saveVideo(shareOption: .kButtonTypeSave)
        }
        else if buttonTypeSharing == 2
        {
            //Insta
            appDelegate.logEvent(name: "Video_Instagram", category: "Video Share", action: self.imageData.name!)
            appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "IG")
            appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "IG")
            self.removeShareViewMethod()
            self.saveVideo(shareOption: .kButtonTypeInstagram)
            
        }
        else if buttonTypeSharing == 3
        {
            //FB
            appDelegate.logEvent(name: "Video_FB", category: "Video Share", action: self.imageData.name!)
            appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "FB")
            appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "FB")
            self.removeShareViewMethod()
            if PHPhotoLibrary.authorizationStatus() == .authorized {
                self.facebookVideoSharing()
            } else {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    if status == .authorized {
                        self.facebookVideoSharing()
                    }
                })
            }
        }
        else if buttonTypeSharing == 4
        {
           // self.hideProgressBar()
            //Other
            appDelegate.logEvent(name: "Video_Share", category: "Video Share", action: self.imageData.name!)
            appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "Video")
            appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "Video")
            self.removeShareViewMethod()
            
            if let videoLink = videoFileURL{
                let objectsToShare = [videoLink]
                let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                activityViewController.excludedActivityTypes =   [
                    UIActivityType.assignToContact,
                    UIActivityType.print,
                    UIActivityType.addToReadingList,
                    UIActivityType.saveToCameraRoll,
                    UIActivityType.openInIBooks,
                    UIActivityType.saveToCameraRoll
                ]
                //  activityViewController.excludedActivityTypes = []
                activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
                if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad {
                    activityViewController.popoverPresentationController?.barButtonItem = self.navigationItem.rightBarButtonItem
                    activityViewController.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
                    // actionSheet.popoverPresentationController?.sourceView = self.view
                    //            actionSheet.popoverPresentationController?.sourceRect = CGRect(x: self.rightDownPlusBtn.frame.minX - 160, y: self.rightDownPlusBtn.frame.minY - 60, width: 0, height: 0)
                }
                activityViewController.completionWithItemsHandler = { (activityType, completed:Bool, returnedItems:[Any]?, error: Error?) in
                    if completed {
                        if(error == nil)
                        {
                            self.hideProgressBar()
                            if self.isRewardActive{
                                var paintCount =  UserDefaults.standard.integer(forKey: self.paint_count)
                                // paintCount = paintCount + 10  // need to comfirm 10 points
                                paintCount = paintCount + 10
                                UserDefaults.standard.set(paintCount, forKey: self.paint_count)
                                self.addInSharedImages()
                                self.showAwardedView()
                                self.appDelegate.logEvent(name: "Reward_w2", category: "Reward Screen", action: "video share")
                                if(self.isVideoSharing){
                                    self.appDelegate.logEvent(name: "Share_V_Complete", category: "Share Video", action: self.imageData.name!)
                                    self.appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "Vreward")
                                    self.appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "Vreward")
                                }
                                else{
                                    self.appDelegate.logEvent(name: "Share_P_Complete", category: "Share Picture", action: self.imageData.name!)
                                    self.appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "Preward")
                                    self.appDelegate.logEvent(name: "Social_action", category: "Video Screen", action: "Preward")
                                }
                                self.isRewardActive = false
                            }
                        }else{
                            self.hideProgressBar()
                            print("activity: \(String(describing: activityType)), success: \(access), items: \(String(describing: returnedItems)), error: \(String(describing: error))")
                        }
                    }
                }
                self.present(activityViewController, animated: true, completion: nil)
                self.hideProgressBar()
            }
        }
    }
    
    
    //MARK:  Facebook Video sharing
    func facebookVideoSharing()
    {
        if let videoLink = videoFileURL{
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoLink)
            }) { saved, error in
                if saved {
                    
                    let fetchOptions = PHFetchOptions()
                    fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                    let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions).lastObject
                    PHImageManager().requestAVAsset(forVideo: fetchResult!, options: nil, resultHandler: { (avurlAsset, audioMix, dict) in
                        let urlString = self.videoFileURL?.path
                        let urlArray = urlString?.components(separatedBy: ".")
                        let videoExtension = urlArray![(urlArray?.count)!-1]
                        let videoID = fetchResult!.localIdentifier
                        let videoIDArray = videoID.components(separatedBy: "/")
                        let getVideoID = videoIDArray[0]
                        let assestString = "assets-library://asset/asset.\(videoExtension)?id=\(getVideoID)&ext=\(videoExtension)"
                        let urlAsset = URL(string: assestString)
                        DispatchQueue.main.async() {
                            let vid: ShareVideo = ShareVideo.init(videoURL: urlAsset!)
                            let shareContent: ShareVideoContent = ShareVideoContent()
                            shareContent.hashtag = Hashtag("#pixelcolorapp")
                            shareContent.video = vid
                            //ShareDialog.init(fromViewController: self, content: shareContent, delegate: self as! SharingDelegate)
                            self.hideProgressBar()
                            ShareDialog.init(fromViewController:self,content:shareContent,delegate:self).show()
                        }
                    })
                }
            }
        }
    }
    
    //MARK: Facebook Sharing Delegate Options
    
    
    func sharer(_ sharer: Sharing, didCompleteWithResults results: [String : Any]) {
        if self.shoudReviewApp && self.isComplete && self.isJustCompleted{
            self.openRatePopupView()
        }
        print("share completed")
        self.hideProgressBar()
        //         DispatchQueue.main.async {
        //        let alertController = UIAlertController(title: NSLocalizedString("FB share completed", comment: ""), message: nil, preferredStyle: .alert)
        //        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //        alertController.addAction(defaultAction)
        //        self.present(alertController, animated: true, completion: nil)
        //
        //        }
        
        self.appDelegate.logEvent(name: "FB_Confirm", category: "FB Share", action: self.imageData.name!)
        
        if isRewardActive{
            var paintCount =  UserDefaults.standard.integer(forKey: paint_count)
            paintCount = paintCount + 10
            UserDefaults.standard.set(paintCount, forKey: paint_count)
            self.addInSharedImages()
            self.showAwardedView()
            self.appDelegate.logEvent(name: "Reward_w2", category: "Reward Screen", action: "FB Share")
            self.appDelegate.logEvent(name: "Share_V_Complete", category: "Share Video", action: self.imageData.name!)
            self.appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "FBreward")
            self.isRewardActive = false
        }
    }
    
    func sharer(_ sharer: Sharing!, didFailWithError error: Error!) {
        print("share failed")
        self.hideProgressBar()
        //        DispatchQueue.main.async {
        //            let alertController = UIAlertController(title: NSLocalizedString("FB share failed", comment: ""), message: nil, preferredStyle: .alert)
        //            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //            alertController.addAction(defaultAction)
        //            self.present(alertController, animated: true, completion: nil)
        //
        //        }
        if self.shoudReviewApp && self.isComplete && self.isJustCompleted{
            self.openRatePopupView()
        }
    }
    
    func sharerDidCancel(_ sharer: Sharing!) {
        print("share cancelled")
        self.hideProgressBar()
        //        DispatchQueue.main.async {
        //            let alertController = UIAlertController(title: NSLocalizedString("FB share cancelled", comment: ""), message: nil, preferredStyle: .alert)
        //            let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        //            alertController.addAction(defaultAction)
        //            self.present(alertController, animated: true, completion: nil)
        //
        //        }
        if self.shoudReviewApp && self.isComplete && self.isJustCompleted{
            self.openRatePopupView()
        }
    }
    
    //MARK: Instagram share completed
    @objc func willEnterForeground(_ notification: NSNotification!) {
        if self.shoudReviewApp && self.isComplete && self.isJustCompleted{
            self.openRatePopupView()
        }
        if self.isSharedOnInstagram{
            self.isSharedOnInstagram = false
            if isRewardActive{
                self.showAwardedView()
                self.appDelegate.logEvent(name: "Reward_w2", category: "Reward Screen", action: "IG share")
                self.appDelegate.logEvent(name: "Share_V_Complete", category: "Share Video", action: self.imageData.name!)
                self.appDelegate.logEvent(name: "Share_Social", category: "Video Screen", action: "IGreward")
                isRewardActive = false
            }
        }
    }
    
    //MARK: Check if shared
    
    func checkIfAlreadyShared() -> Bool{
        guard let sharedImagesArray = UserDefaults.standard.object(forKey:SHARED_IMAGES) as? NSMutableArray else{
            return true
        }
        guard let imageId = self.imageData.imageId else{
            return false
        }
        if sharedImagesArray.contains(imageId){
            return false
        }
        return true
    }
    
    func checkSessionLimitForPopUp() -> Bool{
        let sessionLimit = UserDefaults.standard.integer(forKey: SESSION_LIMIT)
        return sessionLimit < 1 ? false:true
    }
    
    func addInSharedImages(){
        if let x = UserDefaults.standard.object(forKey: SHARED_IMAGES) as? NSArray{
            let tempArray:NSMutableArray = x.mutableCopy() as! NSMutableArray
            tempArray.add(self.imageData.imageId!)
            UserDefaults.standard.set(tempArray, forKey: SHARED_IMAGES)
            tempArray.removeAllObjects()
        }else{
            let tempArray:NSMutableArray =  NSMutableArray()
            tempArray.add(self.imageData.imageId!)
            UserDefaults.standard.set(tempArray, forKey: SHARED_IMAGES)
            tempArray.removeAllObjects()
        }
    }
    
    func isFirstImage() -> Bool{
        if #available(iOS 10.0, *) {
            let dbHelper = DBHelper.sharedInstance
            // Suppose count 1 is tutorial image not consider in counting
            // return dbHelper.getMyWorkImages().count > 1 ? false:true
            return dbHelper.getMyWorkImages().count > 1 ? false:true
            
            
        } else {
            // Fallback on earlier versions
            return false
        }
    }
    
    
    //MARK:- Get Localized Watermark Image
    func getLocalizedWaterMarkImageIphone() -> String{
        var imageName:String = "watermark"
        let preferredLang = NSLocale.preferredLanguages[0]
        if let currentLanguage = Locale.currentLanguage {
            switch  currentLanguage.rawValue{
            case "English": // english
                
                if preferredLang.contains("en-GB"){
                    imageName = "watermarkEnglishUKiPhone"
                } else{
                    imageName = "watermark"
                }
                break
            case "Spanish": // spanish
                imageName = "watermarkSpanishiPhone"
                break
            case "French": // French
                imageName = "watermarkFrenchiPhone"
                break
            case "Italian": // Italian
                imageName = "watermarkItalianiPhone"
                break
            case "German": // German
                imageName = "watermarkGermaniPhone"
                break
            case "Russian": // Russian
                imageName = "watermarkRussianiPhone"
                break
            case "Korean": // Korean
                imageName = "watermarkKoreaniPhone"
                break
            case "Japanese": // Japanese
                imageName = "watermarkJapaneseiPhone"
                break
            case "Chinese": // Chinese
                imageName = "watermarkChineseiPhone"
                break
            default:
                imageName = "watermark"
            }
        }
        return imageName
    }
    
    func getLocalizedWaterMarkImageIpad() -> String{
        var imageName:String = "watermarkIpad"
        let preferredLang = NSLocale.preferredLanguages[0]
        if let currentLanguage = Locale.currentLanguage {
            switch  currentLanguage.rawValue{
            case "English": // english
                if preferredLang.contains("en-GB"){
                    imageName = "watermarkEnglishUKiPad"
                } else{
                    imageName = "watermarkIpad"
                }
                break
            case "Spanish": // spanish
                imageName = "watermarkSpanishiPad"
                break
            case "French": // French
                imageName = "watermarkFrenchiPad"
                break
            case "Italian": // Italian
                imageName = "watermarkItalianiPad"
                break
            case "German": // German
                imageName = "watermarkGermaniPad"
                break
            case "Russian": // Russian
                imageName = "watermarkRussianiPad"
                break
            case "Korean": // Korean
                imageName = "watermarkKoreaniPad"
                break
            case "Japanese": // Japanese
                imageName = "watermarkJapaneseIpad"
                break
            case "Chinese": // Chinese
                imageName = "watermarkChineseIpad"
                break
            default:
                imageName = "watermarkIpad"
            }
        }
        return imageName
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
    }
    
    @IBAction func CopyHasTagAction(_ sender: Any) {
        
        let pasteBoard = UIPasteboard.general
        pasteBoard.string = "#pixelcolorapp"
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "CopyTagViewController") as! CopyTagViewController
        vc.modalPresentationStyle = .overCurrentContext
        self.present(vc,animated:true,completion:nil)
        
    }
    
    
    
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
                   self.dismissIntersialAd()

            }
            else{
                //Show reward ads after 10 mins
                self.showRewardedAds()
                self.dismissIntersialAd()

            }

          
            
        }
    }
    @objc func showRewardedAds()
    {
        redirectToForward()
        isFromPlayVC = true
        rewardedAdHelper.showRewardedAd(viewController: self)
    }
 
    
    //MARK: Show Ads
    @objc func showIntertialAds()
    {
        redirectToForward()
        isFromPlayVC = true
        interstitialAdHelper.showIntersialAd(viewController: self)
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
        else if(isInternetAvailable() == false){
            return false
        }
        else if (launchCount < 2){
            return false
        }
        else{
            return true
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
    
    
    //MARK: Open rate popup.
    var timer: Timer?
    func openRatePopupView(value: Bool = false) {
        if value {
            timer?.invalidate()
            timer = nil
            timer = Timer.scheduledTimer(timeInterval: 1.0, target:self, selector:#selector(self.openRateViewController), userInfo:nil, repeats:false)
        }
    }
    
    @objc func openRateViewController() {
        
        let feedbackOrRateTappedString = UserDefaults.standard.string(forKey: "feedbackOrRateTapped")
        if feedbackOrRateTappedString == "0" || feedbackOrRateTappedString == nil {
            let vc = self.storyboard?.instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
            vc.rateViewControllerDelegate = self
            vc.modalPresentationStyle = .overCurrentContext
            self.appDelegate.logEvent(name: "Rate_View", category: "", action: imageData.name!)
            self.present(vc,animated:true,completion:nil)
        }
        
    }
    
    //    func showRatePopup() {
    //
    //        if(self.rateViewController != nil) {
    //            self.rateViewController.view.removeFromSuperview()
    //        }
    //        self.rateViewController = self.storyboard?.instantiateViewController(withIdentifier: "RateViewController") as! RateViewController
    //        self.rateViewController.rateViewControllerDelegate = self
    //        self.rateViewController.view.frame = UIScreen.main.bounds
    //        UIApplication.shared.keyWindow?.insertSubview(self.rateViewController.view, at: self.view.subviews.count)
    //
    //    }
    
    
    //MARK: RateViewControllerDelegate.
    func crossBtnNoConnectionTapDelegate(sender: UIButton) {
        self.rateViewController.view.removeFromSuperview()
    }
    
    func rateBtnTappedDelegate(sender: UIButton) {
        print("Try")
        requestReview()
    }
    
}

extension Locale {
    static func preferredLocale() -> Locale {
        guard let preferredIdentifier = Locale.preferredLanguages.first else {
            return Locale.current
        }
        return Locale(identifier: preferredIdentifier)
    }
}

extension PlayVideoVC : GetVideoPathDelegate
{
    func GetSavePath(vPath: String,imgPath: String, isSave: Bool) {
        self.sharingEnable = isSave
        if self.fromFB {
            self.progressBar.setProgress(to: 1, withAnimation: true)
        }
        else if self.fromInsta{
            self.instaProgressBar.setProgress(to: 1, withAnimation: true)
        }
        else if self.fromShare{
            self.ShareProgressBar.setProgress(to: 1, withAnimation: true)
        }
        else if self.fromSave{
            self.saveProgressBar.setProgress(to: 1, withAnimation: true)
        }
        self.imageFileURL = NSURL(string: imgPath)! as URL
        self.videoFileURL = NSURL(string: "file://" + vPath)! as URL//fileOutpurURL
        // print(self.videoFileURL)
        DispatchQueue.main.async {
            self.recorderDev.stop(input: "pl",isVideo: false, completion: { fileOutpurURL,imageUrl  -> Void in
                DispatchQueue.main.async {self.recorderDev = Recorder()}
            })
            if self.isSharingClicked
            {
                self.pointAndColorArray.removeAll()
                self.viewForVideo.removeFromSuperview()
                
            }
            if self.sharingEnable {
                if self.fromFB {
                    self.facebookShareButtonClicked(self.facebookButton)
                }
                else if self.fromInsta{
                    self.instagramShareButtonClicked(self.instagramButton)
                }
                else if self.fromShare{
                    self.shareButtonClicked(self.shareButton)
                }
                else if self.fromSave{
                    self.saveButtonClicked(self.saveButton)
                }
//                switch self.type {
//                case kButtonType.kButtonTypeShare:
//                    self.shareButtonClicked(self.shareButton)
//                    break;
//                case kButtonType.kButtonTypeInstagram:
//                    self.instagramShareButtonClicked(self.instagramButton)
//                    break;
//                case kButtonType.kButtonTypeFacebook:
//                    self.facebookShareButtonClicked(self.facebookButton)
//                    break;
//                case kButtonType.kButtonTypeSave:
//                    self.saveButtonClicked(self.saveButton)
//                    break;
//
//                }
            }
            self.removeAllAnimationsForControls()
        }
    }
    func getPercent(percent: Int) {
        if(self.countArray.count == 0){
            return
        }
        let percentage = (Double((percent*100)/(self.countArray.count*3)) / 100)
       // print("percentage:- \(percentage)")
       // print("percent:- \(self.percent)")
        
        if((self.percent+percentage) > self.percent){
           
        if(self.percent < 1){
            self.percent =  self.percent+percentage
            DispatchQueue.main.async {
                
                if self.fromFB {
                    
                    self.progressBar.setProgress(to: self.percent, withAnimation: true)
                    
                }
                if self.fromInsta{
                    self.instaProgressBar.setProgress(to: self.percent, withAnimation: true)
                }
                if self.fromShare{
                    self.ShareProgressBar.setProgress(to: self.percent, withAnimation: true)
                }
                if self.fromSave{
                    
                    self.saveProgressBar.setProgress(to: self.percent, withAnimation: true)
                }
                
            }
        }
        }
    }
}



