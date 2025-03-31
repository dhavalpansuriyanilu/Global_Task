//
//  VideoFilterVC.swift
//  ImageProcessing
//
//  Created by Developer 1 on 08/11/23.
//

import UIKit
import GPUImage
import AVFoundation
import AVKit

class VideoFilterVC: UIViewController {
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    @IBOutlet weak var playerView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let videoURL = Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4") {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = playerView.bounds
            playerView.layer.addSublayer(playerLayer!)
            player?.play()
        }
    }
}

//class VideoFilterVC: UIViewController {
//    var playerLayer: AVPlayerLayer?
//    var player: AVPlayer?
//    var isLoop: Bool = false
//
//    @IBOutlet weak var playerView: UIView!
    
//
//
//    var filter: GPUImageOutput!
//    var movie: GPUImageMovie!
//    var brightnessFilter: GPUImageBrightnessFilter!
////    var filterView: GPUImageView!
//
//    @IBOutlet weak var filterView: GPUImageView!
//    var selectedFilterIndex = 0
//    @IBOutlet weak var collectionView: UICollectionView!
//
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        let videoURL = Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4") // Replace with your video file
//
//
//    }
//}
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.configureNew(url: urlNew.clipPath.absoluteString)
//    }
//    // Create a method to apply the selected filter
//    func applyFilterToVideo() {
//        // Check if a filter is selected
//        if selectedFilterIndex >= 0 && selectedFilterIndex < filters.count {
//            // Remove previous targets and create a new filter
//            movie.removeAllTargets()
//            let selectedFilter = filters[selectedFilterIndex]
//
//            // Set up the filter and target
//            selectedFilter.addTarget(filterView)
//            movie.addTarget(selectedFilter as! GPUImageInput)
//        }
//    }
//
//    func configureNew(url: String) {
//        if let videoURL = URL(string: url) {
//            player = AVPlayer(url: videoURL)
//            playerLayer = AVPlayerLayer(player: player)
//            playerLayer?.frame = playerView.bounds
//            playerLayer?.videoGravity = .resizeAspectFill
//            if let playerLayer = self.playerLayer {
//                playerView.layer.addSublayer(playerLayer)
////                player?.play()
//            }
//            NotificationCenter.default.addObserver(self, selector: #selector(reachTheEndOfTheVideo(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
//        }
//    }
//
//}
//
////MARK: - Collection view Delegate and DataSource
//extension VideoFilterVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//
//        let itemWidth = collectionView.bounds.size.width
//        let itemHeight = collectionView.bounds.size.height
//        return CGSize(width: itemWidth, height: itemHeight)
//
//    }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//
//        return filters.count
//    }
//
//    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//
//
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCollectionViewCell2", for: indexPath) as! videoCollectionViewCell2
//
//        cell.lblFilterName.text = "filter\(indexPath.item)"
//        cell.backgroundColor = .brown
//        return cell
//
//    }
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        // Set the selected filter based on the index
//        filter = filters[indexPath.item]
//
//        // Apply the filter to the video
//        applyFilterToVideo()
//    }
//
//
//}
