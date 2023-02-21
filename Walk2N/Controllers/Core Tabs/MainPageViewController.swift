//
//  MainPageViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase

class MainPageViewController: UIViewController {
    
    let progressShapeLayer = CAShapeLayer()
    let titleText = UILabel()
    var stepText = UILabel()
    var tokenEarnedText = UILabel()
    let goalText = UILabel()
    var percentText = UILabel()
    var startStep: Double = 0
    var endStep: Double = 0
    var startPercent: Double = 0.0
    var endPercent: Double = 0.0
    let duration: Double = 1
    let animateStart = Date()
    var curShoe = UIImageView()
    let curShoeTitle = UILabel()
    let addShoe = UIButton()
    let db = DatabaseManager.shared
    
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
        navigationItem.title = "Home"
        authorizeHealthKit()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpNavbar()
        checkAuth()
        checkUserInfo()
        loadCircularProgress()
        loadCurrentShoe()
        addShoe.addTarget(self, action: #selector(openModal), for: .touchUpInside)
        db.updateHistoricalSteps()
        db.updateBonus()
    }
    

    @objc private func openModal() {
        let popup = PopUpModalViewController()
        popup.title = "Choose a shoe to earn!"
        present(UINavigationController(rootViewController: popup), animated: true)
    }
    
    private func loadCurrentShoe() {
        
        curShoeTitle.frame = CGRect(x: 0, y: 0, width: 250, height: 40)
        curShoeTitle.center.x = view.center.x
        curShoeTitle.center.y = view.top + 500
        curShoeTitle.textAlignment = .center
        
        addShoe.setTitle("Choose", for: .normal)
        addShoe.frame = CGRect(x: 0, y: 0, width: 250, height: 20)
        addShoe.center.x = view.center.x
        addShoe.center.y = view.top + 525
        addShoe.setTitleColor(.systemBlue, for: .normal)
        addShoe.titleLabel?.font =  UIFont(name: "", size: 10)

        curShoe.frame = CGRect(x: 0, y: 0, width: 250, height: 120)
        curShoe.center.x = view.center.x
        curShoe.center.y = view.top + 620
        
        curShoe.layer.cornerRadius = 10
        curShoe.layer.shadowColor = UIColor.black.cgColor
        curShoe.layer.shadowOpacity = 0.5
        curShoe.layer.shadowOffset = CGSize(width: 0, height: 2)
        curShoe.layer.shadowRadius = 4
                
        db.checkUserUpdates { data, update, added, deleted in
            if added == true || deleted == true || update == true {
                if data["currentShoe"] as? [String: Any] != nil {
                    let currentShoe = data["currentShoe"] as? [String: Any]
                    self.curShoeTitle.text = "Current Shoe: \(currentShoe!["name"] as! String)"
                    if let url = URL(string: currentShoe!["imgUrl"] as! String) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                          guard let imageData = data else { return }
                            DispatchQueue.main.async { [self] in
                                self.curShoe.image = UIImage(data: imageData)
                          }
                        }.resume()
                      }
                } else {
                    self.curShoe.image = UIImage(named: "blank-removebg-preview.png")
                    self.curShoeTitle.text = "Current Shoe"
                }
            }
        }
        
//        curShoe.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
//        curShoe.layer.masksToBounds = true
//        curShoe.layer.cornerRadius = 10
//        curShoe.contentMode = .scaleToFill
//        curShoe.layer.borderWidth = 2
        
        self.view.addSubview(curShoeTitle)
        self.view.addSubview(addShoe)
        self.view.addSubview(curShoe)
    }


    private func loadCircularProgress () {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: self.view.center.x, y: self.view.top + 300), radius: 150, startAngle: -CGFloat.pi, endAngle: CGFloat.pi, clockwise: true)
        progressShapeLayer.path = circularPath.cgPath
        progressShapeLayer.strokeColor = UIColor.systemGreen.cgColor
        progressShapeLayer.fillColor = nil
        progressShapeLayer.lineWidth = 10
        progressShapeLayer.lineCap = CAShapeLayerLineCap.round
        progressShapeLayer.strokeEnd = 0
        
        // create track
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lightGray.cgColor
        trackLayer.fillColor = nil
        trackLayer.lineWidth = 10
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        // add text
        titleText.text = "Today's Steps"
        titleText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        titleText.font = UIFont.systemFont(ofSize: 20)
        titleText.textAlignment = .center
        titleText.center.x = view.center.x
        titleText.center.y = view.top + 220
        
        stepText.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        stepText.font = UIFont.boldSystemFont(ofSize: 60)
        stepText.textAlignment = .center
        stepText.center.x = view.center.x
        stepText.center.y = view.top + 270
        
        goalText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        goalText.textAlignment = .center
        goalText.center.x = view.center.x
        goalText.center.y = view.top + 320
        goalText.text = "Goal: \(Int(getStepGoalToday()))"
        
        percentText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        percentText.textAlignment = .center
        percentText.center.x = view.center.x
        percentText.center.y = view.top + 360
        percentText.textColor = UIColor.lightGray
        
        tokenEarnedText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        tokenEarnedText.textAlignment = .center
        tokenEarnedText.center.x = view.center.x
        tokenEarnedText.center.y = view.top + 400
        
        tokenEarnedText.textColor = UIColor.systemGreen
        tokenEarnedText.font = tokenEarnedText.font.withSize(13)
        
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["bonusEarnedToday"] != nil {
                    let bonusEarnedToday = (doc["bonusEarnedToday"] as! Double).truncate(places: 2)
                    self.tokenEarnedText.text = "Today Earned: \(bonusEarnedToday)"
                }
            }
        }
        
        db.checkUserUpdates { data, update, addition, deletion in
            if update == true {
                if data["bonusEarnedToday"] != nil {
                    let bonusEarnedToday = (data["bonusEarnedToday"] as! Double).truncate(places: 2)
                    self.tokenEarnedText.text = "Today Earned: \(bonusEarnedToday)"
                }
            }
        }
        
        getCurrentStep { curStep in
            DispatchQueue.main.async {
                self.endStep = curStep
                self.endPercent = Double(curStep / self.getStepGoalToday()) * 100.truncate(places: 2)
                
                self.animateText(target: 1)
                
                self.db.getUserInfo { docSnapshot in
                    for doc in docSnapshot {
                        if doc["historicalSteps"] != nil {
                            var historicalSteps = doc["historicalSteps"] as! [Any]
                            historicalSteps = historicalSteps.sorted(by: {
                                ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                            })
                            let reachedGoal = (historicalSteps[historicalSteps.count - 1] as! [String: Any])["reachedGoal"] as! Bool
                            if reachedGoal == true {
                                self.percentText.text = "Goal Reached!"
                            } else {
                                self.animateText(target: 2)
                            }
                        }
                    }
                }
    
                
                self.view.addSubview(self.titleText)
                self.view.addSubview(self.stepText)
                self.view.addSubview(self.goalText)
                self.view.addSubview(self.percentText)
                self.view.addSubview(self.tokenEarnedText)
            }
        }
        
        
        view.layer.addSublayer(trackLayer)
        view.layer.addSublayer(self.progressShapeLayer)
        setPercentage()
    }
    
    private func animateText(target: Int) {
        if target == 1 {
            let displayLink = CADisplayLink(target: self, selector: #selector(self.updateStepNumber))
            displayLink.add(to: .main, forMode: RunLoop.Mode.default)
        }else {
            let displayLink = CADisplayLink(target: self, selector: #selector(self.updatePercentageNumber))
            displayLink.add(to: .main, forMode: RunLoop.Mode.default)
        }
        
    }
    
    private func setPercentage () {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        let stepGoalToday = getStepGoalToday()
        getCurrentStep { steps in
            DispatchQueue.main.async {
                animation.toValue = Double(steps / stepGoalToday).truncate(places: 1)
                animation.duration = CFTimeInterval(self.duration)
                animation.fillMode = CAMediaTimingFillMode.forwards
                animation.isRemovedOnCompletion = false
                self.progressShapeLayer.add(animation, forKey: "stepPercentage")
            }
        }
    }
    
    private func getCurrentStep(completion: @escaping(Double) -> Void ) {
        var curStep: Double = 0.0
        HealthKitManager().gettingStepCount(0) { stepArr, timeArr in
            if stepArr.count > 0 {
                curStep = stepArr[0]
            }
            completion(curStep)
        }
    }
    
    private func getStepGoalToday() -> Double {
        
        // output by ML model
        return 1000.0
    }
    
    private func checkUserInfo() {
        // check whether user has input their weight height gender and age
        db.isUserInfoAvail { userInfoAvail in
            if userInfoAvail == false {
                let collectUserInfoVC = self.storyboard?.instantiateViewController(withIdentifier: "CollectInfoViewController")
                collectUserInfoVC!.modalPresentationStyle = .fullScreen
                self.present(collectUserInfoVC!, animated: true)
            }
        }
    }
    
    
    private func checkAuth(){
        // check whether user is authenticated
        if Auth.auth().currentUser == nil {
            let loginViewController = LoginViewController()
            loginViewController.modalPresentationStyle = .fullScreen
            present(loginViewController, animated: true)
        }
    }
    
    private func helper(target: Int) {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(animateStart)
        
        if elapsedTime > duration {
            if target == 1 {
                self.stepText.text = "\(Int(endStep))"
            } else {
                self.percentText.text = "Progress: \(endPercent.truncate(places: 2))%"
            }
        } else {
            let percent = elapsedTime / duration
            
            if target == 1 {
                let val = percent * (endStep - startStep)
                self.stepText.text = "\(Int(val))"
            } else {
                let val = percent * (endPercent - startPercent)
                self.percentText.text = "Progress: \(val.truncate(places: 2))%"
            }
        }
    }
    
    @objc private func toProfile() {
        self.tabBarController!.selectedIndex = 3
    }
    
    @objc private func updateStepNumber() {
        helper(target: 1)
    }
    
    @objc private func updatePercentageNumber() {
        helper(target: 2)
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
