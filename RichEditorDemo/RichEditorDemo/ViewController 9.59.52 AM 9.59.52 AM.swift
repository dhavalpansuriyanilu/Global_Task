//
//  ViewController.swift
//  RichEditorDemo
//
//  Created by 29_MackbookAir on 20/09/24.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var newScript: UIView!


    let editorViewController = EditorViewController()

    override func viewDidLoad() {
        super.viewDidLoad()

        editorViewController.translatesAutoresizingMaskIntoConstraints = false
        newScript.addSubview(editorViewController)
        NSLayoutConstraint.activate([
            editorViewController.topAnchor.constraint(equalTo: newScript.topAnchor),
            editorViewController.leadingAnchor.constraint(equalTo: newScript.leadingAnchor),
            editorViewController.trailingAnchor.constraint(equalTo: newScript.trailingAnchor),
            editorViewController.bottomAnchor.constraint(equalTo: newScript.bottomAnchor)
        ])
    }
    
    @IBAction func gettext(_ sender: UIButton){
        let item = editorViewController.editor.html
        print(item)
        editorViewController.editor.html = ""
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
            self.editorViewController.editor.html = item
        }
    }
}

