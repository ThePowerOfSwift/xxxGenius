//
//  ProgressIndicatorView.swift
//  test1
//
//  Created by ddpisces on 16/6/6.
//  Copyright © 2016年 pixelGenius. All rights reserved.
//

import UIKit
import SnapKit

class ProgressIndicatorView: UIView {

  let closeButton = UIButton(frame: CGRectZero)
  let progressBar = UIProgressView(frame: CGRectZero)
  let progressLabel = UILabel(frame: CGRectZero)
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    let color = UIColor(red: 27.0/255.0, green: 163.0/255.0, blue: 156.0/255.0, alpha: 1)
    
    closeButton.setImage(UIImage(named: "close2"), forState: .Normal)
    closeButton.translatesAutoresizingMaskIntoConstraints = false
    addSubview(closeButton)
    
    progressBar.progressTintColor = color
    progressBar.translatesAutoresizingMaskIntoConstraints = false
    progressBar.setProgress(0.5, animated: true)
    addSubview(progressBar)
    
    progressLabel.textColor = color
    progressLabel.translatesAutoresizingMaskIntoConstraints = false
    progressLabel.font = UIFont(name: "ArialRoundedMTBold", size: 16.0)
    progressLabel.text = "Reversing Video..."
    addSubview(progressLabel)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    
    // close button
    closeButton.snp_remakeConstraints { (make) in
      make.centerY.equalTo(self).offset(4.0)
      make.size.equalTo(40.0)
      make.left.equalTo(self)
    }
    
    // progress bar
    progressBar.snp_remakeConstraints { (make) in
      make.bottom.equalTo(closeButton).offset(-4.0)
      make.left.equalTo(closeButton.snp_right).offset(6.0)
      make.right.equalTo(self)
      make.height.equalTo(10.0)
    }

    // label
    progressLabel.snp_remakeConstraints { (make) in
      make.right.equalTo(progressBar)
      make.left.equalTo(progressBar)
      make.height.equalTo(18.0)
      make.bottom.equalTo(progressBar.snp_top).offset(-4.0)
    }
  }
}
