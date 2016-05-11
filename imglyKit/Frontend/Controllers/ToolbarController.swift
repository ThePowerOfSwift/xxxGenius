//
//  ToolbarController.swift
//  imglyKit
//
//  Created by ddpisces on 16/5/10.
//  Copyright © 2016年 9elements GmbH. All rights reserved.
//

import UIKit

enum ToobarSelectedFeature {
  case FastSlow
}

protocol ToolbarControllerDelegate {
  func selectedFeature(feature: ToobarSelectedFeature)
}

class ToolbarController: UIViewController {
  
  let toolBar = UIToolbar()
  
  var delegate : ToolbarControllerDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    toolBar.tintColor = UIColor.whiteColor()
    toolBar.barTintColor = UIColor.blackColor()
    toolBar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toolBar)
    
    toolBar.snp_makeConstraints { (make) in
      make.left.equalTo(view.snp_left)
      make.right.equalTo(view.snp_right)
      make.top.equalTo(view.snp_top)
      make.bottom.equalTo(view.snp_bottom)
    }
    
    let playFastSlowItem = UIBarButtonItem(image: UIImage(named: "time108"), style: .Plain, target: nil, action: #selector(showPlayFastSlow))
    
    toolBar.setItems([playFastSlowItem], animated: true)
  }
  
  func showPlayFastSlow() {
    
    delegate?.selectedFeature(ToobarSelectedFeature.FastSlow)
  }
}
