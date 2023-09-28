//
//  Recorder.swift
//  aninative
//
//  Created by Andy Drizen on 03/01/2015.
//  Copyright (c) 2015 Andy Drizen. All rights reserved.
//

import UIKit
import AVFoundation

enum Languages: String {
    case none = ""
    case en = "English"
    case fr = "French"
    case it = "Italian"
    case es = "Spanish"
    case de = "German"
    case ru = "Russian"
    case ko = "Korean"
    case ja = "Japanese"
    case zh = "Chinese"
}

//Video Encoder
//let kErrorDomain = "TimeLapseBuilder"
//let kFailedToStartAssetWriterError = 0
//let kFailedToAppendPixelBufferError = 1
protocol GetVideoPathDelegate:class {
    func GetSavePath(vPath:String,imgPath:String,isSave:Bool)
    func getPercent(percent:Int)
}

@objc public class Recorder: NSObject {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var displayLink : CADisplayLink?
    
    var imageCounter = 0
    public var view : UIView?
    var outputPath : NSString?
    var imagesUrls = [NSURL]()
    var allImages =  [UIImage]()
    
    var referenceDate : NSDate?
    public var name = "image"
    public var outputJPG = false
    var imageDataR = ImageData()
    var inputSize: CGSize = CGSize(width: 0.0, height: 0.0)
    var storedPath = ""
    var imgPath = ""
    var encodingStatus = true
    weak var getVideoPath: GetVideoPathDelegate?
    let vFps = 30
    var lastImage : UIImage?
    
    public func start() {
        
        if (view == nil) {
            NSException(name: NSExceptionName(rawValue: "No view set"), reason: "You must set a view before calling start.", userInfo: nil).raise()
        }
        else {
            imagesUrls.removeAll()
            displayLink = CADisplayLink(target: self, selector: #selector(handleDisplayLink))
            displayLink!.add(to: RunLoop.main, forMode: RunLoopMode.commonModes)
            
            referenceDate = NSDate()
        }
        
        encodingStatus = true
    }
    
    
    public func stop(input: String,isVideo:Bool, completion: @escaping (URL,URL) -> ()) {
        
        
        if(isVideo){
            if(imageCounter == 0)
            {
                //inputSize = (image?.size)!
                imageCounter = imageCounter + 1
                //DispatchQueue.global().async(execute: {
                self.setupStoredPath()
                if(self.inputSize.width <= 0 || self.inputSize.height <= 0 )
                {
                    self.inputSize = CGSize(width:640, height: 640)
                }
                self.writeImagesAsMovie(videoSize: self.inputSize, videoFPS: Int32(self.vFps))
                // })
            }
        }
        
        // change by shoaib
        // displayLink!.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
        displayLink?.invalidate()
        displayLink = nil
        view = nil
        encodingStatus = false
        
        //        displayLink?.invalidate()
        //        view = nil
        //        encodingStatus = false
        
        
    }
    
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "uk.co.andydrizen.test" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count - 1] as NSURL
    }()
    
    @objc func handleDisplayLink(displayLink : CADisplayLink) {
        if (view != nil) {
            createImageFromView(captureView: view!)
        }
    }
    
    func outputPathString() -> String {
        if (outputPath != nil) {
            return outputPath! as String
        }
        else {
            //return applicationDocumentsDirectory.absoluteString!
            
            let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            let appPath = documentsPath1.appendingPathComponent("PL2")
            //print(appPath!)
            do {
                try FileManager.default.createDirectory(atPath: appPath!.path, withIntermediateDirectories: true, attributes: nil)
            } catch let error as NSError {
                NSLog("Unable to create directory \(error.debugDescription)")
            }
            return (appPath?.absoluteString)!
        }
    }
    
    func getLogoImage(size:CGSize,localizedLogoImage:String) -> UIImage?
    {
        // Shoaib
        
        //        let widthInPoints = self.inputSize.width
        //        let videoLogo = UIImage(named: self.getLocalizedVideoLogoImage())
        //        UIGraphicsBeginImageContextWithOptions(self.inputSize, false, 1.0)
        //        videoLogo?.draw(in: CGRect(x:0,y:0,width:widthInPoints,height:widthInPoints))
        //        let resizedLogo = UIGraphicsGetImageFromCurrentImageContext()
        //        UIGraphicsEndImageContext()
        //         return resizedLogo!
        
        
        
        
        return autoreleasepool { () -> UIImage in
            let widthInPoints = size.width //self.inputSize.width
            let videoLogo = UIImage(named: localizedLogoImage)//self.getLocalizedVideoLogoImage())
            UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
            videoLogo?.draw(in: CGRect(x:0,y:0,width:widthInPoints,height:widthInPoints))
            let resizedLogo = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return resizedLogo!
        }
        
    }
    
    
    var isFirsrtTime = true
    func createImageFromView(captureView : UIView) {
        if (view != nil) {
             var image = UIImage()
            autoreleasepool{
                UIGraphicsBeginImageContextWithOptions(captureView.bounds.size, false, 1)
                captureView.drawHierarchy(in: captureView.bounds, afterScreenUpdates: false)
                image = UIGraphicsGetImageFromCurrentImageContext()!;
                UIGraphicsEndImageContext();
            }
            
            let size = CGSize(width:640, height: 640)
            let img1 = ResizeImg(image: image, targetSize: size)
            if(img1 != nil){
                var data : NSData?
                data = UIImageJPEGRepresentation(img1, 0.75)! as NSData
                let image = UIImage(data: data! as Data)
                if(self.allImages.count>=0){
                    self.allImages.append(image!)
                }else{
                    return
                }
                
                // Change by Shoaib
                //lastImage = image
                lastImage = image
                
                
                inputSize = (image!.size)
                if(inputSize.width <= 0 || inputSize.height <= 0 )
                {
                    inputSize = CGSize(width:640, height: 640)
                }
                
            }
            
            
        }
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
    
    func setupStoredPath()
    {
        //TimeLapseBuilder Video Recorder
        var tempPath:String
        let documentsPath1 = NSURL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        let appPath = documentsPath1.appendingPathComponent("PL2")
        // print(appPath!)
        do {
            try FileManager.default.createDirectory(atPath: appPath!.path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            NSLog("Unable to create directory \(error.debugDescription)")
        }
        
        tempPath = (appPath?.path)! + "/PL2temp.mp4"
        if(FileManager.default.fileExists(atPath: tempPath))
        {
            do {
                try FileManager.default.removeItem(atPath: tempPath)
            } catch {
                print("Not me error")
            }
            
        }
        /*repeat{
         let random = arc4random()
         tempPath = (appPath?.path)! + "/PL2\(random).mp4"
         }while(FileManager.default.fileExists(atPath: tempPath))*/
        
        self.storedPath = tempPath
    }
    
    //Another Writer Code
    
    fileprivate func SaveLastImage() {
        // change by shoaib
        // let size = CGSize(width:800, height: 800)
        //let img = ResizeImg(image: self.lastImage!, targetSize: size)
        let img = self.lastImage ?? UIImage()
        var fileExtension = "png"
        var data : NSData?
        if (self.outputJPG) {
            data = UIImageJPEGRepresentation(img, 0.75)! as NSData
            fileExtension = "jpg"
        }
        else {
            data = UIImagePNGRepresentation(img)! as NSData
        }
        
        var path = self.outputPathString()
        path = path.appending("/\(self.name)-\(self.imageCounter).\(fileExtension)")
        
        if let imageRaw = data {
            imageRaw.write(to: NSURL(string: path)! as URL, atomically: false)
        }
        
        self.imgPath = path
    }
    
    func writeImagesAsMovie(videoSize: CGSize, videoFPS: Int32) {
        if(self.inputSize.width <= 0 || self.inputSize.height <= 0 )
        {
            inputSize = CGSize(width:640, height: 640)
        }
        
        // Create AVAssetWriter to write video
        guard let assetWriter = createAssetWriter(path:self.storedPath, size: self.inputSize) else {
            print("Error converting images to video: AVAssetWriter not created")
            return
        }
        
        // If here, AVAssetWriter exists so create AVAssetWriterInputPixelBufferAdaptor
        let writerInput = assetWriter.inputs.filter{ $0.mediaType == AVMediaType.video }.first!
        let sourceBufferAttributes : [String : AnyObject] = [
            kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_32ARGB) as AnyObject,
            kCVPixelBufferWidthKey as String : inputSize.width as AnyObject,
            kCVPixelBufferHeightKey as String : inputSize.height as AnyObject,
        ]
        let pixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: writerInput, sourcePixelBufferAttributes: sourceBufferAttributes)
        
        // Start writing session
        
        
        
        let logoImage:UIImage = self.getLogoImage(size: self.inputSize, localizedLogoImage: self.getLocalizedVideoLogoImage())! //self.getLogoImage()!
        
        //        var items: [AVMetadataItem] = []
        //        let titleItem =  AVMutableMetadataItem()
        //        titleItem.keySpace = AVMetadataKeySpace.common
        //        titleItem.value = UIImageJPEGRepresentation(logoImage, 0)! as NSData
        //       titleItem.duration = CMTimeMake(10, 1)
        //        titleItem.time = CMTimeMake(0, 1)
        //
        //        items.append(titleItem)
        //        assetWriter.metadata = items
        
        assetWriter.startWriting()
        assetWriter.startSession(atSourceTime: kCMTimeZero)
        if (pixelBufferAdaptor.pixelBufferPool == nil) {
            print("Error converting images to video: pixelBufferPool nil after starting session")
            return
        }
        
        // -- Create queue for <requestMediaDataWhenReadyOnQueue>
        //let mediaQueue = DispatchQueue("mediaInputQueue", nil)
        let mediaQueue = DispatchQueue(label: "mediaInputQueue")
        // -- Set video parameters
        let frameDuration = CMTimeMake(1, videoFPS)
        var frameCount = 0
        
        var logoCounter = 0
        writerInput.requestMediaDataWhenReady(on: mediaQueue, using: { () -> Void in
            // Append unadded images to video but only while input ready
            
            while(true)
            {
                if (writerInput.isReadyForMoreMediaData && self.allImages.count > 0) {
                    autoreleasepool(){ // firebase log Crashed: mediaInputQueue // shoaib
                        
                    let lastFrameTime = CMTimeMake(Int64(frameCount), videoFPS)
                    let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDuration)
                    if let img = self.allImages.remove(at: 0) as UIImage?{
                        let size = CGSize(width:self.inputSize.width, height: self.inputSize.width)
                        if(self.isFirsrtTime){
                            self.isFirsrtTime = false
                            var imgInner = UIImage()
                            DispatchQueue.main.sync {
                                imgInner = self.appDelegate.getImage(imgName: self.imageDataR.name!, imageId:self.imageDataR.imageId! )!
                            }
                            if(imgInner.size.width > 0)
                            {
                                let reSizeImage = self.resizeImage(image: imgInner,targetSize: self.inputSize)
                                if !self.appendPixelBufferForImageAtURL(image:reSizeImage, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                                    print("Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
                                    return
                                }
                            }
                            
                        }else{
                            if !self.appendPixelBufferForImageAtURL(image:img, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                                print("Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
                                return
                            }
                        }
                        
                        frameCount += 1
                        self.getVideoPath?.getPercent(percent: frameCount)
                        // print(frameCount)
                    }
                }
                }
                if(!self.encodingStatus && self.allImages.count == 0)
                {
                    // show complete image
                    if(logoCounter < 60)
                    {
                        
                        if (writerInput.isReadyForMoreMediaData) {
                            //let img:UIImage = ((logoCounter>30) ? logoImage : self.ResizeImg(image: self.lastImage!, targetSize: CGSize(width:640, height: 640)))
                            let img:UIImage = ((logoCounter>30) ? logoImage :  self.lastImage ?? UIImage())
                            let lastFrameTime = CMTimeMake(Int64(frameCount), videoFPS)
                            let frameDurationForLogo = CMTimeMake(1, videoFPS)
                            let presentationTime = frameCount == 0 ? lastFrameTime : CMTimeAdd(lastFrameTime, frameDurationForLogo)
                            if !self.appendPixelBufferForImageAtURL(image:img, pixelBufferAdaptor: pixelBufferAdaptor, presentationTime: presentationTime) {
                                print("Error converting images to video: AVAssetWriterInputPixelBufferAdapter failed to append pixel buffer")
                                return
                            }
                            frameCount += 1
                            logoCounter += 1
                            self.getVideoPath?.getPercent(percent: frameCount)
                        }
                    }
                    else{
                        
                        writerInput.markAsFinished()
                        assetWriter.finishWriting {
                            if (assetWriter.error != nil) {
                                print("Error converting images to video: \(String(describing: assetWriter.error))")
                            } else {
                                self.SaveLastImage()
                                //print("Converted images to movie @ \(self.storedPath)")
                                self.getVideoPath?.GetSavePath(vPath: self.storedPath, imgPath:  self.imgPath,isSave: true)
                            }
                        }
                        break;
                        
                    }
                    
                }
                
            }
        })
    }
    
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        return autoreleasepool { () -> UIImage in
            let widthInPoints = self.inputSize.width
            let videoLogo = image //UIImage(named: self.getLocalizedVideoLogoImage())
            // UIGraphicsBeginImageContextWithOptions(self.inputSize, false, 1.0)
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
            videoLogo.draw(in: CGRect(x:0,y:0,width:widthInPoints,height:widthInPoints))
            let resizedLogo = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedLogo!
        }
    }
    
    
    func ResizeImg(image: UIImage, targetSize: CGSize) -> UIImage {
        
        //return image.scale(with: targetSize)!
        return autoreleasepool { () -> UIImage in
            UIGraphicsBeginImageContextWithOptions(targetSize, false, 1)
            image.draw(in: CGRect(x:0,y:0,width:targetSize.width,height:targetSize.height))
            let resizedLogo = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return resizedLogo!
        }
    }
    
    func createAssetWriter(path: String, size: CGSize) -> AVAssetWriter? {
        // Convert <path> to NSURL object
        let pathURL = NSURL(fileURLWithPath: path)
        var newVideoCGSize = size
        if(newVideoCGSize.height <= 0 || newVideoCGSize.width <= 0)
        {
            newVideoCGSize = CGSize(width:640, height: 640)
        }
        do {
            // Create asset writer
            let newWriter = try AVAssetWriter(outputURL: pathURL as URL, fileType: AVFileType.mov)
            // Define settings for video input
            // AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill as AnyObject Shoaib 09 Aug 2019
            let videoSettings: [String : AnyObject] = [
                AVVideoCodecKey  : AVVideoCodecH264 as AnyObject,
                AVVideoWidthKey  : floor(newVideoCGSize.width / 16) * 16    as AnyObject,
                AVVideoHeightKey : floor(newVideoCGSize.height / 16) * 16  as AnyObject,
                AVVideoScalingModeKey : AVVideoScalingModeResizeAspectFill as AnyObject
            ]
            
            // Add video input to writer
            let assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)
            newWriter.add(assetWriterVideoInput)
            
            // Return writer
            //print("Created asset writer for \(size.width)x\(size.height) video")
            return newWriter
        } catch {
            print("Error creating asset writer: \(error)")
            return nil
        }
    }
    
    
    func appendPixelBufferForImageAtURL(image: UIImage, pixelBufferAdaptor: AVAssetWriterInputPixelBufferAdaptor, presentationTime: CMTime) -> Bool {
        var appendSucceeded = false
        
        autoreleasepool {
            if  let pixelBufferPool = pixelBufferAdaptor.pixelBufferPool {
                let pixelBufferPointer = UnsafeMutablePointer<CVPixelBuffer?>.allocate(capacity: 1)
                let status: CVReturn = CVPixelBufferPoolCreatePixelBuffer(
                    kCFAllocatorDefault,
                    pixelBufferPool,
                    pixelBufferPointer
                )
                
                if let pixelBuffer = pixelBufferPointer.pointee, status == 0 {
                    fillPixelBufferFromImage(image: image, pixelBuffer: pixelBuffer)
                    appendSucceeded = pixelBufferAdaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                    pixelBufferPointer.deinitialize(count: 1)
                } else {
                    NSLog("Error: Failed to allocate pixel buffer from pool")
                }
                
                pixelBufferPointer.deallocate()
            }
        }
        
        return appendSucceeded
    }
    
    
    func fillPixelBufferFromImage(image: UIImage, pixelBuffer: CVPixelBuffer) {
        //CVPixelBufferLockBaseAddress(pixelBuffer, [])
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        
        let pixelData = CVPixelBufferGetBaseAddress(pixelBuffer)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        
        // Create CGBitmapContext
        let context = CGContext(
            data: pixelData,
            width: Int(image.size.width),
            height: Int(image.size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer),
            space: rgbColorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue
        )
        
        do {
            context?.draw(image.cgImage!, in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags(rawValue: 0))
        } catch {
            print("Not me error")
        }
        
        
    }
    
    
    /*func saveVideoToLibrary(videoURL: NSURL) {
     PHPhotoLibrary.requestAuthorization { status in
     // Return if unauthorized
     guard status == .Authorized else {
     print("Error saving video: unauthorized access")
     return
     }
     
     // If here, save video to library
     PHPhotoLibrary.sharedPhotoLibrary().performChanges({
     PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(videoURL)
     }) { success, error in
     if !success {
     print("Error saving video: \(error)")
     }
     }
     }
     }*/
    
}

extension Locale {
    
    static var enLocale: Locale {
        return Locale(identifier: "en-EN")
    }
    
    static var currentLanguage: Languages? {
        guard let code = preferredLanguages.first?.components(separatedBy: "-").first else {
            print("could not detect language code")
            return nil
        }
        guard let rawValue = enLocale.localizedString(forLanguageCode: code) else {
            print("could not localize language code")
            return nil
        }
        
        guard let language = Languages(rawValue: rawValue) else {
            print("could not init language from raw value")
            return nil
        }
        print("language: \(code)-\(rawValue)")
        return language
        
    }
}

extension UIImage {
    func scale(with size: CGSize) -> UIImage? {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}

