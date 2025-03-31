//
//  ViewController.swift
//  FileManagerPractice
//
//  Created by Mr. Dharmesh on 31/05/24.
//

import UIKit

//create, read, write, copy, move, delete
class ViewController: UIViewController {
    
    @IBOutlet weak var textView: UITextView!
    var fileName = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    @IBAction func createFolderAction(_ sender: UIButton) {
        createFolder()
    }
    
    @IBAction func createFileAction(_ sender: UIButton) {
        if textView.text == ""{
            let alert  = UIAlertController(title: "Data Empty", message: "Please enter Data", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
        }
        self.fileName = "yourData.txt"
        let status =  FileHandler.shared.createFile(named: fileName, withContent: textView.text)
        if status {
            print("File saved successfully")
        }else{
            let alert  = UIAlertController(title: "Ther file name is exist", message: "Please change file name", preferredStyle: .alert)
            alert.addTextField { textField in
                textField.placeholder = "file Name"
            }
            
            let createAction = UIAlertAction(title: "Save", style: .default) { [weak alert] _ in
                if let fileName = alert?.textFields?[0].text, !fileName.isEmpty {
                    self.fileName = "\(fileName).txt"
                    let status  = FileHandler.shared.createFile(named: self.fileName, withContent: self.textView.text)
                    if status {
                        print("File saved successfully")
                    }else{
                        
                    }
                } else {
                    print("Folder name is empty")
                }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(createAction)
            alert.addAction(cancelAction)
            
            self.present(alert, animated: true, completion: nil)
        }
       
       
    }

    @IBAction func readFileAction(_ sender: UIButton) {
        if let content = FileHandler.shared.readFile(named: fileName) {
            print("File content: \(content)")
        }
    }
    
    @IBAction func writeFileAction(_ sender: UIButton) {
        FileHandler.shared.writeFile(named: fileName, withContent: "Overwritten content")
    }
    
    @IBAction func appendToFileAction(_ sender: UIButton) {
        FileHandler.shared.appendToFile(named: "\(fileName)", withContent: " Updaetd Additional text.")
    }
    
    @IBAction func deleteFileAction(_ sender: UIButton) {
        FileHandler.shared.deleteFile(named: "example.txt")
    }
    
    @IBAction func copyFileAction(_ sender: UIButton) {
        FileHandler.shared.copyFile(from: "example.txt", to: "example_copy.txt")
    }
    
    @IBAction func moveFileAction(_ sender: UIButton) {
        FileHandler.shared.moveFile(from: "example.txt", to: "new_example.txt")
    }
    
    
    @IBAction func saveImageAction(_ sender: UIButton) {
        guard let image = UIImage(named: "Cat") else { return }
        FileHandler.shared.saveImage(named: "Cat.jpg", image: image)
    }
    
    @IBAction func loadImageAction(_ sender: UIButton) {
        if let image = FileHandler.shared.loadImage(named: "Cat.jpg") {
            // Use the loaded image (e.g., display it in an UIImageView)
            print("Image loaded successfully")
        }
    }
    
}
extension ViewController {
    
    func createFolder(){
        
        let alert = UIAlertController(title: "Create Folder", message: "Enter the name of the new folder", preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = "Folder Name"
        }
        
        let createAction = UIAlertAction(title: "Create", style: .default) { [weak alert] _ in
            if let folderName = alert?.textFields?[0].text, !folderName.isEmpty {
                FileHandler.shared.createFolder(named: folderName)
            } else {
                print("Folder name is empty")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(createAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
        
    }
}
