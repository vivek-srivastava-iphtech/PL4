//
//  LabelImage.swift
//  PL2
//
//  Created by iPHTech8 on 10/26/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit

class LabelImage: UIImage {

    var squareWidth:CGFloat = 10.0
    var coloredColors = [[UIColor]]()
    var colorsNumber = [ColorWithNumber]()
    var grayoutNumber = Int()
    var labelArray = [[(String,UIColor,CGFloat)]]()
   
   
    override func draw(in rect: CGRect) {
        var textFont =  UIFont()
        if UI_USER_INTERFACE_IDIOM() == .pad{
            textFont =  UIFont(name:"Avenir-Light", size:16.0)!
        }
        else{
            textFont =  UIFont(name:"Avenir-Light", size:11.0)!
        }
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        let textFontAttributes = [NSAttributedStringKey.font: textFont, NSAttributedStringKey.paragraphStyle:style
            ] as [NSAttributedStringKey : Any]
        
        //        let context = UIGraphicsGetCurrentContext()
        //        context?.setLineWidth(0.25)
        let rows = Int(rect.width/squareWidth)
        let columns = Int(rect.height/squareWidth)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(0.25)
        
        for  x in 0..<rows{
            for  y in 0..<columns{
                let touple =  labelArray[x][y]
                let number = touple.0 as NSString
              /*
                let rectanglePath = UIBezierPath()
                rectanglePath.lineWidth = 0.25
               
                rectanglePath.move(to: CGPoint(x: x * Int(squareWidth), y: y * Int(squareWidth)))
                rectanglePath.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth), y: y * Int(squareWidth)))
                rectanglePath.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
                rectanglePath.addLine(to: CGPoint(x: x * Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
                rectanglePath.close()
                */
                 context?.move(to: CGPoint(x: x * Int(squareWidth), y: y * Int(squareWidth)))
                 context?.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth), y: y * Int(squareWidth)))
                 context?.addLine(to: CGPoint(x: x * Int(squareWidth) + Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
                 context?.addLine(to: CGPoint(x: x * Int(squareWidth) , y: y * Int(squareWidth) + Int(squareWidth)))
                 context?.closePath()
 
                
                if grayoutNumber == Int(touple.0){
                    context?.setFillColor(UIColor(white: 0.7, alpha: 0.5).cgColor)
//                    UIColor(white: 0.7, alpha: 0.5).setFill()
//                    rectanglePath.fill()
                    context?.fillPath()
                }
                touple.1.setStroke()
                context?.setStrokeColor(touple.1.cgColor)
                context?.strokePath()
//                rectanglePath.stroke()
                number.drawVerticallyCentered(in: CGRect(x:CGFloat(x) * squareWidth,y:CGFloat(y) * squareWidth,width:squareWidth,height:squareWidth), withAttributes: textFontAttributes)
                
                let newImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                UIGraphicsEndImageContext()
                UIGraphicsEndImageContext()
                
            }
        }
    }
    
}
