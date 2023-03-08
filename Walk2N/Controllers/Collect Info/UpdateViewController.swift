//
//  UpdateViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/7/23.
//

import UIKit

class UpdateViewController: UIViewController {
    
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var heightTextField: UITextField!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var backbtn: UIButton!
    @IBOutlet weak var updateBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        prepopulateData()
        
        backbtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        updateBtn.setOnClickListener {
            self.update()
        }
        
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
        rightSwipe.direction = .right
        
        self.view.isUserInteractionEnabled = true

        self.view.addGestureRecognizer(rightSwipe)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    private func prepopulateData() {
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["age"] != nil && (doc["age"] as? Double) != nil && doc["height"] != nil && (doc["height"] as? Double) != nil && doc["weight"] != nil && (doc["weight"] as? Double) != nil && doc["gender"] != nil && (doc["gender"] as? String) != nil{
                        let age = (doc["age"] as! Double)
                        let weight = (doc["weight"] as! Double)
                        let height = (doc["height"] as! Double)
                        let gender = (doc["gender"] as! String)
                    
                    self.genderTextField.text = gender
                    self.ageTextField.text = "\(age)"
                    self.heightTextField.text = "\(height)"
                    self.weightTextField.text = "\(weight)"
                    
                }
            }
        }
    }
    
    private func update() {
        let age = Double(ageTextField.text!)
        let gender = genderTextField.text
        let height = Double(heightTextField.text!)
        let weight = Double(weightTextField.text!)
                
        DatabaseManager.shared.updateUserInfo(fieldToUpdate: ["age", "gender", "height", "weight"], fieldValues: [age as Any, gender as Any, height as Any, weight as Any]) { done in
            self.dismiss(animated: true)
            GoalPredictManager.shared.predict()
        }
    }
    @objc func handleSwipes(_ sender: UISwipeGestureRecognizer)
    {
        if sender.direction == .right {
            let transition: CATransition = CATransition()
            transition.duration = 0.5
            transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
            transition.type = CATransitionType.reveal
            transition.subtype = CATransitionSubtype.fromLeft
            self.view.window!.layer.add(transition, forKey: nil)
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    

}

