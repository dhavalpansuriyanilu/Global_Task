//
//  VerticaleScrollVC.swift
//  CameraAppDemo
//
//  Created by MacBook_Air_41 on 23/09/24.
//

import UIKit


class VerticalScrollVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var centerView: UIView!


    let colors: [UIColor] = [.green, .blue, .red, .orange,.green, .blue, .red, .orange,.green, .blue, .red, .orange,.green, .blue, .red, .orange,.green, .blue, .red, .orange,.green, .blue, .red, .orange,.green, .blue, .red, .orange]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        centerView.layer.masksToBounds = false
        centerView.layer.cornerRadius = centerView.frame.height / 2
        centerView.borderColor = .white
        centerView.borderWidth = 2
    }
}

extension VerticalScrollVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ColoredCell", for: indexPath) as! ColoredCell
        cell.backgroundColor = colors[indexPath.item]
        cell.layer.cornerRadius = cell.frame.height / 2
        return cell
    }

    // MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // Handle cell tap if needed
    }
}

class ColoredCell: UICollectionViewCell {

}
