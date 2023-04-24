//
//  NutritionalGuidanceViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/28/23.
//

import UIKit
import SwiftSpinner
import Firebase

class NutritionalGuidanceViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = models[indexPath.row]
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.textColor = .white
        
        if indexPath.row % 2 == 1 {
            cell.backgroundColor = .grayish
            cell.textLabel?.textColor = .lessDark
        }
        else {
            cell.backgroundColor = .lightGreen
        }
        return cell
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            models.append(text)
            GptApiService().getGptResponse(messagePrompt: text) { str in
                self.models.append(str)
                DispatchQueue.main.async {
                    self.table.reloadData()
                    self.textField.text = nil
                }
            }
        }
        return true
    }
    
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var filterBtn: UIImageView!
    
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
    
    @IBOutlet weak var breakfastCookbook: UIImageView!
    @IBOutlet weak var lunchCookbook: UIImageView!
    @IBOutlet weak var dinnerCookbook: UIImageView!
    
    @IBOutlet weak var regenerateBtn: UIButton!
    @IBOutlet weak var breakfastViewToHideHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var lunchViewToHideHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dinnerViewToHideHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var dailyCaloriesContainer: UIView!
    @IBOutlet weak var dailyMealB: UIView!
    @IBOutlet weak var dailyMealL: UIView!
    @IBOutlet weak var dailyMealD: UIView!
    
    @IBOutlet weak var backBtn: UIButton!
    
//    @IBOutlet weak var activeCal: UILabel!
//    @IBOutlet weak var activityLevel: UILabel!
//    @IBOutlet weak var mealCal: UILabel!
//    @IBOutlet weak var TDEEText: UILabel!
    
    @IBOutlet weak var addBreakfast: UIButton!
    @IBOutlet weak var addLunch: UIButton!
    @IBOutlet weak var addDinner: UIButton!
    
    @IBOutlet weak var loggedBreakfastName: UILabel!
    @IBOutlet weak var loggedBreakfastCal: UILabel!
    @IBOutlet weak var loggedBreakfastCarb: UILabel!
    @IBOutlet weak var loggedBreakfastProtein: UILabel!
    @IBOutlet weak var loggedBreakfastFat: UILabel!
    @IBOutlet weak var loggedBreakfastImg: UIImageView!
    
    @IBOutlet weak var loggedLunchCal: UILabel!
    @IBOutlet weak var loggedLunchCarb: UILabel!
    @IBOutlet weak var loggedLunchProtein: UILabel!
    @IBOutlet weak var loggedLunchFat: UILabel!
    @IBOutlet weak var loggedLunchImg: UIImageView!
    @IBOutlet weak var loggedLunchName: UILabel!
    
    @IBOutlet weak var loggedDinnerCal: UILabel!
    @IBOutlet weak var loggedDinnerCarb: UILabel!
    @IBOutlet weak var loggedDinnerProtein: UILabel!
    @IBOutlet weak var loggedDinnerFat: UILabel!
    @IBOutlet weak var loggedDinnerImg: UIImageView!
    @IBOutlet weak var loggedDinnerName: UILabel!
    
    @IBOutlet weak var loggedBreakfastBar: UIView!
    @IBOutlet weak var loggedLunchBar: UIView!
    @IBOutlet weak var loggedDinnerBar: UIView!
    
    @IBOutlet weak var recomText: UILabel!
    @IBOutlet weak var dailyCalories: UILabel!
    
    @IBOutlet weak var bloodSugarContainer: UIView!
    @IBOutlet weak var bloodSugarText: UILabel!
    @IBOutlet weak var bloodSugarLabel: UILabel!
    
    @IBOutlet weak var cholesterolContainer: UIView!
    @IBOutlet weak var cholesterolLabel: UILabel!

    @IBOutlet weak var dietGoalText: UILabel!
    @IBOutlet weak var goalPreferContainer: UIView!
    @IBOutlet weak var dietPreferText: UILabel!
    @IBOutlet weak var alergiesContainer: UIView!
    @IBOutlet weak var alergiesText: UITextView!
    @IBOutlet weak var restrictionsContainer: UIView!
    @IBOutlet weak var dietRestrictions: UITextView!
    
//    @IBOutlet weak var chatView: UIView!
    
    let db = DatabaseManager.shared
    
    var breakfastJson: Meal?
    var lunchJson: Meal?
    var dinnerJson: Meal?
    
    private let format = "{ 'breakfast': { 'mealName': 'the name of the breakfast meal', 'calories': '200', 'macronutrients': { 'carbs': '10%', 'protein': '20%', 'fat': '70%' },},}, the macronutrients are in percentage"
    private let breakfastActionPrompt = "recommend me a [BREAKFAST] meal that adds up to TDEE calories"
    private let lunchActionPrompt = "recommend me a [LUNCH] meal that adds up to TDEE calories"
    private let dinnerActionPrompt = "recommend me a [DINNER] meal that adds up to TDEE calories"
    private let strictFormat = ". with no instructions or any information except for the format I specified. Just give me the json result!"

    private let textField: UITextField = {
        let text = UITextField()
        text.placeholder = "Type here..."
        text.translatesAutoresizingMaskIntoConstraints = false
        text.backgroundColor = .white
        text.layer.cornerRadius = 8
        text.returnKeyType = .done
        return text
    }()
    
    private let table: UITableView = {
       let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    private var models = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        models.append("Hello")
        models.append("It is good that you are ")
        
        contentView.backgroundColor = UIColor.white
        setUpDietMetrics()
//        initialMealLoading(run: true) { _ in }
//        getActivities()
        loadLoggedMeal()
//        hideRecoms()
        
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
//        breakfastContainer.backgroundColor = .background1
//        breakfastContainer.layer.cornerRadius = 8
//
//        lunchContainer.backgroundColor = .background1
//        lunchContainer.layer.cornerRadius = 8
//
//        dinnerContainer.backgroundColor = .background1
//        dinnerContainer.layer.cornerRadius = 8
//
//        breakfastMealName.numberOfLines = 2
//        breakfastMealName.lineBreakMode = NSLineBreakMode.byWordWrapping
//
//        lunchMealName.numberOfLines = 2
//        lunchMealName.lineBreakMode = NSLineBreakMode.byWordWrapping
//
//        dinnerMealName.numberOfLines = 2
//        dinnerMealName.lineBreakMode = NSLineBreakMode.byWordWrapping
//
//        breakfastLineView.layer.cornerRadius = 4
//        lunchLineView.layer.cornerRadius = 4
//        dinnerLineView.layer.cornerRadius = 4
        
        bloodSugarContainer.backgroundColor = .background1
        bloodSugarContainer.layer.cornerRadius = 8
        
        cholesterolContainer.backgroundColor = .background1
        cholesterolContainer.layer.cornerRadius = 8
        
        goalPreferContainer.backgroundColor = .background1
        goalPreferContainer.layer.cornerRadius = 8
        
        alergiesContainer.backgroundColor = .background1
        alergiesContainer.layer.cornerRadius = 8
        alergiesText.backgroundColor = .background1
        
        restrictionsContainer.backgroundColor = .background1
        restrictionsContainer.layer.cornerRadius = 8
        dietRestrictions.backgroundColor = .background1
        
        loggedBreakfastBar.layer.cornerRadius = 4
        loggedLunchBar.layer.cornerRadius = 4
        loggedDinnerBar.layer.cornerRadius = 4
        
//        dailyCaloriesContainer.backgroundColor = .background1
        dailyMealB.backgroundColor = .background1
        dailyMealL.backgroundColor = .background1
        dailyMealD.backgroundColor = .background1
//        chatView.backgroundColor = .background1
//
//        dailyCaloriesContainer.layer.cornerRadius = 8
        dailyMealB.layer.cornerRadius = 8
        dailyMealL.layer.cornerRadius = 8
        dailyMealD.layer.cornerRadius = 8
//        chatView.layer.cornerRadius = 8
        table.layer.cornerRadius = 8
        table.backgroundColor = .grayish
        
        textField.delegate = self
        table.delegate = self
        table.dataSource = self
        
//        chatView.addSubview(textField)
//        chatView.addSubview(table)
        
//        NSLayoutConstraint.activate([
//            textField.heightAnchor.constraint(equalToConstant: 50),
//            textField.leftAnchor.constraint(equalTo: chatView.leftAnchor, constant: 5),
//            textField.rightAnchor.constraint(equalTo: chatView.rightAnchor, constant: -5),
//            textField.bottomAnchor.constraint(equalTo: chatView.bottomAnchor, constant: -5),
//
//            table.leftAnchor.constraint(equalTo: chatView.leftAnchor, constant: 5),
//            table.rightAnchor.constraint(equalTo: chatView.rightAnchor, constant: -5),
//            table.topAnchor.constraint(equalTo: chatView.topAnchor, constant: 5),
//            table.bottomAnchor.constraint(equalTo: textField.topAnchor, constant: -5)
//        ])
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        filterBtn.isUserInteractionEnabled = true
        filterBtn.addGestureRecognizer(tapGestureRecognizer)
        
        
        addBreakfast.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let saveMealViewController = storyboard.instantiateViewController(identifier: "SaveMealViewController") as! SaveMealViewController
            saveMealViewController.title = "Log Meal"
            saveMealViewController.mealType = "breakfast"
            
            let nav = UINavigationController(rootViewController: saveMealViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
        addLunch.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let saveMealViewController = storyboard.instantiateViewController(identifier: "SaveMealViewController") as! SaveMealViewController
            saveMealViewController.title = "Log Meal"
            saveMealViewController.mealType = "lunch"
            
            let nav = UINavigationController(rootViewController: saveMealViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
        addDinner.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let saveMealViewController = storyboard.instantiateViewController(identifier: "SaveMealViewController") as! SaveMealViewController
            saveMealViewController.title = "Log Meal"
            saveMealViewController.mealType = "dinner"
            
            let nav = UINavigationController(rootViewController: saveMealViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
//        filterBtn.setOnClickListener {

//        }
        
        backBtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        
        self.hideKeyboardWhenTappedAround()
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleMetrics(_:)), name:NSNotification.Name(rawValue: "nutritionalFilter"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleSaveMeal(_:)), name:NSNotification.Name(rawValue: "mealSave"), object: nil)
        
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
    
//    private func hideRecoms() {
//        let today = Date()
//        db.getUserInfo { docSnapshot in
//            for doc in docSnapshot {
//                let mealHist = doc["mealHist"] as? [Any]
//                if mealHist != nil && mealHist!.count > 0 {
//                    for i in 0..<mealHist!.count {
//                        let meal = mealHist![i] as! [String: Any]
//                        let date = (meal["date"] as! Timestamp).dateValue()
//                        if self.isSameDay(date, today) {
//                            let breakfast = meal["breakfast"] as? [String: Any]
//                            let lunch = meal["lunch"] as? [String: Any]
//                            let dinner = meal["dinner"] as? [String: Any]
//                            if breakfast != nil {
//                                self.breakfastContainer.isHidden = true
//                                self.breakfastViewToHideHeightConstraint.constant = 0
//                                self.toggleContainerView(currentView: self.breakfastContainer, topView: self.recomText, bottomView: self.lunchContainer, activate: true)
//                            }
//                            else {
//                                self.breakfastContainer.isHidden = false
//                                self.breakfastViewToHideHeightConstraint.constant = 170
//                                self.toggleContainerView(currentView: self.breakfastContainer, topView: self.recomText, bottomView: self.lunchContainer, activate: false)
//                            }
//                            if lunch != nil {
//                                self.lunchContainer.isHidden = true
//                                self.lunchViewToHideHeightConstraint.constant = 0
//                                self.toggleContainerView(currentView: self.lunchContainer, topView: self.breakfastContainer, bottomView: self.dinnerContainer, activate: true)
//                            }
//                            else {
//                                self.lunchContainer.isHidden = false
//                                self.lunchViewToHideHeightConstraint.constant = 170
//                                self.toggleContainerView(currentView: self.lunchContainer, topView: self.breakfastContainer, bottomView: self.dinnerContainer, activate: false)
//                            }
//
//                            if dinner != nil {
//                                self.dinnerContainer.isHidden = true
//                                self.dinnerViewToHideHeightConstraint.constant = 0
//                                self.toggleContainerView(currentView: self.dinnerContainer, topView: self.lunchContainer, bottomView: self.dailyCalories, activate: true)
//                            }
//                            else {
//                                self.dinnerContainer.isHidden = false
//                                self.dinnerViewToHideHeightConstraint.constant = 170
//                                self.toggleContainerView(currentView: self.dinnerContainer, topView: self.lunchContainer, bottomView: self.dailyCalories, activate: false)
//                            }
//                        }
//                    }
//                }
//            }
//        }
//    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let filterVC = storyboard.instantiateViewController(identifier: "filterVC")
        filterVC.title = "Health Metrics"
        
        let nav = UINavigationController(rootViewController: filterVC)
        nav.modalPresentationStyle = .fullScreen
        self.present(nav, animated: true)
    }
    
    private func setUpDietMetrics() {
        db.getUserDietaryFilter { docSnapshot in
            for doc in docSnapshot {
                let bloodSugarLevel = doc["bloodSugarLevel"] as? String
                let cholesterolLevel = doc["cholesterolLevel"] as? String
                let cusinePreferences = doc["cusinePreferences"] as? String
                let dietGoal = doc["dietGoal"] as? String
                let dietaryPreferences = doc["dietaryPreferences"] as? String
                let foodAlergies = doc["foodAlergies"] as? [String]
                
                if bloodSugarLevel != nil {
                    self.bloodSugarText.text = "\(bloodSugarLevel!)"
                    self.bloodSugarLabel.text = "\(bloodSugarLevel!) mg/dL"
                }
                if cholesterolLevel != nil {
                    self.cholesterolLabel.text = "\(cholesterolLevel!) mg/dL"
                }
                if cusinePreferences != nil {
                    self.dietPreferText.text = "\(cusinePreferences!)"
                }
                if dietGoal != nil {
                    self.dietGoalText.text = "\(dietGoal!)"
                }
                if dietaryPreferences != nil {
                    self.dietRestrictions.text = "\(dietaryPreferences!)"
                }
                if foodAlergies != nil {
                    var str = ""
                    for i in 0..<foodAlergies!.count {
                        str += foodAlergies![i] + " "
                    }
                    self.alergiesText.text = str
                }
            }
        }
    }
    
    private func initialMealLoading(run: Bool, _ completion: @escaping (String) -> Void) {
        var originalPrompt: String = ""

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

                self.db.getUserDietaryFilter { filterDocSnapshot in
                    for filterDoc in filterDocSnapshot {
                        let bloodSugarLevel = filterDoc["bloodSugarLevel"] as? String
                        let cholesterolLevel = filterDoc["cholesterolLevel"] as? String
                        let cusinePreferences = filterDoc["cusinePreferences"] as? String
                        let dietGoal = filterDoc["dietGoal"] as? String
                        let dietaryPreferences = filterDoc["dietaryPreferences"] as? String
                        let foodAlergies = filterDoc["foodAlergies"] as? [String]
                        let otherInfo = filterDoc["otherInfo"] as? String

                        if bloodSugarLevel != nil && bloodSugarLevel != "" {
                            originalPrompt += "My blood sugar level is \(bloodSugarLevel!) mg/dL. "
                        }
                        if cholesterolLevel != nil  && cholesterolLevel != "" {
                            originalPrompt += "My cholesterol level is \(cholesterolLevel!) mg/dL. "
                        }
                        if cusinePreferences != nil && cusinePreferences != "" {
                            originalPrompt += "My preferred cuisine style is \(cusinePreferences!) dishes. "
                        }
                        if dietGoal != nil && dietGoal != ""{
                            originalPrompt += "My diet goal is to \(dietGoal!). "
                        }
                        if dietaryPreferences != nil && dietaryPreferences != "" {
                            originalPrompt += "My dietary restriction is \(dietaryPreferences!). "
                        }
                        if foodAlergies != nil {
                            var foodAlergiesStr = ""
                            if foodAlergies!.count > 0 {
                                for i in 0..<foodAlergies!.count {
                                    foodAlergiesStr += (foodAlergies![i] + ", ")
                                }
                                originalPrompt += "I am alergic to the following food: \(foodAlergiesStr). "
                            }
                        }
                        if otherInfo != nil && otherInfo != "" {
                            originalPrompt += "Watch out for the following information: \(otherInfo!). "
                        }
                    }
                    
                    self.getActivities { (TDEE, ActLevel, ActCal, MealCal) in
                        originalPrompt += "My TDEE calories is \(TDEE). "
                        originalPrompt += "My activity level is \(ActLevel). "
                        originalPrompt += "My active calory consumed is \(ActCal). "
                        originalPrompt += "My calory intake from food so far is \(MealCal). "
//                        originalPrompt += " Recommend me the meals that matches with my TDEE calories and my diet goal."
                    }

//                    originalPrompt += "My TDEE calories is \(String(describing: self.TDEEText.text!)). "
//                    originalPrompt += "My activity level is \(String(describing: self.activityLevel.text!)). "
//                    originalPrompt += "My active calory consumed is \(String(describing: self.activeCal.text!)). "
//                    originalPrompt += "My calory intake from food so far is \(String(describing: self.mealCal.text!)). "
//                    originalPrompt += " Recommend me the meals that matches with my TDEE calories and my diet goal."
//                    print("initial prompt",originalPrompt)

                    completion(originalPrompt)

                    if run == true {
//                        self.updateMealView(originalPrompt, updateBaesOnPreference: false, saveMeal: false)
                    }
                }
            }
        }
    }
    
    private func toggleContainerView(currentView: UIView, topView: UIView, bottomView: UIView, activate: Bool) {
        let bottomConstraint = NSLayoutConstraint(item: topView, attribute: .bottom, relatedBy: .equal, toItem: bottomView, attribute: .top, multiplier: 1, constant: -20)
        if activate == true {
            NSLayoutConstraint.activate([bottomConstraint])
        }
        else {
            NSLayoutConstraint.deactivate([bottomConstraint])
        }
        currentView.superview?.layoutIfNeeded()
    }
    
    private func loadLoggedMeal() {
        let today = Date()
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                let mealHist = doc["mealHist"] as? [Any]
                
                if mealHist != nil && mealHist!.count > 0 {
                    for i in 0..<mealHist!.count {
                        let meal = mealHist![i] as! [String: Any]
                        let date = (meal["date"] as! Timestamp).dateValue()
                        if self.isSameDay(date, today) {
                            let breakfast = meal["breakfast"] as? [String: Any]
                            let lunch = meal["lunch"] as? [String: Any]
                            let dinner = meal["dinner"] as? [String: Any]
                            
                            self.addBreakfast.isHidden = false
                            self.addLunch.isHidden = false
                            self.addDinner.isHidden = false
                            
                            if breakfast != nil {
                                self.addBreakfast.isHidden = true
                                let cal = breakfast!["mealCalories"] as? Double ?? 0.0
                                let carbs = breakfast!["mealCarbs"] as? Double ?? 0.0
                                let fat = breakfast!["mealFat"] as? Double ?? 0.0
                                let protein = breakfast!["mealProtein"] as? Double ?? 0.0
                                let imgUrl = breakfast!["mealImg"] as? String ?? ""
                                let mealName = breakfast!["mealName"] as? String ?? ""
                                
                                let totals = carbs + protein + fat
                                
                                let carbPercent = Double(carbs / totals)
                                let proteinPercent = Double(protein / totals)
                                let fatPercent = Double(fat / totals)
                                
                                self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbPercent, proteinPercent, fatPercent], view: self.loggedBreakfastBar)
                                
                                DispatchQueue.main.async {
                                    self.loggedBreakfastName.text = mealName
                                    self.loggedBreakfastCal.text = "\(cal) kcal"
                                    self.loggedBreakfastCarb.text = "\(Int(carbPercent * 100))%"
                                    self.loggedBreakfastProtein.text = "\(Int(proteinPercent * 100))%"
                                    self.loggedBreakfastFat.text = "\(Int(fatPercent * 100))%"
                                    
                                    if let url = URL(string: imgUrl) {
                                        DispatchQueue.global().async {
                                            if let data = try? Data(contentsOf: url) {
                                                if let image = UIImage(data: data) {
                                                    DispatchQueue.main.async {
                                                        self.loggedBreakfastImg.image = image.circleMasked
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if lunch != nil {
                                self.addLunch.isHidden = true
                                let cal = lunch!["mealCalories"] as? Double ?? 0.0
                                let carbs = lunch!["mealCarbs"] as? Double ?? 0.0
                                let fat = lunch!["mealFat"] as? Double ?? 0.0
                                let protein = lunch!["mealProtein"] as? Double ?? 0.0
                                let imgUrl = lunch!["mealImg"] as? String ?? ""
                                let mealName = lunch!["mealName"] as? String ?? ""
                                
                                let totals = carbs + protein + fat
                                
                                let carbPercent = Double(carbs / totals)
                                let proteinPercent = Double(protein / totals)
                                let fatPercent = Double(fat / totals)
                                
                                self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbPercent, proteinPercent, fatPercent], view: self.loggedLunchBar)
                                
                                DispatchQueue.main.async {
                                    self.loggedLunchName.text = mealName
                                    self.loggedLunchCal.text = "\(cal) kcal"
                                    self.loggedLunchCarb.text = "\(Int(carbPercent * 100))%"
                                    self.loggedLunchProtein.text = "\(Int(proteinPercent * 100))%"
                                    self.loggedLunchFat.text = "\(Int(fatPercent * 100))%"
                                    
                                    if let url = URL(string: imgUrl) {
                                        DispatchQueue.global().async {
                                            if let data = try? Data(contentsOf: url) {
                                                if let image = UIImage(data: data) {
                                                    DispatchQueue.main.async {
                                                        self.loggedLunchImg.image = image.circleMasked
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            if dinner != nil {
                                self.addDinner.isHidden = true
                                let cal = dinner!["mealCalories"] as? Double ?? 0.0
                                let carbs = dinner!["mealCarbs"] as? Double ?? 0.0
                                let fat = dinner!["mealFat"] as? Double ?? 0.0
                                let protein = dinner!["mealProtein"] as? Double ?? 0.0
                                let imgUrl = dinner!["mealImg"] as? String ?? ""
                                let mealName = dinner!["mealName"] as? String ?? ""
                                
                                let totals = carbs + protein + fat
                                
                                let carbPercent = Double(carbs / totals)
                                let proteinPercent = Double(protein / totals)
                                let fatPercent = Double(fat / totals)
                                
                                self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbPercent, proteinPercent, fatPercent], view: self.loggedDinnerBar)
                                
                                DispatchQueue.main.async {
                                    self.loggedDinnerName.text = mealName
                                    self.loggedDinnerCal.text = "\(cal) kcal"
                                    self.loggedDinnerCarb.text = "\(Int(carbPercent * 100))%"
                                    self.loggedDinnerProtein.text = "\(Int(proteinPercent * 100))%"
                                    self.loggedDinnerFat.text = "\(Int(fatPercent * 100))%"
                                    
                                    if let url = URL(string: imgUrl) {
                                        DispatchQueue.global().async {
                                            if let data = try? Data(contentsOf: url) {
                                                if let image = UIImage(data: data) {
                                                    DispatchQueue.main.async {
                                                        self.loggedDinnerImg.image = image.circleMasked
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    private func getActivities(_ completion:@escaping((String, String, String, String))->Void?) {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["weight"] != nil && doc["weight"] as? Double != nil
                    && doc["height"] != nil && doc["height"] as? Double != nil
                    && doc["gender"] != nil && doc["gender"] as? String != nil
                    && doc["age"] != nil && doc["age"] as? Double != nil
                {
                    var activeLevel: String = ""
                    var activeLevelFactor: Double = 0
                    HealthKitManager().gettingActivityLevel(date: Date()) { cal in
                        print("active level", cal)
                        if Double(cal).truncate(places: 2) <= 1000.0 {
                            activeLevel = "Sedantary"
                            activeLevelFactor = 1.2
                        }
                        else if Double(cal).truncate(places: 2) > 1000.0 && Double(cal).truncate(places: 2) <= 2000.0 {
                            activeLevel = "Low Active"
                            activeLevelFactor = 1.375
                        }
                        else if Double(cal).truncate(places: 2) > 2000.0 && Double(cal).truncate(places: 2) <= 3000.0 {
                            activeLevel = "Active"
                            activeLevelFactor = 1.55
                        }
                        else {
                            activeLevel = "Very Active"
                            activeLevelFactor = 1.725
                        }
                        let weight = doc["weight"] as! Double
                        let height = doc["height"] as! Double
                        let age = doc["age"] as! Double
                        let gender = doc["gender"] as! String

                        var s: Double = 0

                        if gender == "Male" {
                            s = 5
                        }
                        else {
                            s = -161
                        }

                        let BMR = 10 * weight + 6.25 * height - 5 * age + s
                        let TDEE = BMR * activeLevelFactor
                        var mealCal: Double? = 0

                        let mealHist = doc["mealHist"] as? [Any]
                        let today = Date()
                        if mealHist == nil || mealHist!.count == 0 {
                            mealCal = 0
                        } else {
                            for i in 0..<mealHist!.count {
                                let meal = mealHist![i] as! [String: Any]
                                let breakfast = meal["breakfast"] as? [String: Any]
                                let lunch = meal["lunch"] as? [String: Any]
                                let dinner = meal["dinner"] as? [String: Any]

                                var breakfastCal = 0.0
                                if breakfast != nil {
                                    breakfastCal = breakfast!["mealCalories"] as? Double ?? 0.0
                                }
                                var lunchCal = 0.0
                                if lunch != nil {
                                    lunchCal = lunch!["mealCalories"] as? Double ?? 0.0
                                }
                                var dinnerCal = 0.0
                                if dinner != nil {
                                    dinnerCal = dinner!["mealCalories"] as? Double ?? 0.0
                                }

                                let date = (meal["date"] as! Timestamp).dateValue()
                                if self.isSameDay(today, date) {
                                    mealCal = breakfastCal + lunchCal + dinnerCal
                                }
                            }
                        }
                        
                        completion(("\(TDEE.truncate(places: 2))", activeLevel, "\(Double(cal).truncate(places: 2))", "\(String(describing: mealCal!))"))

//                        DispatchQueue.main.async {
//                            self.activeCal.text = "\(Double(cal).truncate(places: 2))"
//                            self.activityLevel.text = activeLevel
//                            self.TDEEText.text = "\(TDEE.truncate(places: 2))"
//                            self.mealCal.text = "\(String(describing: mealCal!))"
//                        }
                    }
                }
            }
        }

    }
    
//    private func updateMealView(_ prompt: String, updateBaesOnPreference: Bool, saveMeal: Bool) {
//        let dispatchGroup = DispatchGroup()
//        let calendar = Calendar.current
//        let today = Date()
//        let startOfDay = calendar.startOfDay(for: today)
//
//        DispatchQueue.main.async {
//
//            let uid = Auth.auth().currentUser?.uid
//
//            self.db.getRecommendations { docSnapshot in
//                if docSnapshot.count == 0 || updateBaesOnPreference == true || saveMeal == true {
//
//                    self.db.getUserInfo { docSnapshot in
//                        for doc in docSnapshot {
//                            let mealHist = doc["mealHist"] as? [Any]
//                            var isTodayRecom = false
//                            if mealHist != nil && mealHist!.count > 0 {
////                                print("triggered in count more than 0", updateBaesOnPreference)
//
//                                print(prompt)
//                                let today = Date()
//                                for i in 0..<mealHist!.count {
//                                    let meal = mealHist![i] as! [String: Any]
//                                    let date = (meal["date"] as! Timestamp).dateValue()
//                                    if self.isSameDay(date, today) {
//                                        isTodayRecom = true
//                                        let breakfast = meal["breakfast"] as? [String: Any]
//                                        let lunch = meal["lunch"] as? [String: Any]
//                                        let dinner = meal["dinner"] as? [String: Any]
//
//                                        if breakfast == nil {
//                                            dispatchGroup.enter()
//                                            self.retrieveMealInfo(prompt: prompt + self.breakfastActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "breakfast") {_ in
//                                                dispatchGroup.leave()
//                                            }
//                                        }
//
//
//                                        if lunch == nil {
//                                            var finalString = ""
//                                            if breakfast != nil {
//                                                let name = breakfast!["mealName"] as! String
//                                                let cal = breakfast!["mealCalories"] as! Double
//
//                                                finalString += " I ate \(name) with \(cal) calories as my breakfast"
//                                            }
//
//                                            dispatchGroup.enter()
//                                            self.retrieveMealInfo(prompt: prompt + self.lunchActionPrompt + finalString + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "lunch") {_ in
//                                                dispatchGroup.leave()
//                                            }
//
//                                        }
//
//                                        if dinner == nil {
//                                            var finalString = ""
//                                            if breakfast != nil {
//                                                let name = breakfast!["mealName"] as! String
//                                                let cal = breakfast!["mealCalories"] as! Double
//
//                                                finalString += " I ate \(name) with \(cal) calories as my breakfast. "
//                                            }
//
//                                            if lunch != nil {
//                                                let name = lunch!["mealName"] as! String
//                                                let cal = lunch!["mealCalories"] as! Double
//
//                                                finalString += " I ate \(name) with \(cal) calories as my lunch. "
//                                            }
//
//                                            dispatchGroup.enter()
//                                            self.retrieveMealInfo(prompt: prompt + self.dinnerActionPrompt + finalString + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "dinner") {_ in
//                                                dispatchGroup.leave()
//                                            }
//                                        }
//
//                                        dispatchGroup.notify(queue: .main) {
//                                            if updateBaesOnPreference == true || saveMeal == true {
//                                                if breakfast == nil {
//                                                    print("breakfast update triggered")
//                                                    self.db.updateRecom(uid: uid!, date: startOfDay, field: "breakfast", value: self.breakfastJson?.firestoreData as Any) { bool in }
//                                                }
//                                                if lunch == nil {
//                                                    print("lunch update triggered")
//                                                    self.db.updateRecom(uid: uid!, date: startOfDay, field: "lunch", value: self.lunchJson?.firestoreData as Any) { bool in }
//                                                }
//                                                if dinner == nil {
//                                                    print("dinner update triggered")
//                                                    self.db.updateRecom(uid: uid!, date: startOfDay, field: "dinner", value: self.dinnerJson?.firestoreData as Any) { bool in }
//                                                }
//                                            } else {
//                                                if saveMeal == false {
//                                                    self.db.saveTodayRecom(meal: MealHist(uid: uid, breakfast: self.breakfastJson ?? nil, lunch: self.lunchJson ?? nil, dinner: self.dinnerJson ?? nil, date: startOfDay))
//                                                }
//                                            }
//
//                                        }
//
//
//                                    }
//                                }
//                            }
//                            if mealHist == nil || mealHist?.count == 0 || isTodayRecom == false {
//                                print("triggered in meal hist count 0", updateBaesOnPreference)
//                                dispatchGroup.enter()
//                                self.retrieveMealInfo(prompt: prompt + self.breakfastActionPrompt + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "breakfast") { breakfastData in
//                                    let breakfastName = breakfastData!["mealName"] as! String
//                                    let breakfastCalories = breakfastData!["calories"] as? Double ?? Double(breakfastData!["calories"] as! String)!
//                                    self.retrieveMealInfo(prompt: prompt + self.lunchActionPrompt + " Recommended breakfast is: \(breakfastName) and the calories is \(breakfastCalories)" + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "lunch") { lunchData in
//                                        let lunchName = breakfastData!["mealName"] as! String
//                                        let lunchCalories = lunchData!["calories"] as? Double ?? Double(lunchData!["calories"] as! String)!
//                                        self.retrieveMealInfo(prompt: prompt + self.dinnerActionPrompt + " Recommended breakfast is: \(breakfastName) and the calories for breakfast is \(breakfastCalories) and recommended lunch is \(lunchName) and the calories for lunch is \(lunchCalories)" + " in the format of " + self.format.replacingOccurrences(of: "'", with: "\"") + self.strictFormat, mealType: "dinner") { dinnerData in
//                                            dispatchGroup.leave()
//                                        }
//                                    }
//                                }
//
//                                dispatchGroup.notify(queue: .main) {
//                                    if updateBaesOnPreference == true {
//                                        self.db.updateRecom(uid: uid!, date: startOfDay, field: "breakfast", value: self.breakfastJson?.firestoreData as Any) { bool in }
//                                        self.db.updateRecom(uid: uid!, date: startOfDay, field: "lunch", value: self.lunchJson?.firestoreData as Any) { bool in }
//                                        self.db.updateRecom(uid: uid!, date: startOfDay, field: "dinner", value: self.dinnerJson?.firestoreData as Any) { bool in }
//
//                                    } else {
//                                        self.db.saveTodayRecom(meal: MealHist(uid: uid, breakfast: self.breakfastJson!, lunch: self.lunchJson!, dinner: self.dinnerJson!, date: startOfDay))
//                                    }
//
//                                }
//                            }
//                        }
//                    }
//
//
//                }
//                else {
//                    for doc in docSnapshot {
//                        let breakfastData = doc["breakfast"] as? [String: Any]
//                        let lunchData = doc["lunch"] as? [String: Any]
//                        let dinnerData = doc["dinner"] as? [String: Any]
//
//                        if breakfastData != nil {
//                            let calories = breakfastData!["mealCalories"] as! Double
//                            let carbs = breakfastData!["mealCarbs"] as! Double
//                            let protein = breakfastData!["mealProtein"] as! Double
//                            let fat = breakfastData!["mealFat"] as! Double
//                            let name = breakfastData!["mealName"] as! String
//                            let imgUrl = breakfastData!["mealImg"] as! String
//
//                            self.breakfastCalories.text = "\(calories) kcal"
//                            self.breakfastMealName.text = name
//                            self.breakfastCarbs.text = "\(Int(carbs * 100))%"
//                            self.breakfastProtein.text = "\(Int(protein * 100))%"
//                            self.breakfastFat.text = "\(Int(fat * 100))%"
//
//                            self.setUpImage(urlString: imgUrl, imageView: self.breakfastMealImage)
//
//                            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbs, protein, fat], view: self.breakfastLineView)
//
//                            self.breakfastJson = Meal(mealName: name, mealCalories: calories, mealCarbs: carbs, mealProtein: protein, mealFat: fat, mealImg: imgUrl)
//                            self.breakfastJson?.setMealType(mealType: "breakfast")
//
//                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBreakFast(_:)))
//                            self.breakfastCookbook.isUserInteractionEnabled = true
//                            self.breakfastCookbook.addGestureRecognizer(tap)
//
//                        }
//
//                        if lunchData != nil {
//                            let calories = lunchData!["mealCalories"] as! Double
//                            let carbs = lunchData!["mealCarbs"] as! Double
//                            let protein = lunchData!["mealProtein"] as! Double
//                            let fat = lunchData!["mealFat"] as! Double
//                            let name = lunchData!["mealName"] as! String
//                            let imgUrl = lunchData!["mealImg"] as! String
//
//                            self.lunchCalories.text = "\(calories) kcal"
//                            self.lunchMealName.text = name
//                            self.lunchCarbs.text = "\(Int(carbs * 100))%"
//                            self.lunchProtein.text = "\(Int(protein * 100))%"
//                            self.lunchFat.text = "\(Int(fat * 100))%"
//
//                            self.setUpImage(urlString: imgUrl, imageView: self.lunchMealImage)
//
//                            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbs, protein, fat], view: self.lunchLineView)
//
//                            self.lunchJson = Meal(mealName: name, mealCalories: calories, mealCarbs: carbs, mealProtein: protein, mealFat: fat, mealImg: imgUrl)
//                            self.lunchJson?.setMealType(mealType: "lunch")
//
//                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLunch(_:)))
//                            self.lunchCookbook.addGestureRecognizer(tap)
//                        }
//
//                        if dinnerData != nil {
//                            let calories = dinnerData!["mealCalories"] as! Double
//                            let carbs = dinnerData!["mealCarbs"] as! Double
//                            let protein = dinnerData!["mealProtein"] as! Double
//                            let fat = dinnerData!["mealFat"] as! Double
//                            let name = dinnerData!["mealName"] as! String
//                            let imgUrl = dinnerData!["mealImg"] as! String
//
//                            self.dinnerCalories.text = "\(calories) kcal"
//                            self.dinnerMealName.text = name
//                            self.dinnerCarbs.text = "\(Int(carbs * 100))%"
//                            self.dinnerProtein.text = "\(Int(protein * 100))%"
//                            self.dinnerFat.text = "\(Int(fat * 100))%"
//
//                            self.setUpImage(urlString: imgUrl, imageView: self.dinnerMealImage)
//
//                            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [carbs, protein, fat], view: self.dinnerLineView)
//
//                            self.dinnerJson = Meal(mealName: name, mealCalories: calories, mealCarbs: carbs, mealProtein: protein, mealFat: fat, mealImg: imgUrl)
//                            self.dinnerJson?.setMealType(mealType: "dinner")
//
//                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDinner(_:)))
//                            self.dinnerCookbook.addGestureRecognizer(tap)
//                        }
//                    }
//                }
//            }
//
//
//        }
//
//    }
    
    @objc func didPullToRefresh() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            //            self.initialMealLoading(run: true){ _ in }
//            self.getActivities()
            self.loadLoggedMeal()
//            self.hideRecoms()
            self.setUpDietMetrics()
            self.scrollView.refreshControl?.endRefreshing()
        }
    }
    
    @objc func handleSaveMeal(_ notification: NSNotification) {
        initialMealLoading(run: true) { prompt in
            print("triggered in close modal", prompt)
//            self.hideRecoms()
//            self.updateMealView(prompt, updateBaesOnPreference: false, saveMeal: true)
        }
    }
    
    @objc func handleMetrics(_ notification: NSNotification) {
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
                newConditionalPrompt += "Additionally, here is the things you need to watch out for: \(String(describing: otherInfo!)). "
            }
            
//            newConditionalPrompt += "My TDEE calories is \(String(describing: TDEEText.text!)). "
//            newConditionalPrompt += "My activity level is \(String(describing: activityLevel.text!)). "
//            newConditionalPrompt += "My active calory consumed is \(String(describing: activeCal.text!)). "
//            newConditionalPrompt += "My calory intake from food so far is \(String(describing: mealCal.text!))."
            newConditionalPrompt += " Recommend me the meals that matches with my TDEE calories and my diet goal."
            
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
                    
//                    print(originalPrompt + " " + newConditionalPrompt)
                    
//                    self.updateMealView(originalPrompt + " " + newConditionalPrompt, updateBaesOnPreference: true, saveMeal: false)
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
    
//    private func retrieveMealInfo(prompt: String, mealType: String, completion: (([String: Any]?) -> Void)?) {
//        //        setUpLoading()
//        print("retrieve function triggered", prompt)
//        DispatchQueue.main.async {
//            GptApiService().getGptResponse(messagePrompt: prompt) { output in
//                if output.contains("{") && output.contains("}") {
//                    let openingBracketIndex = output.firstIndex(of: "{")
//                    let closingBracketIndex = output.lastIndex(of: "}")
//
//                    let startIndex = output.index(openingBracketIndex ?? output.startIndex, offsetBy: 0) // starting index of the desired substring
//                    let endIndex = output.index(closingBracketIndex ?? output.endIndex, offsetBy: 0) // ending index of the desired substring
//
//                    let substr = output[startIndex...endIndex]
//
//                    guard let mealData = substr.data(using: .utf8) else {
//                        print("failed to convert json string to data")
//                        DispatchQueue.main.async {
//                            self.dismiss(animated: false, completion: nil)
//                        }
//                        return
//                    }
//
//                    do {
//                        let jsonData = try JSONSerialization.jsonObject(with: mealData, options: [])
//                        if let jsonObj = jsonData as? [String: Any] {
//                            if mealType == "breakfast" {
//                                let breakfastObj = jsonObj["breakfast"] as? [String: Any]
//                                if breakfastObj != nil {
//                                    self.setUpBreakfast(breakfastData: breakfastObj!) {
//                                        completion!(breakfastObj!)
//                                    }
//                                }
//                            }
//                            if mealType == "lunch" {
//                                let lunchObj = jsonObj["lunch"] as? [String: Any]
//                                if lunchObj != nil {
//                                    self.setUpLunch(lunchData: lunchObj!) {
//                                        completion!(lunchObj!)
//                                    }
//                                }
//                            }
//                            if mealType == "dinner" {
//                                let dinnerObj = jsonObj["dinner"] as? [String: Any]
//                                if dinnerObj != nil {
//                                    self.setUpDinner(dinnerData: dinnerObj!) {
//                                        completion!(dinnerObj!)
//                                    }
//                                }
//                            }
//
//                        }
//                        //                        self.stopLoading()
//                    }
//                    catch {
//                        print(error)
//                    }
//                }
//                else {
//                    print("failed to convert json string to data")
//                }
//            }
//        }
//    }
    
//    private func setUpBreakfast(breakfastData: [String: Any], completion: @escaping () -> Void) {
//
//        let mealName = breakfastData["mealName"] as! String
//
//        let calories = breakfastData["calories"] as? Double ?? Double(breakfastData["calories"] as! String)!
//
//        let macronutrients = breakfastData["macronutrients"] as? [String: Any]
//
//        let carbs = macronutrients!["carbs"] as! String
//        let protein = macronutrients!["protein"] as! String
//        let fat = macronutrients!["fat"] as! String
//
//        completion()
//
//        do {
//            try ImageApiService().generateImage(mealName, completion: { url in
//                guard let imageURL = URL(string: url!) else {
//                    print("invalid url")
//                    return
//                }
//                let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
//                    guard let data = data, error == nil else {
//                        // Handle error
//                        return
//                    }
//                    do {
//                        guard let image = UIImage(data: data) else {
//                            throw RetrieveImageError.unableToGetImage
//                        }
//                        DispatchQueue.main.async {
//                            self.breakfastMealImage.image = image.circleMasked
//                        }
//                        let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
//
//                        self.breakfastJson = meal
//
//                        DispatchQueue.main.async {
//                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapBreakFast(_:)))
//                            self.breakfastCookbook.isUserInteractionEnabled = true
//                            self.breakfastCookbook.addGestureRecognizer(tap)
//                        }
//
//
//                    } catch {
//                        print(error)
//                    }
//                }
//                task.resume()
//            })
//        }
//        catch {
//            print(error)
//        }
//
//        DispatchQueue.main.async {
//            self.breakfastMealName.text = mealName
//            self.breakfastCalories.text = "\(calories) kcal"
//            self.breakfastCarbs.text = carbs
//            self.breakfastProtein.text = protein
//            self.breakfastFat.text = fat
//
//            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.breakfastLineView)
//
//        }
//
//
//    }
    
//    @objc func tapBreakFast(_ sender: UITapGestureRecognizer? = nil) {
//        DispatchQueue.main.async {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
//
//            mealDetail.mealNameText = (self.breakfastJson?.mealName)!
//            mealDetail.imageUrl = self.breakfastJson?.mealImg
//
//            mealDetail.mealFatText = self.breakfastJson?.mealFat
//            mealDetail.mealCarbsText = self.breakfastJson?.mealCarbs
//            mealDetail.mealProteinText = self.breakfastJson?.mealProtein
//            mealDetail.cal = self.breakfastJson?.mealCalories
//            mealDetail.mealType = "breakfast"
//
//            let nav = UINavigationController(rootViewController: mealDetail)
//
//            mealDetail.title = "Recipe Details"
//
//            nav.modalPresentationStyle = .fullScreen
//
//            self.present(nav, animated: true)
//        }
//
//    }
    
//    private func setUpLunch(lunchData: [String: Any], completion: @escaping () -> Void) {
//
//        let mealName = lunchData["mealName"] as! String
//
//        let calories = lunchData["calories"] as? Double ?? Double(lunchData["calories"] as! String)!
//
//        let macronutrients = lunchData["macronutrients"] as? [String: Any]
//
//        let carbs = macronutrients!["carbs"] as! String
//        let protein = macronutrients!["protein"] as! String
//        let fat = macronutrients!["fat"] as! String
//
//        do {
//            try ImageApiService().generateImage(mealName, completion: { url in
//                guard let imageURL = URL(string: url!) else {
//                    print("invalid url")
//                    return
//                }
//                let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
//                    guard let data = data, error == nil else {
//                        // Handle error
//                        return
//                    }
//                    do {
//                        guard let image = UIImage(data: data) else {
//                            throw RetrieveImageError.unableToGetImage
//                        }
//                        DispatchQueue.main.async {
//                            self.lunchMealImage.image = image.circleMasked
//                        }
//                        let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
//
//                        self.lunchJson = meal
//
//                        DispatchQueue.main.async {
//                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapLunch(_:)))
//                            self.lunchCookbook.addGestureRecognizer(tap)
//                        }
//
//                        completion()
//
//                    } catch {
//                        print(error)
//                    }
//                }
//                task.resume()
//            })
//        }
//        catch {
//            print(error)
//        }
//
//        DispatchQueue.main.async {
//            self.lunchMealName.text = mealName
//            self.lunchCalories.text = "\(calories) kcal"
//            self.lunchCarbs.text = carbs
//            self.lunchProtein.text = protein
//            self.lunchFat.text = fat
//
//            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.lunchLineView)
//
//        }
//
//    }
    
//    @objc func tapLunch(_ sender: UITapGestureRecognizer? = nil) {
//        DispatchQueue.main.async {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
//
//            mealDetail.mealNameText = (self.lunchJson?.mealName)!
//            mealDetail.imageUrl = self.lunchJson?.mealImg
//            mealDetail.mealFatText = self.lunchJson?.mealFat
//            mealDetail.mealCarbsText = self.lunchJson?.mealCarbs
//            mealDetail.mealProteinText = self.lunchJson?.mealProtein
//            mealDetail.cal = self.lunchJson?.mealCalories
//            mealDetail.mealType = "lunch"
//
//            let nav = UINavigationController(rootViewController: mealDetail)
//
//            mealDetail.title = "Recipe Details"
//
//            nav.modalPresentationStyle = .fullScreen
//
//            self.present(nav, animated: true)
//        }
//
//    }
    
//    private func setUpDinner(dinnerData: [String: Any], completion: @escaping () -> Void) {
//
//        let mealName = dinnerData["mealName"] as! String
//
//        let calories = dinnerData["calories"] as? Double ?? Double(dinnerData["calories"] as! String)!
//
//        let macronutrients = dinnerData["macronutrients"] as? [String: Any]
//
//        let carbs = macronutrients!["carbs"] as! String
//        let protein = macronutrients!["protein"] as! String
//        let fat = macronutrients!["fat"] as! String
//
//
//        do {
//            try ImageApiService().generateImage(mealName, completion: { url in
//                guard let imageURL = URL(string: url!) else {
//                    print("invalid url")
//                    return
//                }
//                let task = URLSession.shared.dataTask(with: imageURL) { data, response, error in
//                    guard let data = data, error == nil else {
//                        // Handle error
//                        return
//                    }
//                    do {
//                        guard let image = UIImage(data: data) else {
//                            throw RetrieveImageError.unableToGetImage
//                        }
//                        DispatchQueue.main.async {
//                            self.dinnerMealImage.image = image.circleMasked
//                        }
//                        let meal = Meal(mealName: mealName, mealCalories: calories, mealCarbs: self.percentToDouble(percent: carbs), mealProtein: self.percentToDouble(percent: protein), mealFat: self.percentToDouble(percent: fat), mealImg: url)
//
//                        self.dinnerJson = meal
//
//                        DispatchQueue.main.async {
//                            let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapDinner(_:)))
//                            self.dinnerCookbook.addGestureRecognizer(tap)
//                        }
//
//                        completion()
//
//                    } catch {
//                        print(error)
//                    }
//                }
//                task.resume()
//            })
//        }
//        catch {
//            print(error)
//        }
//
//        DispatchQueue.main.async {
//            self.dinnerMealName.text = mealName
//            self.dinnerCalories.text = "\(calories) kcal"
//            self.dinnerCarbs.text = carbs
//            self.dinnerProtein.text = protein
//            self.dinnerFat.text = fat
//
//            self.setUpProportions(color: [.orange, .darkRed, UIColor(hexString: "#83c0ec")], proportions: [self.percentToDouble(percent: carbs), self.percentToDouble(percent: protein), self.percentToDouble(percent: fat)], view: self.dinnerLineView)
//
//        }
//
//
//    }
    
//    @objc func tapDinner(_ sender: UITapGestureRecognizer? = nil) {
//        DispatchQueue.main.async {
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let mealDetail = storyboard.instantiateViewController(identifier: "mealDetail") as! MealDetailViewController
//
//            mealDetail.mealNameText = (self.dinnerJson?.mealName)!
//
//            mealDetail.imageUrl = self.dinnerJson?.mealImg
//            mealDetail.mealFatText = self.dinnerJson?.mealFat
//            mealDetail.mealCarbsText = self.dinnerJson?.mealCarbs
//            mealDetail.mealProteinText = self.dinnerJson?.mealProtein
//            mealDetail.cal = self.dinnerJson?.mealCalories
//            mealDetail.mealType = "dinner"
//
//            let nav = UINavigationController(rootViewController: mealDetail)
//
//            mealDetail.title = "Recipe Details"
//
//            nav.modalPresentationStyle = .fullScreen
//
//            self.present(nav, animated: true)
//        }
//
//    }
    
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
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year &&
        components1.month == components2.month &&
        components1.day == components2.day
    }
}
