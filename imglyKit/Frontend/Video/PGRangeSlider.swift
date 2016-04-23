//
//  PGRangeSlider.swift
//  test
//
//  Created by ddpisces on 16/4/22.
//  Copyright © 2016年 pixelGenius. All rights reserved.
//

import UIKit

class PGRangeSlider: UIControl {

    var minimumValue = 0.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var maximumValue = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    var currentValue = 1.0 {
        didSet {
            updateLayerFrames()
        }
    }
    
    let trackLayer = PGRangeSliderTrackLayer()
    let thumbLayer = PGRangeSliderThumbLayer()
    
    var trackTintColor = UIColor(white: 0.9, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var trackHighlightTintColor = UIColor(red: 0.42, green: 0.68, blue: 0.76, alpha: 1.0) {
        didSet {
            trackLayer.setNeedsDisplay()
        }
    }
    
    var thumbTintColor = UIColor.whiteColor() {
        didSet {
            thumbLayer.setNeedsDisplay()
        }
    }
    
    var curvaceousness : CGFloat = 1.0 {
        didSet {
            thumbLayer.setNeedsDisplay()
            trackLayer.setNeedsDisplay()
        }
    }
    
    var previousLocation = CGPoint()
    
    var thumbWidth: CGFloat {
        return CGFloat(bounds.height)
    }
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(trackLayer)
        
        thumbLayer.rangeSlider = self
        thumbLayer.contentsScale = UIScreen.mainScreen().scale
        layer.addSublayer(thumbLayer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func layoutSubviews() {
        updateLayerFrames()
    }
    
    func updateLayerFrames() {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        trackLayer.frame = bounds.insetBy(dx: 0.0, dy: bounds.height / 3.0)
        trackLayer.setNeedsDisplay()
        
        let thumbCenter = CGFloat(positionForValue(currentValue))
        thumbLayer.frame = CGRect(x: thumbCenter - thumbWidth / 2.0, y: 0.0,
                                       width: thumbWidth, height: thumbWidth)
        thumbLayer.setNeedsDisplay()
        
        CATransaction.commit()
    }
    
    override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        previousLocation = touch.locationInView(self)
        
        if thumbLayer.frame.contains(previousLocation) {
            thumbLayer.highlighted = true
        }
        
        return thumbLayer.highlighted
    }
    
    override func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        let location = touch.locationInView(self)
        
        // 1. Determine by how much the user has dragged
        let deltaLocation = Double(location.x - previousLocation.x)
        let deltaValue = (maximumValue - minimumValue) * deltaLocation / Double(bounds.width - thumbWidth)
        
        previousLocation = location
        
        // 2. Update the values
        if thumbLayer.highlighted {
            currentValue += deltaValue
            currentValue = boundValue(currentValue, toLowerValue: minimumValue, upperValue: maximumValue)
        }
        
        sendActionsForControlEvents(.ValueChanged)
        
        return true
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        thumbLayer.highlighted = false
    }
    
    func positionForValue(value: Double) -> Double {
        return (value - minimumValue) / (maximumValue - minimumValue) * Double(bounds.width)
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
}
