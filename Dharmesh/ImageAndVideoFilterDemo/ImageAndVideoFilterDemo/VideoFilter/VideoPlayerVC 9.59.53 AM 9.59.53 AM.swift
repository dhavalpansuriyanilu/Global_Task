import UIKit
import AVFoundation
import GPUImage

class VideoPlayerVC: UIViewController {
    
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var gpuImageView: GPUImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoProcessing: UIActivityIndicatorView!
    
    @IBOutlet weak var sliderProgress: UISlider!
    
    var player: AVPlayer?
    var playerItem : AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    var gpuMovie: GPUImageMovie?
    var filter: GPUImageOutput?
    var selectedVideo = "Semple1"
    var arrVideos:[String] = ["Semple1","Semple2","Semple3","Semple4"]
    var totalFilters = 21

    let colors: [UIColor] = [
        UIColor.gray,
        UIColor.red,
        UIColor.green,
        UIColor.blue,
        UIColor.orange,
        UIColor.purple,
        UIColor.yellow,
        UIColor.cyan,
        UIColor.magenta,
        UIColor.brown,
        UIColor.green
    ]
    weak var sliderUpdateTimer: Timer?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playSempleVideo()
        
        // Start the activity indicator
        videoProcessing.startAnimating()

        // Play the video after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.videoProcessing.stopAnimating()
           
        }
    }
    
    func setupUI() {
        
        sliderUpdateTimer = Timer.scheduledTimer(
            timeInterval: 0.1,
            target: self,
            selector: #selector(updateSlider),
            userInfo: nil,
            repeats: true
        )
    }
    
    // Updating Slider
    @objc func updateSlider() {
        if let currentTime = player?.currentTime() {
            let currentTimeInSeconds = Float(CMTimeGetSeconds(currentTime))
            sliderProgress.value = currentTimeInSeconds
        }
    }
    //handeling slider ValueChanged
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        
        if let duration = player?.currentItem?.duration.seconds {
            let targetTime = duration * Double(sender.value)
            let time = CMTime(seconds: targetTime, preferredTimescale: 1)
            player?.seek(to: time)
        }
    }
    
    
    func playSempleVideo(){
        let path = Bundle.main.path(forResource: selectedVideo, ofType: "mp4")
        let pathURL = NSURL.fileURL(withPath: path ?? "")
        play(videoURL: pathURL)
    }


    func play(videoURL: URL){

        player = AVPlayer()

        playerItem = AVPlayerItem(url: videoURL)

        player?.replaceCurrentItem(with: playerItem)

        gpuMovie = GPUImageMovie(playerItem: playerItem)
        gpuMovie?.playAtActualSpeed = true

        let defaultFilter = GPUImageFilter()

        gpuMovie?.addTarget(defaultFilter)
        gpuMovie?.playAtActualSpeed = true
        defaultFilter.addTarget(gpuImageView)

        gpuMovie?.startProcessing()
        observeVideoEndAndLoop()//loop video
        
        if let duration = player?.currentItem?.duration {
            let durationInSeconds = Float(CMTimeGetSeconds(duration))
            self.sliderProgress.maximumValue =  durationInSeconds
        }
    }
    
    
    
    func observeVideoEndAndLoop() {
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: nil, queue: nil) { [weak self] _ in
            self?.player?.seek(to: CMTime.zero)
            self?.player?.play()
        }
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
    
    @IBAction func selectVideoFromGallery(_ sender: UIButton) {
        playPauseButton.isSelected = false
        selectVideoFromLibrary()
    }

    
}
extension VideoPlayerVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 2{
//            let itemWidth = collectionView.bounds.size.width
//            let itemHeight = collectionView.bounds.size.height
            return CGSize(width: 100, height: 100)
        }else{
            let itemWidth = collectionView.bounds.size.width
            let itemHeight = collectionView.bounds.size.height
            return CGSize(width: itemWidth, height: itemHeight)
        }
       
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 2{
            return  arrVideos.count
        }else{
            return totalFilters
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 2{
            
            let cell2 = videoCollectionView.dequeueReusableCell(withReuseIdentifier: "videoCollectionCell", for: indexPath) as! videoCollectionCell
            
            cell2.lblVideoName.text = arrVideos[indexPath.item]
            cell2.backgroundColor = .darkGray
            return cell2
        }else{
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "filterCell", for: indexPath) as! videoCollectionViewCell2
            
            if indexPath.item == 0{
                cell.lblFilterName.text = "Normal"
            }else{
                cell.lblFilterName.text = "filter\(indexPath.item)"
            }
           
            cell.backgroundColor = .brown
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
       
        if collectionView.tag == 2{
            selectedVideo = arrVideos[indexPath.item]
            playSempleVideo()
            playPauseButton.isSelected = false
        }else{
            
            switch indexPath.item {
            case 0:
                applyFilter0()
            case 1:
                applyImageHueFilter()
            case 2:
                applyImageSwirlFilter()
            case 3:
                applyBrightnessFilter()
            case 4:
                applyImageSketchFilter()
            case 5:
                applyImageRGBFilter()
            case 6:
                applyImageContrastFilter()
            case 7:
                applyImageSmoothToonFilter()
            case 8:
                applyImageSepiaFilter()
            case 9:
                applyImageGammaFilter()
            case 10:
                applyWeakPixelInclusionFilter()
            case 11:
                applySphereRefractionFilter()
            case 12:
                applyThresholdEdgeDetectionFilter()
            case 13:
                applyZoomBlurFilter()
            case 14:
                applyImageSketchFilter()
            case 15:
                applyImageRGBFilter()
            case 16:
                applyImageContrastFilter()
            case 17:
                applyImageSmoothToonFilter()
            case 18:
                applyImageSepiaFilter()
            case 19:
                applyImageGammaFilter()
            case 20:
                applyWeakPixelInclusionFilter()
                
            default:
                break
            }
        }
    }
    
}
//MARK: - Filters
extension VideoPlayerVC{
    func applySphereRefractionFilter() {
        let filter = GPUImageSphereRefractionFilter()
        filter.radius = 0.25 // Example radius value
        filter.refractiveIndex = 0.71 // Example refractive index value
        applyFilter(filter)
    }
    func applyFilter0() {
    
        let defaultFilter = GPUImageFilter()
        applyFilter(defaultFilter)
    }
    
    func applyZoomBlurFilter() {
        let filter = GPUImageZoomBlurFilter()
        filter.blurSize = 2.0 // Example blur size
        applyFilter(filter)
    }
    
    func applyThresholdEdgeDetectionFilter() {
        let filter = GPUImageThresholdEdgeDetectionFilter()
        applyFilter(filter)
    }
    func applySubtractBlendFilter() {
        let filter = GPUImageSubtractBlendFilter()
        applyFilter(filter)
    }
    
    func applyWeakPixelInclusionFilter() {
        let filter = GPUImageWeakPixelInclusionFilter()
        applyFilter(filter)
    }
    
    func applyImageHueFilter() {
        // Create and apply your first filter
        let filter = GPUImageHueFilter()
        filter.hue = 90.0
        
        applyFilter(filter)
    }

    func applyImageSwirlFilter() {
        // Create and apply your second filter
        let filter = GPUImageSwirlFilter()
        applyFilter(filter)
    }

    func applyBrightnessFilter() {
        // Create and apply your third filter
        let filter = GPUImageBrightnessFilter()
        filter.brightness = 0.5
        
        applyFilter(filter)
    }

    func applyImageSketchFilter() {
        // Create and apply your fifth filter
        let filter = GPUImageSketchFilter()
//        filter.exposure = 1.0
        
        applyFilter(filter)
    }
    
    func applyImageRGBFilter() {
        
        let rgbFilter = GPUImageRGBFilter()
        rgbFilter.red = 1.0
        rgbFilter.green = 0.5
        rgbFilter.blue = 0.2
        applyFilter(rgbFilter)
    }
    
    func applyImageContrastFilter() {
        let contrastFilter = GPUImageContrastFilter()
        contrastFilter.contrast = 2.0
        applyFilter(contrastFilter)
    }
    
    func applyImageSmoothToonFilter() {
        let filter = GPUImageSmoothToonFilter()
        applyFilter(filter)
    }
    
    func applyImageSepiaFilter() {
        let filter = GPUImageSepiaFilter()
        filter.intensity = CGFloat(4.3)
        applyFilter(filter)
    }
    
    func applyImageGammaFilter() {
        let Filter = GPUImageGammaFilter()
        Filter.gamma = CGFloat(5.2)
        applyFilter(Filter)
    }
   
    func applyFilter(_ filter: GPUImageOutput) {
        // Stop the processing before changing the filter
        gpuMovie?.endProcessing()
        
        // Remove existing targets
        gpuMovie?.removeAllTargets()
        
        // Add the new filter
        gpuMovie?.addTarget(filter as? GPUImageInput)
        
        // Add the final filter to the view
        filter.addTarget(gpuImageView)
        
        // Start processing again
        gpuMovie?.startProcessing()
        
        observeVideoEndAndLoop() // Loop video
    }
}

extension VideoPlayerVC: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func selectVideoFromLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) ?? []
        picker.mediaTypes = ["public.movie"]
        picker.videoQuality = .typeHigh
        picker.videoExportPreset = AVAssetExportPresetHEVC1920x1080
        picker.allowsEditing = true
        
        present(picker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true, completion: nil)
        
        guard let movieUrl = info[.mediaURL] as? URL else { return }

        // Print the video URL as a string
        let urlString = movieUrl.absoluteString
        print("Video URL as String: \(urlString)")

        // Play the selected video
        play(videoURL: movieUrl)
    }
}
