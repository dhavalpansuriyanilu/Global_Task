//
//  PhotoAndVideoOpen.swift
//  PermissionManagerDemo
//
//  Created by Mr. Dharmesh on 03/06/24.
//

import UIKit
import Photos
import BSImagePicker

class PhotoAndVideoOpen: UIViewController {
   
    @IBOutlet weak var bntSelectImageVideo: UIButton!
    @IBOutlet weak var selectionSegment: UISegmentedControl!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var selectedImages : [UIImage] = []
    var selectedVideos:[URL] = []
    var mediaType:ContentType = .images
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MediaSelectionManager.shared.contentType = .images
    }
    
    
    @IBAction func selectionTypeSegment(_ sender: UISegmentedControl) {
        
        if sender.selectedSegmentIndex == 0{
            MediaSelectionManager.shared.contentType = .images
            mediaType = .images
            bntSelectImageVideo.setTitle("Select Images", for: .normal)
            collectionView.reloadData()
        }else{
            MediaSelectionManager.shared.contentType = .videos
            mediaType = .videos
            bntSelectImageVideo.setTitle("Select Videos", for: .normal)
            collectionView.reloadData()
        }
    }
    
    @IBAction func selectDataAction(_ sender: UIButton) {

        MediaSelectionManager.shared.mediaSelection(form: self, type: self.mediaType, quantity: 5)
        MediaSelectionManager.shared.completionHandler = { mediaContent in
            if MediaSelectionManager.shared.contentType == .images {
                if let images = mediaContent as? [UIImage] {
                    print("After Total Images: \(mediaContent.count)")
                    self.selectedImages.append(contentsOf: images)
                    print("After Total Images: \(self.selectedImages.count)")
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            } else if MediaSelectionManager.shared.contentType == .videos {
                if let videos = mediaContent as? [URL] {
                    self.selectedVideos.append(contentsOf: videos)
                    print("After Total Images: \(self.selectedVideos.count)")
                    DispatchQueue.main.async {
                        self.collectionView.reloadData()
                    }
                }
            }
        }
    }
}


extension PhotoAndVideoOpen : UICollectionViewDelegate , UICollectionViewDataSource , UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let size = (collectionView.frame.size.width-10)/2 //here dividing the collection cell in two part
        return CGSize(width: size, height: size + 80)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if MediaSelectionManager.shared.contentType == .images{
            return selectedImages.count
        }else{
            return selectedVideos.count
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionCell", for: indexPath) as! collectionCell
        if MediaSelectionManager.shared.contentType == .images {
            cell.configure(with: selectedImages[indexPath.item])
        } else {
            cell.configure(with: selectedVideos[indexPath.item])
        }
        
        return cell
    }
    
    
}
