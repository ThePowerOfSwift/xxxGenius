//
//  RangeSelectionController.swift
//  test
//
//  Created by ddpisces on 16/5/25.
//  Copyright © 2016年 pixelGenius. All rights reserved.
//

import UIKit
import AVFoundation

struct VideoAsset {
  var asset: AVAsset
  var startTime: CMTime
  var endTime: CMTime
}

class RangeSelectionController: UITableViewController {
  
  // merely used to int the track
  var videoTrack: AVMutableCompositionTrack?
  
  private var videoAssets: [VideoAsset] = []
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = false
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
    print("MEMORY WARNING")
  }
  
  private func addAsset(asset: AVAsset?) {
    if let asset = asset {
      let videoAsset = VideoAsset(asset: asset, startTime: kCMTimeZero, endTime: asset.duration)
      videoAssets.append(videoAsset)
      tableView.reloadData()
    }
  }
  
  func initAssets(asset: AVAsset?) {
    videoAssets.removeAll()
    addAsset(asset)
  }
  
  private func getAssetThumbnail(index: Int, completion: (resultImage: UIImage) -> Void) {
    let asset = self.videoAssets[index].asset
    let atTime = self.videoAssets[index].startTime
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    
    imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: atTime)]) {(_, image, _, result, error) in
      if result == .Succeeded {
        dispatch_async(dispatch_get_main_queue()) {
          completion(resultImage: UIImage(CGImage: image!))
        }
      }
    }
    
  }
  
  // MARK: - Table view data source
  
  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videoAssets.count
  }
  
  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("rangeSelectionCell", forIndexPath: indexPath) as! VideoRangeSelectionCell
    
    // cell image
    getAssetThumbnail(indexPath.row) { (resultImage) in
      cell.imageThumb.image = resultImage
    }

    // cell slider min/max value
    let duration  = videoAssets[indexPath.row].asset.duration
    cell.rangeSlider.minimumValue = 0.0
    cell.rangeSlider.maximumValue = CGFloat(CMTimeGetSeconds(duration))
    cell.rangeSlider.maximumSelectedValue = CGFloat(CMTimeGetSeconds(duration))
    cell.rangeSlider.tag = indexPath.row
    cell.rangeSlider.delegate = self
    
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50.0
  }
  
  /*
   // Override to support conditional editing of the table view.
   override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the specified item to be editable.
   return true
   }
   */
  
  /*
   // Override to support editing the table view.
   override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
   if editingStyle == .Delete {
   // Delete the row from the data source
   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
   } else if editingStyle == .Insert {
   // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
   }
   }
   */
  
  /*
   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
   
   }
   */
  
  /*
   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
   // Return false if you do not want the item to be re-orderable.
   return true
   }
   */
  
  /*
   // MARK: - Navigation
   
   // In a storyboard-based application, you will often want to do a little preparation before navigation
   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
   // Get the new view controller using segue.destinationViewController.
   // Pass the selected object to the new view controller.
   }
   */
  
}

extension RangeSelectionController: YSRangeSliderDelegate {
  func rangeSliderDidChange(rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue: CGFloat) {
  }
  
  func rangeSliderTouchEndDidChange(rangeSlider: YSRangeSlider, minimumSelectedValue: CGFloat, maximumSelectedValue: CGFloat) {
    let index = rangeSlider.tag
    
    videoAssets[index].startTime = CMTime(seconds: Double(rangeSlider.minimumSelectedValue), preferredTimescale: 600)
    videoAssets[index].endTime = CMTime(seconds: Double(rangeSlider.maximumSelectedValue), preferredTimescale: 600)
    
    getAssetThumbnail(index) {[weak self](resultImage) in
      let cell = self?.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0)) as! VideoRangeSelectionCell
      cell.imageThumb.image = resultImage
    }
  }
}
