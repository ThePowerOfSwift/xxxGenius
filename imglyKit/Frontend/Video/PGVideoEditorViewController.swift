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

public class PGVideoEditorViewController: UIViewController {

    public var videoFileUrl: NSURL?
    
    let playerView = PGPlayerView()
    let player = AVPlayer()
    let toolsBar = UIToolbar()
    let playControl = PGRangeSlider(frame: CGRectZero)
    
    private var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.toRGB(229.0, green: 224.0, blue: 221.0)

        // Do any additional setup after loading the view.
        navigationItem.title = "Video Editor"
        
        // setup Video Player View
        playerView.playerLayer.player = player
        playerView.translatesAutoresizingMaskIntoConstraints = false
        playerView.backgroundColor = UIColor.redColor()
        view.addSubview(playerView)
        
        // setup Play Controls
        playControl.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playControl)
        
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
        playControl.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 20).active = true
        playControl.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: -20).active = true
        playControl.bottomAnchor.constraintEqualToAnchor(toolsBar.topAnchor).active = true
        playControl.heightAnchor.constraintEqualToConstant(40).active = true
        
        // player view layout
        playerView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor).active = true
        playerView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor).active = true
        playerView.bottomAnchor.constraintEqualToAnchor(playControl.topAnchor).active = true
        playerView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    }
    
//    func setupPlayerView() {
//        let videoPlay = UIBarButtonItem(
//    }

}
