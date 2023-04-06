//
//  NutritionalGuidanceViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/28/23.
//

import UIKit

class NutritionalGuidanceViewController: UIViewController {
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
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
    
    @IBOutlet weak var regenerateBtn: UIButton!
    
    var breakfastJson: Meal?
    var lunchJson: Meal?
    var dinnerJson: Meal?
    
    private let format = """
            {
                "breakfast": {
                    "mealName": "the name of the breakfast meal",
                    "calories": "200",
                    "macronutrients": {
                        "carbs": "10%",
                        "protein": "20%",
                        "fat": "70%"
                    },
                },
                "lunch": {
                    "mealName": "the name of the lunch meal",
                    "calories": "300",
                    "macronutrients": {
                        "carbs": "30%",
                        "protein": "40%",
                        "fat": "30%"
                    },
                },
                "dinner": {
                    "mealName": "the name of the dinner meal",
                    "calories": "500",
                    "macronutrients": {
                        "carbs": "20%",
                        "protein": "70%",
                        "fat": "10%"
                    }
                }
            }
        """
    
    private let originalPrompt = """
        "I am 5 feet 3 and 110 lbs, I want to gain weight, recommend me a [BREAKFAST] meal, [LUNCH] meal, and a [DINNER] meal with associated [CALORIES]."
        """
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavbar(text: "Meal")
        contentView.backgroundColor = UIColor.white
        updateMealView("\(originalPrompt)in this format: \(format)")
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
        
        regenerateBtn.setOnClickListener { [self] in
            self.updateMealView("I do not like the previous answer, recommend another [BREAKFAST] meal, another [LUNCH] meal, and another [DINNER] meal with associated [CALORIES] different from previous answer, but this time with Chinese food. in this format: \(format)")
        }
        
    }
    
    private func setUpLoading() {
        let alert = UIAlertController(title: nil, message: "Setting up meals...", preferredStyle: .alert)
        
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 5, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();
        
        breakfastLineView.layer.cornerRadius = 4
        lunchLineView.layer.cornerRadius = 4
        dinnerLineView.layer.cornerRadius = 4
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
    private func updateMealView(_ prompt: String) {
        print(prompt)
        setUpLoading()
        
        GptApiService().fetchUrlRequest(url: "",
                                        httpMethod: "",
                                        messagePrompt: prompt ) { output in
            
            print(output, output.contains("{") && output.contains("}"))
            
            if output.contains("{") && output.contains("}") {
                
                let openingBracketIndex = output.firstIndex(of: "{")
                let closingBracketIndex = output.lastIndex(of: "}")
                
                let startIndex = output.index(openingBracketIndex ?? output.startIndex, offsetBy: 0) // starting index of the desired substring
                let endIndex = output.index(closingBracketIndex ?? output.endIndex, offsetBy: 0) // ending index of the desired substring
                
                let substr = output[startIndex...endIndex]
                
                print("substring", substr)
                
                guard let mealData = substr.data(using: .utf8) else {
                    print("failed to convert json string to data")
                    DispatchQueue.main.async {
                        self.dismiss(animated: false, completion: nil)
                    }
                    return
                }
                
                print("mealData", mealData)
                
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: mealData, options: [])
                    
                    print(jsonData)
                    
                    if let jsonObj = jsonData as? [String: Any],
                       let breakfastObj = jsonObj["breakfast"] as? [String: Any],
                       let lunchObj = jsonObj["lunch"] as? [String: Any],
                       let dinnerObj = jsonObj["dinner"] as? [String: Any] {
                        
                        self.setUpBreakfast(breakfastData: breakfastObj)
                        self.setUpLunch(lunchData: lunchObj)
                        self.setUpDinner(dinnerData: dinnerObj)
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: false, completion: nil)
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
        }
    }
    
    @objc func didPullToRefresh() {
        //        updateMealView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    private func setUpBreakfast(breakfastData: [String: Any]) {

        let mealName = breakfastData["mealName"] as! String
        
        let calories = breakfastData["calories"] as? Double ?? Double(breakfastData["calories"] as! String)!
        
        //        let ingredients = breakfastData["ingredients"] as! [Any]
        
        let macronutrients = breakfastData["macronutrients"] as? [String: Any]
        
        let carbs = macronutrients!["carbs"] as! String
        let protein = macronutrients!["protein"] as! String
        let fat = macronutrients!["fat"] as! String
        
        Task {
            do {
                let image = try await ImageApiService().generateImage(mealName)
                breakfastMealImage.image = image.circleMasked
                
                let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: image)
                
                self.breakfastJson = meal
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBreakFast(_:)))
                self.breakfastContainer.addGestureRecognizer(tap)
                
            } catch {
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            self.breakfastMealName.text = mealName
            self.breakfastCalories.text = "\(calories) kcal"
            self.breakfastCarbs.text = carbs
            self.breakfastProtein.text = protein
            self.breakfastFat.text = fat
            
            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.breakfastLineView)
        }
        
    }
    
    @objc func tapBreakFast(_ sender: UITapGestureRecognizer? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
        
        mealDetail.mealNameText = (breakfastJson?.mealName)!
        mealDetail.image = breakfastJson?.mealImg
        mealDetail.mealFatText = breakfastJson?.mealFat
        mealDetail.mealCarbsText = breakfastJson?.mealCarbs
        mealDetail.mealProteinText = breakfastJson?.mealProtein
        mealDetail.cal = breakfastJson?.mealCalories
            
        let nav = UINavigationController(rootViewController: mealDetail)
        
        mealDetail.title = "Recipe Details"
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true)
    }
    
    private func setUpLunch(lunchData: [String: Any]) {
        
        let mealName = lunchData["mealName"] as! String
        
        let calories = lunchData["calories"] as? Double ?? Double(lunchData["calories"] as! String)!
        
        //        let ingredients = lunchData["ingredients"] as! [Any]
        
        let macronutrients = lunchData["macronutrients"] as? [String: Any]
        
        let carbs = macronutrients!["carbs"] as! String
        let protein = macronutrients!["protein"] as! String
        let fat = macronutrients!["fat"] as! String
        
        Task {
            do {
                let image = try await ImageApiService().generateImage(mealName)
                lunchMealImage.image = image.circleMasked
                
                let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: image)
                
                self.lunchJson = meal
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLunch(_:)))
                self.lunchContainer.addGestureRecognizer(tap)
                
            } catch {
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            self.lunchMealName.text = mealName
            self.lunchCalories.text = "\(calories) kcal"
            self.lunchCarbs.text = carbs
            self.lunchProtein.text = protein
            self.lunchFat.text = fat
            
            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.lunchLineView)
        }
        
    }
    
    @objc func tapLunch(_ sender: UITapGestureRecognizer? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
        
        mealDetail.mealNameText = (lunchJson?.mealName)!
        mealDetail.image = lunchJson?.mealImg
        mealDetail.mealFatText = lunchJson?.mealFat
        mealDetail.mealCarbsText = lunchJson?.mealCarbs
        mealDetail.mealProteinText = lunchJson?.mealProtein
        mealDetail.cal = lunchJson?.mealCalories
            
        let nav = UINavigationController(rootViewController: mealDetail)
        
        mealDetail.title = "Recipe Details"
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true)
    }
    
    private func setUpDinner(dinnerData: [String: Any]) {
        let mealName = dinnerData["mealName"] as! String
        
        let calories = dinnerData["calories"] as? Double ?? Double(dinnerData["calories"] as! String)!
        
        //        let ingredients = dinnerData["ingredients"] as! [Any]
        
        let macronutrients = dinnerData["macronutrients"] as? [String: Any]
        
        let carbs = macronutrients!["carbs"] as! String
        let protein = macronutrients!["protein"] as! String
        let fat = macronutrients!["fat"] as! String
        
        Task {
            do {
                let image = try await ImageApiService().generateImage(mealName)
                dinnerMealImage.image = image.circleMasked
                
                let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: image)
                
                self.dinnerJson = meal
                
                let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDinner(_:)))
                self.dinnerContainer.addGestureRecognizer(tap)
                
            } catch {
                print(error)
            }
        }
        
        DispatchQueue.main.async {
            self.dinnerMealName.text = mealName
            self.dinnerCalories.text = "\(calories) kcal"
            self.dinnerCarbs.text = carbs
            self.dinnerProtein.text = protein
            self.dinnerFat.text = fat
            
            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.dinnerLineView)
            
        }
        
    }
    
    @objc func tapDinner(_ sender: UITapGestureRecognizer? = nil) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
        
        mealDetail.mealNameText = (dinnerJson?.mealName)!
        mealDetail.image = dinnerJson?.mealImg
        mealDetail.mealFatText = dinnerJson?.mealFat
        mealDetail.mealCarbsText = dinnerJson?.mealCarbs
        mealDetail.mealProteinText = dinnerJson?.mealProtein
        mealDetail.cal = dinnerJson?.mealCalories
            
        let nav = UINavigationController(rootViewController: mealDetail)
        
        mealDetail.title = "Recipe Details"
        
        nav.modalPresentationStyle = .fullScreen
        
        self.present(nav, animated: true)
    }
    
    private func setUpProportions(color: [UIColor], proportions: [Double], view: UIView) {
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
    
    private func percentToDouble(percent: String) -> Double {
        let percentageWithoutSymbol = percent.replacingOccurrences(of: "%", with: "")
        let percentInDouble = Double(percentageWithoutSymbol)
        
        return (percentInDouble! / 100.0).truncate(places: 2)
    }
}
