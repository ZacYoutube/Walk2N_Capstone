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
        self.setUpNavbar()
        authorizeHealthKit()
        checkAuth()
        checkUserInfo()
        loadCircularProgress()
        loadCurrentShoe()
        timeToAddStep()
        addShoe.addTarget(self, action: #selector(openModal), for: .touchUpInside)
    }
    
    private func timeToAddStep() {
        let cal = Calendar.current
        let now = Date()
        let date = cal.date(bySettingHour: 0, minute: 0, second: 0, of: now)!
        let timer = Timer(fireAt: date, interval: 0, target: self, selector: #selector(addStepToDB), userInfo: nil, repeats: false)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }

    @objc private func addStepToDB() {
        if (Auth.auth().currentUser != nil) {
            HealthKitManager().gettingStepCount(1) { stepArr, timeArr in
                for (step, time) in zip(stepArr, timeArr) {
                    let stepGoalToday = 1000.0
                    var reachedGoal = false
                    if step >= stepGoalToday {
                        reachedGoal = true
                    }
                    let stepToday = HistoricalStep(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid, stepCount: Int(step), date: time, reachedGoal: reachedGoal)
                    DatabaseManager.shared.updateArrayData(fieldName: "historicalSteps", fieldVal: stepToday.firestoreData, pop: false) { success in
                        if success == true {
                            print("successfully added")
                        } else {
                            print("unsuccessfully added")
                        }
                    }
                }
            }
        }
    }
    
    @objc private func openModal() {
        let popup = PopUpModalViewController()
        popup.title = "Choose a shoe to earn!"
        present(UINavigationController(rootViewController: popup), animated: true)
    }
    
    private func loadCurrentShoe() {
        
        curShoeTitle.text = "Current Shoe"
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

        
        curShoe.frame = CGRect(x: 0, y: 0, width: 250, height: 150)
        curShoe.center.x = view.center.x
        curShoe.center.y = view.top + 620
        
        
        let db = DatabaseManager.shared
        
        db.checkUserUpdates { data, update in
            if update == true {
                if data["currentShoe"] as? [String: Any] != nil {
                    let currentShoe = data["currentShoe"] as? [String: Any]
                    if let url = URL(string: currentShoe!["imgUrl"] as! String) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                          guard let imageData = data else { return }
                            DispatchQueue.main.async { [self] in
                                self.curShoe.image = UIImage(data: imageData)
                          }
                        }.resume()
                      }
                } else {
                    self.curShoe.image = nil
                }
            }
        }
        
        curShoe.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
        curShoe.layer.masksToBounds = true
        curShoe.layer.cornerRadius = 10
        curShoe.contentMode = .scaleToFill
        curShoe.layer.borderWidth = 2
        
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
        tokenEarnedText.text = "Tokens earned: 0"
        tokenEarnedText.textColor = UIColor.lightGray
        
        getCurrentStep { curStep in
            DispatchQueue.main.async {
                self.endStep = curStep
                self.endPercent = Double(curStep / self.getStepGoalToday()) * 100.truncate(places: 2)
                self.view.addSubview(self.titleText)
                self.view.addSubview(self.stepText)
                self.view.addSubview(self.goalText)
                self.view.addSubview(self.percentText)
                self.view.addSubview(self.tokenEarnedText)
            }
        }
        
        animateText(target: 1)
        animateText(target: 2)
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
            animation.toValue = Double(steps / stepGoalToday).truncate(places: 1)
            animation.duration = CFTimeInterval(self.duration)
            animation.fillMode = CAMediaTimingFillMode.forwards
            animation.isRemovedOnCompletion = false
            self.progressShapeLayer.add(animation, forKey: "stepPercentage")
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
        DatabaseManager().isUserInfoAvail { userInfoAvail in
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
