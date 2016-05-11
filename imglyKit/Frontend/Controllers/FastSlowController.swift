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
}

class FastSlowController: UIViewController {
  
  var delegate : FastSlowControllerDelegate?
  
  let closeButton = UIButton()
  let rateSlider  = HUMSlider()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.blackColor()
    
    closeButton.setImage(UIImage(named: "close36"), forState: .Normal)
    closeButton.addTarget(self, action: #selector(featureClose), forControlEvents: .TouchUpInside)
    view.addSubview(closeButton)
    
    closeButton.snp_makeConstraints { (make) in
      make.left.equalTo(view).offset(4.0)
      make.top.equalTo(view).offset(4.0)
      make.width.equalTo(22.0)
      make.height.equalTo(22.0)
    }
  }
  
  func featureClose() {
    delegate?.featureClose()
  }
}
