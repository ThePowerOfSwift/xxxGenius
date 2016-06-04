//
//  AVUtils.swift
//  ReverseVid
//
//  Created by ddpisces on 16/3/15.
//  Copyright © 2016年 Picnic. All rights reserved.
//

import Foundation
import AVFoundation
import Photos

protocol ReverseVideoDelegate: NSObjectProtocol {
  func updateProgressValue(value: Float)
  func reverseVideoComplete()
}

class AVUtils {
  
  static let sharedInstance = AVUtils()
  
  var delegate: ReverseVideoDelegate?

  var transform: CGAffineTransform?
  
  private func mergeAssets(video1: AVAsset, video2: AVAsset) {
    
    // delete existing merged video asset
    let mergedPath = mergedVideoPath().path!
    deleteFileInPath(mergedPath)
    
    let mixComposition  = AVMutableComposition()
    
    do {
      // insert video
      let videoTrack = mixComposition.addMutableTrackWithMediaType(AVMediaTypeVideo,
                                                                   preferredTrackID: Int32(kCMPersistentTrackID_Invalid))
      
      try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, video1.duration),
                                     ofTrack: video1.tracksWithMediaType(AVMediaTypeVideo)[0],
                                     atTime: kCMTimeZero)
      
      // insert second video
      try videoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, video2.duration),
                                     ofTrack: video2.tracksWithMediaType(AVMediaTypeVideo)[0],
                                     atTime: video1.duration)
      
      // iOS saved in Lanscape mode
      if let tran = transform {
        videoTrack.preferredTransform = tran
      }
      
    } catch let error as NSError {
      print("\(error)")
      return
    }
    
    dispatch_async(GlobalMainQueue) {[weak self] in
      self?.delegate?.updateProgressValue(0.9)
    }
    
    
    let exporter = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
    exporter?.outputURL = mergedVideoPath()
    exporter?.outputFileType = AVFileTypeQuickTimeMovie
    exporter?.shouldOptimizeForNetworkUse = true
    
    exporter?.exportAsynchronouslyWithCompletionHandler({ [weak self] in
      
        let path = self?.mergedVideoPath().path
        
        if UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(path!) {
          UISaveVideoAtPathToSavedPhotosAlbum(path!, nil, nil, nil)
        }
      
       dispatch_async(GlobalMainQueue, {[weak self] in
        self?.delegate?.updateProgressValue(1.0)
        self?.delegate?.reverseVideoComplete()
      })
    })
  }
  
  func reverseAsset(asset: AVAsset, transform: CGAffineTransform?) {
    
    // delete existing merged video asset
    let path = reversedVideoPath().path!
    deleteFileInPath(path)
    
    if let tran = transform {
      self.transform = tran
    }
    
    dispatch_async(GlobalMainQueue) {[weak self] in
      self?.delegate?.updateProgressValue(0.0)
    }
    
    dispatch_async(GlobalBackgroundQueue) {[weak self] in
      self?.reversedAsset(asset)
    }
  }
  
  private func reversedAsset(asset: AVAsset) {
    do {
      let reader = try AVAssetReader(asset: asset)
      let outputURL: NSURL = reversedVideoPath()
      
      guard let videoTrack = asset.tracksWithMediaType(AVMediaTypeVideo).last else {
        return
      }
      
      let readerOutputSettings: [String:AnyObject] = [
        "\(kCVPixelBufferPixelFormatTypeKey)": Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)
      ]
      let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
      
      reader.addOutput(readerOutput)
      reader.startReading()
      
      // Read in frames (CMSampleBuffer is a frame)
      var samples = [CMSampleBuffer]()
      while let sample = readerOutput.copyNextSampleBuffer() {
        samples.append(sample)
      }
      
      // update progress value by 10%
      dispatch_async(GlobalMainQueue) {[weak self] in
        self?.delegate?.updateProgressValue(0.1)
      }
      
      // Write to AVAsset
      let writer = try AVAssetWriter(URL: outputURL, fileType: AVFileTypeMPEG4)
      
      let writerOutputSettings: [String:AnyObject] = [
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: videoTrack.naturalSize.width,
        AVVideoHeightKey: videoTrack.naturalSize.height,
        AVVideoCompressionPropertiesKey: [AVVideoAverageBitRateKey: videoTrack.estimatedDataRate]
      ]
      
      let sourceFormatHint = videoTrack.formatDescriptions.last as! CMFormatDescriptionRef
      let writerInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: writerOutputSettings, sourceFormatHint: sourceFormatHint)
      writerInput.expectsMediaDataInRealTime = false
      
      let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: .None)
      writer.addInput(writerInput)
      writer.startWriting()
      writer.startSessionAtSourceTime(CMSampleBufferGetPresentationTimeStamp(samples[0]))
      
      for (index, sample) in samples.enumerate() {
        let presentationTime = CMSampleBufferGetPresentationTimeStamp(sample)
        
        if let imageBufferRef = CMSampleBufferGetImageBuffer(samples[samples.count - index - 1]) {
          pixelBufferAdaptor.appendPixelBuffer(imageBufferRef, withPresentationTime: presentationTime)
        }
        
        while !writerInput.readyForMoreMediaData {
          NSThread.sleepForTimeInterval(0.1)
        }
        
        // update progress value when write asset
        dispatch_async(GlobalMainQueue, {[weak self] in
          let currentProgress = 0.1 + Float(index)/Float(samples.count) * 0.7
          self?.delegate?.updateProgressValue(currentProgress)
        })
      }
      
      let videoReverse = AVAsset(URL: reversedVideoPath())
      
      writer.finishWritingWithCompletionHandler {
        
        // merge asset after reversing
        self.mergeAssets(asset, video2: videoReverse)
      }
    }
    catch let error as NSError {
      print("\(error)")
      return
    }
  }
  
  private func reversedVideoPath() -> NSURL {
    var documentPath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)[0]
    documentPath = documentPath.URLByAppendingPathComponent("reversedAsset.mov")
    print(documentPath)
    
    return documentPath
  }
  
  private func mergedVideoPath() -> NSURL {
    var documentPath = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains:.UserDomainMask)[0]
    documentPath = documentPath.URLByAppendingPathComponent("mergedAsset.mov")
    print(documentPath)
    
    return documentPath
  }
  
  private func deleteFileInPath(path: String) {
    if NSFileManager.defaultManager().fileExistsAtPath(path) {
      do {
        try NSFileManager.defaultManager().removeItemAtPath(path)
      } catch let error as NSError {
        print("\(error)")
        return
      }
    }
  }
}