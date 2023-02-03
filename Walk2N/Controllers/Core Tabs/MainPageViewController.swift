//
//  MainPageViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase

class MainPageViewController: UIViewController {

    private func authorizeHealthKit() {
        let isEnabled = HealthKitManager().authorizeHealthKit()
        if isEnabled == false {
            print("HealthKit Failed to Authorize")
        } else {
            print("HealthKit Successfully Authorized")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorizeHealthKit()
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.setImage(UIImage(named: "profile.png"), for: .normal)
        button.addTarget(self, action:#selector(toProfile), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        let barButton = UIBarButtonItem(customView: button)
        self.navigationItem.leftBarButtonItems = [barButton]
    }
    
    private func checkAuth(){
        // check whether user is authenticated
        if Auth.auth().currentUser == nil {
            let loginViewController = LoginViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true)
        }
    }
    
    @objc private func toProfile() {
        self.tabBarController!.selectedIndex = 3
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
