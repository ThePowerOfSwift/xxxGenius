//
//  RangeSelectionController.swift
//  test
//
//  Created by ddpisces on 16/5/25.
//  Copyright © 2016年 pixelGenius. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices

struct VideoAsset {
  var asset: AVAsset
  var startTime: CMTime
  var endTime: CMTime
}

protocol RangeSelectionControllerDelegate {
  func rangeSelectionFeatureClose()
  func selectionUpdateVideoPlayer(item: AVPlayerItem)
}

class RangeSelectionController: UITableViewController {
  
  // merely used to int the track
  var videoTrack: AVMutableCompositionTrack?
  
  var delegate : RangeSelectionControllerDelegate?
  
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
      } else {
        dispatch_async(dispatch_get_main_queue()) {
          completion(resultImage: UIImage(named: "noneimage")!)
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
    
    // only update max selected value when load first time
    if cell.rangeSlider.maximumSelectedValue == -1.0 {
      cell.rangeSlider.maximumSelectedValue = CGFloat(CMTimeGetSeconds(duration))
    } else {
      
      // cell reused need to reassgin value
      cell.rangeSlider.minimumSelectedValue = CGFloat(CMTimeGetSeconds(videoAssets[indexPath.row].startTime))
      cell.rangeSlider.maximumSelectedValue = CGFloat(CMTimeGetSeconds(videoAssets[indexPath.row].endTime))
    }
    
    cell.rangeSlider.tag = indexPath.row
    cell.rangeSlider.delegate = self
    upateCellLabel(cell, start: kCMTimeZero, end: duration)
    
    print("Min Selected: \(cell.rangeSlider.minimumSelectedValue), Max Selected: \(cell.rangeSlider.maximumSelectedValue)")
    print("Index: \(indexPath.row), MIN: \(cell.rangeSlider.minimumValue), MAX: \(cell.rangeSlider.maximumValue)")
    
    return cell
  }
  
  override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 50.0
  }
  
  // Override to support conditional editing of the table view.
  override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
    // Return false if you do not want the specified item to be editable.
    
    if videoAssets.count <= 1 {
      return false
    }
    
    return true
  }
  
  // Override to support editing the table view.
  override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    if editingStyle == .Delete {
      
      videoAssets.removeAtIndex(indexPath.row)
      tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
      
      // re-assign slider's tag to reflect the index in table, OR App would crash.
      for index in 0...(videoAssets.count - 1) {
        let index = NSIndexPath(forRow: index, inSection: 0)
        let cell = self.tableView.cellForRowAtIndexPath(index) as! VideoRangeSelectionCell
        cell.rangeSlider.tag = index.row
      }
      
      delegate?.selectionUpdateVideoPlayer(composeAssetsToItem())
    } else if editingStyle == .Insert {
      // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
  }
  

   // Override to support rearranging the table view.
   override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {
    print("From Row:\(fromIndexPath), TO Row:\(toIndexPath)")
    
    if fromIndexPath == toIndexPath { return }
    
    // swap element
    let from = fromIndexPath.row, to = toIndexPath.row
    (videoAssets[from], videoAssets[to]) = (videoAssets[to], videoAssets[from])
   }

   // Override to support conditional rearranging of the table view.
   override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
  }
  
  
  @IBAction func featureClose(sender: AnyObject) {
    // free memory
    videoAssets.removeAll()
    
    delegate?.rangeSelectionFeatureClose()
  }
  
  @IBAction func addVideoAsset(sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    picker.allowsEditing = false
    picker.sourceType = .PhotoLibrary
    picker.mediaTypes = [String(kUTTypeMovie)]
    
    self.presentViewController(picker, animated: true, completion: nil)
  }
  
  @IBAction func tableInEditMode(sender: UIButton) {
    if self.tableView.editing {
      self.tableView.setEditing(false, animated: true)
    } else {
      self.tableView.setEditing(true, animated: true)
    }
  }
  
  // MARK: - Helps
  private func upateCellLabel(cell: VideoRangeSelectionCell, start: CMTime, end: CMTime) {
    
    let start_time = CMTimeGetSeconds(start)
    let end_time = CMTimeGetSeconds(end)
    
    // start
    let start_minutes = Int(start_time / 60)
    let start_seconds = Int(start_time % 60)
    
    // end
    let end_minutes = Int(end_time / 60)
    let end_seconds = Int(end_time % 60)
    
    // duration
    let duration = round(CMTimeGetSeconds(CMTimeSubtract(end, start)))
    
    let rangeText = "\(start_minutes):\(start_seconds)~\(end_minutes):\(end_seconds)(\(duration))s"
    cell.rangeLabel.text = rangeText
  }
  
  private func composeAssetsToItem() -> AVPlayerItem {
    let composition = AVMutableComposition()
    let track = composition.addMutableTrackWithMediaType(AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
    
    if let transform = self.videoTrack?.preferredTransform {
      track.preferredTransform = transform
    }
    
    var insertTime = kCMTimeZero
    
    for assetItem in videoAssets {
      let range = CMTimeRange(start: assetItem.startTime, end: assetItem.endTime)
      
      do {
        let assetTrack = assetItem.asset.tracksWithMediaType(AVMediaTypeVideo).first!
        try track.insertTimeRange(range, ofTrack: assetTrack, atTime: insertTime)
      } catch (_) {
        print("Compose Asset Item Failure.")
      }
      
      insertTime = CMTimeAdd(insertTime, range.duration)
    }
    
    let playerItem = AVPlayerItem(asset: composition)
    print(CMTimeGetSeconds(playerItem.duration))
    
    return playerItem
  }
}

// MARK: - YSRangeSliderDelegate
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
      
      // update time range label
      let start = self?.videoAssets[index].startTime
      let end = self?.videoAssets[index].endTime
      self?.upateCellLabel(cell, start: start!, end: end!)
    }
    
    delegate?.selectionUpdateVideoPlayer(composeAssetsToItem())
  }
}

// MARK: - UIImagePickerControllerDelegate
extension RangeSelectionController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
    self.dismissViewControllerAnimated(false, completion: nil)
    
    let videoURL = info[UIImagePickerControllerMediaURL] as? NSURL
    
    if let url = videoURL {
      let videoAsset = AVAsset(URL: url)
      self.addAsset(videoAsset)
      
      delegate?.selectionUpdateVideoPlayer(composeAssetsToItem())
    }
  }
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    self.dismissViewControllerAnimated(true, completion: nil)
  }
}