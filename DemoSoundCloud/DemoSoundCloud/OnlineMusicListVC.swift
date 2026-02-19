import UIKit
import AVKit
import WebKit

// MARK: - View Controller
class OnlineMusicListVC: UIViewController {
    
    private let tableView = UITableView()
    private let spinner = UIActivityIndicatorView(style: .large)
    var player: AVPlayer?
    var isPlaying = false

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "SoundCloud Love Tracks"
        view.backgroundColor = .white
        
        setupTableView()
        setupSpinner()
        
        showLoader(true)
        SoundCloudService.shared.fetchTracks { [weak self] in
            self?.showLoader(false)
            print("TotalCount: \(SoundCloudService.shared.tracks.count)")
            self?.tableView.reloadData()
        }
    }
    
    @IBAction func btnpress(_ sender: UIButton){
    }
    
    private func setupTableView() {
        tableView.frame = view.bounds
        tableView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(
            UINib(nibName: "MusicCell", bundle: nil),
            forCellReuseIdentifier: "MusicCell"
        )

        view.addSubview(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.tableView.reloadData()
    }
    private func setupSpinner() {
        spinner.hidesWhenStopped = true
        spinner.center = view.center
        view.addSubview(spinner)
    }
    
    private func showLoader(_ show: Bool) {
        DispatchQueue.main.async {
            if show {
                self.spinner.startAnimating()
            } else {
                self.spinner.stopAnimating()
            }
        }
    }
}
extension OnlineMusicListVC: UITableViewDataSource, UITableViewDelegate { 
    // MARK: - TableView DataSource & Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SoundCloudService.shared.tracks.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(
            withIdentifier: "MusicCell",
            for: indexPath
        ) as! MusicCell

        let track = SoundCloudService.shared.tracks[indexPath.row]

        cell.lblMusicName.text = track.musicName
        cell.setImage(urlString: track.musicImage)
        return cell
    }

    func startStop(webView: WKWebView){
        DispatchQueue.main.asyncAfter(deadline: .now() + 10){
            if self.isPlaying{
                self.isPlaying = false
                let js = """
                var btn = document.querySelector('.playControls__play');
                if(btn && btn.classList.contains('playing')){ btn.click(); }
                """
                webView.evaluateJavaScript(js, completionHandler: nil)
            }else{
                self.isPlaying = true
                let js = """
                var btn = document.querySelector('.playControls__play');
                if(btn && btn.classList.contains('playing') === false){ btn.click(); }
                """
                webView.evaluateJavaScript(js, completionHandler: nil)
            }
            self.startStop(webView: webView)
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let track = SoundCloudService.shared.tracks[indexPath.row]
        if let url = URL(string: track.musicUrl) {
            let webView = WKWebView(frame: self.view.bounds)
            self.view.addSubview(webView)
            webView.load(URLRequest(url: url))
            self.isPlaying = true
            self.startStop(webView: webView)
        }
        
        

//        play(track: track)
//        let streamURL = URL(string:track.musicUrl)!
//
//        let headers = [
//            "Authorization": "OAuth \(SoundCloudService.shared.accessToken ?? "")"
//        ]
//
//        let asset = AVURLAsset(
//            url: streamURL,
//            options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
//        )
//        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
//        try? AVAudioSession.sharedInstance().setActive(true)
//
//        let item = AVPlayerItem(asset: asset)
//        item.addObserver(self,
//                         forKeyPath: "status",
//                         options: [.new, .old],
//                         context: nil)
//
//        let player = AVPlayer(playerItem: item)
//        player.play()
//
//        SoundCloudService.shared.getTrackToPlay(track: track){ url in
//            DispatchQueue.main.async {
//                if let destinationURL = url {
//                    let player = AVPlayer(url: destinationURL)
//                    let playerVC = AVPlayerViewController()
//                    playerVC.player = player
//                    self.present(playerVC, animated: true) { 
//                        player.play() 
//                    }
//                }else{
//                    print("Something went wrong while downloading the track")
//                }
//            }
//        }
    }
    func play(track: MusicModel) {
        
        if let url = URL(string: track.musicUrl) {
            let webView = WKWebView(frame: self.view.bounds)
            self.view.addSubview(webView)
            webView.load(URLRequest(url: url))
        }

        let streamURL = URL(string: track.musicUrl)!

        let headers = [
            "Authorization": "OAuth \(SoundCloudService.shared.accessToken!)"
        ]

        let asset = AVURLAsset(
            url: streamURL,
            options: ["AVURLAssetHTTPHeaderFieldsKey": headers]
        )

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        let item = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: item)
        self.player?.play()
    }

    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == "status" {
            let item = object as! AVPlayerItem
            if item.status == .failed {
                print("❌ Player error:", item.error?.localizedDescription ?? "unknown")
            } else if item.status == .readyToPlay {
                print("✅ Ready to play")
            }
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        
        if position > contentHeight - frameHeight - 300 {
            showLoader(true)
            SoundCloudService.shared.fetchTracks { [weak self] in
                self?.showLoader(false)
                self?.tableView.reloadData()
            }
        }
    }
}
