//
//  ViewController1.swift
//  AudioSpliter
//
//  Created by Mr. Dharmesh on 02/05/24.
//

import UIKit

class ViewController1: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

       
    }
    
    @IBAction func ServerAudioSpleateAction(_ sender: UIButton) {
        let vc = (storyboard?.instantiateViewController(identifier: "ViewController") as? ViewController)
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    @IBAction func localAudioSpleateAction(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(identifier: "ViewController2") as? ViewController2
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
   

}
