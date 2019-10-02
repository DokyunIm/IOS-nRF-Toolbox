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
    override var internalSections: [Section] { [bloodPressureSection] }
    override var peripheralDescription: Peripheral { .bloodPressure }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Blood Pressure Monitor"
    }
    
    override func didUpdateValue(for characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case CBUUID.Characteristics.BloodPressure.measurement:
            bloodPressureSection.update(with: characteristic.value!)
            reloadSection(id: .bloodPressure)
        case CBUUID.Characteristics.BloodPressure.intermediateCuff:
//            bloodPressureSection.update(with: characteristic.value!)
//            reloadSection(id: .bloodPressure)
            fallthrough
        default:
            super.didUpdateValue(for: characteristic)
        }
    }
}
