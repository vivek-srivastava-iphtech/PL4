//
//  SliderCell.swift
//  InPower
//
//  Created by Saddam Khan on 5/31/21.
//  Copyright © 2021 iPHSTech31. All rights reserved.
//

import UIKit

class SliderCell: UICollectionViewCell {
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var containerViewLeading: NSLayoutConstraint!
    @IBOutlet weak var containerViewTrailing: NSLayoutConstraint!

    @IBOutlet weak var checkImage: UIImageView!
    
    @IBOutlet weak var newButton: UIButton!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.newButton.layer.cornerRadius = 5
        self.newButton.clipsToBounds = true
        self.newButton.isUserInteractionEnabled = false
        self.newButton.setTitle(NSLocalizedString("NEW", comment: ""), for: .normal)
        if UIDevice.current.userInterfaceIdiom == .pad
        {
            self.newButton.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        }
    }
    
}

