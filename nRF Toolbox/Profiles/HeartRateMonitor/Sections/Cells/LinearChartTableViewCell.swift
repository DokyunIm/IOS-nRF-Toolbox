//
//  LinearChartTableViewCell.swift
//  nRF Toolbox
//
//  Created by Nick Kibysh on 08/10/2019.
//  Copyright © 2019 Nordic Semiconductor. All rights reserved.
//

import UIKit
import Charts

class LinearChartTableViewCell: UITableViewCell {

    let chartsView = LineChartView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(chartsView)
        chartsView.translatesAutoresizingMaskIntoConstraints = false
        chartsView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        chartsView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        chartsView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        chartsView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true 
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(with data: [(x: TimeInterval, y: Int)]) {
        let dataSet = configureChartData(data)
        chartsView.data = dataSet
    }
    
    private func configureChartData(_ value: [(x: TimeInterval, y: Int)]) -> LineChartData {
        let chartValues = value.map { ChartDataEntry(x: $0.x, y: Double($0.y)) }
        let set = LineChartDataSet(entries: chartValues)
        return LineChartData(dataSet: set)
    }

}
