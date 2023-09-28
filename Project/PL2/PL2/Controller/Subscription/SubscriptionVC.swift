//
//  SubscriptionVC.swift
//  PL2
//
//  Created by iPHTech2 on 06/02/19.
//  Copyright © 2019 IPHS Technologies. All rights reserved.
//

import UIKit

class SubscriptionVC: UIViewController
{
    @IBOutlet var imgSubscription: UIImageView!
    @IBOutlet var lblDescription: UILabel!
    @IBOutlet var lblSimplyRelex: UILabel!
    @IBOutlet var lblNoCommitment: UILabel!
    @IBOutlet var btnFreeTrial: UIButton!
    
    @IBOutlet weak var yearSubscriptionView: UIView!
    @IBOutlet weak var monthSubscriptionView: UIView!
    @IBOutlet weak var weekSubscriptionView: UIView!
    
    @IBOutlet var lblOffer: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var widthConstraint: NSLayoutConstraint!
    @IBOutlet var freeStringLabel: UILabel!
    
    @IBOutlet weak var timetoRelaxLabel: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var subscriptionHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weekHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var weekWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var monthHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var yearHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var yearWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weekMonthMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthYearMarginConstraint: NSLayoutConstraint!
    @IBOutlet weak var continueButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var noCommitMentTopConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var weekPriceLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthPriceLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var monthDiscountPriceLabelTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var yearPriceLabelTopConstraint: NSLayoutConstraint!
    
    var boxSize:CGFloat = 100
    var fontSize:CGFloat = 10
    var fontTitleSize:CGFloat = 14
    @IBOutlet weak var oneWeekLabel: UILabel!
    @IBOutlet weak var oneMonthLabel: UILabel!
    @IBOutlet weak var oneYearLabel: UILabel!
    @IBOutlet weak var oneWeekAmountLabel: UILabel!
    @IBOutlet weak var oneMonthAmountLabel: UILabel!
    @IBOutlet weak var oneYearAmountLabel: UILabel!
    @IBOutlet weak var img_Offer: UIImageView!
    @IBOutlet weak var subscriptionContainerView: UIView!
    
    var isFromFreeButton:Bool = false
    var timer : Timer?
    var count = 0
    let WEEK_SUBSCRIPTION_PRODUCT_ID = "com.moomoolab.pl2wk"
    let array = ["image1", "image2", "image3"]
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var selectedPurchaseType = 0 //Shoaib.............
    var imgName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgSubscription.clipsToBounds = true
        self.imgSubscription.contentMode = .scaleAspectFit
        self.GetAnimationImage()
        NotificationCenter.default.addObserver(self, selector: #selector(self.orientationChanged(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        
        DispatchQueue.main.async(execute: {
            self.timer = Timer.scheduledTimer(timeInterval: 6, target: self, selector: #selector(self.GetAnimationImage), userInfo: nil, repeats: true)
        })
        
        if UI_USER_INTERFACE_IDIOM() == .pad {
            setOrientation()
        }
       
        
        // self.view.backgroundColor = .yellow
        var monthOffPrice = ""
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER_MODS"){
                    monthOffPrice = val as! String
                    print("monthOffPrice MONTHLY_PRICE_OFFER_MODS : - \(monthOffPrice)")
                }
            }else {
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"){
                    monthOffPrice = val as! String
                    print("monthOffPrice MONTHLY_PRICE_OFFER: - \(monthOffPrice)")
                }
            }
        
        let monthStr = NSLocalizedString("/ Month", comment: "")
        
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string:monthOffPrice + monthStr)
        
        
        if #available(iOS 14, *) {
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        } else {
            attributeString.addAttribute(NSAttributedStringKey.baselineOffset, value: 0, range: NSMakeRange(0, attributeString.length))
            attributeString.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 1, range: NSMakeRange(0, attributeString.length))
            
        }
        
        
        if( UIDevice.current.userInterfaceIdiom == .phone) {
            if let currentLanguage = Locale.currentLanguage {
                switch  currentLanguage.rawValue{
                case "Italian": // english
                    fontTitleSize = 11
                    break
                case "French": // French
                    fontTitleSize = 11
                    break
                default:
                    fontTitleSize = 14
                }
                
            }
            weekHeightConstraint.constant = boxSize
            weekWidthConstraint.constant = boxSize
            monthHeightConstraint.constant = boxSize
            monthWidthConstraint.constant = boxSize
            yearHeightConstraint.constant = boxSize
            yearWidthConstraint.constant = boxSize
            
            oneWeekLabel.font = oneWeekLabel.font.withSize(fontTitleSize)
            
            oneMonthLabel.font = oneMonthLabel.font.withSize(fontTitleSize)
            oneYearLabel.font = oneYearLabel.font.withSize(fontTitleSize)
            
            oneWeekAmountLabel.font = oneWeekAmountLabel.font.withSize(fontSize)
            oneMonthAmountLabel.font = oneMonthAmountLabel.font.withSize(fontSize)
            oneYearAmountLabel.font = oneYearAmountLabel.font.withSize(fontSize)
            lblOffer.font = lblOffer.font.withSize(fontSize)
            subscriptionHeightConstraint.constant = 100
            
            weekMonthMarginConstraint.constant = 6
            monthYearMarginConstraint.constant = 6
            
        }
        else {
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
           
            boxSize = boxSize+50
            let amoutTopMargin = boxSize / 2 - (oneMonthAmountLabel.frame.height + oneMonthAmountLabel.frame.height)
            
            monthDiscountPriceLabelTopConstraint.constant = 25
            weekPriceLabelTopConstraint.constant = amoutTopMargin
            monthPriceLabelTopConstraint.constant = amoutTopMargin
            yearPriceLabelTopConstraint.constant = amoutTopMargin
            
            weekHeightConstraint.constant =  boxSize
            weekWidthConstraint.constant = boxSize
            monthHeightConstraint.constant = boxSize
            monthWidthConstraint.constant = boxSize
            yearHeightConstraint.constant = boxSize
            yearWidthConstraint.constant = boxSize
            
            oneWeekLabel.font = oneWeekLabel.font.withSize(fontTitleSize)
            oneMonthLabel.font = oneMonthLabel.font.withSize(fontTitleSize)
            oneYearLabel.font = oneYearLabel.font.withSize(fontTitleSize)
            oneWeekAmountLabel.font = oneWeekAmountLabel.font.withSize(fontSize+6)
            oneMonthAmountLabel.font = oneMonthAmountLabel.font.withSize(fontSize+6)
            oneYearAmountLabel.font = oneYearAmountLabel.font.withSize(fontSize+6)
            lblOffer.font = lblOffer.font.withSize(fontSize+6)
            subscriptionHeightConstraint.constant = 160
            lblOffer.font = lblOffer.font.withSize(14)
            weekMonthMarginConstraint.constant = 20
            monthYearMarginConstraint.constant = 20
            
        }
        
        lblOffer.attributedText = attributeString
        yearSubscriptionView.layer.borderWidth = 3
        yearSubscriptionView.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        yearSubscriptionView.layer.cornerRadius = 10
        
        monthSubscriptionView.layer.borderWidth = 3
        monthSubscriptionView.layer.borderColor = UIColor(red: 0.91, green: 0.49, blue: 0.45, alpha: 1.00).cgColor
        monthSubscriptionView.layer.cornerRadius = 10
        
        weekSubscriptionView.layer.borderWidth = 3
        weekSubscriptionView.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        weekSubscriptionView.layer.cornerRadius = 10
        
        let weekGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        let monthGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        
        let yearGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapView(_:)))
        
        weekSubscriptionView?.tag = 0
        monthSubscriptionView?.tag = 1
        yearSubscriptionView?.tag = 2
        
        monthSubscriptionView.addGestureRecognizer(monthGestureRecognizer)
        weekSubscriptionView.addGestureRecognizer(weekGestureRecognizer)
        yearSubscriptionView.addGestureRecognizer(yearGestureRecognizer)
        
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        } else {
            // Fallback on earlier versions
        }
        
        //vivek code
        oneWeekLabel.text = (NSLocalizedString("Weekly Subscription", comment: ""))
            //"\(NSLocalizedString("Weekly", comment: ""))\n\(NSLocalizedString("Subscription", comment: ""))"
        // oneWeekAmountLabel.text = "$8.99/\(NSLocalizedString("Month", comment: ""))"
        let weekStr = NSLocalizedString("/ Week", comment: "")
        var weekPrice = ""
        if let val = UserDefaults.standard.value(forKey: "WEEKLY_PRICE"){
            weekPrice = val as! String
        }
        
        self.oneWeekAmountLabel.text = weekPrice+weekStr
        oneWeekAmountLabel.sizeToFit()
        print("subVC VDL")
        
        oneMonthLabel.text = (NSLocalizedString("Monthly Subscription", comment: ""))
            
        //"\(NSLocalizedString("Monthly", comment: ""))\n\(NSLocalizedString("Subscription", comment: ""))"
        
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
        
        
        oneMonthAmountLabel.text = monthPrice+monthStr //"$8.99/\(NSLocalizedString("Month", comment: ""))"
        oneMonthAmountLabel.sizeToFit()
        monthOffPrice = ""
//        if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"){
//            monthOffPrice = val as! String
//        }
        if(UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER_MODS"){
                    monthOffPrice = val as! String
                    print("monthOffPrice MONTHLY_PRICE_OFFER_MODS : - \(monthOffPrice)")
                }
            }else {
                if let val = UserDefaults.standard.value(forKey: "MONTHLY_PRICE_OFFER"){
                    monthOffPrice = val as! String
                    print("monthOffPrice MONTHLY_PRICE_OFFER: - \(monthOffPrice)")
                }
            }
        lblOffer.attributedText = attributeString // monthOffPrice+monthStr //"\(monthOffPrice)/ \(NSLocalizedString("month", comment: ""))"
        lblOffer.adjustsFontSizeToFitWidth = true
        lblOffer.textAlignment = .center
        
        oneYearLabel.text = (NSLocalizedString("Yearly Subscription", comment: ""))
            
        //"\(NSLocalizedString("Annual", comment: ""))\n\(NSLocalizedString("Subscription", comment: ""))"
        let yearStr = NSLocalizedString("/ Year", comment: "")
        
        var yearPrice = ""
        if let val = UserDefaults.standard.value(forKey: "YEARLY_PRICE"){
            yearPrice = val as! String
        }
        
        oneYearAmountLabel.text = yearPrice+yearStr
        oneYearAmountLabel.sizeToFit()
        
        if (UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            if UIDevice.current.userInterfaceIdiom == .phone {
                continueButtonTopConstraint.constant = 21
            }
            else {
                continueButtonTopConstraint.constant = 31
            }
            freeStringLabel.isHidden = true
            noCommitMentTopConstraint.constant = 0
            self.selectedPurchaseType = 1 //Shaoib............
        }
        else {
//            subscriptionHeightConstraint.constant = 0
//            monthHeightConstraint.constant = 0
//            weekHeightConstraint.constant = 0
//            yearHeightConstraint.constant = 0
            self.subscriptionContainerView.isHidden = true
            
            self.continueButtonTopConstraint.isActive = false
            let topConstraint = NSLayoutConstraint.init(item: self.btnFreeTrial, attribute: NSLayoutAttribute.top, relatedBy: .equal, toItem: self.subscriptionContainerView, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 0)
            
            self.continueButtonTopConstraint = topConstraint
            self.continueButtonTopConstraint.isActive = true
            oneMonthLabel.isHidden = true
            oneMonthAmountLabel.isHidden = true
            lblOffer.isHidden = true
            oneWeekLabel.isHidden = true
            oneWeekAmountLabel.isHidden = true
            oneYearLabel.isHidden = true
            oneYearAmountLabel.isHidden = true
            img_Offer.isHidden = true
            continueButtonTopConstraint.constant = 16
            freeStringLabel.isHidden = false
            appDelegate.logEvent(name: "Subscription_Screen_View", category: "Subscription", action: "View Subscription Screen")
        }
    }
    
    func selectSubscriptionType(_ sView:UIView){
        weekSubscriptionView.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        monthSubscriptionView.layer.borderColor =
            UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        yearSubscriptionView.layer.borderColor = UIColor(red: 0.82, green: 0.82, blue: 0.82, alpha: 1.00).cgColor
        
        
        sView.layer.borderColor =  UIColor(red: 0.91, green: 0.49, blue: 0.45, alpha: 1.00).cgColor
        selectedPurchaseType = sView.tag
        print("selectedPurchaseType \(selectedPurchaseType)")
    }
    
    @objc func didTapView(_ sender: UITapGestureRecognizer) {
        print("did tap view", sender.view?.tag)
        selectSubscriptionType(sender.view!)
    }
    
    
    
    //    override var prefersStatusBarHidden: Bool {
    //        return true
    //    }
    
    @objc func orientationChanged(_ notification: Notification) {
        
        let orientation = UIDevice.current.orientation
        
        if UI_USER_INTERFACE_IDIOM() == .phone {
            return
        }
        
        if orientation == .landscapeLeft || orientation == .landscapeRight {
            
            landScapeLeft()
            
        }else {
            
            setOrientation()
        }
        
        if(isFromFreeButton)
        {
            let userInterface = UIDevice.current.userInterfaceIdiom
            
            if(userInterface == .pad) {
                setiPadDeviceImage()
            }
            else
            {
                self.imgSubscription.image = UIImage(named: hasTopNotch ? "banner_sub-iphoneR": "banner_sub-iphone")
            }
        }else {
            
            var toImage = UIImage(named: "\(imgName)-iphone")
            if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || self.view.frame.width > self.view.frame.height) {
                toImage = UIImage(named: "\(imgName)-ipadh")
                print("-ipadh")
            }
            else if (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown || self.view.frame.width < self.view.frame.height) {
                toImage = UIImage(named: "\(imgName)-ipadv")
                print("-ipadv")
            }
            
            
            UIView.transition(with: self.imgSubscription,
                              duration:0,
                              options: .transitionCrossDissolve,
                              animations: { self.imgSubscription.image = toImage },
                              completion: nil)
            
            //self.imgSubscription.image = toImage
        }
    }
    
    func landScapeLeft(){
        self.widthConstraint.isActive = false
        self.heightConstraint.isActive = false
        var width: NSLayoutConstraint
        var height: NSLayoutConstraint
        width = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
        if(isFromFreeButton)
        {
            height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 0.25, constant: 0)
        }
        else {
            
            height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.6, constant: 2)
        }
        self.widthConstraint = width
        self.heightConstraint = height
        self.widthConstraint.isActive = true
        self.heightConstraint.isActive = true
    }
    
    
    
    fileprivate func setOrientation() {
        let size = UIScreen.main.bounds.size
        if size.width < size.height {
            self.widthConstraint.isActive = false
            self.heightConstraint.isActive = false
            var width: NSLayoutConstraint
            var height: NSLayoutConstraint
            width = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.width, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
            if(isFromFreeButton){
                height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: -20)
            }
            else{
                height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.6, constant: -25)
            }
            self.widthConstraint = width
            self.heightConstraint = height
            
            self.widthConstraint.isActive = true
            self.heightConstraint.isActive = true
            print("Portrait: \(size.width) X \(size.height)")
        } else {
            landScapeLeft()
            print("Landscape: \(size.width) X \(size.height)")
            
        }
    }
    
    @objc func GetAnimationImage()
    {
        
        let userInterface = UIDevice.current.userInterfaceIdiom
        if(isFromFreeButton)
        {
            stopTimer()
            
            
            if(userInterface == .pad) {
                setiPadDeviceImage()
            }
            else
            {
                self.imgSubscription.image = UIImage(named: hasTopNotch ? "banner_sub-iphoneR": "banner_sub-iphone")
            }
            self.imgSubscription.bindFrameToSuperviewBounds()
        }
        else {
            
            imgName = array.randomElement()!
            
            var toImage = UIImage(named: "\(imgName)-iphone")
            
            if(userInterface == .pad) {
                if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || self.view.frame.width > self.view.frame.height) {
                    toImage = UIImage(named: "\(imgName)-ipadh")
                }
                else if (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown || self.view.frame.width < self.view.frame.height) {
                    toImage = UIImage(named: "\(imgName)-ipadv")
                }
            }
            else
            {
                if(hasTopNotch){
                    toImage = UIImage(named: "\(imgName)-iphoneR")
                }else {
                    toImage = UIImage(named: "\(imgName)-iphone")
                }
            }
            
            
            UIView.transition(with: self.imgSubscription,
                              duration:5,
                              options: .transitionCrossDissolve,
                              animations: { self.imgSubscription.image = toImage },
                              completion: nil)
            self.imgSubscription.bindFrameToSuperviewBounds()
        }
    }
    
    var hasTopNotch: Bool {
        if #available(iOS 11.0, *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
        
        
        if(isFromFreeButton)
        {
            stopTimer()
            
            timetoRelaxLabel.translatesAutoresizingMaskIntoConstraints = false
            
            timetoRelaxLabel.heightAnchor.constraint(equalToConstant: 0).isActive = true
            
            btnFreeTrial.backgroundColor = UIColor(hexString: "#479c25")
            
            let userInterface = UIDevice.current.userInterfaceIdiom
            
            if(userInterface == .pad) {
                setiPadDeviceImage()
            }
            else
            {
                self.imgSubscription.image = UIImage(named: hasTopNotch ? "banner_sub-iphoneR": "banner_sub-iphone")
            }
            //            if(isFromFreeButton && UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            //                            let title = NSLocalizedString("Start Now", comment: "")
            //                            btnFreeTrial.setTitle(title, for: .normal)
            //
            //            }else{
            self.btnFreeTrial.setTitle(NSLocalizedString("Continue",comment:""), for: .normal)
            // }
        }else{
            self.btnFreeTrial.setTitle(NSLocalizedString("Get started",comment:""), for: UIControlState.normal)
            
        }
        
        self.imgSubscription.bindFrameToSuperviewBounds()
        if UI_USER_INTERFACE_IDIOM() == .pad {
            setOrientation()
        }else{
            self.heightConstraint.isActive = false
            var height: NSLayoutConstraint
            if(isFromFreeButton){
                if(hasTopNotch){
                    height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: 18)
                }
                else {
                    height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 0.77, constant: 5)
                }
            }else {
                if(hasTopNotch){
                    height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.height, multiplier: 0.5, constant: 19)
                }
                else {
                    height = NSLayoutConstraint.init(item: self.imgSubscription, attribute: NSLayoutAttribute.height, relatedBy: .equal, toItem: self.view, attribute: NSLayoutAttribute.width, multiplier: 1, constant: 0)
                }
            }
            self.heightConstraint = height
            self.heightConstraint.isActive = true
            
        }
        //}
        self.lblSimplyRelex.text = NSLocalizedString("Simply relax and color.\nSee your beautiful artwork comes to life\nAccess to all pictures and unlimited paint tools",comment:"")
        self.lblNoCommitment.text = NSLocalizedString("No commitment. Cancel anytime.",comment:"")
        
        
        let weekStr = NSLocalizedString("/ Week", comment: "")
        var weekPrice = ""
        if let val = UserDefaults.standard.value(forKey: "WEEKLY_PRICE"){
            weekPrice = val as! String
        }
        self.freeStringLabel.text = NSLocalizedString("3 day free, then", comment: "") + " "+weekPrice+weekStr
        print("subSciVC VWA")
        self.lblDescription.text = NSLocalizedString("Subscription may be managed by the user and auto-renewal\nmay be turned off by going to the user's Account Settings\nafter purchase. Any unused portion of a free trialperiod, if\noffered, will be forfeited when the user purchases a subscription\nto that publication, where applicable. Payment will be charged to\niTunes Account at confirmation of purchase. Subscription\nautomaticallyrenews unless auto-renewis turned off at\nleast 24-hours before the end of the current period.\nAccount will be charged for renewal within 24-hour prior", comment: "")
        
        if (UIDevice.current.userInterfaceIdiom != .pad) {
            self.lblSimplyRelex.font = self.lblSimplyRelex.font.withSize(18)
            self.lblSimplyRelex.lineBreakMode = NSLineBreakMode.byWordWrapping
            
            self.btnFreeTrial.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
            //self.freeStringLabel.font = UIFont.boldSystemFont(ofSize: 16.0)
            self.freeStringLabel.font = self.lblSimplyRelex.font
        }
        else {
            self.freeStringLabel.font = self.lblSimplyRelex.font
            // self.freeStringLabel.font = self.btnFreeTrial.titleLabel?.font
        }
        
        btnFreeTrial.titleLabel!.adjustsFontSizeToFitWidth = true;
        btnFreeTrial.titleLabel!.minimumScaleFactor = 0.5;
        
        self.timetoRelaxLabel.text = NSLocalizedString("It's time to relax",comment:"")
        // timetoRelaxLabel.adjustsFontSizeToFitWidth = true;
        
        self.view.bringSubview(toFront: img_Offer)
        img_Offer.layer.zPosition = 5;
        
        if (UserDefaults.standard.integer(forKey: purchasessKey) == 1){
            
            if(isFromFreeButton)
            {
                appDelegate.logEvent(name: "Updated_Banner_Subscription", category: "Subscription", action: "View Updated Banner")
            }
            else{
                appDelegate.logEvent(name: "Updated_Launch_Subscription", category: "Subscription", action: "View Updated Subscription")
                appDelegate.logEvent(name: "Launch_Sub_wins", category: "Subscription", action: "Updated_sub")
                appDelegate.logEvent(name: "Audience_Beta", category: "Audience", action: "Testing")
            }
        }
            
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        btnFreeTrial.layer.cornerRadius = btnFreeTrial.frame.height/2
        btnFreeTrial.clipsToBounds = true
    }
    
    func setiPadDeviceImage() {
        
        if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || self.view.frame.width > self.view.frame.height) {
            self.imgSubscription.image = UIImage(named: "banner_sub-ipadh")
            print("banner_sub-ipadh")
        }
        else if (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown || self.view.frame.width < self.view.frame.height) {
            self.imgSubscription.image = UIImage(named: "banner_sub-ipadv")
            print("banner_sub-ipadv")
        }
        
    }
    
    func attributedString() -> NSAttributedString? {
        let attributes : [NSAttributedStringKey : Any] = [
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 17.0),
            NSAttributedStringKey.foregroundColor : UIColor.white
        ]
        let attributedString = NSAttributedString(string: NSLocalizedString("Continue", comment: ""), attributes: attributes)
        return attributedString
    }
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func freeButtonTapped(_ sender: Any) {
        
        
    }
    
    func stopTimer()
    {
        if timer != nil {
            timer!.invalidate()
            timer = nil
        }
    }
}

extension UIView {
    
    func bindFrameToSuperviewBounds() {
        guard let superview = self.superview else {
            print("Error! `superview` was nil – call `addSubview(view: UIView)` before calling `bindFrameToSuperviewBounds()` to fix this.")
            return
        }
        
        self.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.topAnchor.constraint(equalTo: superview.topAnchor,constant: 0),
            self.leadingAnchor.constraint(equalTo: superview.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: superview.trailingAnchor)
        ])
    }
}
