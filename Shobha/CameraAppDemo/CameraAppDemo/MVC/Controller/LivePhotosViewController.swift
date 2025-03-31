//
//  LivePhotosViewController.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 23/09/24.
//

import UIKit
import Photos
import PhotosUI

class LivePhotosViewController: UIViewController {
    
    @IBOutlet weak var liveImgCollectionView: UICollectionView!
    var imgArr = [UIImage]()
    var capturedImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
}


extension LivePhotosViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return capturedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LiveImageCollectionCell", for: indexPath) as! LiveImageCollectionCell
        let livePhotoURL = capturedImages[indexPath.item]
        cell.liveImage.image = livePhotoURL
        cell.liveImage.contentMode = .scaleAspectFit
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width)/3, height: collectionView.bounds.size.width)
    }
        
}




class LiveImageCollectionCell: UICollectionViewCell {
    @IBOutlet weak var liveImage: UIImageView!
}

