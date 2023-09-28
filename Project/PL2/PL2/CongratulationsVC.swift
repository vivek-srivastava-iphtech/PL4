//
//  CongratulationsVC.swift
//  PL2
//
//  Created by Zaman Meraj on 2/26/19.
//  Copyright © 2019 IPHS Technologies. All rights reserved.
//

import UIKit

protocol CongratulationVCDelegate:class{
    func crossBtnTappedDelegate(sender: UIButton)
    func claimBtnTappedDelegate(sender: UIButton)
}


class CongratulationsVC: UIViewController {

    @IBOutlet weak var alertView: UIView!
    @IBOutlet weak var claimBtn: UIButton!
    @IBOutlet weak var successLable: UILabel!
    @IBOutlet weak var bonusDescLable: UILabel!
    
    weak var congratulateVCDelegate: CongratulationVCDelegate?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
       self.successLable.text = NSLocalizedString("Success!",comment:"")
          self.bonusDescLable.text = NSLocalizedString("Bonus pack has been\nunlocked! Check it out at\nBonus section.",comment:"")
        self.claimBtn.setTitle(NSLocalizedString("CLAIM",comment:""), for: UIControlState.normal)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        self.claimBtn.layer.cornerRadius = self.claimBtn.frame.height/2
        self.claimBtn.clipsToBounds = true
        self.alertView.layer.cornerRadius = 10
        self.alertView.clipsToBounds = true
        
    }


    @IBAction func crossBtnTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.3, animations: {
            self.alertView.transform = CGAffineTransform.init(translationX: 0, y: UIScreen.main.bounds.height)
        }) { (isAnimating) in
            self.congratulateVCDelegate?.crossBtnTappedDelegate(sender: sender)
            self.view.layoutIfNeeded()
        }

    }

    
    
    @IBAction func claimBtnTapped(_ sender: UIButton) {
         self.congratulateVCDelegate?.claimBtnTappedDelegate(sender: sender)
    }
    
    
}
