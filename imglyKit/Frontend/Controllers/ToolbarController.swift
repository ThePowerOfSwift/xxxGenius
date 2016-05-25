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
  case MultiVideosCombined
}

protocol ToolbarControllerDelegate {
  func selectedFeature(feature: ToobarSelectedFeature)
}

class ToolbarController: UIViewController {
  
  let toolBar = UIToolbar()
  
  var delegate: ToolbarControllerDelegate?
  
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
    
    let flexibleItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    let playFastSlowItem = UIBarButtonItem(image: UIImage(named: "time108"), style: .Plain, target: nil, action: #selector(showPlayFastSlow))
    let multiVideosCombinedItem = UIBarButtonItem(image: UIImage(named: "trim36"), style: .Plain, target: nil, action: #selector(showMultiVideosCombined))
    
    toolBar.setItems([playFastSlowItem, flexibleItem, multiVideosCombinedItem], animated: true)
  }
  
  func showPlayFastSlow() {
    delegate?.selectedFeature(ToobarSelectedFeature.FastSlow)
  }
  
  func showMultiVideosCombined() {
    delegate?.selectedFeature(ToobarSelectedFeature.MultiVideosCombined)
  }
}
