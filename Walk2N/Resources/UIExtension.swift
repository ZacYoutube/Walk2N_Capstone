//
//  shortCut.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit

extension UIView {
    
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
        
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func navigateToController(destController: Any) {
        self.navigationController!.pushViewController(destController as! UIViewController, animated: true)
    }
    
    func setupRemainingNavItems() {
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
//        let titleImageView = UIImageView(image: UIImage(named: "profile.png"))
//        titleImageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
//        titleImageView.contentMode = .scaleAspectFit
//        titleImageView.clipsToBounds = true
//        navigationItem.titleView = titleImageView

        let button = UIButton(type: .custom)
        button.setImage(UIImage (named: "profile.png"), for: .normal)
        button.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        button.addTarget(self, action: #selector(tapbutton), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: button)

        self.navigationItem.leftBarButtonItem = barButtonItem
    }

    @objc func tapbutton(){
        self.navigationController?.popViewController(animated: true)
        print("tap")
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
