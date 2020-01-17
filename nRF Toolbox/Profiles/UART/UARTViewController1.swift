//
//  UARTViewController1.swift
//  nRF Toolbox
//
//  Created by Nick Kibish on 30.12.2019.
//  Copyright © 2019 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

class UARTViewController1: UIViewController {

    let btManager = BluetoothManager()
    
    private lazy var connectBtn = UIBarButtonItem(title: "Connect", style: .done, target: self, action: #selector(openConnectorViewController))
    
    @IBOutlet private var peripheralView: PeripheralView!
    @IBOutlet private var collectionView: UARTCommandListCollectionView!
    private var commands: [UARTCommandModel] = Array.init(repeating: EmptyModel(), count: 9)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        btManager.delegate = self
        btManager.logger = self
        navigationItem.rightBarButtonItem = connectBtn
        
        commands[5] = TextCommand(text: "Play", image: "Play")
        let data = "ay".data(using: .ascii)!
        commands[7] = DataCommand(data: data, image: "Pause")
        
        navigationItem.title = "UART"
        
        peripheralView.disconnect()
        peripheralView.delegate = self
        
        collectionView.commandListDelegate = self
    }
    
    @objc func openConnectorViewController() {
        let scanner = PeripheralScanner(services: nil)
        let connectionController = ConnectionViewController(scanner: scanner)
        connectionController.delegate = self

        let nc = UINavigationController.nordicBranded(rootViewController: connectionController)
        nc.modalPresentationStyle = .formSheet

        self.present(nc, animated: true, completion: nil)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
    }
}

extension UARTViewController1: ConnectionViewControllerDelegate {
    func connected(to peripheral: Peripheral) {
        btManager.connectPeripheral(peripheral: peripheral.peripheral)
    }
}

extension UARTViewController1: BluetoothManagerDelegate {
    
    func didConnectPeripheral(deviceName aName: String?) {
        guard let presented = presentedViewController,
            let scannerNC = presented as? UINavigationController,
            let scanner = scannerNC.viewControllers.first as? ConnectionViewController else {
            return
        }
        
        scanner.dismiss(animated: true, completion: nil)
        navigationItem.rightBarButtonItem?.isEnabled = false
        peripheralView.connected(peripheral: aName ?? "No Name")
    }
    
    func didDisconnectPeripheral() {
        navigationItem.rightBarButtonItem?.isEnabled = true
        peripheralView.disconnect()
    }
    
    func peripheralReady() {
        
    }
    
    func peripheralNotSupported() {
        // MARK: Show Alert
        peripheralView.disconnect()
        navigationItem.rightBarButtonItem?.isEnabled = true
    }
}

extension UARTViewController1: Logger {
    func log(level aLevel: LOGLevel, message aMessage: String) {
        Log(category: .ble, type: .debug).log(message: aMessage)
    }
}

extension UARTViewController1: UARTNewCommandDelegate {
    func createdNewCommand(_ command: UARTCommandModel) {
        guard let selectedItemIndex = collectionView.indexPathsForSelectedItems?.first?.item else {
            return
        }
        
        commands[selectedItemIndex] = command
        collectionView.commands = commands
        collectionView.reloadData()
        dismiss(animated: true, completion: nil)
    }
    
}

extension UARTViewController1: PeripheralViewDelegate {
    func requestConnect() {
        self.openConnectorViewController()
    }
}

extension UARTViewController1: UARTCommandListDelegate {
    func selectedCommand(_ command: UARTCommandModel) {
        guard !(command is EmptyModel) else {
            let vc = UARTNewCommandViewController()
            vc.delegate = self
            let nc = UINavigationController.nordicBranded(rootViewController: vc, prefersLargeTitles: false)
            self.present(nc, animated: true)
            return
        }
        
        guard btManager.isConnected() else {
            openConnectorViewController()
            return
        }
        
        btManager.send(command: command)
    }
}
