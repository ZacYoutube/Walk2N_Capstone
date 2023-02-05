//
//  HistoricalStepViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import HealthKit
import Charts

class HistoricalStepViewController: UIViewController {
    

    @IBOutlet weak var averageSteps: UILabel!
    @IBOutlet weak var totalSteps: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "History"
        self.setupRemainingNavItems()
        // Do any additional setup after loading the view.
            HealthKitManager().gettingStepCount { steps, time in
                var color = [NSUIColor](repeating: NSUIColor(red: 255.0, green: 0, blue: 0, alpha: 1.0), count: steps.count)
                for i in 0..<steps.count{
                    if steps[i] >= 1000 {
                        color[i] = NSUIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
                    }
                }
                self.displaySteps(stepsArr: steps, timeArr: time, color: color)
                var average: Double = 0.0
                var total: Double = 0.0
                for i in 0..<steps.count{
                    total += steps[i]
                }
                
                average = Double(floor(Double(total) / Double(steps.count)))
                
                DispatchQueue.main.async {
                    self.averageSteps.text = String(average)
                    self.totalSteps.text = String(total)
                }
            }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func displaySteps(stepsArr: Array<Double>, timeArr: Array<String>, color: Array<NSUIColor>) {
        DispatchQueue.main.async {
            let barChart = BarChartView(frame: CGRect(x: 0, y: 0, width: self.view.width, height: self.view.width))
            barChart.setChartValues(xAxisValues: timeArr, values: stepsArr, color: color, label: "Steps")
            barChart.chartDescription.enabled = false
            barChart.xAxis.drawGridLinesEnabled = false
            barChart.xAxis.drawAxisLineEnabled = false
            barChart.rightAxis.enabled = false
            barChart.leftAxis.enabled = false
            self.view.addSubview(barChart)
            barChart.center = self.view.center
        }
    }
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


