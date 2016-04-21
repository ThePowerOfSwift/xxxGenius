/*
	Copyright (C) 2015 Apple Inc. All Rights Reserved.
	See LICENSE.txt for this sample’s licensing information
	
	Abstract:
	Player view backed by an PGAVPlayerLayer.
*/

import UIKit
import AVFoundation

/// A simple `UIView` subclass that is backed by an `PGAVPlayerLayer` layer.
class PGPlayerView: UIView {
    var player: AVPlayer? {
        get {
            return playerLayer.player
        }
        
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    override class func layerClass() -> AnyClass {
        return AVPlayerLayer.self
    }
}
