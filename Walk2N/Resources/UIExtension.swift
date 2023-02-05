//
//  shortCut.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit

extension UIView {
    
    // make it easier to just query view.width instead of view.frame.size.width
    
    public var width: CGFloat {
        return frame.size.width
    }
    
    public var height: CGFloat {
        return frame.size.height
    }
    
    public var top: CGFloat {
        return frame.origin.y
    }
    
    public var btm: CGFloat {
        return frame.origin.y + frame.size.height
    }
    
    public var left: CGFloat {
        return frame.origin.x
    }
    
    public var right: CGFloat {
        return frame.origin.x + frame.size.width
    }
}

extension UIViewController {
        
    // hide keyboard
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    // push to navigation stack [ for convenience purposes ]
    func navigateToController(destController: Any) {
        self.navigationController!.pushViewController(destController as! UIViewController, animated: true)
    }
    
    // shared navbar across different view controllers [ under development ]
    func setUpNavbar() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()

        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "profile.png"), for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        button.addTarget(self, action: #selector(popNavigate), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)

        self.navigationItem.leftBarButtonItem = barButtonItem
    }

    @objc func popNavigate(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
