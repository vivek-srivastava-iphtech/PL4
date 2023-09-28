//
//  DailyGiftViewController.swift
//  PL2
//
//  Created by iPHTech2 on 22/04/20.
//  Copyright © 2020 IPHS Technologies. All rights reserved.
//

import UIKit
import MessageUI

protocol DailyGiftViewControllerDelegate:class{
    func dailyGiftCrossBtnDelegate()
}

class DailyGiftViewController: UIViewController, FaveButtonDelegate {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertViewWidth: NSLayoutConstraint!
    @IBOutlet weak var alertViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headingText: UILabel!
    @IBOutlet weak var todayLabel: UILabel!
    @IBOutlet weak var todayImageView: UIImageView!
    @IBOutlet weak var todayHint: UILabel!
    @IBOutlet weak var day2Label: UILabel!
    @IBOutlet weak var day2ImageView: UIImageView!
    @IBOutlet weak var day2Hint: UILabel!
    @IBOutlet weak var day3Label: UILabel!
    @IBOutlet weak var day3ImageView: UIImageView!
    @IBOutlet weak var day3Hint: UILabel!
    @IBOutlet weak var day4Label: UILabel!
    @IBOutlet weak var day4ImageView: UIImageView!
    @IBOutlet weak var day4Hint: UILabel!
    @IBOutlet weak var day5Label: UILabel!
    @IBOutlet weak var day5ImageView: UIImageView!
    @IBOutlet weak var day5Hint: UILabel!
    @IBOutlet weak var claimButton: UIButton!
    @IBOutlet weak var claimButtonHeight: NSLayoutConstraint!
    @IBOutlet var animatedButton : FaveButton?

    weak var dailyGiftViewControllerDelegate: DailyGiftViewControllerDelegate?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    
    let colors = [
        DotColors(first: color(0x7DC2F4), second: color(0xE2264D)),
        DotColors(first: color(0xF8CC61), second: color(0x9BDFBA)),
        DotColors(first: color(0xAF90F4), second: color(0x90D1F9)),
        DotColors(first: color(0xE9A966), second: color(0xF8C852)),
        DotColors(first: color(0xF68FA7), second: color(0xF6A2B8))
    ]


    override func viewDidLoad() {
        super.viewDidLoad()
        
        headingText.text = NSLocalizedString("Get your daily gift!", comment: "")
        todayLabel.text = NSLocalizedString("Today", comment: "")
        todayHint.text = "\(hints3Reward)\(NSLocalizedString(" x Hints", comment: ""))"
        day2Label.text = NSLocalizedString("Day 2", comment: "")
        day2Hint.text = "\(hints5Reward)\(NSLocalizedString(" x Hints", comment: ""))"
        day3Label.text = NSLocalizedString("Day 3", comment: "")
        day3Hint.text = "\(hints7Reward)\(NSLocalizedString(" x Hints", comment: ""))"
        day4Label.text = NSLocalizedString("Day 4", comment: "")
        day4Hint.text = "\(hints10Reward)\(NSLocalizedString(" x Hints", comment: ""))"
        day5Label.text = NSLocalizedString("Day 5", comment: "")
        day5Hint.text = "\(hints12Reward)\(NSLocalizedString(" x Hints", comment: ""))"
        claimButton.setTitle(NSLocalizedString("CLAIM", comment: ""), for: .normal)
        
        headingText.adjustsFontSizeToFitWidth = true
        todayLabel.adjustsFontSizeToFitWidth = true
        todayHint.adjustsFontSizeToFitWidth = true
        day2Label.adjustsFontSizeToFitWidth = true
        day2Hint.adjustsFontSizeToFitWidth = true
        day3Label.adjustsFontSizeToFitWidth = true
        day3Hint.adjustsFontSizeToFitWidth = true
        day4Label.adjustsFontSizeToFitWidth = true
        day4Hint.adjustsFontSizeToFitWidth = true
        day5Label.adjustsFontSizeToFitWidth = true
        day5Hint.adjustsFontSizeToFitWidth = true

        setImagesAccordingToGiftCountValue()
        saveGiftClaimCountAndHintCountValue()
        appDelegate.logEvent(name: "Daily_Win", category: "Daily Gift Window", action: "daily_show")
        animatedButton?.isHidden = true

        NotificationCenter.default.addObserver(self, selector: #selector(saveClosingTime), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
        
    }
    
    func setImagesAccordingToGiftCountValue() {
        
        let giftClaimCount = UserDefaults.standard.integer(forKey: giftClaimCountValue)
        if giftClaimCount == 1 {
            setImage(sendImage: todayImageView)
        }
        else if giftClaimCount == 2 {
            setImage(sendImage: todayImageView)
            setImage(sendImage: day2ImageView)
        }
        else if giftClaimCount == 3 {
            setImage(sendImage: todayImageView)
            setImage(sendImage: day2ImageView)
            setImage(sendImage: day3ImageView)
        }
        else if giftClaimCount == 4 {
            setImage(sendImage: todayImageView)
            setImage(sendImage: day2ImageView)
            setImage(sendImage: day3ImageView)
            setImage(sendImage: day4ImageView)
        }
        else if giftClaimCount == 5 {
            setImage(sendImage: todayImageView)
            setImage(sendImage: day2ImageView)
            setImage(sendImage: day3ImageView)
            setImage(sendImage: day4ImageView)
            setImage(sendImage: day5ImageView)
        }
    }

    func setImage(sendImage imageView: UIImageView) {
        
        UIView.transition(with: imageView, duration: 0.5, options: .transitionCrossDissolve, animations: {

            if #available(iOS 13.0, *) {
                imageView.image = UIImage(systemName: "checkmark.circle.fill")
                
            } else {
                
                imageView.image = #imageLiteral(resourceName: "blueCheck")
            }

        }, completion: nil)

    }


    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        if (UIDevice.current.userInterfaceIdiom == .phone) {
            
            let deviceType = UIDevice.current.deviceType
            if deviceType == .iPhones_5_5s_5c_SE {
                alertViewWidth.constant = self.view.frame.width * 0.93
                alertViewHeight.constant = self.view.frame.height * 0.76
            }
            else {
                alertViewWidth.constant = self.view.frame.width * 0.78
                alertViewHeight.constant = self.view.frame.height * 0.6
            }
            alertView.layer.cornerRadius = 15
            claimButtonHeight.constant = 54
            claimButton.layer.cornerRadius = 27
        }
        else {

            if (UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight || self.view.frame.width > self.view.frame.height) {
                alertViewWidth.constant = self.view.frame.width * 0.50
                alertViewHeight.constant = self.view.frame.height * 0.84
                alertView.layer.cornerRadius = 20
            }
            else if (UIDevice.current.orientation == .portrait || UIDevice.current.orientation == .portraitUpsideDown || self.view.frame.width < self.view.frame.height) {
                alertViewWidth.constant = self.view.frame.width * 0.68
                alertViewHeight.constant = self.view.frame.height * 0.76
                alertView.layer.cornerRadius = 20
            }
            
            claimButtonHeight.constant = 70
            claimButton.layer.cornerRadius = 35

        }
        alertView.clipsToBounds = true
        claimButton.clipsToBounds = true

    }

    @IBAction func crossTapped(_ sender: UIButton) {

        dismissView()
        
    }
    
    func saveGiftClaimCountAndHintCountValue()  {
        
        let giftClaimCount = UserDefaults.standard.integer(forKey: giftClaimCountValue)
        let currentValue = giftClaimCount+1
        UserDefaults.standard.set(currentValue, forKey: giftClaimCountValue)
        
        if currentValue == 1 {
            UserDefaults.standard.set(hints3Reward, forKey: "GIFT_HINT_COUNT")
        }
        else if currentValue == 2 {
            UserDefaults.standard.set(hints5Reward, forKey: "GIFT_HINT_COUNT")
        }
        else if currentValue == 3 {
            UserDefaults.standard.set(hints7Reward, forKey: "GIFT_HINT_COUNT")
        }
        else if currentValue == 4 {
            UserDefaults.standard.set(hints10Reward, forKey: "GIFT_HINT_COUNT")
        }
        else if currentValue == 5 {
            UserDefaults.standard.set(hints12Reward, forKey: "GIFT_HINT_COUNT")
        }
    }
    
    @objc func saveClosingTime() {

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        formatter.locale = Locale.current
        let giftDisplayTimeString = formatter.string(from: Date())
        UserDefaults.standard.set("\(giftDisplayTimeString)", forKey: giftWindowsVisibleTime)

    }

    @objc func dismissView() {

        saveClosingTime()
        self.dailyGiftViewControllerDelegate?.dailyGiftCrossBtnDelegate()
        self.dismiss(animated: true, completion: nil)
    }

    //MARK: Claim Tap Action.
    @IBAction func claimButtonTapped(_ sender: UIButton) {
        appDelegate.logEvent(name: "Daily_Claim", category: "Daily Gift Window", action: "daily_claim")
        sender.isEnabled = false
        setImagesAccordingToGiftCountValue()
        
        let giftClaimCount = UserDefaults.standard.integer(forKey: giftClaimCountValue)
        
        let gift_d5past = UserDefaults.standard.bool(forKey: gift_day_5_Past)
        if(gift_d5past == true)
        {
            appDelegate.logEvent(name: "gift_d5past", category: "Daily Gift Window", action: "daily_claim")
        }
        else {
            if giftClaimCount == 1 {
                appDelegate.logEvent(name: "gift_d1", category: "Daily Gift Window", action: "daily_claim")
            }
            else if giftClaimCount == 2 {
                appDelegate.logEvent(name: "gift_d2", category: "Daily Gift Window", action: "daily_claim")
            }
            else if giftClaimCount == 3 {
                appDelegate.logEvent(name: "gift_d3", category: "Daily Gift Window", action: "daily_claim")
            }
            else if giftClaimCount == 4 {
                appDelegate.logEvent(name: "gift_d4", category: "Daily Gift Window", action: "daily_claim")
            }
            else if giftClaimCount == 5 {
                UserDefaults.standard.set(true, forKey: gift_day_5_Past)
                appDelegate.logEvent(name: "gift_d5", category: "Daily Gift Window", action: "daily_claim")
            }
        }
        perform(#selector(dismissView), with: nil, afterDelay: 0.6)

    }
    
    //MARK: FaveButton Delegate.
    func faveButton(_ faveButton: FaveButton, didSelected selected: Bool) {
    }
    
    func faveButtonDotColors(_ faveButton: FaveButton) -> [DotColors]?{
        if(faveButton === animatedButton){
            return colors
        }
        return nil
    }

}
