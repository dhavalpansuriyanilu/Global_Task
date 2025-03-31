//
//  ImageViewController.swift
//  CustomNotification
//
//  Created by MacBook_Air_41 on 16/10/24.
//

import UIKit

//class ImageViewController: UIViewController {
//    
//    var imageView: UIImageView!
//    var imageToShow: UIImage?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        view.backgroundColor = .black.withAlphaComponent(0.0)
//        
//        imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
//        imageView.center = view.center
//        imageView.contentMode = .scaleAspectFit
//        imageView.image = imageToShow
//        imageView.alpha = 0.0
//        view.addSubview(imageView)
//        
//        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
//            self.imageView.frame = self.view.bounds
//            self.imageView.center = self.view.center
//            self.imageView.alpha = 1.0
//            self.view.backgroundColor = .black.withAlphaComponent(0.0)
//        }, completion: nil)
//        
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
//        view.addGestureRecognizer(tapGesture)
//    }
//    
//    @objc func dismissImage() {
//        // Reverse the animation to shrink the image and fade out
//        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
//            self.imageView.frame = CGRect(x: self.view.center.x - 5, y: self.view.center.y - 5, width: 10, height: 10)
//            self.imageView.alpha = 0.0
//            self.view.backgroundColor = .black.withAlphaComponent(0.0)
//        }) { _ in
//            self.dismiss(animated: false, completion: nil)
//        }
//    }
//}


class ImageViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView! 
    @IBOutlet weak var viewBg: UIView!

    
    var imageToShow: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black.withAlphaComponent(0.0)
        
        // Set the image to show
        imageView.image = imageToShow
        imageView.alpha = 0.0
        
        // Animate image view
        UIView.animate(withDuration: 1.5, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [.curveEaseInOut], animations: {
            self.imageView.frame = self.view.bounds
            self.imageView.center = self.view.center
            self.imageView.alpha = 1.0
            self.view.backgroundColor = .black.withAlphaComponent(0.0)
        }, completion: nil)
        
        // Configure title and subtitle
        titleLabel.text = "Nature"
        subtitleLabel.numberOfLines = 2
        subtitleLabel.text = "Nature is the purest portal to inner-peace."
        
        // Add tap gesture for dismissing the image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissImage))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.layer.cornerRadius = 20
    }
    
    @objc func dismissImage1() {
        // Reverse the animation to shrink the image and fade out
        UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
            self.viewBg.frame = CGRect(x: self.view.center.x - 5, y: self.view.center.y - 5, width: 10, height: 10)
            self.viewBg.alpha = 0.0
            self.view.backgroundColor = .black.withAlphaComponent(0.0)
        }) { _ in
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    @objc func dismissImage() {
           UIView.animate(withDuration: 1.5, delay: 0, options: [.curveEaseInOut], animations: {
               self.viewBg.alpha = 0.0
               self.view.backgroundColor = .black.withAlphaComponent(0.0)
           }) { _ in
               self.dismiss(animated: false, completion: nil) 
           }
       }

}
