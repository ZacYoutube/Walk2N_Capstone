//
//  ProfileViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase

class ProfileViewController: UIViewController {
    
    private let logoutBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Logout", for: .normal)
        btn.setTitleColor(.black, for: .normal)
        btn.layer.cornerRadius = 10
        btn.backgroundColor = .white
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(logoutBtn)
        view.backgroundColor = .systemBackground
        navigationItem.title = "Profile"
        logoutBtn.addTarget(self, action: #selector(logout), for: .touchUpInside)
        self.setupRemainingNavItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        logoutBtn.frame = CGRect(x: 25, y: view.height - 150, width: view.width - 45, height: 50)
        
    }
    
    @objc private func logout() {
        AuthManager().logout()
        let loginViewController = LoginViewController()
        loginViewController.modalPresentationStyle = .fullScreen
        present(loginViewController, animated: true)
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
