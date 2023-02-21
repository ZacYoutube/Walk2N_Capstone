//
//  LoginViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 1/30/23.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {

    private var activityView: UIActivityIndicatorView?
    
    private let header: UIView = {
        let header = UIView()
        header.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        return header
    }()
    
    private let emailTextField: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter your email"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x:0, y:0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let passwordTextField: UITextField = {
        let field = UITextField()
        field.isSecureTextEntry = true
        field.placeholder = "Enter your password"
        field.returnKeyType = .next
        field.leftViewMode = .always
        field.leftView = UIView(frame: CGRect(x:0, y:0, width: 10, height: 0))
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.layer.cornerRadius = 10
        field.backgroundColor = .secondarySystemBackground
        return field
    }()
    
    private let loginBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Login", for: .normal)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .systemBlue
        return btn
    }()
    
    private let createAccountBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("New user? Sign up here!", for: .normal)
        btn.setTitleColor(.link, for: .normal)
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
    
    private func addSubView() {
        view.addSubview(header)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginBtn)
        view.addSubview(createAccountBtn)
        view.addSubview(errorLabel)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        header.frame = CGRect(x: 0, y: view.safeAreaInsets.top, width: view.width, height: view.height / 3.0)
        let logo = UIImageView(image: UIImage(named: "shoe"))
        logo.frame = CGRectMake(100, 150, 150, 100)
        
        logo.center = CGPoint(x: header.width  / 2,
                              y: header.height / 2)
        errorLabel.center = CGPoint(x: view.width  / 2,
                                    y: errorLabel.height / 2)
        header.addSubview(logo)
        
        emailTextField.frame = CGRect(x: 25, y: header.btm, width: view.width - 50, height: 50)
        passwordTextField.frame = CGRect(x: 25, y: emailTextField.btm + 20, width: view.width - 50, height: 50)
        loginBtn.frame = CGRect(x: 25, y: passwordTextField.btm + 20, width: view.width - 50, height: 50)
        createAccountBtn.frame = CGRect(x: 25, y: loginBtn.btm + 20, width: view.width - 50, height: 50)
        errorLabel.frame = CGRect(x: 25, y: createAccountBtn.btm + 10, width: view.width - 50, height: 50)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addSubView()
        view.backgroundColor = .systemBackground
        loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        createAccountBtn.addTarget(self, action: #selector(signup), for: .touchUpInside)
        self.hideKeyboardWhenTappedAround()
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
    
    @objc private func login() {
            
        let email = emailTextField.text
        let pw = passwordTextField.text

        guard email!.isEmpty || pw!.isEmpty || pw!.count >= 8 else{
            errorLabel.text = "Please fill in required field properly"
            errorLabel.alpha = 1
            return
        }
        
        self.showLoading()
        
        AuthManager.shared.login(email: email!, password: pw!){ success in
            DispatchQueue.main.async {
                if success {
                    self.hideLoading()
                    self.dismiss(animated: true, completion: nil)
                }else{
                    self.errorLabel.text = "Failed to log in"
                    self.errorLabel.alpha = 1
                    return
                }
            }
            
        }
        
    }
    
    @objc private func signup() {
        let signUpViewController = SignUpViewController()
        signUpViewController.title = "Sign up"
        present(UINavigationController(rootViewController: signUpViewController), animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
