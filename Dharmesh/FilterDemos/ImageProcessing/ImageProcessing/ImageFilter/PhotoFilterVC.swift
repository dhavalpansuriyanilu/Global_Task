//
//  ViewController.swift
//  ImageProcessing
//
//  Created by Developer 1 on 07/11/23.
//

import UIKit
import GPUImage
import AdvancedActionSheet


class PhotoFilterVC: UIViewController {
    
    @IBOutlet weak var lblSelectImg: UILabel!
    @IBOutlet weak var brightnessSlider: UISlider!
    
    @IBOutlet weak var imageProcessing: UIActivityIndicatorView!
    @IBOutlet weak var collectionView: UICollectionView!


    var arrImage: [String] = ["Image1","Image2","Image3","Image4","Image5"]
    
    let filters: [GPUImageOutput] = [
        GPUImageBrightnessFilter(),
        GPUImageExposureFilter(),
        GPUImageContrastFilter(),
        GPUImageSaturationFilter(),
        GPUImageGammaFilter(),
        GPUImageLevelsFilter(),
        GPUImageColorMatrixFilter(),
        GPUImageRGBFilter(),
        GPUImageHueFilter(),
        GPUImageWhiteBalanceFilter(),
        GPUImageGrayscaleFilter(),
        GPUImageSepiaFilter(),
        GPUImageSketchFilter(),
        GPUImageEmbossFilter(),
        GPUImageSmoothToonFilter()
    ]
    
    var selectedFilterIndex = 0
    
    @IBOutlet weak var img1: UIImageView!
    var originalImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Config theme (colors):
        AdvancedActionSheetConfigs.configColors(text: UIColor.black,alertBackground: UIColor.white)
        brightnessSlider.isHidden = true
        
    }
    
    
    @IBAction func brightnessSliderValueChanged(_ sender: UISlider) {
        
        let sliderValue = sender.value/100

        
    }
    
    
    @IBAction func selectImgAction(_ sender: UIButton) {
        selectImage()

    }
    
    
    @IBAction func normalImgAction(_ sender: UIButton) {
        
        if let originalImage = originalImage {
            img1.image = originalImage
            brightnessSlider.value = 0
        }
    }
}

//MARK: - Image Selection
extension PhotoFilterVC : UINavigationControllerDelegate, UIImagePickerControllerDelegate{
    
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
//        brightnessSlider.isHidden = false
    }
    
    func openCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        //imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
//        brightnessSlider.isHidden = false
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

//MARK: - Collection view Delegate and DataSource
extension PhotoFilterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let itemWidth = collectionView.bounds.size.width
        let itemHeight = collectionView.bounds.size.height
        return CGSize(width: itemWidth, height: itemHeight)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionCell", for: indexPath) as! FilterCollectionCell
        
        cell.lblFilterName.text = "filter\(indexPath.item)"
        cell.backgroundColor = .brown
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      
//        guard img1.image != nil else {
//            showImageAlert()
//               return
//        }
        brightnessSlider.value = 0
        // Check which filter option was selected
        let filterIndex = indexPath.item
        selectedFilterIndex = indexPath.item
        
        
        // Apply the selected filter based on the index
        switch selectedFilterIndex {
        case 0:
            FilterManager.shared.applyBrightnessFilter(image: originalImage!, brightness: 0.5) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 1:
            FilterManager.shared.applyExposureFilter(image: originalImage!, exposure: 0.5) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 2:
            FilterManager.shared.applySaturationFilter(image: originalImage!, saturation: 50) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 3:
            FilterManager.shared.applyGammaFilter(image: originalImage!, gamma: 50) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 4:
            FilterManager.shared.applyContrastFilter(image: originalImage!, contrast: 50) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 5:
            FilterManager.shared.applyRGBFilter(image: originalImage!, red: 70, green: 10, blue: 33) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 6:
            FilterManager.shared.applyHueFilter(image: originalImage!, hue: 50) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 7:
            FilterManager.shared.applyWhiteBalanceFilter(image: originalImage!, temperature: 50, tint:50){ filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 8:
            brightnessSlider.isHidden = true
            FilterManager.shared.applyGrayscaleFilter(image: originalImage!) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 9:
            FilterManager.shared.applySepiaFilter(image: originalImage!, intensity: 30) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 10:
            brightnessSlider.isHidden = true
            FilterManager.shared.applySketchFilter(image: originalImage!) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 11:
            FilterManager.shared.applyEmbossFilter(image: originalImage!, intensity: 40) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 12:
            brightnessSlider.isHidden = true
            FilterManager.shared.applySmoothToonFilter(image: originalImage!) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        case 13:
            FilterManager.shared.applySaturationFilter(image: originalImage!, saturation: 50) { filteredImage in
                DispatchQueue.main.async {
                    self.img1.image = filteredImage
                }
            }
        default:
            break
        }
        
    }
}
