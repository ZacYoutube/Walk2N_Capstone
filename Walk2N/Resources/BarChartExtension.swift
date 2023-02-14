//
//  BarChartExtension.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/2/23.
//

import Foundation
import Charts

// from online source in order to make barchart view work

extension BarChartView {

    private class BarChartFormatter: NSObject,AxisValueFormatter {

        var values : [String]
        required init (values : [String]) {
            self.values = values
            super.init()
        }


        func stringForValue(_ value: Double, axis: AxisBase?) -> String {
            return values[Int(value)]
        }
    }

    func setChartValues (xAxisValues : [String], values : [Double], color: [NSUIColor], label : String) {

        var barChartDataEntries = [BarChartDataEntry]()

        for i in 0..<values.count {
            let dataEntry = BarChartDataEntry(x: Double(i), y: values[i])
            barChartDataEntries.append(dataEntry)
        }
        let chartDataSet = BarChartDataSet(entries: barChartDataEntries, label: label)
        chartDataSet.colors = color
        let chartData = BarChartData(dataSet: chartDataSet)

        let formatter = BarChartFormatter(values: xAxisValues)
        let xAxis = XAxis()
        xAxis.valueFormatter = formatter
        self.xAxis.valueFormatter = xAxis.valueFormatter
        self.xAxis.labelPosition = .bottom

        self.data = chartData
        self.data?.notifyDataChanged()
        self.notifyDataSetChanged()
        self.leftAxis.axisMinimum = 0.0
        self.leftAxis.axisMaximum = 2000.0
        self.xAxis.drawLimitLinesBehindDataEnabled = true
        
    

        self.animate(xAxisDuration: 2.0, yAxisDuration: 2.0, easingOption: .linear)

    }

}
