import IQAudioRecorderController

class CustomAudioRecorderViewController: IQAudioRecorderViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        // Create and configure the background image view
        if let bgImage = UIImage(named: "ic_scary_audio_bg") {
            let imageView = UIImageView(image: bgImage)
            imageView.frame = view.bounds
            imageView.contentMode = .scaleAspectFill
            
            // Create a transparent background view
            let backgroundView = UIView(frame: view.bounds)
            backgroundView.addSubview(imageView)
            backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            // Add the background view behind the visual effect view
            if let visualEffectView = view.subviews.first(where: { $0 is UIVisualEffectView }) {
                view.insertSubview(backgroundView, belowSubview: visualEffectView)
            } else {
                // If UIVisualEffectView is not found, add background view to the main view
                view.addSubview(backgroundView)
            }
        } else {
            print("Image not found")
        }
    }
}
