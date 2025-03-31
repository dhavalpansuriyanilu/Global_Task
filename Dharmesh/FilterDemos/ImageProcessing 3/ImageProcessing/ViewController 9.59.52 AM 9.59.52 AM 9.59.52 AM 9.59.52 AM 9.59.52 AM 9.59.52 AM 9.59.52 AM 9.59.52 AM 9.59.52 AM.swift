//
//  ViewController.swift
//  ImageProcessing
//
//  Created by Developer 1 on 07/11/23.
//

import UIKit
import GPUImage
import AdvancedActionSheet


class ViewController: UIViewController {
    
    @IBOutlet weak var lblSelectImg: UILabel!
    
    @IBOutlet weak var imageProcessing: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var filters: [GPUImageOutput] = [
            GPUImageSmoothToonFilter(),
            GPUImageGrayscaleFilter(),
            GPUImageSepiaFilter(),
            GPUImageSketchFilter(),
            GPUImageEmbossFilter(),
            GPUImagePosterizeFilter(),
            GPUImageVignetteFilter(),
            GPUImageHueFilter(),
            GPUImageHighPassFilter(),
            GPUImagePolkaDotFilter()
        ]
    
//    var filters: [GPUImageOutput] = [
//            GPUImageBrightnessFilter(),
//            GPUImageExposureFilter(),
//            GPUImageContrastFilter(),
//            GPUImageSaturationFilter(),
//            GPUImageGammaFilter(),
//            GPUImageLevelsFilter(),
//            GPUImageColorMatrixFilter(),
//            GPUImageRGBFilter(),
//            GPUImageHueFilter(),
//            GPUImageWhiteBalanceFilter()
//        ]
//
    var arrImage: [String] = ["Image1","Image2","Image3","Image4","Image5"]
    
    var filterArrayName: [String] = ["filter1","filter2","filter3","filter4","filter5","filter6","filter7","filter8","filter9","filter10"]
    
    let filterColors: [UIColor] = [
        UIColor.red,
        UIColor.blue,
        UIColor.green,
        UIColor.orange,
        UIColor.purple,
        UIColor.orange,
        UIColor.systemRed,
        UIColor.yellow,
        UIColor.systemPink,
        UIColor.systemBlue
    ]
    
    @IBOutlet weak var img1: UIImageView!
    var originalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func selectImgAction(_ sender: UIButton) {
        selectImage()
    }
    
    
    @IBAction func normalImgAction(_ sender: UIButton) {
        if let originalImage = originalImage {
            img1.image = originalImage
        }
    }
    
//    func applyFilterToImages(index: Int) {
//        // Ensure that you have an input image (e.g., inputImage is your UIImage)
//        guard let inputImage = img1.image else {
//            // Handle the case where there's no image to apply a filter
//            return
//        }
//
//        let filter = filters[index]
//
//        inputImage.performImageOperation(withFilter: filter) { processedImage in
//            DispatchQueue.main.async {
//                if let processedImage = processedImage {
//                    self.img1.image = processedImage
//                    self.imageProcessing.stopAnimating()
//                } else {
//                    // Handle the case where image processing fails
//                }
//            }
//        }
//    }

    
//    func applyFilterToImages(index: Int) {
//        // Ensure you have a valid image in img1
//        guard let inputImage = img1.image else {
//            return
//        }
//
//        inputImage.performImageOperation(withFilterIndex: index) { filteredImage in
//            DispatchQueue.main.async {
//                self.img1.image = filteredImage
//                self.imageProcessing.stopAnimating()
//            }
//        }
//    }
    
}

extension ViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
    func selectImage(){

        let alert = AdvancedActionSheet()
        alert.addAction(item: .normal(id: 0, title: "Open Gallery", completionHandler: { (_) in
            // User tapped on this action, do appropriate tasks
            alert.dismiss(animated: true)
            print("Open Gallery tapped")
            self.openGallery()
            
        }))
        alert.addAction(item: .normal(id: 1, title: "Open Camera", completionHandler: { (_) in
            // User tapped on this action, do appropriate tasks
            alert.dismiss(animated: true)
            self.openCamera()
            
        }))
        
        alert.present(presenter: self, completion: nil)
    }

    
    func openGallery() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        img1.image = selectedImage
        lblSelectImg.isHidden = true
        // Set the original image
        originalImage = selectedImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func showImageAlert() {
        let alert = UIAlertController(title: "No Image Selected", message: "Please select an image from the gallery first.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }

}


extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = collectionView.bounds.size.width
        let itemHeight = collectionView.bounds.size.height
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filterArrayName.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionCell", for: indexPath) as! FilterCollectionCell
        
        cell.lblFilterName.text = filterArrayName[indexPath.item]
        cell.backgroundColor = filterColors[indexPath.item]
        return cell
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
            // Handle filter selection when a collection view cell is tapped

            // Check which filter option was selected
            let filterIndex = indexPath.item

            // Load the original image (adjust this according to your image source)
            guard let originalImage = img1.image else {
                // Handle the case where there's no image to apply a filter
                return
            }

            // Apply the selected filter based on the index
            switch filterIndex {
            case 0:
                applyBrightnessFilter(image: originalImage, brightness: 0.5) { filteredImage in
                    DispatchQueue.main.async {
                        self.img1.image = filteredImage
                    }
                }
            case 1:
                applyExposureFilter(image: originalImage, exposure: 2.0) { filteredImage in
                    DispatchQueue.main.async {
                        self.img1.image = filteredImage
                    }
                }
            case 2:
                applySaturationFilter(image: originalImage, saturation: 2.0) { filteredImage in
                    DispatchQueue.main.async {
                        self.img1.image = filteredImage
                    }
                }
            case 3:
                applyGammaFilter(image: originalImage, gamma: 2.0) { filteredImage in
                    DispatchQueue.main.async {
                        self.img1.image = filteredImage
                    }
                }
            case 4:
                applyContrastFilter(image: originalImage, contrast: 2.0) { filteredImage in
                    DispatchQueue.main.async {
                        self.img1.image = filteredImage
                    }
                }

            default:
                break
            }
        }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        print(indexPath.item)
//
//        if let image = img1.image {
//            // An image is set, so apply the filter
//            self.imageProcessing.startAnimating()
//            applyFilterToImages(index: indexPath.item)
//        } else {
//            // No image is set, so show an alert
//            showImageAlert()
//        }
//    }
}
extension ViewController{
    func applyBrightnessFilter(image: UIImage, brightness: Float, completion: @escaping (UIImage?) -> Void) {
        let brightnessFilter = GPUImageBrightnessFilter()
        brightnessFilter.brightness = CGFloat(brightness) // Adjust the brightness (between -1.0 and 1.0)

        applyFilter(image: image, filter: brightnessFilter, completion: completion)
    }

    func applyExposureFilter(image: UIImage, exposure: Float, completion: @escaping (UIImage?) -> Void) {
        let exposureFilter = GPUImageExposureFilter()
        exposureFilter.exposure = CGFloat(exposure) // Adjust the exposure (between -10.0 and 10.0)

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
    
    func applyFilterToImages(index: Int) {
            // Ensure that you have an input image (e.g., inputImage is your UIImage)
            guard let inputImage = img1.image else {
                // Handle the case where there's no image to apply a filter
                return
            }

            let filter = filters[index]

            applyFilter(image: inputImage, filter: filter) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        }
    
    func applyFilter(image: UIImage, filter: GPUImageOutput, completion: @escaping (UIImage?) -> Void) {
            let processImg = image
            let picture = GPUImagePicture(image: processImg)

        picture?.addTarget(filter as! GPUImageInput)

            filter.useNextFrameForImageCapture()
        picture?.processImage {
                let processedImage = filter.imageFromCurrentFramebuffer()
                completion(processedImage)
            }
        }
}
