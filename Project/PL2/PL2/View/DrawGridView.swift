//
//  DrawGridView.swift
//  PL2
//
//  Created by iPHTech8 on 10/11/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//
import UIKit

class DrawGridView: UIView {

    var squareWidth:CGFloat = 10.0
    var colorArray = [[UIColor]]()
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.contentsScale = UIScreen.main.scale;
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func draw(_ rect: CGRect) {
        let rows = Int(rect.width/squareWidth)
        let columns = Int(rect.height/squareWidth)
        let context = UIGraphicsGetCurrentContext()
        
//         context?.saveGState()
//        let rectanglePath = UIBezierPath()
        for  x in 0..<rows{
            
            for  y in 0..<columns{
//                context?.saveGState()
                
                context?.move(to: CGPoint(x: x * Int(squareWidth), y: y * Int(squareWidth)))
                context?.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth), y: y * Int(squareWidth)))
                context?.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
                context?.addLine(to: CGPoint(x: x * Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
                colorArray[x][y].setFill()
                context?.fillPath()
//                context?.saveGState()
//                context?.restoreGState()
            }
        }
//         context?.restoreGState()
    }
 

}
