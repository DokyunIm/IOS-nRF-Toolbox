//
//  BloodPressureSection.swift
//  nRF Toolbox
//
//  Created by Nick Kibysh on 02/10/2019.
//  Copyright © 2019 Nordic Semiconductor. All rights reserved.
//

import Foundation

class BloodPressureSection: DetailsTableViewSection {
    
    override var sectionTitle: String { "Bloot Pressure" }
    
    override func update(with data: Data) {
        
        let characteristic = BloodPreasureCharacteristic(data: data)
        let formatter = MeasurementFormatter()
        
        let systolicItem = DefaultDetailsTableViewCellModel(title: "Systolic", value: formatter.string(from: characteristic.systolicPreasure))
        let diastolicItem = DefaultDetailsTableViewCellModel(title: "Diastolic", value: formatter.string(from: characteristic.diastolicPreasure))
        let maItem = DefaultDetailsTableViewCellModel(title: "Mean AP", value: formatter.string(from: characteristic.meanArterialPreasure))
        
        self.items = [systolicItem, diastolicItem, maItem]
        
        super.update(with: data)
    }
}
