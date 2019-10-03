//
//  RunningTableViewController.swift
//  nRF Toolbox
//
//  Created by Nick Kibysh on 24/09/2019.
//  Copyright © 2019 Nordic Semiconductor. All rights reserved.
//

import UIKit
import CoreBluetooth

class RunningTableViewController: PeripheralTableViewController {
    lazy private var runningSpeedCadenceSection = RunningSpeedSection.init(id: .runningSpeedCadence, itemUpdated: { [weak self] (section, item) in
            self?.reloadItemInSection(section, itemId: item, animation: .none)
        })
    private let activitySection = ActivitySection(id: .runningActivitySection)
    override var peripheralDescription: Peripheral { .runningSpeedCadenceSensor }
    override var internalSections: [Section] { [activitySection, runningSpeedCadenceSection] }
    
    override func didUpdateValue(for characteristic: CBCharacteristic) {
        switch characteristic.uuid {
        case CBUUID.Characteristics.Running.measurement:
            characteristic.value.map {
                let running = RunningCharacteristic(data: $0)
                self.runningSpeedCadenceSection.update(with: running)
                self.activitySection.update(with: running)
                
                self.reloadSections(ids: [.runningSpeedCadence, .runningActivitySection], animation: .none)
            }
            
        default:
            super.didUpdateValue(for: characteristic)
        }
    }
}
