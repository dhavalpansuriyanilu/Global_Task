//
//  ImageMaskVC.swift
//  MaskImageDemo
//
//  Created by Mr. Dharmesh on 31/05/24.
//

import UIKit
import CoreImage

class ImageMaskVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageMaskCollectionView: UICollectionView!
    var maskView = UIImageView()
    
    let arrMaskImg = [
        "MaskImage1",
        "MaskImage2",
        "MaskImage3",
        "MaskImage4",
        "MaskImage5",
        "MaskImage6",
        "MaskImage7",
        "MaskImage8",
        "MaskImage9",
        "MaskImage10",
        "MaskImage11",
        "MaskImage12",
        "MaskImage13",
        "MaskImage14",
        "MaskImage15",
        "MaskImage16",
        "MaskImage17",
        "MaskImage18",
        "MaskImage19",
        "MaskImage20",
        "MaskImage21",
        "MaskImage22",
        "MaskImage23",
        "MaskImage24",
        "MaskImage25",
        "MaskImage26",
        "MaskImage27",
        "MaskImage28",
        "MaskImage29",
        "MaskImage30",
        "MaskImage31",
        "MaskImage32",
        "MaskImage33",
        "MaskImage34",
        "MaskImage35",
        "MaskImage36",
        "MaskImage37",
        "MaskImage38",
        "MaskImage39",
        "MaskImage40",
        "hand1",
        "hand2"
       
        ]
    
    var pickedImage : UIImage!
    var isMask = true
    var selecedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        pickedImage = UIImage(named: "SourceImage4")
        imageView.image = pickedImage
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        maskView.frame = imageView.bounds
    }
    
    func applyMask(maskName: String) {
        DispatchQueue.main.async { [self] in
            var newMaskImage: UIImage?
            
            newMaskImage = UIImage(named: maskName)
            
            
            self.imageView.image = pickedImage
            // Remove existing maskView if it exists
            self.maskView.removeFromSuperview()

            if self.isMask {
               
                // Create a new maskView
                self.maskView = UIImageView(frame: self.imageView.bounds)
                self.maskView.image = newMaskImage

                self.imageView.mask = self.maskView
            } else {
                let image  = self.createMaskedImage(originalImage:pickedImage, maskImage: newMaskImage!)

                self.imageView.image = image
            }
        }
    }

    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            isMask = true
        }else{
            isMask = false
        }
    }
    
    //MARK: - With Blur
    func createMaskedImage(originalImage: UIImage, maskImage: UIImage) -> UIImage? {
        guard let ciImage = CIImage(image: originalImage) else { return nil }
        let blurFilter = CIFilter(name: "CIGaussianBlur")
        blurFilter?.setValue(ciImage, forKey: kCIInputImageKey)
        blurFilter?.setValue(5, forKey: kCIInputRadiusKey) // Adjust the blur radius as needed
        
        guard let outputImage = blurFilter?.outputImage else { return nil }
        
        let ciContext = CIContext(options: nil)
        guard let cgImage = ciContext.createCGImage(outputImage, from: ciImage.extent) else { return nil }
        
        let blurredImage = UIImage(cgImage: cgImage, scale: originalImage.scale, orientation: originalImage.imageOrientation)
        
        let originalSize = originalImage.size
        
        UIGraphicsBeginImageContextWithOptions(originalSize, false, originalImage.scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        // Flip the context to handle the upside-down issue
        context.translateBy(x: 0, y: originalSize.height)
        context.scaleBy(x: 1.0, y: -1.0)
        
        // Draw the blurred image
        context.draw(blurredImage.cgImage!, in: CGRect(origin: .zero, size: originalSize))
        
        // Create a mask from the mask image
        guard let maskCgImage = maskImage.cgImage else { return nil }
        
        // Draw the mask image over the blurred image
        context.clip(to: CGRect(origin: .zero, size: originalSize), mask: maskCgImage)
        
        // Apply the mask by clearing the masked area
        context.clear(CGRect(origin: .zero, size: originalSize))
        
        // Get the new image
        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return maskedImage
    }


    //MARK: -Without Blur
//    func createMaskedImage(originalImage: UIImage, maskImage: UIImage) -> UIImage? {
//        let originalSize = originalImage.size
//        let maskSize = maskImage.size
//        
//        UIGraphicsBeginImageContextWithOptions(originalSize, false, originalImage.scale)
//        guard let context = UIGraphicsGetCurrentContext() else { return nil }
//        
//        // Flip the context to handle the upside-down issue
//        context.translateBy(x: 0, y: originalSize.height)
//        context.scaleBy(x: 1.0, y: -1.0)
//        
//        // Draw the original image
//        context.draw(originalImage.cgImage!, in: CGRect(origin: .zero, size: originalSize))
//        
//        // Create a mask from the mask image
//        guard let maskCgImage = maskImage.cgImage else { return nil }
//        
//        // Draw the mask image over the original image
//        context.clip(to: CGRect(origin: .zero, size: originalSize), mask: maskCgImage)
//        
//        // Apply the mask by clearing the masked area
//        context.clear(CGRect(origin: .zero, size: originalSize))
//        
//        // Get the new image
//        let maskedImage = UIGraphicsGetImageFromCurrentImageContext()
//        UIGraphicsEndImageContext()
//        
//        return maskedImage
//    }

    
    @IBAction func btnSelectImageAction(_ sender: UIButton) {
        openGallery()
    }
    
}

extension ImageMaskVC : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrMaskImg.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = imageMaskCollectionView.dequeueReusableCell(withReuseIdentifier: "ImageMaskCell", for: indexPath) as! ImageMaskCell
        
        let img = arrMaskImg[indexPath.row]
//        print("\(String(indexPath.row)) \(img)")
        
        cell.imgMask.image = UIImage(named: img)
        
        cell.lblNo.text = String(indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let img = arrMaskImg[indexPath.row]
        selecedIndex = indexPath.row
        applyMask(maskName: img)
    }
}
extension ImageMaskVC : UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func openGallery(){
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .fullScreen
            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.present(imagePicker, animated: true, completion: nil)
        }
        
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[.originalImage] as? UIImage {
            self.pickedImage = pickedImage
            imageView.image = pickedImage
        }
        
        picker.dismiss(animated: true, completion:{[self]in})
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:{[self]in})
        
    }
}

class ImageMaskCell : UICollectionViewCell {
    
    @IBOutlet weak var imgMask: UIImageView!
    @IBOutlet weak var lblNo: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
}
