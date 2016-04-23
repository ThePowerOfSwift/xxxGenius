//
//  Utils.swift
//  iOS Example
//
//  Created by ddpisces on 16/4/23.
//  Copyright © 2016年 9elements GmbH. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    class func toRGB(red:Double, green:Double, blue:Double, alpha:Double = 1.0) -> UIColor {
        return UIColor(red: CGFloat(red)/255.0, green: CGFloat(green)/255.0, blue: CGFloat(blue)/255.0, alpha: CGFloat(alpha))
    }
}