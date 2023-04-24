//
//  CalendarViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 3/14/23.
//

import UIKit
import FSCalendar
import Firebase

class CalendarViewController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {

    @IBOutlet var back: UIButton!
    
    @IBOutlet var calendar: FSCalendar!
    @IBOutlet var applyButton: UIButton!
    
    @IBOutlet weak var containerView: UIView!

    var minDate: Date?

    var chosenDate: Date?

    override func viewDidLoad() {
        super.viewDidLoad()
        calendar.delegate = self
        calendar.dataSource = self

        applyButton.isEnabled = false
        
        containerView.clipsToBounds = true
        containerView.layer.borderColor = UIColor.lightGreen.cgColor
        containerView.layer.cornerRadius = 8
        containerView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        containerView.layer.borderWidth = 0.5

        getMinDate { date in
            self.minDate = date
            self.calendar.reloadData()
        }

        applyButton.setOnClickListener {
            let dict:[String: Date] = ["date": self.chosenDate!]
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "MyNotificationName"), object: nil, userInfo: dict)

            self.dismiss(animated: true)
        }

        back.setOnClickListener {
            self.dismiss(animated: true)
        }
    }
//
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("i disappear will")
    }

    func getMinDate(completion:@escaping((Date) -> Void)) {
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil {
                    var historicalSteps = (doc["historicalSteps"] as! [Any])
                    historicalSteps = historicalSteps.sorted(by: {
                        ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                    })
                    let earliest = ((historicalSteps[0] as! [String: Any])["date"] as! Timestamp).dateValue()
                    completion(earliest)
                }
            }
        }
    }


    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        applyButton.isEnabled = true
        chosenDate = date
    }
    func minimumDate(for calendar: FSCalendar) -> Date {
        return minDate ?? Date()
    }
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }


}

