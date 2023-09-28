//
//  AdScreenViewController.swift
//  PL2
//
//  Created by Lekha Mishra on 11/24/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit

class AdScreenViewController: UIViewController {
    
    @IBOutlet weak var freeButton: UIButton!
    @IBOutlet weak var monthSubscriptionButton: UIButton!
    @IBOutlet weak var yearSubscriptionButton: UIButton!
    @IBOutlet weak var joinCommunityLbl: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var title = NSLocalizedString("$2.99 / Week", comment: "")
        freeButton.setTitle(title, for: .normal)
        
        title = NSLocalizedString("$7.99 / Month", comment: "")
        var price = " $7.99"
       // title = title+price
        monthSubscriptionButton.setTitle(title, for: .normal)
        
        title = NSLocalizedString("$39.99 / Year", comment: "")
        price = " $39.99"
        yearSubscriptionButton.setTitle(title, for: .normal)
        
        title = NSLocalizedString("Get Pixel Coloring Pro unlimited access to all pictures and updates.", comment: "")
        joinCommunityLbl.text = title
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK:- Button actions
    
    @IBAction func cancelClicked(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func helpClicked(_ sender: Any) {
        //let vc = self.storyboard?.instantiateViewController(withIdentifier: "AboutWebViewController") as! AboutWebViewController
        //vc.intPassed = 1;
        //self.present(vc,animated:true,completion:nil)
        self.dismiss(animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
