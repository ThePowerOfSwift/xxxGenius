//
//  MultiVideosCombinedController.swift
//  imglyKit
//
//  Created by ddpisces on 16/5/21.
//  Copyright © 2016年 9elements GmbH. All rights reserved.
//

import UIKit
import AVFoundation

protocol MultiVideosCombinedControllerDelegate {
  func combinedFeatureClose()
  func updatePlayer()
}

class MultiVideosCombinedController: UIViewController {
  
  var mixComposition: AVMutableComposition?
  
  // merely used to int the track
  var videoTrack: AVMutableCompositionTrack?
  
  var delegate: MultiVideosCombinedControllerDelegate?
  
  let closeButton = UIButton()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.blackColor()
  }
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    // Close Button
    closeButton.setImage(UIImage(named: "close36"), forState: .Normal)
    closeButton.imageEdgeInsets = UIEdgeInsets(top: 8.0, left: 8.0, bottom: 8.0, right: 8.0)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    closeButton.addTarget(self, action: #selector(featureClose), forControlEvents: .TouchUpInside)
    view.addSubview(closeButton)
    

    closeButton.snp_makeConstraints { (make) in
      make.left.equalTo(view).offset(4.0)
      make.centerY.equalTo(view)
      make.size.equalTo(36.0)
    }
    
  }
  
  func featureClose() {
    
  }
}
