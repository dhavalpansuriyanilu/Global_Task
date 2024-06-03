//
//  FileHandler.swift
//  FileManagerPractice
//
//  Created by Mr. Dharmesh on 01/06/24.
//
import Foundation
import Foundation
import UIKit

class FileHandler {
    static let shared = FileHandler()
    
    private var currentFolder: URL?
    
    private init() { }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func getCurrentFolderURL() -> URL? {
        guard let folder = currentFolder else {
            print("Current folder is not set")
            return nil
        }
        return folder
    }
    
    func setCurrentFolder(named folderName: String) {
        let folderURL = getDocumentsDirectory().appendingPathComponent(folderName)
        currentFolder = folderURL
    }
    
    func createFolder(named folderName: String) {
        let folderURL = getDocumentsDirectory().appendingPathComponent(folderName)
        
        if FileManager.default.fileExists(atPath: folderURL.path) {
            print("Folder is already FolderExists")
        }else{
            do {
                try FileManager.default.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
                print("Folder created successfully")
                setCurrentFolder(named: folderName)
            } catch {
                print("Failed to create folder: \(error)")
            }
        }
        
    }
    
    func createFile(named fileName: String, withContent content: String) -> Bool {
        guard let folderURL = getCurrentFolderURL() else { return false}
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        if FileManager.default.fileExists(atPath: fileURL.path){
            print("File is already fileExists")
            return false
        }else{
            do {
                try content.write(to: fileURL, atomically: true, encoding: .utf8)
                print("File created successfully")
                return true
            } catch {
                print("Failed to create file: \(error)")
                return false
            }
        }
    }
    
    func readFile(named fileName: String) -> String? {
        guard let folderURL = getCurrentFolderURL() else { return nil }
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        do {
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            return content
        } catch {
            print("Failed to read file: \(error)")
            return nil
        }
    }
    
    func writeFile(named fileName: String, withContent content: String) {
        createFile(named: fileName, withContent: content)
    }
    
    func appendToFile(named fileName: String, withContent content: String) {
        guard let folderURL = getCurrentFolderURL() else { return }
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        do {
            if let fileHandle = FileHandle(forWritingAtPath: fileURL.path) {
                fileHandle.seekToEndOfFile()
                if let data = content.data(using: .utf8) {
                    fileHandle.write(data)
                }
                fileHandle.closeFile()
                print("Data appended successfully")
            } else {
                print("File not found")
            }
        } catch {
            print("Failed to append data: \(error)")
        }
    }
    
    func deleteFile(named fileName: String) {
        guard let folderURL = getCurrentFolderURL() else { return }
        let fileURL = folderURL.appendingPathComponent(fileName)
        
        do {
            try FileManager.default.removeItem(at: fileURL)
            print("File deleted successfully")
        } catch {
            print("Failed to delete file: \(error)")
        }
    }
    
    func copyFile(from sourceFileName: String, to destinationFileName: String) {
        guard let folderURL = getCurrentFolderURL() else { return }
        let sourceURL = folderURL.appendingPathComponent(sourceFileName)
        let destinationURL = folderURL.appendingPathComponent(destinationFileName)
        
        do {
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            print("File copied successfully")
        } catch {
            print("Failed to copy file: \(error)")
        }
    }
    
    func moveFile(from sourceFileName: String, to destinationFileName: String) {
        guard let folderURL = getCurrentFolderURL() else { return }
        let sourceURL = folderURL.appendingPathComponent(sourceFileName)
        let destinationURL = folderURL.appendingPathComponent(destinationFileName)
        
        do {
            try FileManager.default.moveItem(at: sourceURL, to: destinationURL)
            print("File moved successfully")
        } catch {
            print("Failed to move file: \(error)")
        }
    }
    
    func saveImage(named imageName: String, image: UIImage) {
        guard let folderURL = getCurrentFolderURL() else { return }
        let imageURL = folderURL.appendingPathComponent(imageName)
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            print("This Image name is already Exists")
        }else{
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                do {
                    try imageData.write(to: imageURL)
                    print("Image saved successfully")
                } catch {
                    print("Failed to save image: \(error)")
                }
            }
        }
        
    }
    
    func loadImage(named imageName: String) -> UIImage? {
        guard let folderURL = getCurrentFolderURL() else { return nil }
        let imageURL = folderURL.appendingPathComponent(imageName)
        
        do {
            let imageData = try Data(contentsOf: imageURL)
            return UIImage(data: imageData)
        } catch {
            print("Failed to load image: \(error)")
            return nil
        }
    }
}
