//
//  HomeVC.swift
//  ImageProcessing
//
//  Created by Developer 1 on 09/11/23.
//

import UIKit
import GPUImage
import AVFoundation

class HomeVC: UIViewController {
    
   
    var videoCamera:GPUImageVideoCamera?
    var filter:GPUImagePixellateFilter?
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
       
    }
        
    @IBAction func openCamera(_ sender: UIButton) {
        print("No input")
//        videoCamera = GPUImageVideoCamera(sessionPreset: AVCaptureSession.Preset.hd1280x720.rawValue, cameraPosition: .back)
//        videoCamera?.outputImageOrientation = .portrait
//
//        filter = GPUImagePixellateFilter()
//
//        videoCamera?.addTarget(filter)
//        filter?.addTarget(self.view as? GPUImageView)
//
//        videoCamera?.startCapture()
    }
}
