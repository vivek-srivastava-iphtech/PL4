//
//  CustomAwardView.swift
//  PL2
//
//  Created by iPHTech12 on 18/09/2018.
//  Copyright © 2018 IPHS Technologies. All rights reserved.
//

import UIKit

protocol customAwardViewDelegate:class{
    func dismissBtnofCustomAwardViewClicked(view:UIView)
}
class CustomAwardView: UIView {

    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var toplabel: UILabel!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightLabel: UILabel!
     @IBOutlet weak var sharefbinImageView: UIImageView!
     @IBOutlet weak var coloredBucketiPadImage: UIImageView!
    
    weak var delegate:customAwardViewDelegate?
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("CustomAwardView", owner: self, options:nil )
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    @IBAction func dismissBtn(_ sender: Any) {
        delegate?.dismissBtnofCustomAwardViewClicked(view: self)
    }
    
    
}
