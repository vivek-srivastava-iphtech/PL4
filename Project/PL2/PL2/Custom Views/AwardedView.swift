//
//  AwardedView.swift
//  PL2
//
//  Created by iPHTech12 on 18/09/2018.
//  Copyright © 2018 IPHS Technologies. All rights reserved.
//

import UIKit

protocol awardView:class{
    func awardViewDismissBtnClicked(view:UIView)
}
class AwardedView: UIView {

   weak var delegate:awardView?
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var toplabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit(){
        Bundle.main.loadNibNamed("AwardedView", owner: self, options:nil )
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleWidth,.flexibleHeight]
    }
    
    @IBAction func dismissBtn(_ sender: Any) {
        delegate?.awardViewDismissBtnClicked(view: self)
    }


}
