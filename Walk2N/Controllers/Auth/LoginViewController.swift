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
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setContinueButton(enabled: false)
        
        activityView = UIActivityIndicatorView(style: .gray)
        activityView.color = UIColor.lightGreen
        
        errorLabel.alpha = 0
        
        view.addSubview(activityView!)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        emailField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        passwordField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        dismissButton.addTarget(self, action: #selector(dismiss), for: .touchUpInside)
        
        loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        emailField.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
            loginBtn.isEnabled = true
            loginBtn.alpha = 1
        } else {
            loginBtn.alpha = 0.7
            loginBtn.setTitleColor(.black, for: .normal)
            loginBtn.isEnabled = false
        }
    }
    
    @objc private func login() {

        print("tapped")
        guard let email = emailField.text else { return }
        guard let pw = passwordField.text else { return }
        
        setContinueButton(enabled: false)

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
                    self.errorLabel.textAlignment = .center
                    self.errorLabel.textColor = .red
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
