//
//  Utility.swift
//  PL2
//
//  Created by iPHTech8 on 9/22/17.
//  Copyright © 2017 Praveen kumar. All rights reserved.
//

import Foundation
import UIKit

func color(_ rgbColor: Int) -> UIColor{
    return UIColor(
        red:   CGFloat((rgbColor & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgbColor & 0x00FF00) >> 8 ) / 255.0,
        blue:  CGFloat((rgbColor & 0x0000FF) >> 0 ) / 255.0,
        alpha: CGFloat(1.0)
    )
}
//MARK: SAVE & FETCH MYWORK COMPLETED IMAGES ID'S
func getCompletedImagesIDArray() -> [String]{
    let defaults = UserDefaults.standard
    if defaults.array(forKey: Completed_ID_Key) != nil{
        return (defaults.array(forKey: Completed_ID_Key)  as? [String])!
    }
    return [String]()
}
func saveCompletedImagesIDArray(array: [String])
{
    let defaults = UserDefaults.standard
    defaults.set(array, forKey: Completed_ID_Key)
    defaults.synchronize()
}
//MARK: Delete & FETCH MYWORK COMPLETED IMAGES ID'S
func deleteCompletedImagesIDArray(imageId: String?){
    var arrayCompleted = getCompletedImagesIDArray()
    if arrayCompleted.contains(imageId!){
        if let index = arrayCompleted.index(where: { $0 == imageId }) {
            arrayCompleted.remove(at: index)
            let defaults = UserDefaults.standard
            defaults.set(arrayCompleted, forKey: Completed_ID_Key)
            defaults.synchronize()
        }
    }
}

extension UIView {
    func getColourFromPoint(point:CGPoint) -> UIColor {
        let colorSpace:CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        var pixelData:[UInt8] = [0, 0, 0, 0]
        
        let context = CGContext(data: &pixelData, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
//        CGContextTranslateCTM(context!, -point.x, -point.y);
        context?.translateBy(x:-point.x,y:-point.y)
        self.layer.render(in: context!)
        
        let red:CGFloat = CGFloat(pixelData[0])/CGFloat(255.0)
        let green:CGFloat = CGFloat(pixelData[1])/CGFloat(255.0)
        let blue:CGFloat = CGFloat(pixelData[2])/CGFloat(255.0)
        let alpha:CGFloat = CGFloat(pixelData[3])/CGFloat(255.0)
        
        let color:UIColor = UIColor(red: red, green: green, blue: blue, alpha: alpha)
        return color
    }
}



extension UIImage {
    
    subscript (x: Int, y: Int) -> UIColor? {
        
        if x < 0 || x > Int(size.width) || y < 0 || y > Int(size.height) {
            return nil
        }
        
        let provider =   cgImage?.dataProvider// CGImageGetDataProvider(self.cgImage!)
//        let providerData = CGDataProvider.init(data: provider! as! CFData)
        let providerData = provider?.data
        
//        let providerData = CGDataProviderCopyData(provider)
        let data = CFDataGetBytePtr(providerData)
        
        let numberOfComponents = 4
        let pixelData = ((Int(size.width) * y) + x) * numberOfComponents
        
        let r = CGFloat(data![pixelData]) / 255.0
        let g = CGFloat(data![pixelData + 1]) / 255.0
        let b = CGFloat(data![pixelData + 2]) / 255.0
        let a = CGFloat(data![pixelData + 3]) / 255.0
        
        return UIColor(red: r.roundTo(places: 1), green: g.roundTo(places: 1), blue: b.roundTo(places: 1 ), alpha: a.roundTo(places: 1))
    }
    
    func red(color:UIColor) -> CGFloat{
    
        let components = color.cgColor.components
        return components![0]
    }
    func green(color:UIColor) -> CGFloat{
        
        let components = color.cgColor.components
        return components![1]
    }
    func blue(color:UIColor) -> CGFloat{
        
        let components = color.cgColor.components
        return components![2]
    }
    func alpha(color:UIColor) -> CGFloat{
        
        let components = color.cgColor.components
        return components![3]
    }
    
    func pixelData() -> [UInt8]? {
        let size = self.size
        let dataSize = size.width * size.height * 4
        var pixelData = [UInt8](repeating: 0, count: Int(dataSize))
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: &pixelData,
                                width: Int(size.width),
                                height: Int(size.height),
                                bitsPerComponent: 8,
                                bytesPerRow: 4 * Int(size.width),
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipLast.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        
        return pixelData
    }
}

extension UIColor {
    func red() -> CGFloat{
        
        let components = self.cgColor.components
        return components![0]
    }
    func green() -> CGFloat{
        
        let components = self.cgColor.components
        return components![1]
    }
    func blue() -> CGFloat{
        
        let components = self.cgColor.components
        return components![2]
    }
    func alpha() -> CGFloat{
        
        let components = self.cgColor.components
        return components![3]
    }
}

extension CGFloat {
    func roundTo(places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}


extension UIView {
    func takeSnapshot() -> UIImage {
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }
    
    
    func copyView() -> UIView {
        return NSKeyedUnarchiver.unarchiveObject(with: NSKeyedArchiver.archivedData(withRootObject: self)) as! UIView
    }
}

extension NSString {
    func drawVerticallyCentered(in rect: CGRect, withAttributes attributes: [NSAttributedStringKey : Any]? = nil) {
        let size = self.size(withAttributes: attributes)
        let centeredRect = CGRect(x: rect.origin.x, y: rect.origin.y + (rect.size.height-size.height)/2.0, width: rect.size.width, height: size.height)
        self.draw(in: centeredRect, withAttributes: attributes)
    }
}

public extension UIDevice {

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }

        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod Touch 5"
            case "iPod7,1":                                 return "iPod Touch 6"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad Mini 5"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }

        return mapToDevice(identifier: identifier)
    }()
    

}



