//
//  NutritionalGuidanceViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/28/23.
//

import UIKit
import SwiftSpinner

class NutritionalGuidanceViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var breakfastContainer: UIView!
    @IBOutlet weak var breakfastMealName: UILabel!
    @IBOutlet weak var breakfastCalories: UILabel!
    @IBOutlet weak var breakfastCarbs: UILabel!
    @IBOutlet weak var breakfastProtein: UILabel!
    @IBOutlet weak var breakfastFat: UILabel!
    @IBOutlet weak var breakfastMealImage: UIImageView!
    @IBOutlet weak var breakfastLineView: UIView!
    
    @IBOutlet weak var lunchContainer: UIView!
    @IBOutlet weak var lunchMealName: UILabel!
    @IBOutlet weak var lunchCalories: UILabel!
    @IBOutlet weak var lunchCarbs: UILabel!
    @IBOutlet weak var lunchProtein: UILabel!
    @IBOutlet weak var lunchFat: UILabel!
    @IBOutlet weak var lunchMealImage: UIImageView!
    @IBOutlet weak var lunchLineView: UIView!
    
    @IBOutlet weak var dinnerContainer: UIView!
    @IBOutlet weak var dinnerMealName: UILabel!
    @IBOutlet weak var dinnerCalories: UILabel!
    @IBOutlet weak var dinnerCarbs: UILabel!
    @IBOutlet weak var dinnerProtein: UILabel!
    @IBOutlet weak var dinnerFat: UILabel!
    @IBOutlet weak var dinnerMealImage: UIImageView!
    @IBOutlet weak var dinnerLineView: UIView!
    @IBOutlet weak var recommendText: UITextView!
    
    @IBOutlet weak var breakfastCookbook: UIImageView!
    
    @IBOutlet weak var regenerateBtn: UIButton!
    
    var breakfastJson: Meal?
    var lunchJson: Meal?
    var dinnerJson: Meal?
    
    var mealList: [Meal]?
    
    private let format = "{ 'breakfast': { 'mealName': 'the name of the breakfast meal', 'calories': '200', 'macronutrients': { 'carbs': '10%', 'protein': '20%', 'fat': '70%' },},}, the macronutrients are in percentage"
    private let conditionPrompt = "I am 5 feet 3 and 110 lbs, I want to gain weight"
    private let breakfastActionPrompt = "recommend me a [BREAKFAST] meal"
    private let lunchActionPrompt = "recommend me a [LUNCH] meal"
    private let dinnerActionPrompt = "recommend me a [DINNER] meal"
    private let strictFormat = ". with no instructions or any information except for the format I specified. Just give me the json result!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavbar(text: "Meal")
        
        contentView.backgroundColor = UIColor.white
        
        self.updateMealView(self.conditionPrompt)
        
        
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        breakfastContainer.backgroundColor = .background1
        breakfastContainer.layer.cornerRadius = 8
        
        lunchContainer.backgroundColor = .background1
        lunchContainer.layer.cornerRadius = 8
        
        dinnerContainer.backgroundColor = .background1
        dinnerContainer.layer.cornerRadius = 8
        
        breakfastMealName.numberOfLines = 2
        breakfastMealName.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        lunchMealName.numberOfLines = 2
        lunchMealName.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        dinnerMealName.numberOfLines = 2
        dinnerMealName.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        breakfastLineView.layer.cornerRadius = 4
        lunchLineView.layer.cornerRadius = 4
        dinnerLineView.layer.cornerRadius = 4
        
        filterBtn.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let filterVC = storyboard.instantiateViewController(identifier: "filterVC")
            filterVC.title = "Health Metrics"
            
            let nav = UINavigationController(rootViewController: filterVC)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(_:)), name:NSNotification.Name(rawValue: "nutritionalFilter"), object: nil)

        //        regenerateBtn.setOnClickListener { [self] in
        ////            self.updateMealView("I do not like the previous answer, recommend another [BREAKFAST] meal, another [LUNCH] meal, and another [DINNER] meal with associated [CALORIES] different from previous answer, but this time with Chinese food. in this format: \(format)")
        ////            self.updateMealView("\(originalPrompt)in this format: \(format)")
        //            self.updateMealView(conditionPrompt)
        //
        //            self.regenerateBtn.isEnabled = false
        //
        //        }
        
        //        HealthKitManager().gettingActivityLevel { arr in
        //            print("I am here", arr)
        //        }
        
        //        GptApiService().getGptStream(messagePrompt: "I am 5''3 and 110 lbs, how much calories do i need to intake?") { Text in
        //            DispatchQueue.main.async {
        //                self.recommendText.text += Text
        //            }
        //        }
        
    }
    
    //    private func setUpLoading() {
    //        let alert = UIAlertController(title: nil, message: "Setting up meals...", preferredStyle: .alert)
    //
    //        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
    //        loadingIndicator.hidesWhenStopped = true
    //        loadingIndicator.style = UIActivityIndicatorView.Style.medium
    //        loadingIndicator.startAnimating();
    //
    //        breakfastLineView.layer.cornerRadius = 4
    //        lunchLineView.layer.cornerRadius = 4
    //        dinnerLineView.layer.cornerRadius = 4
    //
    //        alert.view.addSubview(loadingIndicator)
    //        present(alert, animated: true, completion: nil)
    //    }
    
    private func updateMealView(_ prompt: String) {
        DispatchQueue.main.async {
            self.retrieveMealInfo(prompt: prompt + self.breakfastActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "breakfast")
            self.retrieveMealInfo(prompt: prompt + self.lunchActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "lunch")
            self.retrieveMealInfo(prompt: prompt + self.dinnerActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "dinner")
        }
    }
    
    @objc func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func handleNotification(_ notification: NSNotification) {
       print("closed!")
    }
    
    private func retrieveMealInfo(prompt: String, mealType: String) {
        //        setUpLoading()
        DispatchQueue.main.async {
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
                            self.dismiss(animated: false, completion: nil)
                        }
                        return
                    }
                    
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: mealData, options: [])
                        if let jsonObj = jsonData as? [String: Any] {
                            if mealType == "breakfast" {
                                let breakfastObj = jsonObj["breakfast"] as? [String: Any]
                                if breakfastObj != nil {
                                    self.setUpBreakfast(breakfastData: breakfastObj!)
                                }
                            }
                            if mealType == "lunch" {
                                let lunchObj = jsonObj["lunch"] as? [String: Any]
                                if lunchObj != nil {
                                    self.setUpLunch(lunchData: lunchObj!)
                                }
                            }
                            if mealType == "dinner" {
                                let dinnerObj = jsonObj["dinner"] as? [String: Any]
                                if dinnerObj != nil {
                                    self.setUpDinner(dinnerData: dinnerObj!)
                                }
                            }
                            
                        }
//                        self.stopLoading()
                    }
                    catch {
                        print(error)
                    }
                }
                else {
                    print("failed to convert json string to data")
                }
            }
        }
    }
    
    private func setUpBreakfast(breakfastData: [String: Any]) {
        DispatchQueue.main.async {
            
            let mealName = breakfastData["mealName"] as! String
            
            let calories = breakfastData["calories"] as? Double ?? Double(breakfastData["calories"] as! String)!
            
            let macronutrients = breakfastData["macronutrients"] as? [String: Any]
            
            let carbs = macronutrients!["carbs"] as! String
            let protein = macronutrients!["protein"] as! String
            let fat = macronutrients!["fat"] as! String
            
            Task {
                do {
                    let url = try await ImageApiService().generateImage(mealName)
                    guard let imageURL = URL(string: url) else {
                        throw RetrieveImageError.unableToCreateUrl
                    }
                    
                    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
                    
                    guard let image = UIImage(data: imageData) else {
                        throw RetrieveImageError.unableToGetImage
                    }
                    
                    self.breakfastMealImage.image = image.circleMasked
                    let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
                    
                    self.breakfastJson = meal
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBreakFast(_:)))
                    self.breakfastCookbook.isUserInteractionEnabled = true
                    self.breakfastCookbook.addGestureRecognizer(tap)
                    
                    
                    
                } catch {
                    print(error)
                }
            }
            
            self.breakfastMealName.text = mealName
            self.breakfastCalories.text = "\(calories) kcal"
            self.breakfastCarbs.text = carbs
            self.breakfastProtein.text = protein
            self.breakfastFat.text = fat
            
            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.breakfastLineView)
            
        }
        
    }
    
    @objc func tapBreakFast(_ sender: UITapGestureRecognizer? = nil) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
            
            mealDetail.mealNameText = (self.breakfastJson?.mealName)!
            mealDetail.imageUrl = self.breakfastJson?.mealImg
            
            mealDetail.mealFatText = self.breakfastJson?.mealFat
            mealDetail.mealCarbsText = self.breakfastJson?.mealCarbs
            mealDetail.mealProteinText = self.breakfastJson?.mealProtein
            mealDetail.cal = self.breakfastJson?.mealCalories
            
            let nav = UINavigationController(rootViewController: mealDetail)
            
            mealDetail.title = "Recipe Details"
            
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
        }
        
    }
    
    private func setUpLunch(lunchData: [String: Any]) {
        DispatchQueue.main.async {
            
            let mealName = lunchData["mealName"] as! String
            
            let calories = lunchData["calories"] as? Double ?? Double(lunchData["calories"] as! String)!
            
            let macronutrients = lunchData["macronutrients"] as? [String: Any]
            
            let carbs = macronutrients!["carbs"] as! String
            let protein = macronutrients!["protein"] as! String
            let fat = macronutrients!["fat"] as! String
            
            Task {
                do {
                    let url = try await ImageApiService().generateImage(mealName)
                    guard let imageURL = URL(string: url) else {
                        throw RetrieveImageError.unableToCreateUrl
                    }
                    
                    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
                    
                    guard let image = UIImage(data: imageData) else {
                        throw RetrieveImageError.unableToGetImage
                    }
                    
                    self.lunchMealImage.image = image.circleMasked
                    
                    
                    let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
                    
                    self.lunchJson = meal
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLunch(_:)))
                    self.lunchContainer.addGestureRecognizer(tap)
                    
                } catch {
                    print(error)
                }
            }
            
            self.lunchMealName.text = mealName
            self.lunchCalories.text = "\(calories) kcal"
            self.lunchCarbs.text = carbs
            self.lunchProtein.text = protein
            self.lunchFat.text = fat
            
            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.lunchLineView)
            
        }
    }
    
    @objc func tapLunch(_ sender: UITapGestureRecognizer? = nil) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
            
            mealDetail.mealNameText = (self.lunchJson?.mealName)!
            mealDetail.imageUrl = self.lunchJson?.mealImg
            mealDetail.mealFatText = self.lunchJson?.mealFat
            mealDetail.mealCarbsText = self.lunchJson?.mealCarbs
            mealDetail.mealProteinText = self.lunchJson?.mealProtein
            mealDetail.cal = self.lunchJson?.mealCalories
            
            let nav = UINavigationController(rootViewController: mealDetail)
            
            mealDetail.title = "Recipe Details"
            
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
        }
        
    }
    
    private func setUpDinner(dinnerData: [String: Any]) {
        DispatchQueue.main.async {
            
            let mealName = dinnerData["mealName"] as! String
            
            let calories = dinnerData["calories"] as? Double ?? Double(dinnerData["calories"] as! String)!
            
            let macronutrients = dinnerData["macronutrients"] as? [String: Any]
            
            let carbs = macronutrients!["carbs"] as! String
            let protein = macronutrients!["protein"] as! String
            let fat = macronutrients!["fat"] as! String
            
            Task {
                do {
                    let url = try await ImageApiService().generateImage(mealName)
                    guard let imageURL = URL(string: url) else {
                        throw RetrieveImageError.unableToCreateUrl
                    }
                    
                    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
                    
                    guard let image = UIImage(data: imageData) else {
                        throw RetrieveImageError.unableToGetImage
                    }
                    
                    self.dinnerMealImage.image = image.circleMasked
                    
                    let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
                    
                    self.dinnerJson = meal
                    
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDinner(_:)))
                    self.dinnerContainer.addGestureRecognizer(tap)
                    
                } catch {
                    print(error)
                }
            }
            
            self.dinnerMealName.text = mealName
            self.dinnerCalories.text = "\(calories) kcal"
            self.dinnerCarbs.text = carbs
            self.dinnerProtein.text = protein
            self.dinnerFat.text = fat
            
            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.dinnerLineView)
            
            
        }
        
    }
    
    @objc func tapDinner(_ sender: UITapGestureRecognizer? = nil) {
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
            
            mealDetail.mealNameText = (self.dinnerJson?.mealName)!
            
            mealDetail.imageUrl = self.dinnerJson?.mealImg
            mealDetail.mealFatText = self.dinnerJson?.mealFat
            mealDetail.mealCarbsText = self.dinnerJson?.mealCarbs
            mealDetail.mealProteinText = self.dinnerJson?.mealProtein
            mealDetail.cal = self.dinnerJson?.mealCalories
            
            let nav = UINavigationController(rootViewController: mealDetail)
            
            mealDetail.title = "Recipe Details"
            
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
        }
        
    }
    
    private func saveMeal(meal: Meal) {
        mealList?.append(meal)
        
        print(mealList)
    }
    
    private func setUpProportions(color: [UIColor], proportions: [Double], view: UIView) {
        DispatchQueue.main.async {
            var currentX: Double = 0
            for (index, proportion) in proportions.enumerated() {
                let categoryView = UIView(frame: CGRect(x: currentX, y: 0, width: 100 * proportion, height: 10))
                categoryView.clipsToBounds = true
                
                if index == 0 {
                    categoryView.layer.cornerRadius = 4
                    categoryView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
                }
                else if index == 2 {
                    categoryView.layer.cornerRadius = 4
                    categoryView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
                }
                else {
                    categoryView.layer.cornerRadius = 0
                }
                
                categoryView.backgroundColor = color[index] // Set the background color of the category view (alternating colors for demonstration)
                view.addSubview(categoryView) // Add the category view to the line view
                currentX += 100 * proportion // Update the current X position for the next category
            }
        }
        
    }
    
    private func percentToDouble(percent: String) -> Double {
        let percentageWithoutSymbol = percent.replacingOccurrences(of: "%", with: "")
        let percentInDouble = Double(percentageWithoutSymbol)
        
        return (percentInDouble! / 100.0).truncate(places: 2)
    }
    
    private func setUpLoading() {
        SwiftSpinner.show("Setting Up Recommendations")
    }
    
    private func stopLoading() {
        SwiftSpinner.hide()
    }
}
