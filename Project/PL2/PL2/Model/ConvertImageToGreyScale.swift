//
//  ConvertImageToGreyScale.swift
//  PL2
//
//  Created by Lekha Mishra on 11/23/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import UIKit

class ConvertImageToGreyScale: NSObject {

    func convertImageToGrayScale(image: UIImage) -> UIImage {
        // Create image rectangle with current image width/height
        let imageRect = CGRect(x:0, y:0, width:image.size.width, height:image.size.height)
        
        // Grayscale color space
        let colorSpace: CGColorSpace = CGColorSpaceCreateDeviceGray()
        
        // Create bitmap content with current image size and grayscale colorspace
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
        let context = CGContext(data: nil, width: Int(UInt(image.size.width)), height: Int(UInt(image.size.height)), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        // Draw image into current context, with specified rectangle using previously defined context (with grayscale colorspace)
        context?.draw(image.cgImage!, in: imageRect)
        
        // Create bitmap image info from pixel data in current context
        let imageRef: CGImage = context!.makeImage()!
        
        // Create a new UIImage object
        let newImage: UIImage = UIImage.init(cgImage: imageRef)

        // Return the new grayscale image
        return newImage
    }
    
}
