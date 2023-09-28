//
//  MyWorkCell.swift
//  PL2
//
//  Created by iPHTech8 on 11/1/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit

class MyWorkCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var lockView: UIImageView!
    @IBOutlet weak var leftOffSetConstraint: NSLayoutConstraint!
    @IBOutlet weak var rightOffSetConstraint: NSLayoutConstraint!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var completeIcon: UIImageView!
    
   //var loader = UIActivityIndicatorView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backImageView.layer.cornerRadius = 12
        self.backImageView.clipsToBounds = true
        self.imageView.alpha = 0.9;
        
        //loader = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        //loader.hidesWhenStopped = true
        //contentView.addSubview(loader)
//        loader.startAnimating()
      
    }
    
    func updateOffSet(_ isLeftIndex: Bool) {
        
//        if isLeftIndex{
//            leftOffSetConstraint.constant = 10.0
//            rightOffSetConstraint.constant = 5.0
//        }
//        else
//        {
//            leftOffSetConstraint.constant = 5.0
//            rightOffSetConstraint.constant = 10.0
//        }
        
//        self.layoutIfNeeded()
    }
    
    func updateOffSetForiPadLandscape(_ index: Int) {
        
//        switch index {
//        case 0:
//            leftOffSetConstraint.constant = 20.0
//            rightOffSetConstraint.constant = 0.0
//            break;
//        case 1:
//            leftOffSetConstraint.constant = 10.0
//            rightOffSetConstraint.constant = 10.0
//            break;
//        case 2:
//            leftOffSetConstraint.constant = 0.0
//            rightOffSetConstraint.constant = 20.0
//            break;
//        default:
//            leftOffSetConstraint.constant = 10.0
//            rightOffSetConstraint.constant = 10.0
//        }
        
        
        //        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        //loader.layoutIfNeeded()
        //loader.layer.layoutIfNeeded()
        //loader.center = CGPoint(x: backImageView.frame.size.width/2, y: backImageView.frame.size.height/2)
    }
    


}
