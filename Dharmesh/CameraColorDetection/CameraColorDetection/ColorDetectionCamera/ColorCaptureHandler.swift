//
//  ColorCaptureHandler.swift
//  CameraColorDetection
//
//  Created by Mr. Dharmesh on 07/06/24.
//

import Foundation
import UIKit
import AVFoundation

class ColorCaptureHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    var colorCaptureHandler: ((UIColor) -> Void)?
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        
        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
        guard let baseAddr = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else {
            return
        }
        
        let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
        let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo: CGBitmapInfo = [
            .byteOrder32Little,
            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)
        ]
        
        guard let context = CGContext(data: baseAddr,
                                      width: width,
                                      height: height,
                                      bitsPerComponent: 8,
                                      bytesPerRow: bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue) else {
            return
        }
        
        guard let cgImage = context.makeImage() else {
            return
        }
        
        let capturedColor = captureColor(from: cgImage, at: CGPoint(x: width / 2, y: height / 2))
        
        DispatchQueue.main.async {
            self.colorCaptureHandler?(capturedColor)
        }
    }
    
    private func captureColor(from cgImage: CGImage, at point: CGPoint) -> UIColor {
        guard let pixelData = cgImage.dataProvider?.data,
              let data = CFDataGetBytePtr(pixelData) else {
            return .clear
        }
        
        let pixelInfo = ((Int(cgImage.width) * Int(point.y)) + Int(point.x)) * 4
        
        let red = CGFloat(data[pixelInfo]) / 255.0
        let green = CGFloat(data[pixelInfo + 1]) / 255.0
        let blue = CGFloat(data[pixelInfo + 2]) / 255.0
        let alpha = CGFloat(data[pixelInfo + 3]) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
}

//class ColorCaptureHandler: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
//    
//    var colorCaptureHandler: ((UIColor) -> Void)?
//    
//    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
//            return
//        }
//        CVPixelBufferLockBaseAddress(imageBuffer, CVPixelBufferLockFlags(rawValue: CVOptionFlags(0)))
//        guard let baseAddr = CVPixelBufferGetBaseAddressOfPlane(imageBuffer, 0) else {
//            return
//        }
//        let width = CVPixelBufferGetWidthOfPlane(imageBuffer, 0)
//        let height = CVPixelBufferGetHeightOfPlane(imageBuffer, 0)
//        let bytesPerRow = CVPixelBufferGetBytesPerRowOfPlane(imageBuffer, 0)
//        let colorSpace = CGColorSpaceCreateDeviceRGB()
//        let bimapInfo: CGBitmapInfo = [
//            .byteOrder32Little,
//            CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)]
//        
//        guard let context = CGContext(data: baseAddr, width: width, height: height, bitsPerComponent: 8, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bimapInfo.rawValue) else {
//            return
//        }
//        
//        guard let cgImage = context.makeImage() else {
//            return
//        }
//        
//        if let pixelColor = pickColor(in: cgImage, at: CGPoint(x: width / 2, y: height / 2)) {
//            colorCaptureHandler?(pixelColor)
//        }
//    }
//    
//    private func pickColor(in image: CGImage, at position: CGPoint) -> UIColor? {
//        guard let colorSpace = image.colorSpace else { return nil }
//        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
//        var pixelData: [UInt8] = [0, 0, 0, 0]
//        
//        guard let context = CGContext(data: &pixelData,
//                                      width: 1,
//                                      height: 1,
//                                      bitsPerComponent: 8,
//                                      bytesPerRow: 4,
//                                      space: colorSpace,
//                                      bitmapInfo: bitmapInfo.rawValue),
//              let croppedImage = image.cropping(to: CGRect(x: Int(position.x), y: Int(position.y), width: 1, height: 1))
//        else { return nil }
//        
//        context.draw(croppedImage, in: CGRect(x: 0, y: 0, width: 1, height: 1))
//        
//        let red = CGFloat(pixelData[0]) / 255.0
//        let green = CGFloat(pixelData[1]) / 255.0
//        let blue = CGFloat(pixelData[2]) / 255.0
//        let alpha = CGFloat(pixelData[3]) / 255.0
//        
//        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
//    }
//}
