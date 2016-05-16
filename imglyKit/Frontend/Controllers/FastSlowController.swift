//
//  FastSlowController.swift
//  imglyKit
//
//  Created by ddpisces on 16/5/10.
//  Copyright © 2016年 9elements GmbH. All rights reserved.
//

import UIKit

protocol FastSlowControllerDelegate {
  func featureClose()
  func updateVideoSpeed(speed: Float)
}

class FastSlowController: UIViewController {
  
  var delegate : FastSlowControllerDelegate?
  
  let closeButton = UIButton()
  let speedSlider  = UISlider()
  let seperator = UIView()
  let speedLabel = UILabel()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.blackColor()
    
    // Close Button
    closeButton.setImage(UIImage(named: "close36"), forState: .Normal)
    closeButton.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.addTarget(self, action: #selector(featureClose), forControlEvents: .TouchUpInside)
    view.addSubview(closeButton)
   
    // Rate Slider
    speedSlider.translatesAutoresizingMaskIntoConstraints = false
    speedSlider.minimumValueImage = UIImage(named: "tortoise")
    speedSlider.maximumValueImage = UIImage(named: "rocket")
    speedSlider.setMaximumTrackImage(UIImage(named: "sliderMax"), forState: .Normal)
    speedSlider.setMinimumTrackImage(UIImage(named: "sliderMin"), forState: .Normal)
    speedSlider.setThumbImage(UIImage(named: "sliderThumb"), forState: .Normal)
    speedSlider.minimumValue = 0.0
    speedSlider.maximumValue = 2.0
    speedSlider.addTarget(self, action: #selector(valueChanged), forControlEvents: .ValueChanged)
    speedSlider.value = 1.0
    
    view.addSubview(speedSlider)
    
    // Speed Label
    speedLabel.translatesAutoresizingMaskIntoConstraints = false
    speedLabel.textColor = FlatUIColors.carrotColor()
    speedLabel.textAlignment = .Center
    speedLabel.text = "x1.0"
    view.addSubview(speedLabel)
    
    // Seperator View
    seperator.translatesAutoresizingMaskIntoConstraints = false
    seperator.backgroundColor = FlatUIColors.ironColor()
    view.addSubview(seperator)
    seperator.hidden = true

    setupLayouts()
  }
  
  func valueChanged(sender: UISlider) {
    let speed = sender.value
    speedLabel.text = String(format: "%@%.1f", "x", speed)
    
    delegate?.updateVideoSpeed(speed)
  }
  
  func setupLayouts () {
    
    // Close Button
    closeButton.snp_makeConstraints { (make) in
      make.left.equalTo(view).offset(4.0)
      make.centerY.equalTo(view)
      make.size.equalTo(36.0)
    }
    
    // Seperator
    seperator.snp_makeConstraints { (make) in
      make.left.equalTo(closeButton.snp_right).offset(4.0)
      make.top.equalTo(view).offset(4.0)
      make.bottom.equalTo(view)
      make.width.equalTo(2.0)
    }
    
    // Speed Slider
    speedSlider.snp_makeConstraints { (make) in
      make.left.equalTo(seperator.snp_right).offset(8.0)
      make.right.equalTo(speedLabel.snp_left)
      make.top.equalTo(view)
      make.bottom.equalTo(view)
    }
    
    // Speed Label
    speedLabel.snp_makeConstraints { (make) in
      make.right.equalTo(view)
      make.centerY.equalTo(view)
      make.height.equalTo(20.0)
      make.width.equalTo(60.0)
    }
    
    UIView.animateWithDuration(0.2) { 
      self.view.layoutIfNeeded()
    }
  }
  
  func featureClose() {
    delegate?.featureClose()
  }
}
