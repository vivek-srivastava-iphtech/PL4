//
//  ChooseColorCollectionCell.swift
//  PL2
//
//  Created by iPHTech8 on 9/21/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit

class ChooseColorCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak var colorView: UIView!
    @IBOutlet weak var number:UILabel!
    @IBOutlet weak var colorCompleteImageView:UIImageView!
    @IBOutlet weak var colorProgressBar: CircularProgressBar!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutIfNeeded()
        
        colorView.layer.cornerRadius = colorView.frame.size.height/2.0
//        self.colorView.clipsToBounds = true
//        self.colorView.layer.borderColor = UIColor.white.cgColor
//        self.colorView.layer.borderWidth = 1.0
    }
    


}
