//
//  newsCell.swift
//  PL2
//
//  Created by iPHTech2 on 04/02/19.
//  Copyright © 2019 IPHS Technologies. All rights reserved.
//

import UIKit

class newsCell: UITableViewCell {

//    @IBOutlet weak var containerSubview: UIView!
    @IBOutlet var lblTitle: UILabel!
    @IBOutlet var lblSubTitle: UILabel!
    @IBOutlet var imgProfile: UIImageView!
    @IBOutlet var btnOpen: UIButton!
    @IBOutlet var containerView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        /*btnOpen.layer.cornerRadius = 5
        btnOpen.backgroundColor = UIColor(red:1.00, green:0.40, blue:0.40, alpha:1.0)*/
        
        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 5.0
        
        
        /*containerView.layer.shadowOffset = CGSize(width: -1, height:  1)
        containerView.layer.shadowOpacity = 0.5*/
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        //set the values for top,left,bottom,right margins
        /*let margins = UIEdgeInsets(top: 20, left: 0, bottom: 40, right: 0)
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, margins)*/
        
//        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        
//        contentView.frame = contentView.frame.insetBy(dx: 10, dy: 10)
        
//        containerView.layer.masksToBounds = false
        containerView.layer.cornerRadius = 10
        containerView.clipsToBounds = true
        
        self.btnOpen.layer.cornerRadius = 5
        self.btnOpen.clipsToBounds = true
        
//        containerSubview.layer.cornerRadius = 10
//        containerSubview.clipsToBounds = true
        let margins = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        contentView.frame = UIEdgeInsetsInsetRect(contentView.frame, margins)
        
    }
    
    
    
}
