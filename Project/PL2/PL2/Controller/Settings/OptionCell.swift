//
//  OptionCell.swift
//  PL2
//
//  Created by Lekha Mishra on 12/12/17.
//  Copyright © 2017 IPHS Technologies. All rights reserved.
//

import UIKit

class OptionCell: UITableViewCell {

    @IBOutlet weak var titleTxt: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var arrowLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
