//
//  CopyTagViewController.swift
//  PL2
//
//  Created by iPHTech2 on 31/01/19.
//  Copyright © 2019 IPHS Technologies. All rights reserved.
//

import UIKit

class CopyTagViewController: UIViewController {

    @IBOutlet var lblCopyText: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        lblCopyText.text = NSLocalizedString("copied", comment: "")
        self.perform(#selector(self.HideTagPopup), with: nil, afterDelay: 2.0)

    }

    @objc func HideTagPopup()
    {
       self.dismiss(animated: true, completion: nil)
    }
}
