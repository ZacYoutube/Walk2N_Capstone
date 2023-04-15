//
//  SaveMealViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/12/23.
//

import UIKit
import Firebase
import FirebaseStorage

class SaveMealViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var mealName: UITextField!
    @IBOutlet weak var generateNutrients: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var carbs: UITextField!
    @IBOutlet weak var protein: UITextField!
    @IBOutlet weak var fat: UITextField!
    @IBOutlet weak var containerUnderImageView: UIView!
    @IBOutlet weak var servingCount: UITextField!
    @IBOutlet weak var stepper: UIStepper!
    @IBOutlet weak var totalEnergy: UITextField!
    
    var imagePicker:UIImagePickerController!
    
    var mealType: String?
    
    let db = DatabaseManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        containerUnderImageView.backgroundColor = .background1
        containerUnderImageView.layer.cornerRadius = 30
        containerUnderImageView.layer.zPosition = 1
        containerUnderImageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openImagePicker)))
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
       
        stepper.minimumValue = 0
        stepper.maximumValue = 100

        servingCount.text = "0"
        
        stepper.value = Double(servingCount.text!)!
        stepper.addTarget(self, action: #selector(stepperValueChanged(_:)), for: .valueChanged)

//        print(<#T##items: Any...##Any#>)
        generateNutrients.setOnClickListener {
            if self.mealName.text != nil && self.mealName.text != "" {
                FoodApiService().getFoodResponse(query: self.mealName.text!) { Nutrient in
                    DispatchQueue.main.async {
                        self.carbs.text = "\((Nutrient.totalNutrient.carbsKCal * Double(self.servingCount.text!)!).truncate(places: 2))"
                        self.protein.text = "\((Nutrient.totalNutrient.proteinKCal * Double(self.servingCount.text!)!).truncate(places: 2))"
                        self.fat.text = "\((Nutrient.totalNutrient.fatKCal * Double(self.servingCount.text!)!).truncate(places: 2))"
                        self.totalEnergy.text = "\((Nutrient.totalNutrient.totalKCal * Double(self.servingCount.text!)!).truncate(places: 2))"
                    }
                }
            }
        }
        
        backBtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        
        saveBtn.setOnClickListener {
            self.saveMeals {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "mealSave"), object: nil)
                self.dismiss(animated: true)
            }
        }
        
        self.hideKeyboardWhenTappedAround()
    }

    private func saveMeals(_ completion: @escaping () -> Void) {
        let uid = Auth.auth().currentUser?.uid
        self.uploadProfileImage(self.imageView.image!) { url in
            self.db.getUserInfo { docSnapshot in
                if docSnapshot.count > 0 {
                    for doc in docSnapshot {
                        let mealHist = doc["mealHist"] as? [Any]
                        if mealHist!.count > 0 {
                            let today = Date()
                            var found: Bool = false
                            var finalList = []
                            for i in 0..<mealHist!.count {
                                let meal = mealHist![i] as? [String: Any]
                                
                                if meal != nil {
                                    let breakfast = meal!["breakfast"] as? [String: Any]
                                    let lunch = meal!["lunch"] as? [String: Any]
                                    let dinner = meal!["dinner"] as? [String: Any]
                                    let d = (meal!["date"] as! Timestamp).dateValue()
                                    if self.isSameDay(d, today) {
                                        var newMeal: MealHist?
                                        if self.mealType == "breakfast" {
                                            var lunchData: Meal? = nil
                                            var dinnerData: Meal? = nil
                                            
                                            if lunch != nil {
                                                lunchData = Meal(mealName: lunch!["mealName"] as! String, mealCalories: lunch!["mealCalories"] as! Double, mealCarbs: lunch!["mealCarbs"] as! Double, mealProtein: lunch!["mealProtein"] as! Double, mealFat: lunch!["mealFat"] as! Double, mealImg: lunch!["mealImg"] as! String)
                                            }
                                            if dinner != nil {
                                                dinnerData = Meal(mealName: dinner!["mealName"] as! String, mealCalories: dinner!["mealCalories"] as! Double, mealCarbs: dinner!["mealCarbs"] as! Double, mealProtein: dinner!["mealProtein"] as! Double, mealFat: dinner!["mealFat"] as! Double, mealImg: dinner!["mealImg"] as! String)
                                            }
                                            newMeal = MealHist(uid: uid, breakfast: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), lunch: lunchData, dinner: dinnerData, date: Date())
                                        }
                                        else if self.mealType == "lunch" {
                                            var breakfastData: Meal? = nil
                                            var dinnerData: Meal? = nil
                                            
                                            if breakfast != nil {
                                                breakfastData = Meal(mealName: breakfast!["mealName"] as! String, mealCalories: breakfast!["mealCalories"] as! Double, mealCarbs: breakfast!["mealCarbs"] as! Double, mealProtein: breakfast!["mealProtein"] as! Double, mealFat: breakfast!["mealFat"] as! Double, mealImg: breakfast!["mealImg"] as! String)
                                            }
                                            
                                            if dinner != nil {
                                                dinnerData = Meal(mealName: dinner!["mealName"] as! String, mealCalories: dinner!["mealCalories"] as! Double, mealCarbs: dinner!["mealCarbs"] as! Double, mealProtein: dinner!["mealProtein"] as! Double, mealFat: dinner!["mealFat"] as! Double, mealImg: dinner!["mealImg"] as! String)
                                            }
                                            
                                            newMeal = MealHist(uid: uid, breakfast: breakfastData, lunch: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), dinner: dinnerData, date: Date())
                                        }
                                        else {
                                            var breakfastData: Meal? = nil
                                            var lunchData: Meal? = nil
                                            
                                            if breakfast != nil {
                                                breakfastData = Meal(mealName: breakfast!["mealName"] as! String, mealCalories: breakfast!["mealCalories"] as! Double, mealCarbs: breakfast!["mealCarbs"] as! Double, mealProtein: breakfast!["mealProtein"] as! Double, mealFat: breakfast!["mealFat"] as! Double, mealImg: breakfast!["mealImg"] as! String)
                                            }
                                            if lunch != nil {
                                                lunchData = Meal(mealName: lunch!["mealName"] as! String, mealCalories: lunch!["mealCalories"] as! Double, mealCarbs: lunch!["mealCarbs"] as! Double, mealProtein: lunch!["mealProtein"] as! Double, mealFat: lunch!["mealFat"] as! Double, mealImg: lunch!["mealImg"] as! String)
                                            }
                                            newMeal = MealHist(uid: uid, breakfast: breakfastData, lunch: lunchData, dinner: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), date: Date())
                                        }
                                        found = true
                                        finalList.append(newMeal!.firestoreData)
                                    }
                                    else {
                                        finalList.append(mealHist![i])
                                    }
                                    
                                    self.db.updateUserInfo(fieldToUpdate: ["mealHist"], fieldValues: finalList) { bool in }
                                }
                            }
                            
                            if found == false {
                                var mealToday: MealHist?
                                if self.mealType == "breakfast" {
                                    mealToday = MealHist(uid: uid, breakfast: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), lunch: nil, dinner: nil, date: Date())
                                }
                                else if self.mealType == "lunch" {
                                    mealToday = MealHist(uid: uid, breakfast: nil, lunch: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), dinner: nil, date: Date())
                                }
                                else {
                                    mealToday = MealHist(uid: uid, breakfast: nil, lunch: nil, dinner: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), date: Date())
                                }
                                
                                self.db.updateArrayData(fieldName: "mealHist", fieldVal: mealToday!.firestoreData, pop: false) { bool in }
                            }
                        }
                        else {
                            var mealToday: MealHist?
                            if self.mealType == "breakfast" {
                                mealToday = MealHist(uid: uid, breakfast: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), lunch: nil, dinner: nil, date: Date())
                            }
                            else if self.mealType == "lunch" {
                                mealToday = MealHist(uid: uid, breakfast: nil, lunch: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), dinner: nil, date: Date())
                            }
                            else {
                                mealToday = MealHist(uid: uid, breakfast: nil, lunch: nil, dinner: Meal(mealName: self.mealName.text, mealCalories: Double(self.totalEnergy.text!)?.truncate(places: 2), mealCarbs: Double(self.carbs.text!)?.truncate(places: 2), mealProtein: Double(self.protein.text!)?.truncate(places: 2), mealFat: Double(self.fat.text!)?.truncate(places: 2), mealImg: url?.absoluteString), date: Date())
                            }
                            
                            
                            self.db.updateArrayData(fieldName: "mealHist", fieldVal: mealToday!.firestoreData, pop: false) { bool in
                                completion()
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        let alertController = UIAlertController(title: "Select image source", message: nil, preferredStyle: .actionSheet)

        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        alertController.addAction(cancelAction)

        self.present(alertController, animated: true, completion: nil)
                
    }
    
    @objc func stepperValueChanged(_ sender: UIStepper) {
        let value = Int(sender.value)
        servingCount.text = "\(value)"
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        //        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("foodImages/\(UUID().uuidString)")
        
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        
        
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        
        storageRef.putData(imageData, metadata: metaData) { metaData, error in
            if error == nil, metaData != nil {
                storageRef.downloadURL { (url, error) in
                    if let url = url {
                        completion(url)
                    } else {
                        completion(nil)
                    }
                }
            } else {
                completion(nil)
            }
        }
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

extension SaveMealViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if picker.sourceType == .photoLibrary || picker.sourceType == .camera
        {
            let img: UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage
            self.imageView.contentMode = .scaleAspectFit
            self.imageView.image = img
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // from stackoverflow https://stackoverflow.com/questions/50928934/swift-4-2-cannot-convert-value-of-type-uiimagepickercontroller-infokey-type
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})}
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue}
    
    
}

extension SaveMealViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let allowedCharacters = CharacterSet.decimalDigits
        let characterSet = CharacterSet(charactersIn: string)
        return allowedCharacters.isSuperset(of: characterSet)
    }
}
