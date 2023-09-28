//
//  CustomSwitch.swift
//  PL2
//
//  Created by iPHTech2 on 29/08/18.
//  Copyright © 2018 IPHS Technologies. All rights reserved.
//

import UIKit
@IBDesignable

class CustomSwitch: UISwitch {

    @IBInspectable var OffTint: UIColor? {
        didSet {
            self.tintColor = OffTint
            self.layer.cornerRadius = 16
            self.backgroundColor = OffTint
        }
    }
}
