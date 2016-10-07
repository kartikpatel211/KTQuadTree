//
//  KTClusterAnnotationView.swift
//  KTQuadTree
//
//  Created by Kartik Patel on 10/7/16.
//  Copyright © 2016 KTPatel. All rights reserved.
//

import UIKit
import MapKit
import CoreGraphics

let ScaleFactorAlpha : Float = 0.3
let ScaleFactorBeta : Float = 0.4

class KTClusterAnnotationView: MKAnnotationView {
    var countLabel : UILabel
    var count : Int = 0
    
    override init(frame: CGRect){
        countLabel = UILabel.init()
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        self.setupLabel()
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        
        countLabel = UILabel.init()
        
        
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = UIColor.clearColor()
        self.setupLabel()
        setCountData(2)
    }
    
    required init?(coder aDecoder: NSCoder) {
        countLabel = UILabel.init()
        
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
        self.setupLabel()
    }
    
    func setupLabel() -> Void {
        
        countLabel = UILabel.init(frame: frame)
        countLabel.backgroundColor = UIColor.clearColor()
        countLabel.textColor = UIColor.whiteColor()
        countLabel.textAlignment = .Center
        countLabel.shadowColor = UIColor.colorWithAlphaComponent(UIColor.whiteColor())(0.75)
        countLabel.shadowOffset = CGSizeMake(0, -1)
        countLabel.adjustsFontSizeToFitWidth = true
        countLabel.numberOfLines = 1
        countLabel.font = UIFont.boldSystemFontOfSize(12)
        //countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters
        self.addSubview(countLabel)
    }
    
    func setCountData(countData : Int) -> Void
    {
        count = countData
        
        let newBounds = CGRect.init(x: 0.0, y: 0.0, width: Double(roundf(44 * ScaledValueForValue(Float(count)))), height: Double(roundf(44 * ScaledValueForValue(Float(count)))))
        
        self.frame = CenterRect(newBounds, center: self.center)
        
        let newLabelBounds = CGRect.init(x:0, y:0, width:newBounds.size.width / 1.3, height:newBounds.size.height / 1.3)
        self.countLabel.frame = CenterRect(newLabelBounds, center: RectCenter(newBounds))
        self.countLabel.text = "\(count)"
        
        self.setNeedsDisplay()
    }
    
    override func drawRect(rect : CGRect) -> Void {
        let context : CGContextRef = UIGraphicsGetCurrentContext()!
        
        CGContextSetAllowsAntialiasing(context, true)
        
        let outerCircleStrokeColor : UIColor = UIColor.colorWithAlphaComponent(UIColor.whiteColor())(0.25)
        let innerCircleStrokeColor : UIColor  = UIColor.whiteColor()
        let innerCircleFillColor : UIColor = UIColor.init(colorLiteralRed: 255.0/255.0, green: 95.0/255.0, blue: 42.0/255.0, alpha: 1.0)
        
        let circleFrame : CGRect = CGRectInset(rect, 4, 4)
        
        outerCircleStrokeColor.setStroke()
        CGContextSetLineWidth(context, 5.0)
        CGContextStrokeEllipseInRect(context, circleFrame)
        
        innerCircleStrokeColor.setStroke()
        CGContextSetLineWidth(context, 4)
        CGContextStrokeEllipseInRect(context, circleFrame)
        
        innerCircleFillColor.setFill()
        CGContextFillEllipseInRect(context, circleFrame)
    }
}
func RectCenter(rect:CGRect) -> CGPoint {
    return CGPoint.init(x:CGRectGetMidX(rect), y:CGRectGetMidY(rect))
}

func CenterRect(rect:CGRect, center:CGPoint) -> CGRect {
    let r : CGRect = CGRect.init(x: center.x - rect.size.width/2.0,
                                 y:center.y - rect.size.height/2.0,
                                 width:rect.size.width,
                                 height:rect.size.height)
    return r
}

func ScaledValueForValue(value : Float) -> Float {
    return 1.0 / (1.0 + expf(-1 * ScaleFactorAlpha * powf(value, ScaleFactorBeta)))
}
