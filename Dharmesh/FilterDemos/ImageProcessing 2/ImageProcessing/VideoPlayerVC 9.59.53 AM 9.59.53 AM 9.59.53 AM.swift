import UIKit
import AVFoundation
import GPUImage

class VideoPlayerVC: UIViewController {
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    @IBOutlet weak var gpuImageView: GPUImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var filterCollectionView: UICollectionView!
    
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var movie: GPUImageMovie?
    var filter: GPUImageOutput?
    var selectedFilter: GPUImageFilter?
    var videoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        playPauseButton.isHidden = true
        videoURL = Bundle.main.url(forResource: "SampleVideo", withExtension: "mp4")
        
        setupFilterChain()
        displayVideo()
        observeVideoEndAndLoop()
    }
    
    func setupFilterChain() {

        filter = GPUImageSaturationFilter()
        filter?.addTarget(gpuImageView)

        // Create the GPUImageMovie and set up the filter chain
        movie = GPUImageMovie(url: videoURL)
        movie?.playAtActualSpeed = true
        movie?.addTarget(filter as? GPUImageInput)
    }
    func observeVideoEndAndLoop() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
    }

    
    func displayVideo() {
        DispatchQueue.main.async {
            self.movie?.startProcessing()
        }
        // Add the observer for looping
           observeVideoEndAndLoop()
    }
    
    
    func switchFilterTo(filter: GPUImageOutput) {
        // Remove the previous filter from the filter chain
        self.filter?.removeAllTargets()
        
        // Set the new filter and add it to the filter chain
        self.filter = filter
        filter.addTarget(gpuImageView)
        
        // Add the updated filter to the existing movie object
        movie?.removeAllTargets()
        movie?.addTarget(filter as! GPUImageInput)
    }
    
    
    @objc func stopVideoPlayback() {
        player?.pause()
    }
    
    @IBAction func playPauseAction(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            player?.pause()
        } else {
            sender.isSelected = true
            player?.play()
        }
    }
    
    func applyFilterToVideo(_ filter: GPUImageOutput) {
        // Show the activity indicator
        activityIndicator.startAnimating()
        
        movie?.removeAllTargets()
        movie?.addTarget(filter as! GPUImageInput)
        filter.addTarget(gpuImageView)
        
        // Set a frame processing completion block
        filter.frameProcessingCompletionBlock = { [weak self] output, time in
            // Hide the activity indicator when frame processing is complete
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
            }
        }
        
        movie?.startProcessing()
    }
    
    
    @IBAction func filterAction(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            print("filter1")
            let saturationFilter = GPUImageSaturationFilter()
            saturationFilter.saturation = 1.5
            switchFilterTo(filter: saturationFilter)
        case 2:
            print("filter2")
            let whiteBalanceFilter = GPUImageWhiteBalanceFilter()
            whiteBalanceFilter.temperature = 5000
            whiteBalanceFilter.tint = 50
            switchFilterTo(filter: whiteBalanceFilter)
        case 3:
            print("filter3")
            let hueFilter = GPUImageHueFilter()
            hueFilter.hue = 90.0
            switchFilterTo(filter: hueFilter)
        case 4:
            print("filter4")
            let rgbFilter = GPUImageRGBFilter()
            rgbFilter.red = 1.0
            rgbFilter.green = 0.5
            rgbFilter.blue = 0.2
            switchFilterTo(filter: rgbFilter)
        case 5:
            print("filter5")
            let contrastFilter = GPUImageContrastFilter()
            contrastFilter.contrast = 2.0
            switchFilterTo(filter: contrastFilter)
        default:
            break
        }
    }
    
    
}
