//
//  shortCut.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase

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

        let profile = UIButton(type: .custom)
        profile.setImage(UIImage (named: "profile.png"), for: .normal)
        profile.frame = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 30.0)
        profile.addTarget(self, action: #selector(popNavigate), for: .touchUpInside)
        let barButtonItem = UIBarButtonItem(customView: profile)
        
        let containView = UIView(frame: CGRectMake(0, 0, 120, 40))
        let label = UILabel(frame: CGRectMake(0, 0, 80, 40))
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                let balance =  doc["balance"] as? Double
                label.text = String(balance!)
            }
        }
        
        DatabaseManager.shared.checkUserUpdates { data, update, added, deleted in
            if update == true {
                let balance = data["balance"] as? Double
                label.text = String(balance!)
            }
        }
        
        label.textAlignment = NSTextAlignment.center
        label.layer.borderWidth = 0.2
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.layer.cornerRadius = 10
//        label.center = containView.center

        containView.addSubview(label)

        let imageview = UIImageView(frame: CGRectMake(90, 10, 20, 20))
        imageview.image = UIImage(named: "zec.svg")
        imageview.contentMode = UIView.ContentMode.scaleAspectFill
        
        
        containView.addSubview(imageview)

        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: containView)
        
        self.navigationItem.leftBarButtonItem = barButtonItem
        self.navigationController?.navigationBar.backgroundColor = .white
    }

    @objc func popNavigate(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}



// truncate double decimals
extension Double {
    func truncate(places : Int)-> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

// convert date to day of the week and get its timestamp
extension Date {
    typealias UnixTimestamp = Int
    func dayOfWeek() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let str = dateFormatter.string(from: self)
        let start = String.Index(utf16Offset: 0, in: str)
        let end = String.Index(utf16Offset: 3, in: str)
        let substring = String(str[start..<end])
        return substring.capitalized
    }
    var unixTimestamp: UnixTimestamp {
        return UnixTimestamp(self.timeIntervalSince1970 * 1_000)
    }
}

