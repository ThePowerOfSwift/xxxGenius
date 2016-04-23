//
//  PGRangeSliderTrackLayer.swift
//  test
//
//  Created by ddpisces on 16/4/22.
//  Copyright © 2016年 pixelGenius. All rights reserved.
//

import UIKit

class PGRangeSliderTrackLayer: CALayer {
    weak var rangeSlider: PGRangeSlider?
    
    override func drawInContext(ctx: CGContext) {
        if let slider = rangeSlider {
            // Background
            let cornerRadius = bounds.height * slider.curvaceousness / 2.0
            let path = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
            CGContextSetFillColorWithColor(ctx, slider.trackTintColor.CGColor)
            CGContextAddPath(ctx, path.CGPath)
            CGContextFillPath(ctx)
            
            // Fill the highlighted range
            let upperValuePosition = CGFloat(slider.positionForValue(slider.currentValue))
            var hightlightBound = bounds
            hightlightBound.size.width = upperValuePosition
            let hightlightPath = UIBezierPath(roundedRect: hightlightBound, cornerRadius: cornerRadius)
            CGContextSetFillColorWithColor(ctx, slider.trackHighlightTintColor.CGColor)
            CGContextAddPath(ctx, hightlightPath.CGPath)
            CGContextFillPath(ctx)
        }
    }
}
