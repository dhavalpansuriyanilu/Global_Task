//
//  CustomViewController.swift
//  AudioRecordDemo
//
//  Created by MacBook_Air_41 on 01/08/24.
//

import UIKit
import IQAudioRecorderController

class CustomViewController: UIViewController {

    override func presentBlurredAudioRecorderViewControllerAnimated(_ audioRecorderViewController: IQAudioRecorderViewController) {
          // Enable blur effect
//          audioRecorderViewController.blurrEnabled = true
          
          // Create a UINavigationController with the audio recorder view controller
          let navigationController = UINavigationController(rootViewController: audioRecorderViewController)
          
          // Customize toolbar
          navigationController.isToolbarHidden = false
          navigationController.toolbar.isTranslucent = true
          navigationController.toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
          navigationController.toolbar.setShadowImage(UIImage(), forToolbarPosition: .any)
          
          // Customize navigation bar
          navigationController.navigationBar.isTranslucent = true
          navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
          navigationController.navigationBar.shadowImage = UIImage()
          
          // Set presentation style and transition
          navigationController.modalPresentationStyle = .overCurrentContext
          navigationController.modalTransitionStyle = .crossDissolve
          
          // Refresh UI of audio recorder view controller
          audioRecorderViewController.barStyle = audioRecorderViewController.barStyle
          
          // Add background image to the audio recorder view controller
          if let bgImage = UIImage(named: "ic_scary_audio_bg") {
              let imageView = UIImageView(image: bgImage)
              imageView.frame = audioRecorderViewController.view.bounds
              imageView.contentMode = .scaleAspectFill
              
              // Add imageView to the content view of the visual effect view
              if let visualEffectView = audioRecorderViewController.view.subviews.first(where: { $0 is UIVisualEffectView }) as? UIVisualEffectView {
                  visualEffectView.contentView.addSubview(imageView)
                  visualEffectView.contentView.sendSubviewToBack(imageView)
              } else {
                  // If UIVisualEffectView is not found, add imageView directly to the view
                  audioRecorderViewController.view.addSubview(imageView)
                  audioRecorderViewController.view.sendSubviewToBack(imageView)
              }
          } else {
              print("Background image not found")
          }
          
          // Present the view controller
          present(navigationController, animated: false, completion: nil)
      }
    

   
}
