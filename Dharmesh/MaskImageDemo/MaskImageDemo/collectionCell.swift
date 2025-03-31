//
//  collectionCell.swift
//  MaskImageDemo
//
//  Created by Mr. Dharmesh on 03/06/24.
//

import UIKit
import AVFoundation
import AVKit

class collectionCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var playButton: UIButton!
    
    var videoURL: URL?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    
    func configure(with image: UIImage?) {
        imageView.image = image
        playButton.isHidden = true
    }
    
    func configure(with videoURL: URL) {
        self.videoURL = videoURL
        imageView.image = generateThumbnail(for: videoURL)
        //UIImage(named: "SourceImage3")
        //generateThumbnail(for: videoURL)
        playButton.isHidden = false
    }
    
    func generateThumbnail(for videoURL: URL) -> UIImage? {
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1, preferredTimescale: 60) // Get the thumbnail at 1 second mark
        var thumbnail: UIImage?
        do {
            let cgImage = try generator.copyCGImage(at: time, actualTime: nil)
            thumbnail = UIImage(cgImage: cgImage)
        } catch let error {
            print("Error generating thumbnail: \(error.localizedDescription)")
        }
        return thumbnail
    }
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        if let videoURL = videoURL {
            let player = AVPlayer(url: videoURL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            UIApplication.shared.keyWindow?.rootViewController?.present(playerViewController, animated: true) {
                playerViewController.player?.play()
            }
        }
    }
}
