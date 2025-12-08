//
//  ViewController.swift
//  BLEDEMO
//
//  Created by 29_MackbookAir on 15/09/25.
//

import UIKit

class ViewController: UIViewController, BulbPairingDelegate {
    var pairingManager: BulbPairingManager!

    override func viewDidLoad() {
        super.viewDidLoad()
        pairingManager = BulbPairingManager()
        pairingManager.delegate = self
    }

    // MARK: - BulbPairingDelegate
    func pairingDidSucceed(for peripheral: CBPeripheral) {
        print("✅ Pairing success with \(peripheral.name ?? "unknown")")
    }

    func pairingDidFail(for peripheral: CBPeripheral, error: Error?) {
        print("❌ Pairing failed: \(error?.localizedDescription ?? "unknown error")")
    }

    func pairingLog(_ message: String) {
        print("🔹 \(message)")
    }
}



import CoreBluetooth

protocol BulbPairingDelegate: AnyObject {
    func pairingDidSucceed(for peripheral: CBPeripheral)
    func pairingDidFail(for peripheral: CBPeripheral, error: Error?)
    func pairingLog(_ message: String)
}

class BulbPairingManager: NSObject {
    private var centralManager: CBCentralManager!
    private var targetPeripheral: CBPeripheral?
    private var pairingCharacteristic: CBCharacteristic?
    
    weak var delegate: BulbPairingDelegate?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    func startScan() {
        delegate?.pairingLog("Scanning for bulbs...")
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    private func sendPairingRequest() {
        guard let peripheral = targetPeripheral,
              let characteristic = pairingCharacteristic else { return }
        
        // Example: first step (proprietary, replace with real request bytes)
        let request: [UInt8] = [0x01, 0x00]
        let data = Data(request)
        
        delegate?.pairingLog("Sending pairing request: \(request)")
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    private func handleChallenge(_ data: Data) {
        guard let peripheral = targetPeripheral,
              let characteristic = pairingCharacteristic else { return }
        
        let challenge = [UInt8](data)
        delegate?.pairingLog("Received challenge: \(challenge)")
        
        // 🔑 Replace this with your bulb’s real crypto function
        let response = computeAuthResponse(challenge: challenge)
        
        delegate?.pairingLog("Sending response: \(response)")
        peripheral.writeValue(Data(response), for: characteristic, type: .withResponse)
    }
    
    /// Stub function — replace with real crypto/HMAC/AES
    private func computeAuthResponse(challenge: [UInt8]) -> [UInt8] {
        // Example: just reverse bytes (for demo)
        return challenge.reversed()
    }
}

// MARK: - CBCentralManagerDelegate
extension BulbPairingManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == .poweredOn {
            startScan()
        } else {
            delegate?.pairingLog("Bluetooth not ready: \(central.state.rawValue)")
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String : Any],
                        rssi RSSI: NSNumber) {
        // ⚡ Filter by bulb name or service UUID here
        if let name = peripheral.name, name.contains("Hue color lamp") {
            delegate?.pairingLog("Found bulb: \(name)")
            targetPeripheral = peripheral
            centralManager.stopScan()
            centralManager.connect(peripheral, options: nil)
        }
    }
    
    func centralManager(_ central: CBCentralManager,
                        didConnect peripheral: CBPeripheral) {
        delegate?.pairingLog("Connected to bulb")
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager,
                        didFailToConnect peripheral: CBPeripheral,
                        error: Error?) {
        delegate?.pairingDidFail(for: peripheral, error: error)
    }
}

// MARK: - CBPeripheralDelegate
extension BulbPairingManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let services = peripheral.services else { return }
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didDiscoverCharacteristicsFor service: CBService,
                    error: Error?) {
        guard let characteristics = service.characteristics else { return }
        
        for char in characteristics {
            // ⚡ Filter: replace with your bulb’s real pairing characteristic UUID
            if char.properties.contains(.write) && char.properties.contains(.notify) {
                pairingCharacteristic = char
                delegate?.pairingLog("Found pairing characteristic")
                sendPairingRequest()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        guard let data = characteristic.value else { return }
        handleChallenge(data)
    }
    
    func peripheral(_ peripheral: CBPeripheral,
                    didWriteValueFor characteristic: CBCharacteristic,
                    error: Error?) {
        if error == nil {
            delegate?.pairingLog("Write succeeded")
        } else {
            delegate?.pairingLog("Write failed: \(error!.localizedDescription)")
        }
    }
}
