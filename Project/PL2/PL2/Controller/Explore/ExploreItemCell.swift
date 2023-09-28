//
//  ExploreItemCell.swift
//  PL2
//
//  Created by iPHTech25 on 18/05/21.
//  Copyright © 2021 IPHS Technologies. All rights reserved.
//

import UIKit

class ExploreItemCell: UICollectionViewCell {
    
    @IBOutlet weak var customContentView: UIView!
    @IBOutlet weak var groupImage: UIImageView!
    
    @IBOutlet weak var groupDescription: UILabel!
    @IBOutlet weak var categoryImage: UIImageView!
    @IBOutlet weak var categoryLable: UILabel!
    
    override func layoutSubviews() {
        
        if self.groupImage.tag != 101 {
            let view = UIView(frame:CGRect(x: 0, y: 0, width: self.groupImage.bounds.width+300, height: self.groupImage.bounds.height+300))
            let gradient = CAGradientLayer()
            gradient.frame = view.frame
            gradient.colors = [#colorLiteral(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.1).cgColor, #colorLiteral(red: 0, green: 0, blue: 0, alpha: 0.6).cgColor]
            gradient.locations = [0.0, 1.0]
            view.layer.insertSublayer(gradient, at: 0)
            self.groupImage.addSubview(view)
            self.groupImage.tag = 101
        }

    }

}
