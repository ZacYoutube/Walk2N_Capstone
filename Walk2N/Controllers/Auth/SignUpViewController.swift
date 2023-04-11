//
//  SignUpViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import UIKit
import Firebase
import FirebaseStorage

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var retypedPasswordField: UITextField!
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var tapToChangeProfileButton: UIButton!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    var activityView:UIActivityIndicatorView!
    
    var imagePicker:UIImagePickerController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        setContinueButton(enabled: false)
        
        errorLabel.isHidden = true
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.color = UIColor.lightGreen
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        
        signupBtn.addTarget(self, action: #selector(signup), for: .touchUpInside)
        
        view.addSubview(activityView)
        
        retypedPasswordField.delegate = self
        emailField.delegate = self
        passwordField.delegate = self
        
        retypedPasswordField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        emailField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        
        
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(openImagePicker))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(imageTap)
        profileImageView.layer.cornerRadius = profileImageView.bounds.height / 2
        profileImageView.clipsToBounds = true
        tapToChangeProfileButton.addTarget(self, action: #selector(openImagePicker), for: .touchUpInside)
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.delegate = self
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        retypedPasswordField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        retypedPasswordField.resignFirstResponder()
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        NotificationCenter.default.removeObserver(self)
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
    
    
    @objc func openImagePicker(_ sender:Any) {
        // Open Image Picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @objc private func signup() {
        guard let email = emailField.text else { return }
        guard let pass = passwordField.text else { return }
        guard let pass1 = retypedPasswordField.text else { return }
        guard let image = profileImageView.image else { return }
                
        self.showLoading()

        AuthManager.shared.createNewUser(email: email, password: pass) { registered, uid in
            DispatchQueue.main.async {
                if registered {
                    self.uploadProfileImage(image) { url in
                        if url != nil {
                            var newUser = User(uid: uid, email: email, password: pass, firstName: nil, lastName: nil, balance: 1000.0, boughtShoes: nil, currentShoe: nil, historicalSteps: nil, bonusEarnedToday: 0.0, stepGoalToday: nil, weight: nil, height: nil, age: nil, gender: nil, bonusHistory: [], bonusAwardedForReachingStepGoal: false, bonusEarnedDuringRealTimeRun: 0.0, profileImgUrl: url!.absoluteString, alertHist: [], mealHist: [])
                            DatabaseManager.shared.insertUser(user: newUser) { success in
                                if success {
                                    self.hideLoading()
                                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
//                                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                                    self.changeRootViewController(mainTabBarController)
                                }else{
                                    self.errorLabel.isHidden = false
                                    self.errorLabel.textColor = .red
                                    self.errorLabel.text = "Failed to sign up"
                                    self.hideLoading()

                                }
                            }
                        }
                    }
                }
                else{
                    self.hideLoading()

                    print(registered)
                }
            }
        }
    }
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = emailField.text
        let retypedPassword = retypedPasswordField.text
        let password = passwordField.text
        let formFilled = retypedPassword != nil && retypedPassword != "" && email != nil && email != "" && password != nil && password != "" && retypedPassword == password && profileImageView.image != nil
        setContinueButton(enabled: formFilled)
    }
    
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Resigns the target textField and assigns the next textField in the form.
        switch textField {
        case passwordField:
            passwordField.resignFirstResponder()
            emailField.becomeFirstResponder()
            break
        case emailField:
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
            break
        case retypedPasswordField:
            signup()
            break
        default:
            break
        }
        return true
    }
    
    func setContinueButton(enabled:Bool) {
        if enabled {
            signupBtn.isEnabled = true
            signupBtn.alpha = 1
            signupBtn.layer.borderColor = nil
            signupBtn.backgroundColor = UIColor.lightGreen
            signupBtn.setTitleColor(.white, for: .normal)
        } else {
            signupBtn.setTitleColor(.black, for: .normal)
            signupBtn.isEnabled = false
            signupBtn.backgroundColor = nil
            signupBtn.layer.borderColor = UIColor.lightGray.cgColor
            signupBtn.layer.borderWidth = 1
        }
    }
    
    func uploadProfileImage(_ image:UIImage, completion: @escaping ((_ url:URL?)->())) {
        //        guard let uid = Auth.auth().currentUser?.uid else { return }
        let storageRef = Storage.storage().reference().child("user/\(UUID().uuidString)")
        
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
    
}


extension SignUpViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any])
    {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        if picker.sourceType == .photoLibrary || picker.sourceType == .camera
        {
            let img: UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as! UIImage
            self.profileImageView.image = img
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    // from stackoverflow https://stackoverflow.com/questions/50928934/swift-4-2-cannot-convert-value-of-type-uiimagepickercontroller-infokey-type
    fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})}
    fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
        return input.rawValue}
    
    
}


