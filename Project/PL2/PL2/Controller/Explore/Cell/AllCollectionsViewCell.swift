//
//  AllCollectionsViewCell.swift
//  PL2
//
//  Created by iPHTech38 on 30/08/22.
//  Copyright © 2022 IPHS Technologies. All rights reserved.
//

import UIKit

class AllCollectionsViewCell: UICollectionViewCell {
    
    @IBOutlet weak var groupImage: UIImageView!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var containerViewLeading: NSLayoutConstraint!
    @IBOutlet weak var containerViewTrailing: NSLayoutConstraint!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
}
