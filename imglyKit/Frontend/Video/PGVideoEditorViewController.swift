//
//  PGVideoEditorViewController.swift
//  imglyKit
//
//  Created by ddpisces on 16/4/20.
//  Copyright © 2016年 9elements GmbH. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import SnapKit

enum PGLayoutStyle: Int {
  case Init
  case FastSlow
}


private var playerViewControllerKVOContext = 0

public class PGVideoEditorViewController: UIViewController {
  
  let playerView = PGPlayerView()
  let player = AVPlayer()
  let toolsBar = UIToolbar()
  let fastSlowToolBar = UIToolbar()
  let playSlider = PGRangeSlider(frame: CGRectZero)
  let videoPlayPauseButton = UIButton(frame: CGRectZero)
  private var timeObserverToken: AnyObject?
  
  public var videoFileUrl: NSURL? {
    didSet {
      asset = AVURLAsset(URL: videoFileUrl!, options: nil)
    }
  }
  
  static let assetKeysRequiredToPlay = [
    "playable"
  ]
  
  private var playerLayer: AVPlayerLayer? {
    return playerView.playerLayer
  }
  
  private var playerItem: AVPlayerItem? = nil {
    didSet {
      /*
       If needed, configure player item here before associating it with a player.
       (example: adding outputs, setting text style rules, selecting media options)
       */
      player.replaceCurrentItemWithPlayerItem(self.playerItem)
    }
  }
  
  var currentTime: Double {
    get {
      return CMTimeGetSeconds(player.currentTime())
    }
    
    set {
      let newTime = CMTimeMakeWithSeconds(newValue, 1)
      player.seekToTime(newTime)
    }
  }
  
  var duration: Double {
    //        guard let currentItem = player.currentItem else { return 0.0 }
    //
    //        return CMTimeGetSeconds(currentItem.duration)
    
    return CMTimeGetSeconds(asset!.duration)
  }
  
  var rate: Float {
    get {
      return player.rate
    }
    
    set {
      player.rate = newValue
    }
  }
  
  var asset: AVURLAsset? {
    didSet {
      guard let newAsset = asset else { return }
      
      asynchronouslyLoadURLAsset(newAsset)
    }
  }
  
  deinit {
    if let playerItem = self.playerItem {
      NSNotificationCenter.defaultCenter().removeObserver(playerItem)
    }
  }
  
  var layoutStyle: PGLayoutStyle? {
    didSet {
      if let style = layoutStyle {
        switch style {
        case .Init:
          print("Layout Init")
          initViewsLayout()
          
        case .FastSlow:
          print("Layout FastSlow")
          updateViewsLayout()
        }
      }
      
      UIView.animateWithDuration(0.5, animations: {
        self.view.layoutIfNeeded()
      })
    }
  }
  
  public override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    
    addObserver(self, forKeyPath: "player.rate", options: [.New, .Initial], context: &playerViewControllerKVOContext)
    addObserver(self, forKeyPath: "player.currentItem.duration", options: [.New, .Initial], context: &playerViewControllerKVOContext)
    
    // Make sure we don't have a strong reference cycle by only capturing self as weak.
    let interval = CMTimeMake(1, 1)
    timeObserverToken = player.addPeriodicTimeObserverForInterval(interval, queue: dispatch_get_main_queue()) {
      [unowned self] time in
      
      self.playSlider.currentValue = Double(CMTimeGetSeconds(time)/self.duration)
    }
    
    // initialize view layout
    layoutStyle = PGLayoutStyle.Init
  }
  
  public override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)
    
    player.pause()
    
    if let timeObserverToken = timeObserverToken {
      player.removeTimeObserver(timeObserverToken)
      self.timeObserverToken = nil
    }
    
    removeObserver(self, forKeyPath: "player.rate", context: &playerViewControllerKVOContext)
    removeObserver(self, forKeyPath: "player.currentItem.duration", context: &playerViewControllerKVOContext)
  }
  
  override public func viewDidLoad() {
    super.viewDidLoad()
    
    view.backgroundColor = UIColor.toRGB(229.0, green: 224.0, blue: 221.0)
    
    // Do any additional setup after loading the view.
    navigationItem.title = "Video Editor"
    
    playerView.playerLayer.player = player
    
    // setup Video Player View
    playerView.playerLayer.player = player
    playerView.translatesAutoresizingMaskIntoConstraints = false
    playerView.backgroundColor = UIColor.toRGB(229.0, green: 224.0, blue: 221.0)
    view.addSubview(playerView)
    
    // init video play button
    videoPlayPauseButton.setImage(UIImage(named: "videoPlay", inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil), forState: .Normal)
    videoPlayPauseButton.translatesAutoresizingMaskIntoConstraints = false
    playerView.addSubview(videoPlayPauseButton)
    
    videoPlayPauseButton.addTarget(self, action: #selector(playVideo), forControlEvents: .TouchUpInside)
    
    // setup Play Controls
    playSlider.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(playSlider)
    playSlider.addTarget(self, action: #selector(videoSliderValueChange), forControlEvents: .ValueChanged)
    
    // setup Tool Bar
    toolsBar.tintColor = UIColor.whiteColor()
    toolsBar.barTintColor = UIColor.blackColor()
    toolsBar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(toolsBar)
    
    let playFastSlowItem = UIBarButtonItem(image: UIImage(named: "time108"), style: .Plain, target: nil, action: #selector(showPlayFastSlow))
    
    toolsBar.setItems([playFastSlowItem], animated: true)
    
    // fast slow control bar
    fastSlowToolBar.translatesAutoresizingMaskIntoConstraints = false
    fastSlowToolBar.barTintColor = UIColor.greenColor()
    view.addSubview(fastSlowToolBar)
    
    // gesture
    let recognizer = UITapGestureRecognizer(target: self, action: #selector(handlePauseTap))
    playerView.addGestureRecognizer(recognizer)
  }
  
  
  override public func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
  
  // MARK: - Layout Update
  
  private func initViewsLayout() {
    print(#function)
    
    // Bottom ToolBar layout
    toolsBar.snp_remakeConstraints { (make) in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.height.equalTo(50.0)
      make.bottom.equalTo(view)
    }
    
    // video play controls layout
    playSlider.snp_remakeConstraints { (make) in
      make.left.equalTo(view).offset(20.0)
      make.right.equalTo(view).offset(-20.0)
      make.bottom.equalTo(toolsBar.snp_top)
      make.height.equalTo(40.0)
    }
    
    // player view layout
    playerView.snp_remakeConstraints { (make) in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.top.equalTo(view)
      make.bottom.equalTo(playSlider.snp_top)
    }
    
    // video play/pause button
    videoPlayPauseButton.snp_remakeConstraints { (make) in
      make.size.equalTo(100.0)
      make.center.equalTo(view)
    }
    
    // FastSlow ToolBar
    fastSlowToolBar.snp_remakeConstraints { (make) in
      make.left.equalTo(view)
      make.right.equalTo(view)
      make.height.equalTo(50.0)
      make.bottom.equalTo(view).offset(50.0)
    }
  }
  
  private func updateViewsLayout() {
    print(#function)
    
    toolsBar.snp_updateConstraints { (make) in
      make.bottom.equalTo(view).offset(50.0)
    }
    
    // snp_updateConstraints can only update 'constant'
    // so can only use snp_remakeConstraints
    playSlider.snp_remakeConstraints { (make) in
      make.left.equalTo(view).offset(20.0)
      make.right.equalTo(view).offset(-20.0)
      make.bottom.equalTo(fastSlowToolBar.snp_top)
      make.height.equalTo(40.0)
    }
    
    fastSlowToolBar.snp_updateConstraints { (make) in
      make.bottom.equalTo(view)
    }
  }
  
  // MARK: - Control Handlers
  func videoSliderValueChange(rangeSlider: PGRangeSlider) {
    print("Slider Change: \(rangeSlider.currentValue)")
    currentTime = rangeSlider.currentValue * duration
  }
  
  func playVideo(sender: UIButton) {
    if rate == 0 {
      player.play()
    }
  }
  
  func handlePauseTap(recognizer: UITapGestureRecognizer) {
    if rate != 0 {
      rate = 0
    }
  }
  
  func showPlayFastSlow() {
    print(#function)
    layoutStyle = PGLayoutStyle.FastSlow
  }
  
  func asynchronouslyLoadURLAsset(newAsset: AVURLAsset) {
    /*
     Using AVAsset now runs the risk of blocking the current thread (the
     main UI thread) whilst I/O happens to populate the properties. It's
     prudent to defer our work until the properties we need have been loaded.
     */
    newAsset.loadValuesAsynchronouslyForKeys(PGVideoEditorViewController.assetKeysRequiredToPlay) {
      /*
       The asset invokes its completion handler on an arbitrary queue.
       To avoid multiple threads using our internal state at the same time
       we'll elect to use the main thread at all times, let's dispatch
       our handler to the main queue.
       */
      dispatch_async(dispatch_get_main_queue()) {
        /*
         `self.asset` has already changed! No point continuing because
         another `newAsset` will come along in a moment.
         */
        guard newAsset == self.asset else { return }
        
        /*
         Test whether the values of each of the keys we need have been
         successfully loaded.
         */
        for key in PGVideoEditorViewController.assetKeysRequiredToPlay {
          var error: NSError?
          
          if newAsset.statusOfValueForKey(key, error: &error) == .Failed {
            let stringFormat = NSLocalizedString("error.asset_key_%@_failed.description", comment: "Can't use this AVAsset because one of it's keys failed to load")
            
            let message = String.localizedStringWithFormat(stringFormat, key)
            
            self.handleErrorWithMessage(message, error: error)
            
            return
          }
        }
        
        // We can't play this asset.
        if !newAsset.playable {
          let message = NSLocalizedString("error.asset_not_playable.description", comment: "Can't use this AVAsset because it isn't playable or has protected content")
          
          self.handleErrorWithMessage(message)
          
          return
        }
        
        /*
         We can play this asset. Create a new `AVPlayerItem` and make
         it our player's current item.
         */
        self.playerItem = AVPlayerItem(asset: newAsset)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.playerItemDidReachEnd), name:AVPlayerItemDidPlayToEndTimeNotification, object: self.playerItem)
      }
    }
    
  }
  
  func playerItemDidReachEnd(notification: NSNotification) {
    self.player.seekToTime(kCMTimeZero)
  }
  
  
  // MARK: - Error Handling
  
  func handleErrorWithMessage(message: String?, error: NSError? = nil) {
    NSLog("Error occured with message: \(message), error: \(error).")
    
    let alertTitle = NSLocalizedString("alert.error.title", comment: "Alert title for errors")
    let defaultAlertMessage = NSLocalizedString("error.default.description", comment: "Default error message when no NSError provided")
    
    let alert = UIAlertController(title: alertTitle, message: message == nil ? defaultAlertMessage : message, preferredStyle: UIAlertControllerStyle.Alert)
    
    let alertActionTitle = NSLocalizedString("alert.error.actions.OK", comment: "OK on error alert")
    
    let alertAction = UIAlertAction(title: alertActionTitle, style: .Default, handler: nil)
    
    alert.addAction(alertAction)
    
    presentViewController(alert, animated: true, completion: nil)
  }
  
  // MARK: - KVO Observation
  
  // Update our UI when player or `player.currentItem` changes.
  override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String: AnyObject]?, context: UnsafeMutablePointer<Void>) {
    // Make sure the this KVO callback was intended for this view controller.
    guard context == &playerViewControllerKVOContext else {
      super.observeValueForKeyPath(keyPath, ofObject: object, change: change, context: context)
      return
    }
    
    if keyPath == "player.rate" {
      let newRate = (change?[NSKeyValueChangeNewKey] as! NSNumber).doubleValue
      
      if newRate == 0 {
        videoPlayPauseButton.hidden = false
      } else {
        videoPlayPauseButton.hidden = true
      }
    } else if keyPath == "player.currentItem.duration" {
      
    }
  }
}
