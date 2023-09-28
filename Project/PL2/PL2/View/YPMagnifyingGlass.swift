//
//  YPMagnifyingGlass.swift
//  YPMagnifyingGlass
//
//  Created by Geert-Jan Nilsen on 02/06/15.
//  Copyright (c) 2015 Yuppielabel.com All rights reserved.
//

import UIKit
import QuartzCore

public class YPMagnifyingGlass: UIView {

  public var viewToMagnify: UIView!
  public var touchPoint: CGPoint! {
    didSet {
        self.center = CGPoint(x: touchPoint.x + touchPointOffset.x, y: touchPoint.y + touchPointOffset.y)
    }
  }
  
  public var touchPointOffset: CGPoint!
  public var scale: CGFloat!
  public var scaleAtTouchPoint: Bool!
  
  public var YPMagnifyingGlassDefaultRadius: CGFloat = 60.0
  public var YPMagnifyingGlassDefaultOffset: CGFloat = -80.0
  public var YPMagnifyingGlassDefaultScale: CGFloat = 2.0
  
  public func initViewToMagnify(viewToMagnify: UIView, touchPoint: CGPoint, touchPointOffset: CGPoint, scale: CGFloat, scaleAtTouchPoint: Bool) {
  
    self.viewToMagnify = viewToMagnify
    self.touchPoint = touchPoint
    self.touchPointOffset = touchPointOffset
    self.scale = scale
    self.scaleAtTouchPoint = scaleAtTouchPoint
  
  }

    convenience required public init(coder aDecoder: NSCoder) {
    self.init(coder: aDecoder)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    let label = UILabel()
    label.text = "+"
    label.font = UIFont(name:"Avenir-Light", size:24.0)!
    label.textColor = UIColor.darkGray
    label.bounds = CGRect(x: 0, y: 0, width: 24, height: 24)
    label.center = frame.center
    self.addSubview(label)
    self.layer.borderColor = UIColor.lightGray.cgColor
    self.layer.borderWidth = 0
    self.layer.cornerRadius = frame.size.width / 2
    self.layer.masksToBounds = true
    self.touchPointOffset = CGPoint(x: 0, y: YPMagnifyingGlassDefaultOffset)
    self.scale = YPMagnifyingGlassDefaultScale
    self.viewToMagnify = nil
    self.scaleAtTouchPoint = true
  }
  /*
  private func setFrame(frame: CGRect) {
    super.frame = frame
    self.layer.cornerRadius = frame.size.width / 2
  }
  */
    override public func draw(_ rect: CGRect) {
    let context = UIGraphicsGetCurrentContext()!
    context.setFillColor(UIColor.white.cgColor)
    context.translateBy(x: self.frame.size.width/2, y: self.frame.size.height/2)
    context.scaleBy(x: self.scale, y: self.scale)
    context.translateBy(x: -self.touchPoint.x, y: -self.touchPoint.y + (self.scaleAtTouchPoint != nil ? 0 : self.bounds.size.height/2))
    self.viewToMagnify.layer.render(in: context)
  }
}

extension CGRect {
    var center: CGPoint {
        get {
            return CGPoint(x: origin.x + width / 2, y: origin.y + height / 2)
        }
        set {
            origin.x = newValue.x - width / 2
            origin.y = newValue.y - height / 2
        }
    }
}
