//
//  LoginViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController, UITextFieldDelegate {

    var activityView:UIActivityIndicatorView!

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var dismissButton: UIButton!
    
    var continueButton:RoundedWhiteButton!
    
    private let createAccountBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("New user? Sign up here!", for: .normal)
        btn.setTitleColor(.lightGreen, for: .normal)
        btn.layer.cornerRadius = 10
        return btn
    }()
    
    private let errorLabel: UILabel = {
        let label = UILabel()
        label.alpha = 0
        label.textAlignment = .center
        label.textColor = .red
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        continueButton = RoundedWhiteButton(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        continueButton.setTitleColor(UIColor.lightGreen, for: .normal)
        continueButton.setTitle("Continue", for: .normal)
        continueButton.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        continueButton.center = CGPoint(x: view.center.x, y: view.frame.height - continueButton.frame.height - 24)
        continueButton.highlightedColor = UIColor(white: 1.0, alpha: 1.0)
        continueButton.defaultColor = UIColor.white
        continueButton.addTarget(self, action: #selector(login), for: .touchUpInside)
        continueButton.alpha = 0.5
        view.addSubview(continueButton)
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.color = UIColor.lightGreen
        activityView.frame = CGRect(x: 0, y: 0, width: 50.0, height: 50.0)
        activityView.center = continueButton.center
        
        view.addSubview(activityView!)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector:#selector(keyboardWillAppear), name: UIResponder.keyboardWillShowNotification, object: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillAppear(notification: NSNotification){
        
        let info = notification.userInfo!
        let keyboardFrame: CGRect = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        continueButton.center = CGPoint(x: view.center.x,
                                        y: view.frame.height - keyboardFrame.height - 16.0 - continueButton.frame.height / 2)
        activityView.center = continueButton.center
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
    
    @objc func textFieldChanged(_ target:UITextField) {
        let email = emailField.text
        let password = passwordField.text
        let formFilled = email != nil && email != "" && password != nil && password != ""
        setContinueButton(enabled: formFilled)
    }
    
    @objc func dismiss(_ sender: Any) {
        self.dismiss(animated: false, completion: nil)
        print("tabbbbb")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
                
        switch textField {
        case emailField:
            emailField.resignFirstResponder()
            passwordField.becomeFirstResponder()
            break
        case passwordField:
            login()
            break
        default:
            break
        }
        return true
    }

    func setContinueButton(enabled:Bool) {
        if enabled {
            continueButton.alpha = 1.0
            continueButton.isEnabled = true
        } else {
            continueButton.alpha = 0.5
            continueButton.isEnabled = false
        }
    }
    
    @objc private func login() {

        guard let email = emailField.text else { return }
        guard let pw = passwordField.text else { return }
        
        setContinueButton(enabled: false)
        continueButton.setTitle("", for: .normal)
        activityView!.startAnimating()

        self.showLoading()

        AuthManager.shared.login(email: email, password: pw){ success in
            DispatchQueue.main.async {
                if success {
                    self.hideLoading()
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    let mainTabBarController = storyboard.instantiateViewController(identifier: "MainTabBarController")
                    (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.changeRootViewController(mainTabBarController)
                }else{
                    self.errorLabel.text = "Failed to log in"
                    self.errorLabel.alpha = 1
                    self.hideLoading()
                    return
                }
            }

        }

    }
    
//    @objc private func signup() {
//        let signUpViewController = SignUpViewController()
//        signUpViewController.title = "Sign up"
//        present(UINavigationController(rootViewController: signUpViewController), animated: true)
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
