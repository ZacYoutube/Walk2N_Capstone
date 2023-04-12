//
//  NutritionalGuidanceViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/28/23.
//

import UIKit
import SwiftSpinner
import Firebase

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
    
    let db = DatabaseManager.shared
    
    var breakfastJson: Meal?
    var lunchJson: Meal?
    var dinnerJson: Meal?
    
    private let format = "{ 'breakfast': { 'mealName': 'the name of the breakfast meal', 'calories': '200', 'macronutrients': { 'carbs': '10%', 'protein': '20%', 'fat': '70%' },},}, the macronutrients are in percentage"
    private let breakfastActionPrompt = "recommend me a [BREAKFAST] meal"
    private let lunchActionPrompt = "recommend me a [LUNCH] meal"
    private let dinnerActionPrompt = "recommend me a [DINNER] meal"
    private let strictFormat = ". with no instructions or any information except for the format I specified. Just give me the json result!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpNavbar(text: "Meal")
        
        contentView.backgroundColor = UIColor.white
        
        initialMealLoading()
        
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
    
    private func initialMealLoading() {
        var originalPrompt: String = ""
        
        self.db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                let age = doc["age"] as? Double
                let height = doc["height"] as? Double
                let weight = doc["weight"] as? Double
                let gender = doc["gender"] as? String
                
                if age != nil {
                    originalPrompt += "I am \(String(describing: age)) years old. "
                }
                if gender != nil && gender != "" {
                    originalPrompt += "I am a \(String(describing: gender)). "
                }
                if weight != nil {
                    originalPrompt += "I weigh \(String(describing: weight)) kg. "
                }
                if height != nil {
                    originalPrompt += "And I am \(String(describing: height)) cm tall"
                }
                self.updateMealView(originalPrompt, updateBaesOnPreference: false)
            }
        }
    }
    
    private func updateMealView(_ prompt: String, updateBaesOnPreference: Bool) {
        let dispatchGroup = DispatchGroup()
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        
        DispatchQueue.main.async {
            
            let uid = Auth.auth().currentUser?.uid
            
            self.db.getRecommendations { docSnapshot in
                if docSnapshot.count == 0 || updateBaesOnPreference == true {
                    
                    dispatchGroup.enter()
                    self.retrieveMealInfo(prompt: prompt + self.breakfastActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "breakfast") {
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.enter()
                    self.retrieveMealInfo(prompt: prompt + self.lunchActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "lunch") {
                        dispatchGroup.leave()
                    }
                    
                    dispatchGroup.enter()
                    self.retrieveMealInfo(prompt: prompt + self.dinnerActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "dinner") {
                        dispatchGroup.leave()
                    }
                    dispatchGroup.notify(queue: .main) {
                        if updateBaesOnPreference == true {
                            self.db.updateRecom(uid: uid!, date: startOfDay, field: "breakfast", value: self.breakfastJson?.firestoreData as Any) { bool in }
                            self.db.updateRecom(uid: uid!, date: startOfDay, field: "lunch", value: self.lunchJson?.firestoreData as Any) { bool in }
                            self.db.updateRecom(uid: uid!, date: startOfDay, field: "dinner", value: self.dinnerJson?.firestoreData as Any) { bool in }
        
                        } else {
                            self.db.saveTodayRecom(meal: MealHist(uid: uid, breakfast: self.breakfastJson!, lunch: self.lunchJson!, dinner: self.dinnerJson!, date: startOfDay))
                        }
                        
//                                                        self.db.updateRecom(uid: uid!, date: startOfDay, field: "breakfast", value: self.breakfastJson!) { bool in }
//                                                        self.db.updateRecom(uid: uid!, date: startOfDay, field: "lunch", value: self.lunchJson!) { bool in }
//                                                        self.db.updateRecom(uid: uid!, date: startOfDay, field: "breakfast", value: self.dinnerJson!) { bool in }
                        
                    }
                }
                else {
                    for doc in docSnapshot {
                        let breakfastData = doc["breakfast"] as? [String: Any]
                        let lunchData = doc["lunch"] as? [String: Any]
                        let dinnerData = doc["dinner"] as? [String: Any]
                        
                        if breakfastData != nil {
                            let calories = breakfastData!["mealCalories"] as! Double
                            let carbs = breakfastData!["mealCarbs"] as! Double
                            let protein = breakfastData!["mealProtein"] as! Double
                            let fat = breakfastData!["mealFat"] as! Double
                            let name = breakfastData!["mealName"] as! String
                            let imgUrl = breakfastData!["mealImg"] as! String
                            
                            self.breakfastCalories.text = "\(calories) kcal"
                            self.breakfastMealName.text = name
                            self.breakfastCarbs.text = "\(Int(carbs * 100))%"
                            self.breakfastProtein.text = "\(Int(protein * 100))%"
                            self.breakfastFat.text = "\(Int(fat * 100))%"
                            
                            self.setUpImage(urlString: imgUrl, imageView: self.breakfastMealImage)
                            
                            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbs, protein, fat], view: self.breakfastLineView)
                            
                            self.breakfastJson = Meal(mealName: name, mealCalories: calories, mealCarbs: carbs, mealProtein: protein, mealFat: fat, mealImg: imgUrl)
                            self.breakfastJson?.setMealType(mealType: "breakfast")
                            
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBreakFast(_:)))
                            self.breakfastCookbook.isUserInteractionEnabled = true
                            self.breakfastCookbook.addGestureRecognizer(tap)
                            
                        }
                        
                        if lunchData != nil {
                            let calories = lunchData!["mealCalories"] as! Double
                            let carbs = lunchData!["mealCarbs"] as! Double
                            let protein = lunchData!["mealProtein"] as! Double
                            let fat = lunchData!["mealFat"] as! Double
                            let name = lunchData!["mealName"] as! String
                            let imgUrl = lunchData!["mealImg"] as! String
                            
                            self.lunchCalories.text = "\(calories) kcal"
                            self.lunchMealName.text = name
                            self.lunchCarbs.text = "\(Int(carbs * 100))%"
                            self.lunchProtein.text = "\(Int(protein * 100))%"
                            self.lunchFat.text = "\(Int(fat * 100))%"
                            
                            self.setUpImage(urlString: imgUrl, imageView: self.lunchMealImage)
                            
                            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbs, protein, fat], view: self.lunchLineView)
                            
                            self.lunchJson = Meal(mealName: name, mealCalories: calories, mealCarbs: carbs, mealProtein: protein, mealFat: fat, mealImg: imgUrl)
                            self.lunchJson?.setMealType(mealType: "lunch")
                            
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLunch(_:)))
                            self.lunchContainer.addGestureRecognizer(tap)
                        }
                        
                        if dinnerData != nil {
                            let calories = dinnerData!["mealCalories"] as! Double
                            let carbs = dinnerData!["mealCarbs"] as! Double
                            let protein = dinnerData!["mealProtein"] as! Double
                            let fat = dinnerData!["mealFat"] as! Double
                            let name = dinnerData!["mealName"] as! String
                            let imgUrl = dinnerData!["mealImg"] as! String
                            
                            self.dinnerCalories.text = "\(calories) kcal"
                            self.dinnerMealName.text = name
                            self.dinnerCarbs.text = "\(Int(carbs * 100))%"
                            self.dinnerProtein.text = "\(Int(protein * 100))%"
                            self.dinnerFat.text = "\(Int(fat * 100))%"
                            
                            self.setUpImage(urlString: imgUrl, imageView: self.dinnerMealImage)
                            
                            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbs, protein, fat], view: self.dinnerLineView)
                            
                            self.dinnerJson = Meal(mealName: name, mealCalories: calories, mealCarbs: carbs, mealProtein: protein, mealFat: fat, mealImg: imgUrl)
                            self.dinnerJson?.setMealType(mealType: "dinner")
                            
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDinner(_:)))
                            self.dinnerContainer.addGestureRecognizer(tap)
                        }
                    }
                }
            }
            
            
        }
        
    }
    
    @objc func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func handleNotification(_ notification: NSNotification) {
        print("closed!")
        
        if let data = notification.userInfo?["dietaryFilter"] as? DietFilter {
            let bloodSugarLevel = data.bloodSugarLevel
            let cholesterolLevel = data.cholesterolLevel
            let dietaryGoal = data.dietGoal
            let foodAlergies = data.foodAlergies
            let dietaryPreference = data.dietaryPreferences
            let cuisinePreference = data.cusinePreferences
            let otherInfo = data.otherInfo
            
            var newConditionalPrompt: String = ""
            var originalPrompt: String = ""
            
            if bloodSugarLevel != nil && bloodSugarLevel != "" {
                newConditionalPrompt += "My blood sugar level is \(String(describing: bloodSugarLevel!)) mg/dL. "
            }
            if cholesterolLevel != nil && cholesterolLevel != "" {
                newConditionalPrompt += "My cholesterol level is \(String(describing: cholesterolLevel!)) mg/dL. "
            }
            if dietaryGoal != nil && dietaryGoal != "" {
                newConditionalPrompt += "My diet goal is \(String(describing: dietaryGoal!)). "
            }
            if foodAlergies != nil && foodAlergies!.count > 0 {
                newConditionalPrompt += "I am alergic to the following food: "
                for i in 0..<foodAlergies!.count {
                    newConditionalPrompt += "\(foodAlergies![i]), "
                }
            }
            if dietaryPreference != nil && dietaryPreference != "" {
                newConditionalPrompt += "My dietary preference is \(String(describing: dietaryPreference!)). "
            }
            
            if cuisinePreference != nil && cuisinePreference != "" {
                newConditionalPrompt += "My favorite cuisines is \(String(describing: cuisinePreference!))dishes. "
            }
            
            if otherInfo != nil && otherInfo != "" {
                newConditionalPrompt += "Additionally, here is the things you need to watch out for: \(String(describing: otherInfo!))"
            }
            
            self.db.getUserInfo { docSnapshot in
                for doc in docSnapshot {
                    let age = doc["age"] as? Double
                    let height = doc["height"] as? Double
                    let weight = doc["weight"] as? Double
                    let gender = doc["gender"] as? String
                    
                    if age != nil {
                        originalPrompt += "I am \(String(describing: age!)) years old. "
                    }
                    if gender != nil && gender != "" {
                        originalPrompt += "I am a \(String(describing: gender!)). "
                    }
                    if weight != nil {
                        originalPrompt += "I weigh \(String(describing: weight!)) kg. "
                    }
                    if height != nil {
                        originalPrompt += "And I am \(String(describing: height!)) cm tall. "
                    }
                    
                    print(originalPrompt + " " + newConditionalPrompt)
                    self.updateMealView(originalPrompt + " " + newConditionalPrompt, updateBaesOnPreference: true)
                }
            }
        }
        
//        db.getUserDietaryFilter { docSnapshot in
//            if docSnapshot.count > 0 {
//                for doc in docSnapshot {
//                    let bloodSugarLevel = doc["bloodSugarLevel"] as? String
//                    let cholesterolLevel = doc["cholesterolLevel"] as? String
//                    let dietaryGoal = doc["dietGoal"] as? String
//                    let foodAlergies = doc["foodAlergies"] as? [String]
//                    let dietaryPreference = doc["dietaryPreferences"] as? String
//                    let cuisinePreference = doc["cusinePreferences"] as? String
//                    let otherInfo = doc["otherInfo"] as? String
//
//                    var newConditionalPrompt: String = ""
//                    var originalPrompt: String = ""
//
//                    if bloodSugarLevel != nil && bloodSugarLevel != "" {
//                        newConditionalPrompt += "My blood sugar level is \(String(describing: bloodSugarLevel!)) mg/dL. "
//                    }
//                    if cholesterolLevel != nil && cholesterolLevel != "" {
//                        newConditionalPrompt += "My cholesterol level is \(String(describing: cholesterolLevel!)) mg/dL. "
//                    }
//                    if dietaryGoal != nil && dietaryGoal != "" {
//                        newConditionalPrompt += "My diet goal is \(String(describing: dietaryGoal!)). "
//                    }
//                    if foodAlergies != nil && foodAlergies!.count > 0 {
//                        newConditionalPrompt += "I am alergic to the following food: "
//                        for i in 0..<foodAlergies!.count {
//                            newConditionalPrompt += "\(foodAlergies![i]), "
//                        }
//                    }
//                    if dietaryPreference != nil && dietaryPreference != "" {
//                        newConditionalPrompt += "My dietary preference is \(String(describing: dietaryPreference!)). "
//                    }
//
//                    if cuisinePreference != nil && cuisinePreference != "" {
//                        newConditionalPrompt += "My favorite cuisines is \(String(describing: cuisinePreference!))dishes. "
//                    }
//
//                    if otherInfo != nil && otherInfo != "" {
//                        newConditionalPrompt += "Additionally, here is the things you need to watch out for: \(String(describing: otherInfo!))"
//                    }
//
//                    self.db.getUserInfo { docSnapshot in
//                        for doc in docSnapshot {
//                            let age = doc["age"] as? Double
//                            let height = doc["height"] as? Double
//                            let weight = doc["weight"] as? Double
//                            let gender = doc["gender"] as? String
//
//                            if age != nil {
//                                originalPrompt += "I am \(String(describing: age!)) years old. "
//                            }
//                            if gender != nil && gender != "" {
//                                originalPrompt += "I am a \(String(describing: gender!)). "
//                            }
//                            if weight != nil {
//                                originalPrompt += "I weigh \(String(describing: weight!)) kg. "
//                            }
//                            if height != nil {
//                                originalPrompt += "And I am \(String(describing: height!)) cm tall. "
//                            }
//
//                            print(originalPrompt + " " + newConditionalPrompt)
//                            self.updateMealView(originalPrompt + " " + newConditionalPrompt, updateBaesOnPreference: true)
//                        }
//                    }
//
//                }
//            }
//        }
    }
    
    private func setUpImage(urlString: String, imageView: UIImageView) {
        guard let url = URL(string: urlString) else { return }
        
        // Create URLSession
        let session = URLSession.shared
        
        // Create data task to download image
        let task = session.dataTask(with: url) { (data, response, error) in
            // Handle errors
            if let error = error {
                print("Error downloading image: \(error)")
                return
            }
            
            // Check response status code
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("Error: invalid HTTP response code")
                return
            }
            
            // Set image on main thread
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    imageView.image = image.circleMasked
                }
            }
        }
        
        // Start data task to download image
        task.resume()
    }
    
    private func retrieveMealInfo(prompt: String, mealType: String, completion: @escaping () -> Void) {
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
                                    self.setUpBreakfast(breakfastData: breakfastObj!) {
                                        completion()
                                    }
                                }
                            }
                            if mealType == "lunch" {
                                let lunchObj = jsonObj["lunch"] as? [String: Any]
                                if lunchObj != nil {
                                    self.setUpLunch(lunchData: lunchObj!) {
                                        completion()
                                    }
                                }
                            }
                            if mealType == "dinner" {
                                let dinnerObj = jsonObj["dinner"] as? [String: Any]
                                if dinnerObj != nil {
                                    self.setUpDinner(dinnerData: dinnerObj!) {
                                        completion()
                                    }
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
    
    private func setUpBreakfast(breakfastData: [String: Any], completion: @escaping () -> Void) {
        
        let mealName = breakfastData["mealName"] as! String
        
        let calories = breakfastData["calories"] as? Double ?? Double(breakfastData["calories"] as! String)!
        
        let macronutrients = breakfastData["macronutrients"] as? [String: Any]
        
        let carbs = macronutrients!["carbs"] as! String
        let protein = macronutrients!["protein"] as! String
        let fat = macronutrients!["fat"] as! String
        
        do {
            try ImageApiService().generateImage(mealName, completion: { url in
                guard let imageURL = URL(string: url!) else {
                    print("invalid url")
                    return
                }
                let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
                    guard let data = data, error == nil else {
                        // Handle error
                        return
                    }
                    do {
                        guard let image = UIImage(data: data) else {
                            throw RetrieveImageError.unableToGetImage
                        }
                        DispatchQueue.main.async {
                            self.breakfastMealImage.image = image.circleMasked
                        }
                        let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
                        
                        self.breakfastJson = meal
                        
                        DispatchQueue.main.async {
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBreakFast(_:)))
                            self.breakfastCookbook.isUserInteractionEnabled = true
                            self.breakfastCookbook.addGestureRecognizer(tap)
                        }
                        
                        
                        completion()
                    } catch {
                        print(error)
                    }
                }
                task.resume()
            })
        }
        catch {
            print(error)
        }
        
        //            Task {
        //                do {
        //                    let url = try await ImageApiService().generateImage(mealName)
        //                    guard let imageURL = URL(string: url) else {
        //                        throw RetrieveImageError.unableToCreateUrl
        //                    }
        //
        //                    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        //
        //                    guard let image = UIImage(data: imageData) else {
        //                        throw RetrieveImageError.unableToGetImage
        //                    }
        //
        //                    self.breakfastMealImage.image = image.circleMasked
        //                    let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
        //
        //                    self.breakfastJson = meal
        //
        //                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBreakFast(_:)))
        //                    self.breakfastCookbook.isUserInteractionEnabled = true
        //                    self.breakfastCookbook.addGestureRecognizer(tap)
        //
        //                    completion()
        //
        //                } catch {
        //                    print(error)
        //                }
        //            }
        
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
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
            
            mealDetail.mealNameText = (self.breakfastJson?.mealName)!
            mealDetail.imageUrl = self.breakfastJson?.mealImg
            
            mealDetail.mealFatText = self.breakfastJson?.mealFat
            mealDetail.mealCarbsText = self.breakfastJson?.mealCarbs
            mealDetail.mealProteinText = self.breakfastJson?.mealProtein
            mealDetail.cal = self.breakfastJson?.mealCalories
            mealDetail.mealType = "breakfast"
            
            let nav = UINavigationController(rootViewController: mealDetail)
            
            mealDetail.title = "Recipe Details"
            
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
        }
        
    }
    
    private func setUpLunch(lunchData: [String: Any], completion: @escaping () -> Void) {
        
        let mealName = lunchData["mealName"] as! String
        
        let calories = lunchData["calories"] as? Double ?? Double(lunchData["calories"] as! String)!
        
        let macronutrients = lunchData["macronutrients"] as? [String: Any]
        
        let carbs = macronutrients!["carbs"] as! String
        let protein = macronutrients!["protein"] as! String
        let fat = macronutrients!["fat"] as! String
        
        do {
            try ImageApiService().generateImage(mealName, completion: { url in
                guard let imageURL = URL(string: url!) else {
                    print("invalid url")
                    return
                }
                let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
                    guard let data = data, error == nil else {
                        // Handle error
                        return
                    }
                    do {
                        guard let image = UIImage(data: data) else {
                            throw RetrieveImageError.unableToGetImage
                        }
                        DispatchQueue.main.async {
                            self.lunchMealImage.image = image.circleMasked
                        }
                        let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
                        
                        self.lunchJson = meal
                        
                        DispatchQueue.main.async {
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLunch(_:)))
                            self.lunchContainer.addGestureRecognizer(tap)
                        }
                        
                        
                        completion()
                        
                    } catch {
                        print(error)
                    }
                }
                task.resume()
            })
        }
        catch {
            print(error)
        }
        
        //            Task {
        //                do {
        //                    let url = try await ImageApiService().generateImage(mealName)
        //                    guard let imageURL = URL(string: url) else {
        //                        throw RetrieveImageError.unableToCreateUrl
        //                    }
        //
        //                    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        //
        //                    guard let image = UIImage(data: imageData) else {
        //                        throw RetrieveImageError.unableToGetImage
        //                    }
        //
        //                    self.lunchMealImage.image = image.circleMasked
        //
        //
        //                    let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
        //
        //                    self.lunchJson = meal
        //
        //
        //                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLunch(_:)))
        //                    self.lunchContainer.addGestureRecognizer(tap)
        //
        //                    completion()
        //
        //                } catch {
        //                    print(error)
        //                }
        //            }
        
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
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
            
            mealDetail.mealNameText = (self.lunchJson?.mealName)!
            mealDetail.imageUrl = self.lunchJson?.mealImg
            mealDetail.mealFatText = self.lunchJson?.mealFat
            mealDetail.mealCarbsText = self.lunchJson?.mealCarbs
            mealDetail.mealProteinText = self.lunchJson?.mealProtein
            mealDetail.cal = self.lunchJson?.mealCalories
            mealDetail.mealType = "lunch"
            
            let nav = UINavigationController(rootViewController: mealDetail)
            
            mealDetail.title = "Recipe Details"
            
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
        }
        
    }
    
    private func setUpDinner(dinnerData: [String: Any], completion: @escaping () -> Void) {
        
        let mealName = dinnerData["mealName"] as! String
        
        let calories = dinnerData["calories"] as? Double ?? Double(dinnerData["calories"] as! String)!
        
        let macronutrients = dinnerData["macronutrients"] as? [String: Any]
        
        let carbs = macronutrients!["carbs"] as! String
        let protein = macronutrients!["protein"] as! String
        let fat = macronutrients!["fat"] as! String
        
        do {
            try ImageApiService().generateImage(mealName, completion: { url in
                guard let imageURL = URL(string: url!) else {
                    print("invalid url")
                    return
                }
                let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
                    guard let data = data, error == nil else {
                        // Handle error
                        return
                    }
                    do {
                        guard let image = UIImage(data: data) else {
                            throw RetrieveImageError.unableToGetImage
                        }
                        DispatchQueue.main.async {
                            self.dinnerMealImage.image = image.circleMasked
                        }
                        let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
                        
                        self.dinnerJson = meal
                        
                        DispatchQueue.main.async {
                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDinner(_:)))
                            self.dinnerContainer.addGestureRecognizer(tap)
                        }
                        
                        
                        completion()
                        
                    } catch {
                        print(error)
                    }
                }
                task.resume()
            })
        }
        catch {
            print(error)
        }
        
        //            Task {
        //                do {
        //                    let url = try await ImageApiService().generateImage(mealName)
        //                    guard let imageURL = URL(string: url) else {
        //                        throw RetrieveImageError.unableToCreateUrl
        //                    }
        //
        //                    let (imageData, _) = try await URLSession.shared.data(from: imageURL)
        //
        //                    guard let image = UIImage(data: imageData) else {
        //                        throw RetrieveImageError.unableToGetImage
        //                    }
        //
        //                    self.dinnerMealImage.image = image.circleMasked
        //
        //                    let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
        //
        //                    self.dinnerJson = meal
        //
        //                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDinner(_:)))
        //                    self.dinnerContainer.addGestureRecognizer(tap)
        //
        //                    completion()
        //
        //                } catch {
        //                    print(error)
        //                }
        //            }
        
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
        DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
            
            mealDetail.mealNameText = (self.dinnerJson?.mealName)!
            
            mealDetail.imageUrl = self.dinnerJson?.mealImg
            mealDetail.mealFatText = self.dinnerJson?.mealFat
            mealDetail.mealCarbsText = self.dinnerJson?.mealCarbs
            mealDetail.mealProteinText = self.dinnerJson?.mealProtein
            mealDetail.cal = self.dinnerJson?.mealCalories
            mealDetail.mealType = "dinner"
            
            let nav = UINavigationController(rootViewController: mealDetail)
            
            mealDetail.title = "Recipe Details"
            
            nav.modalPresentationStyle = .fullScreen
            
            self.present(nav, animated: true)
        }
        
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
