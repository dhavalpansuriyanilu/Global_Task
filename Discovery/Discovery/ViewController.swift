//
//  ViewController.swift
//  Discovery
//
//  Created by 29_MackbookAir on 12/09/25.
//

import UIKit
import GCXMulticastDNSKit

class ViewController: UIViewController, DiscoveryDelegate {
    func discoveryDidDiscover(service: GCXMulticastDNSKit.DiscoveryService) {
        print("discovered: \(service)")
    }
    
    func discoveryDidFail(configuration: GCXMulticastDNSKit.DiscoveryConfiguration, error: GCXMulticastDNSKit.DiscoveryError) {
        print("failed: \(error.localizedDescription)")
    }
    
    func discoveryDidDisappear(service: GCXMulticastDNSKit.DiscoveryService) {
        print("disappear: \(service)")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let config = DiscoveryConfiguration(serviceType: "_lnp._tcp", serviceNamePrefix: "local network")
        let discovery = Discovery(with: [config], delegate: self)
    }
}
