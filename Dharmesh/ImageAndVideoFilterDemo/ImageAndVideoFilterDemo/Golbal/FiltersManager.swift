//
//  FiltersManager.swift
//  ImageProcessing
//
//  Created by Developer 1 on 08/11/23.
//

import Foundation
import UIKit
import GPUImage

class FilterManager {
    static let shared = FilterManager()

    private var filter: GPUImageOutput?
    private var image: UIImage?

    private init() {
        // Initialize your GPUImage-related properties or setup here
    }

    // Apply a filter to an image
    func applyFilter(image: UIImage, filter: GPUImageOutput, completion: @escaping (UIImage?) -> Void) {
        self.image = image
        self.filter = filter

        let picture = GPUImagePicture(image: image)
        picture?.addTarget(filter as! GPUImageInput)

        filter.useNextFrameForImageCapture()
        picture?.processImage {
            completion(self.filter?.imageFromCurrentFramebuffer())
        }
    }


    // Reset the current filter and image
    func reset() {
        filter = nil
        image = nil
    }
    
    
    func applyBrightnessFilter(image: UIImage, brightness: Float, completion: @escaping (UIImage?) -> Void) {
        let brightnessFilter = GPUImageVignetteFilter()
        brightnessFilter.vignetteColor.three = 10
//        brightnessFilter.brightness = CGFloat(brightness) // Adjust the brightness (between -1.0 and 1.0)
        
        applyFilter(image: image, filter: brightnessFilter, completion: completion)
    }
    
//    func applyBrightnessFilter(image: UIImage, brightness: Float, completion: @escaping (UIImage?) -> Void) {
//        let brightnessFilter = GPUImageBrightnessFilter()
//        brightnessFilter.brightness = CGFloat(brightness) // Adjust the brightness (between -1.0 and 1.0)
//
//        applyFilter(image: image, filter: brightnessFilter, completion: completion)
//    }
    
    func applyExposureFilter(image: UIImage, exposure: Float, completion: @escaping (UIImage?) -> Void) {
        let exposureFilter = GPUImageSwirlFilter()
        
//        exposureFilter.exposure = CGFloat(exposure) // Adjust the exposure (between -10.0 and 10.0)
        
        applyFilter(image: image, filter: exposureFilter, completion: completion)
    }
    
    func applyContrastFilter(image: UIImage, contrast: Float, completion: @escaping (UIImage?) -> Void) {
        let contrastFilter = GPUImageContrastFilter()
        contrastFilter.contrast = CGFloat(contrast) // Adjust the contrast (between 0.0 and 4.0)
        
        applyFilter(image: image, filter: contrastFilter, completion: completion)
    }
    
    func applySaturationFilter(image: UIImage, saturation: Float, completion: @escaping (UIImage?) -> Void) {
        let saturationFilter = GPUImageSaturationFilter()
        saturationFilter.saturation = CGFloat(saturation) // Adjust the saturation (between 0.0 and 2.0)
        
        applyFilter(image: image, filter: saturationFilter, completion: completion)
    }
    
    func applyGammaFilter(image: UIImage, gamma: Float, completion: @escaping (UIImage?) -> Void) {
        let gammaFilter = GPUImageGammaFilter()
        gammaFilter.gamma = CGFloat(gamma) // Adjust the gamma (between 0.0 and 3.0)
        
        applyFilter(image: image, filter: gammaFilter, completion: completion)
    }
    
    func applyFilter(image: UIImage, filter: GPUImageOutput) -> UIImage? {
        let gpuImagePicture = GPUImagePicture(image: image)
        gpuImagePicture?.addTarget(filter as! GPUImageInput)
        filter.useNextFrameForImageCapture()
        gpuImagePicture?.processImage()
        return filter.imageFromCurrentFramebuffer()
    }
    
    func applyColorMatrixFilter(image: UIImage, matrix: GPUMatrix4x4, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageColorMatrixFilter()
        filter.colorMatrix = matrix
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyRGBFilter(image: UIImage, red: Float, green: Float, blue: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageRGBFilter()
        filter.red = CGFloat(red)
        filter.green = CGFloat(green)
        filter.blue = CGFloat(blue)
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyHueFilter(image: UIImage, hue: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageHueFilter()
        filter.hue = CGFloat(hue)
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyWhiteBalanceFilter(image: UIImage, temperature: Float, tint: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageWhiteBalanceFilter()
        filter.temperature = CGFloat(temperature)
        filter.tint = CGFloat(tint)
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyVignetteFilter(image: UIImage, start: Float, end: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageVignetteFilter()
        filter.vignetteStart = CGFloat(start)
        filter.vignetteEnd = CGFloat(end)
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyGrayscaleFilter(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageGrayscaleFilter()
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applySepiaFilter(image: UIImage, intensity: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageSepiaFilter()
        filter.intensity = CGFloat(intensity)
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applySketchFilter(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageSketchFilter()
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyEmbossFilter(image: UIImage, intensity: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageEmbossFilter()
        filter.intensity = CGFloat(intensity)
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyPosterizeFilter(image: UIImage, levels: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImagePosterizeFilter()
        filter.colorLevels = UInt(Int32(levels))
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applySmoothToonFilter(image: UIImage, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageSmoothToonFilter()
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyPolkaDotFilter(image: UIImage, dotScaling: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImagePolkaDotFilter()
        filter.fractionalWidthOfAPixel = CGFloat(dotScaling)
        applyFilter(image: image, filter: filter, completion: completion)
    }

    func applyHighPassFilter(image: UIImage, strength: Float, completion: @escaping (UIImage?) -> Void) {
        let filter = GPUImageHighPassFilter()
        filter.filterStrength = CGFloat(strength)
        applyFilter(image: image, filter: filter, completion: completion)
    }
}
