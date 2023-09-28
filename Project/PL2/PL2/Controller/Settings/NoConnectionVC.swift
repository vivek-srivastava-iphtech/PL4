//
//  NoConnectionVC.swift
//  PL2
//
//  Created by iPHTech2 on 18/06/19.
//  Copyright © 2019 IPHS Technologies. All rights reserved.
//

import UIKit

    protocol NoConnectionVCDelegate:class{
        func crossBtnNoConnectionTapDelegate(sender: UIButton)
        func tryBtnTappedDelegate(sender: UIButton)
    }


    class NoConnectionVC: UIViewController {

        @IBOutlet weak var titleLbl: UILabel!
        @IBOutlet weak var internetImg: UIImageView!
        @IBOutlet weak var alertView: UIView!
        @IBOutlet weak var tryBtn: UIButton!
        weak var noConnectionVCDelegate: NoConnectionVCDelegate?
        override func viewDidLoad() {
            super.viewDidLoad()


            // self.alertView.transform = CGAffineTransform.init(translationX: 0, y: UIScreen.main.bounds.height)
        }

        override func viewDidAppear(_ animated: Bool) {
            //        UIView.animate(withDuration: 0.3, animations: {
            //            self.alertView.transform = CGAffineTransform.identity
            //        }) { (isAnimating) in
            //            self.view.layoutIfNeeded()
            //        }
        }

        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()

            self.tryBtn.layer.cornerRadius = self.tryBtn.frame.height/2
            self.tryBtn.clipsToBounds = true
            self.alertView.layer.cornerRadius = 10
            self.alertView.clipsToBounds = true

            let str1 = NSLocalizedString("Oops", comment: "")
            let str2 = NSLocalizedString("\n", comment: "")
            let str3 = NSLocalizedString("No Internet Connection", comment: "")
            let str4 = NSLocalizedString("Please try again", comment: "")
           let  tipsTextString = str1 + str2 + str3 + str2 + str4
            titleLbl.text = tipsTextString
             if UI_USER_INTERFACE_IDIOM() == .phone {
                titleLbl.font.withSize(18)
            }
             

        }


        @IBAction func crossTapped(_ sender: UIButton) {
            UIView.animate(withDuration: 0.3, animations: {
                self.alertView.transform = CGAffineTransform.init(translationX: 0, y: UIScreen.main.bounds.height)
            }) { (isAnimating) in
                self.noConnectionVCDelegate?.crossBtnNoConnectionTapDelegate(sender: sender)
                self.view.layoutIfNeeded()
            }

        }



        @IBAction func tryBtnTapped(_ sender: UIButton) {
            self.noConnectionVCDelegate?.tryBtnTappedDelegate(sender: sender)
        }
}
