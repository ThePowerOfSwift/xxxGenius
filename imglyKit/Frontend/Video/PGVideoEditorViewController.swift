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


private var playerViewControllerKVOContext = 0

public class PGVideoEditorViewController: UIViewController {
    
    let playerView = PGPlayerView()
    let player = AVPlayer()
    let toolsBar = UIToolbar()
    let playSlider = PGRangeSlider(frame: CGRectZero)
    let videoPlayPause = UIButton(frame: CGRectZero)
    
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
        guard let currentItem = player.currentItem else { return 0.0 }
        
        return CMTimeGetSeconds(currentItem.duration)
    }
    
    var asset: AVURLAsset? {
        didSet {
            guard let newAsset = asset else { return }
            
            asynchronouslyLoadURLAsset(newAsset)
        }
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        addObserver(self, forKeyPath: "player.rate", options: [.New, .Initial], context: &playerViewControllerKVOContext)
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        
        player.pause()
        
        removeObserver(self, forKeyPath: "player.rate", context: &playerViewControllerKVOContext)
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
        videoPlayPause.setImage(UIImage(named: "videoPlay"), forState: .Normal)
        
        // setup Play Controls
        playSlider.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playSlider)
        playSlider.addTarget(self, action: #selector(videoSliderValueChange), forControlEvents: .ValueChanged)
        
        // setup Tool Bar
        toolsBar.backgroundColor = UIColor.blueColor()
        toolsBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(toolsBar)
    }
    
    public override func viewDidLayoutSubviews() {
        setupViewsLayout()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setupViewsLayout() {
        
        // Bottom ToolBar layout
        toolsBar.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        toolsBar.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        toolsBar.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        toolsBar.heightAnchor.constraintEqualToConstant(40).active = true
        
        // video play controls layout
        playSlider.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 20).active = true
        playSlider.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -20).active = true
        playSlider.bottomAnchor.constraintEqualToAnchor(toolsBar.topAnchor).active = true
        playSlider.heightAnchor.constraintEqualToConstant(40).active = true
        
        // player view layout
        playerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        playerView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        playerView.bottomAnchor.constraintEqualToAnchor(playSlider.topAnchor).active = true
        playerView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    }
    
    func videoSliderValueChange(rangeSlider: PGRangeSlider) {
        print("Slider Change: \(rangeSlider.currentValue)")
        currentTime = rangeSlider.currentValue * duration
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
            }
        }

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
            
            
        }
        
    }
    
//    func setupPlayerView() {
//        let videoPlay = UIBarButtonItem(
//    }

}
