//
//  ViewController.swift
//  AlertDemo
//
//  Created by 41_MacBook_Air on 13/05/25.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var button: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.layer.cornerRadius = 12
    }

    @IBAction func showAlert(_ sender: UIButton) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "AlertViewController") as! AlertViewController
        vc.modalPresentationStyle = .custom
        present(vc, animated: true)
    }

}

