//
//  DietaryFilterViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/10/23.
//

import UIKit
import Firebase

class DietaryFilterViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var bloodSugarLevel: UITextField!
    @IBOutlet weak var cholesteralLevel: UITextField!
    @IBOutlet weak var goal: UISegmentedControl!
    @IBOutlet weak var foodAlergiesEnter: UITextField!
    @IBOutlet weak var foodAlergiesList: UITableView!
    @IBOutlet weak var dietaryPreferences: UIPickerView!
    @IBOutlet weak var cuisinePreferences: UITextField!
    @IBOutlet weak var applyBtn: UIBarButtonItem!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var otherInfo: UITextView!
    @IBOutlet weak var addBtn: UIButton!
    
    let db = DatabaseManager.shared
    
    var options = ["No restrictions","Vegan", "Vegetarian", "Gluten-free", "Dairy-free", "Low-carb"]
    var selectedOption: String?
    
    var foodAlergents: [String] = []
    
    var otherInfoPlaceHolder: UILabel!
    
    var dietGoal: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyBtn.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(applyFilter)))

        self.hideKeyboardWhenTappedAround()
        dietaryPreferences.dataSource = self
        dietaryPreferences.delegate = self
        
        otherInfo.delegate = self
        otherInfo.layer.borderColor = UIColor.grayish.cgColor
        otherInfo.layer.borderWidth = 1
        otherInfo.layer.cornerRadius = 8
        
        otherInfoPlaceHolder = UILabel()
        otherInfoPlaceHolder.text = "Enter some other preferences/cautions you need..."
        otherInfoPlaceHolder.font = .italicSystemFont(ofSize: (otherInfo.font?.pointSize)!)
        otherInfoPlaceHolder.sizeToFit()
        otherInfo.addSubview(otherInfoPlaceHolder)
        otherInfoPlaceHolder.frame.origin = CGPoint(x: 5, y: (otherInfo.font?.pointSize)! / 2)
        otherInfoPlaceHolder.textColor = .tertiaryLabel
        otherInfoPlaceHolder.isHidden = !otherInfo.text.isEmpty
        
        foodAlergiesList.dataSource = self
        foodAlergiesList.delegate = self
        foodAlergiesList.layer.borderColor = UIColor.grayish.cgColor
        foodAlergiesList.layer.borderWidth = 1
        foodAlergiesList.layer.cornerRadius = 8
        
        goal.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)

        addBtn.setOnClickListener {
            if self.foodAlergiesEnter.text != "" {
                self.foodAlergents.append(self.foodAlergiesEnter.text!)
                self.foodAlergiesEnter.text = ""
                self.foodAlergiesList.reloadData()
            }
            
            print(self.foodAlergents)
        }
        
        backBtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        
        
        db.getUserDietaryFilter { docs in
            if docs.count > 0 {
                for doc in docs {
                    let bloodSugarLevel = doc["bloodSugarLevel"] as? String
                    let cholesterolLevel = doc["cholesterolLevel"] as? String
                    let dietGoal = doc["dietGoal"] as? String
                    let foodAlergies = doc["foodAlergies"] as? [String]
                    let dietaryPreferences = doc["dietaryPreferences"] as? String
                    let cusinePreferences = doc["cusinePreferences"] as? String
                    let otherInfo = doc["otherInfo"] as? String
                    
                    if bloodSugarLevel != nil {
                        self.bloodSugarLevel.text = bloodSugarLevel
                    }
                    if cholesterolLevel != nil {
                        self.cholesteralLevel.text = cholesterolLevel
                    }
                    if dietGoal != nil {
                        for i in 0..<self.goal.numberOfSegments {
                            let title = self.goal.titleForSegment(at: i)
                            if title == dietGoal {
                                self.goal.selectedSegmentIndex = i
                            }
                        }
                        self.dietGoal = dietGoal
                    }
                    if foodAlergies != nil {
                        self.foodAlergents = foodAlergies!
                        self.foodAlergiesList.reloadData()
                    }
                    
                    if dietaryPreferences != nil {
                        let index = self.options.firstIndex(of: dietaryPreferences!)
                        self.dietaryPreferences.selectRow(index!, inComponent: 0, animated: true)
                        self.selectedOption = dietaryPreferences
                    }
                    
                    if cusinePreferences != nil {
                        self.cuisinePreferences.text = cusinePreferences
                    }
                    
                    if otherInfo != nil {
                        self.otherInfoPlaceHolder.isHidden = true
                        self.otherInfo.text = otherInfo
                    }
                }
            }
        }

    }
    
    @objc private func applyFilter() {
        
        let uid = Auth.auth().currentUser?.uid
        
        let dict: [String: DietFilter] = ["dietaryFilter": DietFilter(uid: uid, bloodSugarLevel: bloodSugarLevel.text!, cholesterolLevel: cholesteralLevel.text!, dietGoal: dietGoal, foodAlergies: foodAlergents, dietaryPreferences: selectedOption, cusinePreferences: cuisinePreferences.text!, otherInfo: otherInfo.text!)]
        
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "nutritionalFilter"), object: nil, userInfo: dict)
            
        db.getUserDietaryFilter { docSnapshot in
            if docSnapshot.count == 0 {
                self.db.saveToDietFilter(dietFilter: DietFilter(uid: uid!, bloodSugarLevel: self.bloodSugarLevel.text, cholesterolLevel: self.cholesteralLevel.text, dietGoal: self.dietGoal ?? "", foodAlergies: self.foodAlergents, dietaryPreferences: self.selectedOption ?? "", cusinePreferences: self.cuisinePreferences.text, otherInfo: self.otherInfo.text))
            } else {
                self.db.updateUserDietaryFilter(uid: uid!, fieldToUpdate: ["bloodSugarLevel", "cholesterolLevel", "dietGoal", "foodAlergies", "dietaryPreferences", "cusinePreferences", "otherInfo"], fieldValues: [self.bloodSugarLevel.text as Any, self.cholesteralLevel.text as Any, self.dietGoal as Any, self.foodAlergents as Any, self.selectedOption as Any, self.cuisinePreferences.text as Any, self.otherInfo.text as Any]) { bool in }
            }
        }
        self.dismiss(animated: true)
    }
    
    @objc func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        let selectedIndex = sender.selectedSegmentIndex
        let selectedValue = sender.titleForSegment(at: selectedIndex)
        dietGoal = selectedValue
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedOption = options[row]
    }
}

extension DietaryFilterViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        otherInfoPlaceHolder?.isHidden = !textView.text.isEmpty
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        otherInfoPlaceHolder?.isHidden = !textView.text.isEmpty
        moveTextView(textView, moveDistance: -250, up: false)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        moveTextView(textView, moveDistance: -250, up: true)
        otherInfoPlaceHolder?.isHidden = true
    }
    func moveTextView(_ textField: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}

extension DietaryFilterViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "foodAlergyCell")! as UITableViewCell

        cell.textLabel!.text = foodAlergents[indexPath.row]

        return cell;
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return foodAlergents.count
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            foodAlergents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

}
