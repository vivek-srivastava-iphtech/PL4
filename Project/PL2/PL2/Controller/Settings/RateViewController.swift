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


    weak var rateViewControllerDelegate: RateViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        self.alertView.layer.cornerRadius = 10
        self.alertView.clipsToBounds = true
        
        self.feedbackBtn.layer.cornerRadius = feedbackBtn.frame.height/2.0
        self.fiveStartBtn.layer.cornerRadius = fiveStartBtn.frame.height/2.0


        if (UIDevice.current.userInterfaceIdiom == .phone) {
            alertViewWidth.constant = self.view.frame.width * 0.86
            alertViewHeight.constant = self.view.frame.height * 0.535
        }
        else {
            
            if UIDevice.current.orientation == .landscapeLeft || UIDevice.current.orientation == .landscapeRight {
                alertViewWidth.constant = self.view.frame.width * 0.42
                alertViewHeight.constant = self.view.frame.height * 0.62
            }
            else {
                alertViewWidth.constant = self.view.frame.width * 0.56
                alertViewHeight.constant = self.view.frame.height * 0.47
            }

        }

    }

    @IBAction func crossTapped(_ sender: UIButton) {

        self.dismiss(animated: true, completion: nil)

    }
    
    //MARK: Feedback Tap Action.
    @IBAction func feedbackTapped(_ sender: UIButton) {
        
        guard MFMailComposeViewController.canSendMail() else {
               print("Mail services are not available")
               return
           }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
         
        // Configure the fields of the interface.
        composeVC.setToRecipients(["pixel@moomoolab.com"])
        composeVC.setSubject("Feedback")
//        composeVC.setMessageBody("Hello from California!", isHTML: false)

        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)

    }

    //MARK: Five Star Tap Action.
    @IBAction func fiveStarTapped(_ sender: UIButton) {
        
        self.rateViewControllerDelegate?.rateBtnTappedDelegate(sender: sender)
        self.dismiss(animated: true, completion: nil)

    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Swift.Error?) {
        controller.dismiss(animated: true, completion: nil)
    }

}
