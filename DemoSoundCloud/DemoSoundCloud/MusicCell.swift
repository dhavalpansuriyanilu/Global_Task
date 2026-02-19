
import UIKit

class MusicCell: UITableViewCell {

    @IBOutlet weak var imgMusic: UIImageView!
    @IBOutlet weak var lblMusicName: UILabel!

    private var imageTask: URLSessionDataTask?
    private var currentURL: String?

    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgMusic.layer.cornerRadius = 15
        self.imgMusic.contentMode = .scaleAspectFill
        self.imgMusic.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgMusic.image = UIImage(systemName: "music.note.list")
        imageTask?.cancel()
        imageTask = nil
        currentURL = nil
    }

    func setImage(urlString: String) {
        currentURL = urlString
        imgMusic.image = UIImage(systemName: "music.note.list")

        guard let url = URL(string: urlString) else { return }

        imageTask = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard
                let self,
                self.currentURL == urlString,
                let data,
                let image = UIImage(data: data)
            else { return }

            DispatchQueue.main.async {
                self.imgMusic.image = image
            }
        }
        imageTask?.resume()
    }
}
