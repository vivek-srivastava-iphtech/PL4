//
//  CategoryCollectionViewCell.swift
//  PL2
//
//  Created by Lekha Mishra on 11/28/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit

class CategoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func isSelectedItem(val : Bool) {
        
        self.backgroundColor = UIColor.white
        
        if val == true{
            
            self.imgView.backgroundColor = UIColor(hexString: highlightColorString) //UIColor(red: 198.0/255.0, green: 27.0/255.0, blue: 46.0/255.0, alpha: 1.0)
            self.titleTxt.textColor = UIColor.white
            
        }
        else{
            self.imgView.backgroundColor = UIColor.white
            self.titleTxt.textColor = UIColor.gray
        }
    }
    
        override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes)
            -> UICollectionViewLayoutAttributes {
                return layoutAttributes
        }

}
