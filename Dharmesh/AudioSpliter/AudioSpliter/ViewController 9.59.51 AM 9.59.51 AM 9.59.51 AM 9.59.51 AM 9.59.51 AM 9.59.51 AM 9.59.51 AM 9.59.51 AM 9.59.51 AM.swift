import UIKit
import Replicate
import AVFoundation
import MobileCoreServices


enum AudioType {
    case vocal
    case accompaniment
}

//        self.input = ["audio": "https://replicate.delivery/pbxt/JQ94NFDmAHgvF5p13iZKYrc9VpCDjtA5n8tvO05jzUsg7TPN/Lay%20All%20Your%20Love%20On%20Me%20-%20ABBA.mp3"]
   // "https://www.learningcontainer.com/wp-content/uploads/2020/02/Kalimba.mp3"

class ViewController: UIViewController {
    let replicate = Replicate.Client(token: "r8_JIHIUrxqzo2LhTm6GwWfRFFjwKK0qTw0L3WHk")
    
    var input: [String: String] = [:]
    var localFilePath : URL?
    var vocalName : String = ""
    var accompanimentName : String = ""
    var vocal : String = ""
    var accompaniment : String = ""
    var audioPlayer: AVAudioPlayer!
    var uniqueFileName : String = ""
    
    @IBOutlet var slider: UISlider! // Add UISlider IBOutlet
    weak var sliderUpdateTimer: Timer?

    
    @IBOutlet weak var loader: UIActivityIndicatorView!
    @IBOutlet weak var lblStatus: UILabel!
    @IBOutlet weak var playBtn: UIButton!
    @IBOutlet weak var play2Btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loader.isHidden = true
        lblStatus.isHidden = true
        self.play2Btn.isEnabled = false
        self.playBtn.isEnabled = false
        setupUI()
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
    
    //Updating Slider
    @objc func updateSlider(){
        slider.value = Float(audioPlayer?.currentTime ?? 0)
    }
    
    
    @IBAction func spleatAudio(_ sender: UIButton) {
        selectAudio()
        DispatchQueue.main.async {
            self.lblStatus.isHidden = true
        }
        
    }
    
    //PlayVocal
    @IBAction func playVocal(_ sender: UIButton) {
        
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                playBtn.setTitle("Play", for: .normal)
            }else{
               
            }
        } else {
            print("Error: audioPlayer is nil")
        }

        print(vocal)
        guard let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(vocalName) else {
            print("Error: File not found.")
            return
        }
        
        playDownloadedFile(at: destinationURL)
        play2Btn.setTitle("Play", for: .normal)
        playBtn.setTitle("Pause", for: .normal)
        slider.maximumValue = Float(audioPlayer?.duration ?? 0)
    }
    
    //PlayAccompaniment
    @IBAction func playAccompaniment(_ sender: UIButton) {
       
        playBtn.setTitle("Play", for: .normal)
        
        if let audioPlayer = audioPlayer {
            if audioPlayer.isPlaying {
                audioPlayer.stop()
                
                play2Btn.setTitle("Play", for: .normal)
            }else{
               
            }
        } else {
            print("Error: audioPlayer is nil")
        }

        print(accompaniment)
        guard let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(accompanimentName) else {
            print("Error: File not found.")
            return
        }
        
        playBtn.setTitle("Play", for: .normal)
        play2Btn.setTitle("Pause", for: .normal)
        playDownloadedFile(at: destinationURL)
    }
   

}

//MARK: - input and Output Functionality
extension ViewController {
    func inputAudio(from url: URL) {
        localFilePath = url

        // Convert the local file path to a URI
        guard let fileURI = localFilePath?.absoluteString else {
            print("Error: Unable to create URI from file path.")
            return
        }
        
        // Remove unnecessary characters from the fileURI
        let formattedURI = fileURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        // Update the input dictionary with the URI
        self.input = ["audio": formattedURI]
        
        Task {
            do {
                try await spleeteInVocalsAndaccompaniment()
                
            } catch {
                print("Input Error: \(error)")
            }
        }
    }

    
    func spleeteInVocalsAndaccompaniment() async {
        do {
            // Call the run function from the replicate module
            let output = try await replicate.run(
                "soykertje/spleeter:cd128044253523c86abfd743dea680c88559ad975ccd72378c8433f067ab5d0a",
                input: self.input
            )
            
//            replicate.run(<#T##identifier: Identifier##Identifier#>, input: <#T##Decodable & Encodable#>)
            var strVocal = (output?.objectValue?["vocals"] as! Value).stringValue!
            
            var strAccompaniment = (output?.objectValue?["accompaniment"] as! Value).stringValue!
            
            downloadFiles(from: strVocal, type: .vocal)
            downloadFiles(from: strAccompaniment, type: .accompaniment)
            
        } catch {
            self.loader.stopAnimating()
            self.lblStatus.text = "Something error..."
            lblStatus.textColor = .red
            self.lblStatus.isHidden = false
            print("Output Error: \(error)")
        }
    }
}

//MARK: -  Audio Selection Functionality
extension ViewController: UIDocumentPickerDelegate {
    
    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
        print("Document picker was cancelled.")
    }
    
    func selectAudio() {
        let documentPicker = UIDocumentPickerViewController(documentTypes: [String(kUTTypeAudio)], in: .import)
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }

    // MARK: - UIDocumentPickerDelegate

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        guard let selectedURL = urls.first else {
            print("No file selected.")
            return
        }
        
        // Process the selected audio file URL
        inputAudio(from: selectedURL)
        self.loader.isHidden = false
        self.loader.startAnimating()
    }

}

//MARK: - Audio download Functionality
extension ViewController {
    func downloadFiles(from url: String,type:AudioType) {
        guard let fileURL = URL(string: url) else {
            print("Error: Invalid URL")
            return
        }
        if type == .vocal{
            vocal = fileURL.lastPathComponent
            uniqueFileName = UUID().uuidString + "_" + vocal // Append a unique identifier to the file name
            vocalName = uniqueFileName
        }else{
            accompaniment = fileURL.lastPathComponent
            uniqueFileName = UUID().uuidString + "_" + accompaniment // Append a unique identifier to the file name
            accompanimentName = uniqueFileName
        }
        
        
        
        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent(uniqueFileName)
                
        
        let session = URLSession.shared
        let downloadTask = session.downloadTask(with: fileURL) { (tempURL, response, error) in
            if let tempURL = tempURL, error == nil {
                do {
                    try FileManager.default.moveItem(at: tempURL, to: destinationURL)
                    print("File downloaded successfully: \(destinationURL)")
                    DispatchQueue.main.async {
                        self.loader.stopAnimating()
                        self.lblStatus.isHidden = false
                        self.play2Btn.isEnabled = true
                        self.playBtn.isEnabled = true
                        self.lblStatus.textColor = .green
                    }
                } catch {
                    print("Error saving file: \(error)")
                }
            } else {
                print("Error downloading file: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
        
        downloadTask.resume()
    }
    
    func playDownloadedFile(at url: URL) {
        
        do {
            // Initialize audio player with the downloaded file URL
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            // Prepare to play the audio
            audioPlayer.prepareToPlay()
            // Play the audio
            audioPlayer.play()
        
        } catch {
            print("Error playing audio: \(error.localizedDescription)")
        }
    }
}
