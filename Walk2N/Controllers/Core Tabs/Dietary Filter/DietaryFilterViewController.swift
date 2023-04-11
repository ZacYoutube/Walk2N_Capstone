//
//  DietaryFilterViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/10/23.
//

import UIKit

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
    
    var options = ["Vegan", "Vegetarian", "Gluten-free", "Dairy-free", "Low-carb"]
    var selectedOption: String?
    
    var foodAlergents: [String] = []
    
    var otherInfoPlaceHolder: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        applyBtn.customView?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(applyFilter)))

        self.hideKeyboardWhenTappedAround()
        dietaryPreferences.dataSource = self
        dietaryPreferences.delegate = self
        
        otherInfo.delegate = self
        otherInfo.layer.borderColor = UIColor.grayish.cgColor
        otherInfo.layer.borderWidth = 0.5
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
        foodAlergiesList.layer.borderWidth = 0.5
        foodAlergiesList.layer.cornerRadius = 8
        
        addBtn.setOnClickListener {
            if self.foodAlergiesEnter.text != "" {
                self.foodAlergents.append(self.foodAlergiesEnter.text!)
                self.foodAlergiesEnter.text = ""
                self.foodAlergiesList.reloadData()
            }
            
            print(self.foodAlergents)
        }
        
        
        db.getUserDietaryFilter { docs in
            if docs.count > 0 {
                for doc in docs {
                    
                }
            }
        }

    }
    
    @objc private func applyFilter() {
        print("hehehhehe")
//        nutritionalFilter
//        let dict:[String: Date] = ["date": self.chosenDate!]
//        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "nutritionalFilter"), object: nil, userInfo: dict)
        
//        if bloodSugarLevel.text != "" || cholesteralLevel.text != "" || foodAlergies.text != "" || dietaryPrefer
        self.dismiss(animated: true)
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
        print("Selected option: \(selectedOption ?? "none")")
    }
}

extension DietaryFilterViewController: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        otherInfoPlaceHolder?.isHidden = !textView.text.isEmpty
//        let title = titleText.text
//        let description = descriptionText.text
//        let formFilled = title != nil && title != "" && description != nil && description != ""
//        continueBtn(enabled: formFilled)
    }
    func textViewDidEndEditing(_ textView: UITextView) {
        otherInfoPlaceHolder?.isHidden = !textView.text.isEmpty

        print("text view end")
        moveTextView(textView, moveDistance: -250, up: false)
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("text view begin")
        moveTextView(textView, moveDistance: -250, up: true)
        otherInfoPlaceHolder?.isHidden = true
    }
    func moveTextView(_ textField: UITextView, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        print(self.view)
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
