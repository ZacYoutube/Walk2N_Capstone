//
//  ViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/2/23.
//

import UIKit

// aim to prompt to ask user to input their age, weight, and height...
class CollectInfoViewController: UIViewController, UINavigationBarDelegate, UITextFieldDelegate {
    
    private var activityView: UIActivityIndicatorView?
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var continueBtn: UIButton!
    
    var genderPickerView = UIPickerView()
    var heightPickerView = UIPickerView()
    var agePickerView = UIPickerView()
    
    let gender = ["Male", "Female"]
    let height = (120...200).map { String($0) + " cm" }
    let age = (12...100).map{ String($0) }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        navigationItem.title = "Your information"
        genderPickerView.tag = 1
        heightPickerView.tag = 2
        agePickerView.tag = 3
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        heightPickerView.delegate = self
        heightPickerView.dataSource = self
        agePickerView.delegate = self
        agePickerView.dataSource = self
        genderTextField.inputView = genderPickerView
        heightTextField.inputView = heightPickerView
        ageTextField.inputView = agePickerView
        
        self.hideKeyboardWhenTappedAround()
        
        continueBtn.addTarget(self, action: #selector(updateCollectedInfo), for: .touchUpInside)
        continueBtn.backgroundColor = .lightGreen
        continueBtn.setTitleColor(.lessDark, for: .normal)
    }
    
    private func checkInfoInput() {
        if firstNameTextField.text!.isEmpty || firstNameTextField.text == "" || lastNameTextField.text!.isEmpty || lastNameTextField.text == ""
            || genderTextField.text!.isEmpty || weightTextField.text!.isEmpty || weightTextField.text == "" || heightTextField.text!.isEmpty || ageTextField.text!.isEmpty {
            continueBtn.isEnabled = false
        }else{
            continueBtn.isEnabled = true
        }
    }
    
    // show loading gif when in process
    func showLoading() {
        activityView = UIActivityIndicatorView(style: .large)
        activityView?.center = self.view.center
        self.view.addSubview(activityView!)
        activityView?.startAnimating()
    }
    
    // dismiss loading gif
    func hideLoading(){
        activityView?.stopAnimating()
    }
    
    
    @objc func updateCollectedInfo() {
        let age = Int(ageTextField.text!)
        let height = Double((heightTextField.text?.split(separator: " ")[0])!)
        let weight = Double(weightTextField.text!)
        let firstName = firstNameTextField.text
        let lastName = lastNameTextField.text
        let gender = genderTextField.text
        
        let fieldName = ["firstName", "lastName", "gender", "age", "height", "weight"]
        let fieldVal = [firstName as Any, lastName as Any, gender as Any, age as Any, height as Any, weight as Any]
        
        self.showLoading()
        
        DatabaseManager().updateUserInfo(fieldToUpdate: fieldName, fieldValues: fieldVal) { success in
            if success {
                self.hideLoading()
                self.dismiss(animated: true)
            } else {
                self.hideLoading()
                print("failed to save the information")
            }
        }
        
    }
    
}


extension CollectInfoViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return gender.count
        }
        else if pickerView.tag == 2 {
            return height.count
        }
        else if pickerView.tag == 3 {
            return age.count
        }
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return gender[row]
        }
        else if pickerView.tag == 2 {
            return height[row]
        }
        else if pickerView.tag == 3 {
            return age[row]
        }
        
        return ""
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 1 {
            genderTextField.text = gender[row]
            genderTextField.resignFirstResponder()
        }
        else if pickerView.tag == 2 {
            heightTextField.text = height[row]
            heightTextField.resignFirstResponder()
        }
        else if pickerView.tag == 3 {
            ageTextField.text = age[row]
            ageTextField.resignFirstResponder()
        }
    }
}
