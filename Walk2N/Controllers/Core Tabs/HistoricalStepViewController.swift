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

class HistoricalStepViewController: UIViewController, ChartViewDelegate {
    
    @IBOutlet weak var stepInfoContainer: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var stepBarContainer: UIView!
    @IBOutlet weak var distLineContainer: UIView!
    @IBOutlet weak var distInfoContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    lazy var lineChartView: LineChartView = {
        let chart = LineChartView()
        return chart
    }()
    let averageDistLabel = UILabel()
    let totalDistLabel = UILabel()
    let averageDist = UILabel()
    let totalDist = UILabel()
    
    let averageLabel = UILabel()
    let totalLabel = UILabel()
    let averageSteps = UILabel()
    let totalSteps = UILabel()
    let barChart = BarChartView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "History"
        contentView.backgroundColor = UIColor.background
        stepInfoContainer.backgroundColor = .white
        stepBarContainer.backgroundColor = .white
        distLineContainer.backgroundColor = .white
        distInfoContainer.backgroundColor = .white
    
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        displayStepMetrics()
        displayDist()
        self.setUpNavbar()
        
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
        let labelSv = UIStackView(frame: CGRect(x: stepInfoContainer.left + 5, y: stepInfoContainer.top - 5, width: 300, height: 35))
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
                
        let metricSv = UIStackView(frame: CGRect(x: stepInfoContainer.left + 5, y: stepInfoContainer.top + 35, width: 300, height: 35))
        metricSv.axis = .horizontal
        metricSv.alignment = .center
        metricSv.spacing = 0
        metricSv.distribution = .fillEqually
//        metricSv.backgroundColor = .black
        
        // read from firebase and display historical step count in bar chart
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil {
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
        
        
        stepInfoContainer.addSubview(labelSv)
        stepInfoContainer.addSubview(metricSv)
    }
    
    private func displaySteps(stepsArr: Array<Double>, timeArr: Array<String>, color: Array<NSUIColor>) {
        DispatchQueue.main.async {
            self.barChart.frame = self.stepBarContainer.bounds
            self.barChart.setChartValues(xAxisValues: timeArr, values: stepsArr, color: color, label: "Steps for past week")
            let legend = self.barChart.legend

            legend.horizontalAlignment = .center
            legend.verticalAlignment = .top
            legend.orientation = .horizontal
            legend.drawInside = true
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
            self.barChart.isUserInteractionEnabled = false

            self.stepBarContainer.addSubview(self.barChart)
        }
    }
    
    private func displayDist() {
        let labelSv = UIStackView(frame: CGRect(x: distInfoContainer.left, y: 15, width: 300, height: 35))
        labelSv.axis = .horizontal
        labelSv.alignment = .center
        labelSv.spacing = 0
        labelSv.distribution = .fillEqually
//        labelSv.backgroundColor = .black
        
        averageDistLabel.attributedText = NSMutableAttributedString().normal("Average")
        totalDistLabel.attributedText = NSMutableAttributedString().normal("Total Distance")
        
        averageDistLabel.font = UIFont.systemFont(ofSize: 20)
        totalDistLabel.font = UIFont.systemFont(ofSize: 20)
        
        averageDistLabel.textAlignment = .center
        totalDistLabel.textAlignment = .center
        
        labelSv.addArrangedSubview(averageDistLabel)
        labelSv.addArrangedSubview(totalDistLabel)
                
        let metricSv = UIStackView(frame: CGRect(x: distInfoContainer.left, y: 55, width: 300, height: 35))
        metricSv.axis = .horizontal
        metricSv.alignment = .center
        metricSv.spacing = 0
        metricSv.distribution = .fillEqually
        
        distInfoContainer.addSubview(labelSv)
        distInfoContainer.addSubview(metricSv)
        
        HealthKitManager().gettingDistanceArr(7) { dist, time in
            DispatchQueue.main.async {
                self.lineChartView.frame = self.distLineContainer.bounds
                let legend = self.lineChartView.legend

                legend.horizontalAlignment = .center
                legend.verticalAlignment = .top
                legend.orientation = .horizontal
                legend.drawInside = true
                
                var total = 0.0
                var average = 0.0
                for i in 0..<dist.count {
                    total += dist[i]
                }
                total = (total / 1000).truncate(places: 1)
                average = Double(total / 7).truncate(places: 1)
                
                self.averageDist.attributedText = NSMutableAttributedString().bold(String(average)).normal(String(" km"))
                self.totalDist.attributedText = NSMutableAttributedString().bold(String(total)).normal(String(" km"))
                
                self.averageDist.textAlignment = .center
                self.totalDist.textAlignment = .center
                
                self.averageDist.font = UIFont.systemFont(ofSize: 20)
                self.totalDist.font = UIFont.systemFont(ofSize: 20)
                
                self.averageDist.textColor = UIColor.lightGreen
                self.totalDist.textColor = UIColor.lightGreen
                
                metricSv.addArrangedSubview(self.averageDist)
                metricSv.addArrangedSubview(self.totalDist)
                
                var timeArr: Array<String> = Array(repeating: "", count: time.count)
                var distArr: Array<Double> = Array(repeating: 0.0, count: dist.count)
                for i in 0..<time.count {
                    timeArr[i] = time[i].dayOfWeek()!
                }
                for i in 0..<dist.count {
                    distArr[i] = (dist[i] / 1000).truncate(places: 1)
                }
                
                self.lineChartView.setChartValues(xAxisValues: timeArr, values: distArr, label: "Distance for past week")
                self.lineChartView.xAxis.drawGridLinesEnabled = false
                self.lineChartView.xAxis.drawAxisLineEnabled = false
                self.lineChartView.rightAxis.enabled = false
                self.lineChartView.leftAxis.enabled = false
                self.lineChartView.isUserInteractionEnabled = false
                self.distLineContainer.addSubview(self.lineChartView)
            }
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


