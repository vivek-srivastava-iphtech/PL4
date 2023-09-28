//
//  ReviewViewController.swift
//  PL2
//
//  Created by iPHTech2 on 22/04/20.
//  Copyright © 2020 IPHS Technologies. All rights reserved.
//

import UIKit
import MessageUI

protocol RateViewControllerDelegate:class{
    func crossBtnNoConnectionTapDelegate(sender: UIButton)
    func rateBtnTappedDelegate(sender: UIButton)
}


class RateViewController: UIViewController, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var alertViewWidth: NSLayoutConstraint!
    @IBOutlet weak var alertViewHeight: NSLayoutConstraint!
    @IBOutlet weak var feedbackBtn: UIButton!
    @IBOutlet weak var fiveStartBtn: UIButton!
    @IBOutlet weak var imageViewHeight: NSLayoutConstraint!
    @IBOutlet weak var headingText: UILabel!
    @IBOutlet weak var subHeadingText: UILabel!


    weak var rateViewControllerDelegate: RateViewControllerDelegate?
    var timer: Timer?
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard


    override func viewDidLoad() {
        super.viewDidLoad()
        
        let feedbackString = NSLocalizedString("feedback", comment: "")
        let deviceType = UIDevice.current.deviceType
        if deviceType == .iPhones_5_5s_5c_SE {
            if feedbackString.count > 8 {
                self.feedbackBtn.setTitle(" \(feedbackString) ", for: .normal)
            }
            else {
                self.feedbackBtn.setTitle("   \(feedbackString)   ", for: .normal)
            }
        }
        else {
            if feedbackString.count > 8 {
                self.feedbackBtn.setTitle(" \(feedbackString) ", for: .normal)
            }
            else {
                self.feedbackBtn.setTitle("    \(feedbackString)    ", for: .normal)
            }
        }
        
        let fiveStarString = NSLocalizedString("5 stars", comment: "")
        fiveStartBtn.setTitle("\(fiveStarString)", for: .normal)
        feedbackBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        fiveStartBtn.titleLabel?.adjustsFontSizeToFitWidth = true

        self.feedbackBtn.layer.cornerRadius = feedbackBtn.frame.height/2.0
        self.fiveStartBtn.layer.cornerRadius = fiveStartBtn.frame.height/2.0

        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.buttonFrameUpdate), userInfo:nil, repeats:false)
        
        headingText.text = NSLocalizedString("Congratulations!", comment: "")
        subHeadingText.text = NSLocalizedString("Give us a good rating to encourage us!", comment: "")
        subHeadingText.adjustsFontSizeToFitWidth = true

    }

    @objc func buttonFrameUpdate() {
        self.feedbackBtn.layer.cornerRadius = feedbackBtn.frame.height/2.0
        self.fiveStartBtn.layer.cornerRadius = fiveStartBtn.frame.height/2.0
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.alertView.layer.cornerRadius = 10
        self.alertView.clipsToBounds = true

        if (UIDevice.current.userInterfaceIdiom == .phone) {
            alertViewWidth.constant = self.view.frame.width * 0.86
            alertViewHeight.constant = self.view.frame.height * 0.535
            
            
            let deviceType = UIDevice.current.deviceType
            if deviceType == .iPhoneX {
                self.imageViewHeight.constant = self.alertView.frame.height * 0.4
            }
            else {
                self.imageViewHeight.constant = self.alertView.frame.height * 0.42
            }
        }
        else {
            
            
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                alertViewWidth.constant = self.view.frame.width * 0.42
                alertViewHeight.constant = self.view.frame.height * 0.65
            }
            else {
                alertViewWidth.constant = self.view.frame.width * 0.56
                alertViewHeight.constant = self.view.frame.height * 0.47
            }
            self.imageViewHeight.constant = self.alertView.frame.height * 0.42

        }
        
        self.feedbackBtn.layer.cornerRadius = feedbackBtn.frame.height/2.0
        self.fiveStartBtn.layer.cornerRadius = fiveStartBtn.frame.height/2.0

    }

    @IBAction func crossTapped(_ sender: UIButton) {

        self.appDelegate.logEvent(name: "Rate_Cancel", category: "", action: "Cancel Button Tapped")
        self.dismiss(animated: true, completion: nil)

    }
    
    //MARK: Feedback Tap Action.
    @IBAction func feedbackTapped(_ sender: UIButton) {
        
        
        defaults.set("1", forKey: "feedbackOrRateTapped")

        self.appDelegate.logEvent(name: "Rate_Feedback", category: "", action: "Feedback Button Tapped")

        guard MFMailComposeViewController.canSendMail() else {
               print("Mail services are not available")
               showSendMailErrorAlert()
               return
        }

        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.setToRecipients(["feedback@pixelcolorapp.com"])
        composeVC.setSubject("Feedback")
//        composeVC.setMessageBody("Hello from California!", isHTML: false)

        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)

    }

    //MARK: Five Star Tap Action.
    @IBAction func fiveStarTapped(_ sender: UIButton) {
        
        defaults.set("1", forKey: "feedbackOrRateTapped")
        
        self.appDelegate.logEvent(name: "Rate_Stars", category: "", action: "FiveStar Button Tapped")
        
//        self.rateViewControllerDelegate?.rateBtnTappedDelegate(sender: sender)
        
        // Note: Replace the XXXXXXXXXX below with the App Store ID for your app
        // You can find the App Store ID in your app's product URL
        guard let writeReviewURL = URL(string: "https://itunes.apple.com/app/id1277229792?action=write-review")
        else {
            fatalError("Expected a valid URL")
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)

        self.dismiss(animated: true, completion: nil)

    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Swift.Error?) {
        controller.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }

}

extension UIDevice {

    enum DeviceType: String {
        case iPhone4_4S = "iPhone 4 or iPhone 4S"
        case iPhones_5_5s_5c_SE = "iPhone 5, iPhone 5s, iPhone 5c or iPhone SE"
        case iPhones_6_6s_7_8 = "iPhone 6, iPhone 6S, iPhone 7 or iPhone 8"
        case iPhones_6Plus_6sPlus_7Plus_8Plus = "iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus or iPhone 8 Plus"
        case iPhoneX = "iPhone X"
        case unknown = "iPadOrUnknown"
    }
    
    var deviceType: DeviceType {
        switch UIScreen.main.nativeBounds.height {
        case 960:
            return .iPhone4_4S
        case 1136:
            return .iPhones_5_5s_5c_SE
        case 1334:
            return .iPhones_6_6s_7_8
        case 1920, 2208:
            return .iPhones_6Plus_6sPlus_7Plus_8Plus
        case 1624, 2436, 1792, 2688:
            return .iPhoneX
        default:
            return .unknown
        }
    }
    
}
