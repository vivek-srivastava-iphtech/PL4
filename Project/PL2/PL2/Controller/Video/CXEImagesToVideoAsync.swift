//
//  CXEImagesToVideoAsync.swift
//  ImagesToVideo
//
//  Created by Wulei on 2016/12/24.
//  Copyright © 2016年 wulei. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

typealias CXEMovieMakerCompletion = (URL) -> Void
fileprivate typealias CXEMovieMakerUIImageExtractor = (AnyObject) -> UIImage?

class CXEImageToVideoAsync: NSObject{
    
    //MARK: Private Properties
    
    private var assetWriter:AVAssetWriter!
    private var writeInput:AVAssetWriterInput!
    private var bufferAdapter:AVAssetWriterInputPixelBufferAdaptor!
    private var videoSettings:[String : Any]!
    private var frameTime:CMTime!
    private var fileURL:URL!
    private var completionBlock: CXEMovieMakerCompletion?
    
    //MARK: Class Method
    
    class func videoSettings(codec:String, width:Int, height:Int) -> [String: Any]{
        if(Int(width) % 16 != 0){
            print("warning: video settings width must be divisible by 16")
        }
        
        let videoSettings:[String: Any] = [AVVideoCodecKey: AVVideoCodecH264,
                                           AVVideoWidthKey: width,
                                           AVVideoHeightKey: height]
        
        return videoSettings
    }
    
    //MARK: Public methods
    
    init(videoSettings: [String: Any]) {
        super.init()
        
        //let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        var tempPath:String
        let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let appPath = documentsPath1.appendingPathComponent("PL2")
        print(appPath!)
        do {
            try FileManager.default.createDirectory(atPath: appPath!.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        repeat{
            let random = arc4random()
            tempPath = (appPath?.path)! + "/PL2\(random).mp4"
        }while(FileManager.default.fileExists(atPath: tempPath))
        
        self.fileURL = URL(fileURLWithPath: tempPath)
        self.assetWriter = try! AVAssetWriter(url: self.fileURL, fileType: AVFileType.mov)
        
        self.videoSettings = videoSettings
        self.writeInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
        assert(self.assetWriter.canAdd(self.writeInput), "add failed")
        
        self.assetWriter.add(self.writeInput)
        let bufferAttributes:[String: Any] = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB)]
        self.bufferAdapter = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: self.writeInput, sourcePixelBufferAttributes: bufferAttributes)
        self.frameTime = CMTimeMake(48, 48)
    }
    
    func createMovieFrom(urls: [URL], size: CGSize, withCompletion: @escaping CXEMovieMakerCompletion){
        self.createMovieFromSource(images: urls as [AnyObject], extractor:
            {(inputObject:AnyObject) ->UIImage? in

                do {
                    //UIImage(data: try! Data(contentsOf: inputObject as! URL))
                    let dataImage = try Data(contentsOf: inputObject as! URL)
                    let getImage = UIImage(data: dataImage)
                    return getImage
                }
                catch
                {
                    let videoLogo = UIImage(named: self.getLocalizedVideoLogoImage())
                    UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
                    videoLogo?.draw(in: CGRect(x:0,y:0,width:size.width,height:size.width))
                    let resizedLogo = UIGraphicsGetImageFromCurrentImageContext()
                    UIGraphicsEndImageContext()
                    return resizedLogo
                }

        }, withCompletion: withCompletion)
    }
    
    func createMovieFrom(images: [UIImage], withCompletion: @escaping CXEMovieMakerCompletion){
        self.createMovieFromSource(images: images, extractor: {(inputObject:AnyObject) -> UIImage? in
            return inputObject as? UIImage}, withCompletion: withCompletion)
    }
    
    //MARK: Private methods
    
    private func createMovieFromSource(images: [AnyObject], extractor: @escaping CXEMovieMakerUIImageExtractor, withCompletion: @escaping CXEMovieMakerCompletion){
        self.completionBlock = withCompletion
        
        self.assetWriter.startWriting()
        self.assetWriter.startSession(atSourceTime: kCMTimeZero)
        
        let mediaInputQueue = DispatchQueue(label: "mediaInputQueue")
        var i = 0
        let frameNumber = images.count
        self.writeInput.requestMediaDataWhenReady(on: mediaInputQueue){
            while(true){
                if(i >= frameNumber){
                    break
                }
                
                if (self.writeInput.isReadyForMoreMediaData){
                    var sampleBuffer:CVPixelBuffer?
                    autoreleasepool{
                        let img = extractor(images[i])
                        if img == nil{
                            i += 1
                            print("Warning: counld not extract one of the frames")
                            //                            continue
                        }
                        sampleBuffer = self.newPixelBufferFrom(cgImage: img!.cgImage!)
                    }
                    if (sampleBuffer != nil){
                        if(i == 0){
                            self.bufferAdapter.append(sampleBuffer!, withPresentationTime: kCMTimeZero)
                        }else{
                            let value = i - 1
                            let lastTime = CMTimeMake(Int64(value), self.frameTime.timescale)
                            let presentTime = CMTimeAdd(lastTime, self.frameTime)
                            self.bufferAdapter.append(sampleBuffer!, withPresentationTime: presentTime)
                            /*do {
                                try self.bufferAdapter.append(sampleBuffer!, withPresentationTime: presentTime)
                            } catch let error{
                                print(error)
                            }*/
                        }
                        i = i + 1
                    }
                }
            }
            self.writeInput.markAsFinished()
            self.assetWriter.finishWriting {
                DispatchQueue.main.sync {
                    self.completionBlock!(self.fileURL)
                }
            }
        }
    }

    
    private func newPixelBufferFrom(cgImage:CGImage) -> CVPixelBuffer?{
        let options:[String: Any] = [kCVPixelBufferCGImageCompatibilityKey as String: true, kCVPixelBufferCGBitmapContextCompatibilityKey as String: true]
        var pxbuffer:CVPixelBuffer?
        let frameWidth = self.videoSettings[AVVideoWidthKey] as! Int
        let frameHeight = self.videoSettings[AVVideoHeightKey] as! Int
        
        let status = CVPixelBufferCreate(kCFAllocatorDefault, frameWidth, frameHeight, kCVPixelFormatType_32ARGB, options as CFDictionary?, &pxbuffer)
        assert(status == kCVReturnSuccess && pxbuffer != nil, "newPixelBuffer failed")
        
        CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        let pxdata = CVPixelBufferGetBaseAddress(pxbuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata, width: frameWidth, height: frameHeight, bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pxbuffer!), space: rgbColorSpace, bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        assert(context != nil, "context is nil")
        
        context!.concatenate(CGAffineTransform.identity)
        context!.draw(cgImage, in: CGRect(x: 0, y: 0, width: cgImage.width, height: cgImage.height))
        CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0))
        return pxbuffer
    }
    
    func getLocalizedVideoLogoImage() -> String{
        var imageName:String = "video_logo"
        if let currentLanguage = Locale.currentLanguage {
            switch  currentLanguage.rawValue{
            case "English": // english
                imageName = "video_logo"
                break
            case "Spanish": // spanish
                imageName = "videoLogoSpanish"
                break
            case "French": // French
                imageName = "videoLogoFrench"
                break
            case "Italian": // Italian
                imageName = "videoLogoItalian"
                break
            case "German": // German
                imageName = "videoLogoGerman"
                break
            case "Russian": // Russian
                imageName = "videoLogoRussian"
                break
            case "Korean": // Korean
                imageName = "videoLogoKorean"
                break
            case "Japanese": // Japanese
                imageName = "videoLogoJapanese"
                break
            case "Chinese": // Chinese
                imageName = "videoLogoChinese"
                break
            default:
                imageName = "video_logo"
            }
        }
        return imageName
    }

}
