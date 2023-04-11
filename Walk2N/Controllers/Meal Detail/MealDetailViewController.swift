//
//  MealDetailViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/5/23.
//

import UIKit
import Charts

class MealDetailViewController: UIViewController {
    
    @IBOutlet weak var mealImage: UIImageView!
    @IBOutlet weak var mealName: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var content: UIView!
    @IBOutlet weak var carbs: UILabel!
    @IBOutlet weak var proteins: UILabel!
    @IBOutlet weak var fat: UILabel!
    @IBOutlet weak var pieChartContainer: UIView!
    @IBOutlet weak var prepTime: UILabel!
    @IBOutlet weak var ingredients: UITextView!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var directions: UITextView!
    
    @IBOutlet weak var macronutrientsContainer: UIView!
    @IBOutlet weak var prepTimeContainer: UIView!
    
    @IBOutlet weak var imageContainer: UIView!
    
    @IBOutlet weak var backBtn: UIButton!
    
    var mealNameText: String? = ""
    var mealCarbsText:Double? = 0
    var mealProteinText:Double? = 0
    var mealFatText:Double? = 0
    var cal: Double? = 0
    var imageUrl: String? = nil
    
    var pieChart = PieChartView()
    
    private let cookTimeFormat = "{ 'estimatedCookTime': '2 hrs' }"
    private let ingredientFormat = "{ 'ingredients': ['2 gram of chicken breast'] }"
    private let directionFormat = "{ 'directions': ['1. cut the ....' , '2. boil the ...']}"

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mainView.backgroundColor = .white
        content.backgroundColor = .background1
        
        macronutrientsContainer.backgroundColor = .background1
        scrollView.backgroundColor = .background1
        
        macronutrientsContainer.layer.cornerRadius = 8
        
        prepTimeContainer.backgroundColor = UIColor(hexString: "#fff2ee")
        prepTimeContainer.layer.cornerRadius = 8

        ingredients.isEditable = false
        
        pieChartContainer.backgroundColor = .clear
        
        ingredients.textColor = .lessDark
        
        directions.textColor = .lessDark
            
        setUpPassedInfo()
        
        mealName.numberOfLines = 2
        mealName.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        backBtn.setOnClickListener {
            self.getTopMostViewController()?.dismiss(animated: true, completion: nil)
        }
        
        
        imageContainer.layer.zPosition = 1
        
    }
    
    private func setUpPassedInfo() {
        mealName.text = mealNameText!
        if let url = URL(string: imageUrl!) {
            DispatchQueue.global().async {
                if let data = try? Data(contentsOf: url) {
                    if let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.mealImage.image = image
                        }
                    }
                }
            }
        }
        carbs.text = "\((cal! * mealCarbsText!).truncate(places: 0)) kcal"
        proteins.text = "\((cal! * mealProteinText!).truncate(places: 0)) kcal"
        fat.text = "\((cal! * mealFatText!).truncate(places: 0)) kcal"
        
        setUpPieChart()
        
        getCookTime(prompt: "recommend the estimated cook time for \(String(describing: mealNameText)). Just need the json format in the format of \(cookTimeFormat.replacingOccurrences(of: "'", with: "\""))")
        getIngredients(prompt: "recommend the ingredients for \(String(describing: mealNameText)). Just need the json format in the format of \(ingredientFormat.replacingOccurrences(of: "'", with: "\""))")
        getDirections(prompt: "recommend the cooking directions for \(String(describing: mealNameText)). Just need the json format in the format of \(directionFormat.replacingOccurrences(of: "'", with: "\""))")
    }
    
    private func setUpPieChart() {
        pieChart.chartDescription.enabled = false
        pieChart.drawHoleEnabled = false
        pieChart.rotationAngle = 0
        pieChart.rotationAngle = 0
        pieChart.rotationEnabled = false
        pieChart.legend.enabled = false
        
        var entries: [PieChartDataEntry] = Array()
        
        entries.append(PieChartDataEntry(value: mealCarbsText!))
        entries.append(PieChartDataEntry(value: mealProteinText!))
        entries.append(PieChartDataEntry(value: mealFatText!))
        
        let data = PieChartDataSet(entries: entries)
        
        let orange = NSUIColor(cgColor: UIColor.orange.cgColor)
        let red = NSUIColor(cgColor: UIColor.darkRed.cgColor)
        let blue = NSUIColor(hexString: "#83c0ec")
        
        data.colors = [orange, red, blue]
        data.drawValuesEnabled = false
        
        pieChart.data = PieChartData(dataSet: data)
        
        pieChart.frame = pieChartContainer.bounds
        
        pieChartContainer.addSubview(pieChart)
    }
    
    
    private func getCookTime(prompt: String) {
        GptApiService().getGptResponse(messagePrompt: prompt) { output in
            if output.contains("{") && output.contains("}") {
                
                let openingBracketIndex = output.firstIndex(of: "{")
                let closingBracketIndex = output.lastIndex(of: "}")
                
                let startIndex = output.index(openingBracketIndex ?? output.startIndex, offsetBy: 0) // starting index of the desired substring
                let endIndex = output.index(closingBracketIndex ?? output.endIndex, offsetBy: 0) // ending index of the desired substring
                
                let substr = output[startIndex...endIndex]
                
                guard let mealData = substr.data(using: .utf8) else {
                    print("failed to convert json string to data")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: mealData, options: [])
                    
                    if let jsonObj = jsonData as? [String: Any], let estimatedCookTime = jsonObj["estimatedCookTime"] as? String {
                        DispatchQueue.main.async {
                            self.prepTime.text = estimatedCookTime
                        }
                    }
                    else {
                        print("failed to convert json string to data")
                    }
                    
                    
                }
                catch {
                    print(error)
                    
                }
            }
            else {
                print("no data")
            }
        }
    }
        
    private func getIngredients(prompt: String) {
        GptApiService().getGptResponse(messagePrompt: prompt) { output in
            if output.contains("{") && output.contains("}") {
                
                let openingBracketIndex = output.firstIndex(of: "{")
                let closingBracketIndex = output.lastIndex(of: "}")
                
                let startIndex = output.index(openingBracketIndex ?? output.startIndex, offsetBy: 0) // starting index of the desired substring
                let endIndex = output.index(closingBracketIndex ?? output.endIndex, offsetBy: 0) // ending index of the desired substring
                
                let substr = output[startIndex...endIndex]
                
                guard let mealData = substr.data(using: .utf8) else {
                    print("failed to convert json string to data")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: mealData, options: [])
                    
                    if let jsonObj = jsonData as? [String: Any], let ingredients = jsonObj["ingredients"] as? [Any] {
                        
                        var ingredientStr: String = ""
                        
                        for i in 0..<ingredients.count {
                            ingredientStr += "\(ingredients[i])\n\n"
                        }
                        
                        DispatchQueue.main.async {
                            self.ingredients.text = ingredientStr
                        }
                    }
                    else {
                        print("failed to convert json string to data")
                    }
                    
                    
                }
                catch {
                    print(error)
                }
            }
            else {
                print("no data")
            }
        }
        
    }
    
    private func getDirections(prompt: String) {
        GptApiService().getGptResponse(messagePrompt: prompt) { output in
            if output.contains("{") && output.contains("}") {
                
                let openingBracketIndex = output.firstIndex(of: "{")
                let closingBracketIndex = output.lastIndex(of: "}")
                
                let startIndex = output.index(openingBracketIndex ?? output.startIndex, offsetBy: 0) // starting index of the desired substring
                let endIndex = output.index(closingBracketIndex ?? output.endIndex, offsetBy: 0) // ending index of the desired substring
                
                let substr = output[startIndex...endIndex]
                
                guard let mealData = substr.data(using: .utf8) else {
                    print("failed to convert json string to data")
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                    return
                }
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: mealData, options: [])
                    
                    if let jsonObj = jsonData as? [String: Any], let directions = jsonObj["directions"] as? [Any] {
                        
                        var directionStr: String = ""
                        
                        for i in 0..<directions.count {
                            directionStr += "\(directions[i])\n\n"
                        }
                        
                        DispatchQueue.main.async {
                            self.directions.text = directionStr
                        }
                    }
                    else {
                        print("failed to convert json string to data")
                    }
                    
                    
                }
                catch {
                    print(error)
                }
            }
            else {
                print("no data")
            }
        }
        
    }
    
    
//    private func setUpLoading() {
//        let alert = UIAlertController(title: nil, message: "Getting recipes...", preferredStyle: .alert)
//
//        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
//        loadingIndicator.hidesWhenStopped = true
//        loadingIndicator.style = UIActivityIndicatorView.Style.medium
//        loadingIndicator.startAnimating();
//
//        alert.view.addSubview(loadingIndicator)
//        getTopMostViewController()!.present(alert, animated: true, completion: nil)
//    }
    
    
    
}
