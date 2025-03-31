//
//  GlobalFile.swift
//  ImageProcessing
//
//  Created by Developer 1 on 08/11/23.
//

import Foundation
import UIKit
import GPUImage

extension UIImage {
    public func performImageOperation(withFilter filter: GPUImageOutput, completion: @escaping (UIImage?) -> Void) {
        let processImg = self
        let image = GPUImagePicture(image: processImg)
        
        // Apply the provided filter
        image?.addTarget(filter as! GPUImageInput)
        
        let sharpenFilter = GPUImageGammaFilter()
        filter.addTarget(sharpenFilter)
        
        sharpenFilter.useNextFrameForImageCapture()
        image?.processImage {
            let processedImage = sharpenFilter.imageFromCurrentFramebuffer()
            completion(processedImage) // Call the completion handler with the processed image
        }
    }
}

