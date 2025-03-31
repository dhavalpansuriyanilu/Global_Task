//
//  GalleryViewController.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 25/09/24.
//


import UIKit
import AVKit
import AVFoundation
import ImageViewer_swift

enum MemoryAlbum {
    case photo
    case video
}

class GalleryViewController: UIViewController {
    @IBOutlet weak var imgCollectionView: UICollectionView!
    @IBOutlet weak var viewOption: UIView!
    @IBOutlet weak var btnPhoto: UIButton!
    @IBOutlet weak var btnVedio: UIButton!
    
    var capturedVideos: [URL] = []
    var capturedImages: [UIImage] = []
    var currentMemoryAlbum: MemoryAlbum = .photo
    var videoURL: URL?
    var selectedIndexPath: IndexPath?
    var imageURLMapping: [UIImage: URL] = [:]
    var videoFileNames: [String] = []
    var capturedImageURLs: [URL] = []


    var isPhoto = false
    
    var imgArray: [UIImage] = [
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
        UIImage(named: "user")!,
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadImagesFromDocumentsDirectory()
        loadVideos()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        updateUserDefaults()
        loadVideos()

    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        DispatchQueue.main.async {
            self.viewOption.setShadow(radius: self.viewOption.frame.height / 2, shadowRadius: 3, corner: [.layerMaxXMaxYCorner,.layerMaxXMinYCorner,.layerMinXMaxYCorner,.layerMinXMinYCorner], color: .lightGray)
    
            roundCorners(baseview: self.btnPhoto, corners: .allCorners, radius: self.btnPhoto.frame.height / 2)
            roundCorners(baseview: self.btnVedio, corners: .allCorners, radius: self.btnVedio.frame.height / 2)

            if self.isPhoto {
                self.btnPhoto.backgroundColor = .black
                self.btnPhoto.setTitleColor(UIColor(hex: "#FEA532"), for: .normal)
                self.btnVedio.setTitleColor(.black, for: .normal)
            }
        }
    }
    
    @IBAction func backButtonTapped(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnPhotoTapped(_ sender: UIButton) {
        isPhoto = true
        currentMemoryAlbum = .photo
        btnPhoto.backgroundColor = .black
        btnPhoto.setTitleColor(UIColor(hex: "#FEA532"), for: .normal)
        
        btnVedio.backgroundColor = .clear
        btnVedio.setTitleColor(.black, for: .normal)
        imgCollectionView.reloadData()
    }
    
    @IBAction func videoButtonTapped(_ sender: UIButton) {
        isPhoto = false
        currentMemoryAlbum = .video
        btnVedio.backgroundColor = .black
        btnVedio.setTitleColor(UIColor(hex: "#FEA532"), for: .normal)

        btnPhoto.backgroundColor = .clear
        btnPhoto.setTitleColor(.black, for: .normal)
        imgCollectionView.reloadData()
    }
    
    func loadVideos() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return
        }
        let videoFolderURL = documentsDirectory.appendingPathComponent("Videos")
        do {
            let videoFiles = try fileManager.contentsOfDirectory(at: videoFolderURL, includingPropertiesForKeys: nil)
            capturedVideos = videoFiles.filter { $0.pathExtension == "mov" }
            videoFileNames = capturedVideos.map { $0.lastPathComponent }
            print("Videos loaded: \(videoFileNames)")
            imgCollectionView.reloadData()
        } catch {
            print("Error loading videos: \(error.localizedDescription)")
        }
    }
    
    @objc func deleteButtonTapped(_ sender: UIButton) {
        guard let button = sender as? UIButton else { return }
        if let cell = button.superview?.superview as? GalleryCell {
            switch currentMemoryAlbum {
            case .photo:
            
                if let indexPath = imgCollectionView.indexPath(for: cell) {
                    let imageURLToDelete = capturedImageURLs[indexPath.item]
                    
                    capturedImages.remove(at: indexPath.item)
                    capturedImageURLs.remove(at: indexPath.item)
                    
                    let fileManager = FileManager.default
                    do {
                        try fileManager.removeItem(at: imageURLToDelete)
                        print("Image deleted successfully: \(imageURLToDelete)")
                    } catch {
                        print("Error deleting image: \(error.localizedDescription)")
                    }
                    imgCollectionView.deleteItems(at: [indexPath])
                }
            case .video:
                if let videoURL = cell.videoURL, let index = capturedVideos.firstIndex(of: videoURL) {
                    capturedVideos.remove(at: index)
                    let fileManager = FileManager.default
                    do {
                        try fileManager.removeItem(at: videoURL)
                        print("Video deleted successfully: \(videoURL)")
                    } catch {
                        print("Error deleting video: \(error.localizedDescription)")
                    }
                    imgCollectionView.reloadData()
                }
            }
        }
    }
 
    func updateUserDefaults() {
        let recordedVideoURLs = capturedVideos.map { $0.absoluteString }
        UserDefaults.standard.set(recordedVideoURLs, forKey: "recordedVideoURLs")
        
        let savedImagesData = capturedImages.compactMap { $0.pngData() }
        UserDefaults.standard.set(savedImagesData, forKey: "savedImages")
    }

    
    private func playVideo(url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        present(playerViewController, animated: true) {
            player.play()
        }
    }
    
    func loadImagesFromDocumentsDirectory() {
        let fileManager = FileManager.default
        guard let documentsDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            print("Could not access documents directory")
            return
        }
        let imagesFolderURL = documentsDirectory.appendingPathComponent("Images")
        do {
            let imageFiles = try fileManager.contentsOfDirectory(at: imagesFolderURL, includingPropertiesForKeys: nil)
            let imageURLs = imageFiles.filter { $0.pathExtension == "jpg" }
            
            // Load images as UIImage objects
            capturedImages = imageURLs.compactMap { UIImage(contentsOfFile: $0.path) }
            capturedImageURLs = imageURLs
            
            print("Loaded images: \(capturedImageURLs.map { $0.lastPathComponent })")
            imgCollectionView.reloadData() // Reload collection view to display the images
        } catch {
            print("Error loading images: \(error.localizedDescription)")
        }
    }

    func getVideoThumbnail(url: URL) -> UIImage? {
        //let url = url as URL
        let request = URLRequest(url: url)
        let cache = URLCache.shared
        if let cachedResponse = cache.cachedResponse(for: request), let image = UIImage(data: cachedResponse.data) {
            return image
        }
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.maximumSize = CGSize(width: 250, height: 120)
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        var image: UIImage?
        
        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            image = UIImage(cgImage: cgImage)
        } catch { }
        
        if let image = image, let data = image.pngData(), let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil) {
            let cachedResponse = CachedURLResponse(response: response, data: data)
            cache.storeCachedResponse(cachedResponse, for: request)
        }
        return image
    }
}


extension GalleryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch currentMemoryAlbum {
        case .photo:
            return capturedImages.count
        case .video:
            return capturedVideos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GalleryCell", for: indexPath) as! GalleryCell
        cell.imageIndex = indexPath.item
        switch currentMemoryAlbum {
        case .photo:
            cell.imgCat.image = capturedImages[indexPath.item]
            cell.imgCat.setupImageViewer(
                images: capturedImages,
                initialIndex: indexPath.item)
            cell.btnDelete.tag = indexPath.item
            cell.imgCat.isUserInteractionEnabled = true
        case .video:
            let videoURL = capturedVideos[indexPath.item]
            cell.imgCat.image = getVideoThumbnail(url: videoURL)
            cell.videoURL = videoURL
            cell.videoIndex = indexPath.item
            cell.imgCat.isUserInteractionEnabled = false
        }
        cell.btnDelete.addTarget(self, action: #selector(deleteButtonTapped(_:)), for: .touchUpInside)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedIndexPath = indexPath
        switch currentMemoryAlbum {
        case .photo:
            print("Selected item at index: \(indexPath.item)")
        case .video:
            let videoURL = capturedVideos[indexPath.item]
            playVideo(url: videoURL)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = (collectionView.frame.size.width-20)/3
        return CGSize(width: size, height: size)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
}

extension GalleryViewController: AVPlayerViewControllerDelegate {
    func playerViewControllerDidDismiss(_ playerViewController: AVPlayerViewController) {
        // Optionally handle any additional cleanup when the player is dismissed
        print("Video player dismissed")
        dismiss(animated: true)
    }
}

class GalleryCell : UICollectionViewCell {
    @IBOutlet weak var imgDelete: UIImageView!
    @IBOutlet weak var viewBgCell: UIView!
    @IBOutlet weak var imgblackBg: UIImageView!
    @IBOutlet weak var imgCat:UIImageView!
    @IBOutlet weak var viewShadow: UIView!
    @IBOutlet weak var blurView: UIImageView!
    @IBOutlet weak var btnDelete: UIButton!
    var imageIndex: Int?
    var videoURL: URL?
    var videoIndex: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.cornerRadius = 15
        imgCat.layer.cornerRadius = 15
        roundCorners(baseview: self.btnDelete, corners: .allCorners, radius: self.btnDelete.frame.height / 2)
    }
}
