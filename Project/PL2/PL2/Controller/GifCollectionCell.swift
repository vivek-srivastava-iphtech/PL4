//
//  GifCollectionCell.swift
//  PL2
//
//  Created by iPHTech2 on 03/12/18.
//  Copyright © 2018 IPHS Technologies. All rights reserved.
//

import UIKit

class GifCollectionCell: UICollectionViewCell {

    @IBOutlet weak var cancelButton:UIButton!
    @IBOutlet weak var gifImageView:UIImageView!
    @IBOutlet weak var descriptionLabel:UILabel!
    @IBOutlet weak var pageControl: UIPageControl!

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var containerViewTop: NSLayoutConstraint!
    @IBOutlet weak var containerViewBottom: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        

    }

}
