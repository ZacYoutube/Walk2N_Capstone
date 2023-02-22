//
//  HistoricalStepViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import HealthKit
import Charts
import Firebase

class HistoricalStepViewController: UIViewController {
    
    @IBOutlet weak var infoContainer: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var barContainer: UIView!
    
    let averageLabel = UILabel()
    let totalLabel = UILabel()
    let averageSteps = UILabel()
    let totalSteps = UILabel()
    let barChart = BarChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "History"
        contentView.backgroundColor = UIColor.background
        infoContainer.backgroundColor = .white
        barContainer.backgroundColor = .white
        contentView.addSubview(infoContainer)
        contentView.addSubview(barContainer)
        view.addSubview(contentView)
        self.setUpNavbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayStepMetrics()
        
        
//        HealthKitManager().gettingStepCount(7) { steps, time in
//            var color = [NSUIColor](repeating: NSUIColor(red: 255.0, green: 0, blue: 0, alpha: 1.0), count: steps.count)
//            for i in 0..<steps.count{
//                // 1000 is the step goal: we can update it based on the ML model output
//                if steps[i] >= 1000 {
//                        color[i] = NSUIColor(red: 46/255.0, green: 204/255.0, blue: 113/255.0, alpha: 1.0)
//                }
//            }
//            var timeArr: Array<String> = Array(repeating: "", count: time.count)
//            for i in 0..<time.count {
//                timeArr[i] = time[i].dayOfWeek()!
//             }
//            self.displaySteps(stepsArr: steps, timeArr: timeArr, color: color)
//            var average: Double = 0.0
//            var total: Double = 0.0
//            for i in 0..<steps.count{
//                total += steps[i]
//            }
//
//            average = Double(floor(Double(total) / Double(steps.count)))
//
//            if average.isNaN {
//                average = 0.0
//            }
//
//            // keep updating on the main thread
//            DispatchQueue.main.async {
//                self.averageSteps.text = String(average)
//                self.totalSteps.text = String(total)
//            }
//        }
    }

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    private func displayStepMetrics() {
        let labelSv = UIStackView(frame: CGRect(x: infoContainer.left + 5, y: infoContainer.top - 5, width: 300, height: 35))
        labelSv.axis = .horizontal
        labelSv.alignment = .center
        labelSv.spacing = 0
        labelSv.distribution = .fillEqually
//        labelSv.backgroundColor = .black
        
        averageLabel.attributedText = NSMutableAttributedString().normal("Average")
        totalLabel.attributedText = NSMutableAttributedString().normal("Total Steps")
        
        averageLabel.font = UIFont.systemFont(ofSize: 20)
        totalLabel.font = UIFont.systemFont(ofSize: 20)
        
        averageLabel.textAlignment = .center
        totalLabel.textAlignment = .center
        
        labelSv.addArrangedSubview(averageLabel)
        labelSv.addArrangedSubview(totalLabel)
                
        let metricSv = UIStackView(frame: CGRect(x: infoContainer.left + 5, y: infoContainer.top + 35, width: 300, height: 35))
        metricSv.axis = .horizontal
        metricSv.alignment = .center
        metricSv.spacing = 0
        metricSv.distribution = .fillEqually
//        metricSv.backgroundColor = .black
        
        // read from firebase and display historical step count in bar chart
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["historicalSteps"] != nil {
                    var historicalSteps = doc["historicalSteps"]! as! [Any]
                    historicalSteps = historicalSteps.sorted(by: {
                        ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                    })
                    if historicalSteps.count > 7 {
                        historicalSteps = Array(historicalSteps[historicalSteps.count - 8...historicalSteps.count - 1])
                    }
                    var color = [NSUIColor](repeating: UIColor.lightRed, count: historicalSteps.count)
                    var timeArr: Array<String> = Array(repeating: "", count: historicalSteps.count)
                    var stepsArr: Array<Double> = Array(repeating: 0.0, count: historicalSteps.count)
                    for i in 0..<historicalSteps.count {
                        if (historicalSteps[i] as! [String:Any])["stepCount"] as! Double >= (historicalSteps[i] as! [String:Any])["stepGoal"] as! Double {
                            color[i] = UIColor.lightGreen
                        }
                        timeArr[i] = (((historicalSteps[i] as! [String:Any])["date"] as! Timestamp).dateValue()).dayOfWeek()!
                        stepsArr[i] = (historicalSteps[i] as! [String:Any])["stepCount"] as! Double
                    }
                    self.displaySteps(stepsArr: stepsArr, timeArr: timeArr, color: color)
                    var average: Double = 0.0
                    var total: Double = 0.0
                    for i in 0..<stepsArr.count{
                        total += stepsArr[i]
                    }
                    average = Double(floor(Double(total) / Double(stepsArr.count)))
                    if average.isNaN {
                        average = 0.0
                    }
                    DispatchQueue.main.async {
                        self.averageSteps.attributedText = NSMutableAttributedString().bold(String(average))
                        self.totalSteps.attributedText = NSMutableAttributedString().bold(String(total))
                        
                        self.averageSteps.textAlignment = .center
                        self.totalSteps.textAlignment = .center
                        
                        self.averageSteps.font = UIFont.systemFont(ofSize: 20)
                        self.totalSteps.font = UIFont.systemFont(ofSize: 20)
                        
                        self.averageSteps.textColor = UIColor.lightGreen
                        self.totalSteps.textColor = UIColor.lightGreen
                        
                        metricSv.addArrangedSubview(self.averageSteps)
                        metricSv.addArrangedSubview(self.totalSteps)
                    }
                }
            }
        }
        
        
        infoContainer.addSubview(labelSv)
        infoContainer.addSubview(metricSv)
    }
    
    private func displaySteps(stepsArr: Array<Double>, timeArr: Array<String>, color: Array<NSUIColor>) {
        DispatchQueue.main.async {
            self.barChart.frame = self.barContainer.bounds
            self.barChart.setChartValues(xAxisValues: timeArr, values: stepsArr, color: color, label: "Steps")
            let legend = self.barChart.legend

//            legend.horizontalAlignment = .right
//            legend.verticalAlignment = .top
//            legend.orientation = .vertical
//            legend.drawInside = false
//            legend.font = UIFont.systemFont(ofSize: 14)
//            legend.textColor = UIColor.darkGray
//            legend.formSize = 15
//            legend.formToTextSpace = 5
//            legend.xEntrySpace = 10

//            let greenEntry = LegendEntry(label: "Green", form: .square, formSize: 15, formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: UIColor.green)
//            let redEntry = LegendEntry(label: "Red", form: .square, formSize: 15, formLineWidth: 0, formLineDashPhase: 0, formLineDashLengths: nil, formColor: UIColor.red)
//
//            legend.setCustom(entries: [greenEntry, redEntry])

//            self.barChart.legendRenderer = LegendRenderer(viewPortHandler: self.barChart.viewPortHandler, legend: legend)

            self.barChart.chartDescription.enabled = false
            self.barChart.xAxis.drawGridLinesEnabled = false
            self.barChart.xAxis.drawAxisLineEnabled = false
            self.barChart.rightAxis.enabled = false
            self.barChart.leftAxis.enabled = false


            self.barContainer.addSubview(self.barChart)
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


