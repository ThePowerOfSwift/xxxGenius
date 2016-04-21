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
    let playControls = UIView()
    
    private var playerLayer: AVPlayerLayer? {
        return playerView.playerLayer
    }
    
//    public init() {
//        
////        playerView = PGPlayerView()
//        super.init(nibName: nil, bundle: nil)
//    }
//    
//    required public init?(coder aDecoder: NSCoder) {
//        
////        playerView = PGPlayerView()
//        super.init(coder: aDecoder)
//    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.grayColor()

        // Do any additional setup after loading the view.
        navigationItem.title = "Video Editor"
        
        // setup Video Player View
        playerView.playerLayer.player = player
        playerView.backgroundColor = UIColor.redColor()
        
        // setup Tool Bar
        toolsBar.backgroundColor = UIColor.blueColor()
        
        // setup Play Controls
        playControls.backgroundColor = UIColor.greenColor()
        playControls.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(playControls)
        
        // view layout
        
        playControls.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor, constant: 0).active = true
        playControls.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor, constant: 0).active = true
        playControls.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor).active = true
        playControls.heightAnchor.constraintEqualToConstant(20).active = true
        
        
//        playControls.frame = CGRect(origin: CGPoint(x: 3,y: 3), size: CGSize(width: 100, height: 100))
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
