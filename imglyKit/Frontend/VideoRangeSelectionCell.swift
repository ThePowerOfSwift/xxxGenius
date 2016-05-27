//
//  VideoRangeSelectionCell.swift
//  test
//
//  Created by ddpisces on 16/5/24.
//  Copyright © 2016年 pixelGenius. All rights reserved.
//

import UIKit

class VideoRangeSelectionCell: UITableViewCell {
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }
  
  private func commonInit() {
    layoutMargins = UIEdgeInsetsZero
  }
}
