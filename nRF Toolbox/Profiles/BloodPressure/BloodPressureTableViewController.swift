//
//  BloodPressureTableViewController.swift
//  nRF Toolbox
//
//  Created by Nick Kibysh on 01/10/2019.
//  Copyright © 2019 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

extension Identifier where Value == Section {
    static let bloodPressure: Identifier<Section> = "bloodPressure"
    static let cuffPressure: Identifier<Section> = "cuffPressure"
}

extension Peripheral {
    static let bloodPressure = Peripheral(uuid: CBUUID.Profile.bloodPressureMonitor, services: [.battery, .measurement])
}

private extension Peripheral.Service {
    static let measurement = Peripheral.Service(uuid: CBUUID.Service.bloodPressureMonitor, characteristics: [
        Peripheral.Service.Characteristic(uuid: CBUUID.Characteristics.BloodPressure.measurement, action: .notify(true)),
        Peripheral.Service.Characteristic(uuid: CBUUID.Characteristics.BloodPressure.intermediateCuff, action: .notify(true))
    ])
}

class BloodPressureTableViewController: PeripheralTableViewController {
    private var bloodPressureSection = BloodPressureSection(id: .bloodPressure)
    private var cuffPressureSection = CuffPressureSection(id: .cuffPressure)
    
    override var internalSections: [Section] { [bloodPressureSection, cuffPressureSection] }
    override var peripheralDescription: Peripheral { .bloodPressure }
    
    private var dataSectionIds: [Identifier<Section>] = [.bloodPressure, .cuffPressure]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Blood Pressure Monitor"
    }
    
    override func didUpdateValue(for characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case CBUUID.Characteristics.BloodPressure.measurement:
            let bloodPressureCharacteristic = BloodPreasureCharacteristic(data: characteristic.value!)
            
            bloodPressureSection.update(with: bloodPressureCharacteristic)
            setBloodPressureVisibility(true)
            cuffPressureSection.isHidden = true
//            reloadSections(ids: dataSectionIds)
            tableView.reloadData()
        case CBUUID.Characteristics.BloodPressure.intermediateCuff:
            cuffPressureSection.update(with: CuffPreasureCharacteristic(data: characteristic.value!))
            setBloodPressureVisibility(false)
            cuffPressureSection.isHidden = false
//            reloadSections(ids: dataSectionIds)
            tableView.reloadData()
        default:
            super.didUpdateValue(for: characteristic)
        }
    }
    
    private func setBloodPressureVisibility(_ isVisible: Bool) {
        bloodPressureSection.isHidden = !isVisible
    }
}
