import UIKit
import AVFoundation
import GPUImage

class VideoPlayerVC: UIViewController {
    @IBOutlet weak var videoCollectionView: UICollectionView!
    @IBOutlet weak var gpuImageView: GPUImageView!
    @IBOutlet weak var playPauseButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var videoProcessing: UIActivityIndicatorView!
    var player: AVPlayer?
    var playerItem : AVPlayerItem?
    var playerLayer: AVPlayerLayer?
    var gpuMovie: GPUImageMovie?
    var filter: GPUImageOutput?
    var selectedVideo = "Semple1"
    var arrVideos:[String] = ["Semple1","Semple2","Semple3"]
    var totalFilters = 11
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Start the activity indicator
        videoProcessing.startAnimating()
        self.play()
        // Play the video after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.videoProcessing.stopAnimating()
           
        }
    }
    
    func play() {
        
        let path = Bundle.main.path(forResource: selectedVideo, ofType: "mp4")
        player = AVPlayer()
        let pathURL = NSURL.fileURL(withPath: path!)
        
        playerItem = AVPlayerItem(url: pathURL)
        
        player?.replaceCurrentItem(with: playerItem)
        
        gpuMovie = GPUImageMovie(playerItem: playerItem)
        gpuMovie?.playAtActualSpeed = true
        
        let defaultFilter = GPUImageFilter()

        gpuMovie?.addTarget(defaultFilter)
        gpuMovie?.playAtActualSpeed = true
        defaultFilter.addTarget(gpuImageView)
        
        gpuMovie?.startProcessing()
        observeVideoEndAndLoop()//loop video
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
           
            cell.backgroundColor = colors[indexPath.item]
            
            return cell
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 2{
            selectedVideo = arrVideos[indexPath.item]
            play()
        }else{
            
            switch indexPath.item {
            case 0:
                applyFilter0()
            case 1:
                applyFilter1()
            case 2:
                applyFilter2()
            case 3:
                applyFilter3()
            case 4:
                applyFilter4()
            case 5:
                applyFilter5()
            case 6:
                applyFilter6()
            case 7:
                applyFilter7()
            case 8:
                applyFilter8()
            case 9:
                applyFilter9()
            case 10:
                applyFilter10()
                
            default:
                break
            }
        }
    }
    
}
//MARK: - Filters
extension VideoPlayerVC{
    
    func applyFilter0() {
        let defaultFilter = GPUImageFilter()
        applyFilter(defaultFilter)
    }
    func applyFilter1() {
        // Create and apply your first filter
        let filter = GPUImageHueFilter()
        filter.hue = 90.0
        
        applyFilter(filter)
    }

    func applyFilter2() {
        // Create and apply your second filter
        let filter = GPUImageGrayscaleFilter()
        applyFilter(filter)
    }

    func applyFilter3() {
        // Create and apply your third filter
        let filter = GPUImageBrightnessFilter()
        filter.brightness = 0.5
        
        applyFilter(filter)
    }

    func applyFilter4() {
        // Create and apply your fourth filter
        let filter = GPUImageContrastFilter()
        filter.contrast = 2.0
        
        applyFilter(filter)
    }

    func applyFilter5() {
        // Create and apply your fifth filter
        let filter = GPUImageSketchFilter()
//        filter.exposure = 1.0
        
        applyFilter(filter)
    }
    
    func applyFilter6() {
        
        let rgbFilter = GPUImageRGBFilter()
        rgbFilter.red = 1.0
        rgbFilter.green = 0.5
        rgbFilter.blue = 0.2
        applyFilter(rgbFilter)
    }
    
    func applyFilter7() {
        let contrastFilter = GPUImageContrastFilter()
        contrastFilter.contrast = 2.0
        applyFilter(contrastFilter)
    }
    func applyFilter8() {
        let filter = GPUImageSmoothToonFilter()
        applyFilter(filter)
    }
    func applyFilter9() {
        let filter = GPUImageSepiaFilter()
        filter.intensity = CGFloat(4.3)
        applyFilter(filter)
    }
    func applyFilter10() {
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

        // Work with the video URL
        print("Selected Video URL: \(movieUrl)")
    }
    
    // Your existing code...
}
