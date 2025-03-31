//
//  ViewController.swift
//  RokuSocket
//
//  Created by 29_MackbookAir on 18/02/25.
//

import UIKit
import Network
import CommonCrypto

class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var btnConnect: UIButton!
    @IBOutlet var txtIP: UITextField!

    var isActive = false
    var isConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if !isActive{
            isActive = true
            connectToSocket()
        }
    }
    
    func connectToSocket(){
        if txtIP.text?.isEmpty ?? false{
            return
        }
        RokuWebSocketManager.shared.configureRokuWebSocket(ip: txtIP.text ?? "") { status ,deviceinfo in
            if status{
                self.isConnected = true
                self.updateButtonName()
                print("Connected:- \(deviceinfo)")
            }else{
                self.isConnected = false
                self.updateButtonName()
                print("Failed")
            }
        }
    }

    
    func updateButtonName(){
        DispatchQueue.main.async {
            self.btnConnect.setTitle(self.isConnected ? "Disconnect" : "Connect", for: .normal)
        }
    }
    
    @IBAction func longPressStartAction(sender: UIButton){
        RokuWebSocketManager.shared.longPressButtonEvent(event: .down, isLongPress: true)
    }
    
    @IBAction func longPressEndAction(sender: UIButton){
        RokuWebSocketManager.shared.longPressButtonEvent(event: .down, isLongPress: false)
    }
    
    @IBAction func upAction(sender: UIButton){
        RokuWebSocketManager.shared.sendButtonEvent(event: .up)
    }
    
    @IBAction func downAction(sender: UIButton){
        RokuWebSocketManager.shared.sendButtonEvent(event: .down)
    }
    
    @IBAction func leftAction(sender: UIButton){
        RokuWebSocketManager.shared.sendButtonEvent(event: .left)
    }
    
    @IBAction func rightAction(sender: UIButton){
        RokuWebSocketManager.shared.sendButtonEvent(event: .right)
    }
    
    @IBAction func enterAction(sender: UIButton){
        RokuWebSocketManager.shared.sendButtonEvent(event: .select)
    }
    
    @IBAction func homeAction(sender: UIButton){
        RokuWebSocketManager.shared.sendButtonEvent(event: .home)
    }
    
    @IBAction func backAction(sender: UIButton){
        RokuWebSocketManager.shared.sendButtonEvent(event: .back)
    }
    
    @IBAction func disconnectAction(sender: UIButton){
        if isConnected{
            RokuWebSocketManager.shared.disconnectSocket()
        }else{
            self.connectToSocket()
        }
    }
    
    @IBAction func appsAction(sender: UIButton){
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "AppsListVC") as? AppsListVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Dismiss keyboard
        return true
    }

}

