//
//  MainPageViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase

class MainPageViewController: UIViewController {
    
    @IBOutlet weak var stepCountContainer: UIView!
    @IBOutlet weak var progressCircularViewContainer: UIView!
    @IBOutlet weak var currentShoeContainerView: UIView!
    @IBOutlet weak var currentShoeImg: UIImageView!
    @IBOutlet weak var currentShoeName: UILabel!
    @IBOutlet weak var currentShoeAwardPerStep: UILabel!
    @IBOutlet weak var currentShoeExpdate: UILabel!
    @IBOutlet weak var chooseChoe: UIButton!
    @IBOutlet weak var shoeNameContainer: UIView!
    @IBOutlet weak var shoeAwardContainer: UIView!
    @IBOutlet weak var shoeExpContainer: UIView!

    //    @IBOutlet weak var stepGoalContainer: UIView!
//    @IBOutlet weak var bonusEarnedContainer: UIView!
//    @IBOutlet weak var currentShoeContainer: UIView!
    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var stepText: UILabel!
    @IBOutlet weak var goalText: UILabel!
    @IBOutlet weak var bonusText: UILabel!

    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    let progressShapeLayer = CAShapeLayer()

    var tokenEarnedText = UILabel()
//    let bonusText = UILabel()
    var percentText = UILabel()
    var startStep: Double = 0
    var endStep: Double = 0
    var startPercent: Double = 0.0
    var endPercent: Double = 0.0
    let duration: Double = 2
    let animateStart = Date()
    var curShoe = UIImageView()
    let goalIconIv = UIImageView()
    let bonusIconIv = UIImageView()
    let curShoeTitle = UILabel()
    let addShoe = UIButton()
    let db = DatabaseManager.shared
    let goalPredictor = GoalPredictManager.shared
    
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
        contentView.backgroundColor = UIColor.background
        styleView(view: [stepCountContainer, progressCircularViewContainer])
        chooseChoe.addTarget(self, action: #selector(openModal), for: .touchUpInside)
        chooseChoe.titleLabel?.font = .systemFont(ofSize: 15)
//        styleView(view: [progressCircleContainer, stepGoalContainer, bonusEarnedContainer, currentShoeContainer])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.setUpNavbar(text: "Home")
        checkAuth()
        checkUserInfo()
        checkStepGoal()
        loadStepCounts()
        loadCircularProgress()
        loadCurrentShoe()
//        loadStepGoalView()
        loadBonusView()
        addShoe.addTarget(self, action: #selector(openModal), for: .touchUpInside)
        UpdateManager().updateBonusAndHistoricalSteps()
        AlertPredictManager().predictAndSetupNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        goalText.text = ""
//        bonusText.text = ""
//        goalIconIv.image = nil
//        bonusIconIv.image = nil
    }
    
    override func viewDidLayoutSubviews() {
        let contentRect: CGRect = scrollView.subviews.reduce(into: .zero) { rect, view in
            rect = rect.union(contentView.frame)
        }
        scrollView.contentSize = contentRect.size
    }
    
    
    @objc private func openModal() {
        let popup = PopUpModalViewController()
        popup.title = "Choose a shoe to earn!"
        present(UINavigationController(rootViewController: popup), animated: true)
    }
    
    private func styleView(view: [UIView]) {
        for i in 0..<view.count {
            let v = view[i]
            v.layer.borderColor = UIColor(red: 225, green: 232, blue: 235, alpha: 1).cgColor
//            v.backgroundColor = .white
            v.layer.cornerRadius = 8
        }
    }
    
    private func checkStepGoal() {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["stepGoalToday"] == nil || (doc["stepGoalToday"] as? Double) == nil {
                    GoalPredictManager.shared.predict()
                }
            }
        }
    }
    
    private func loadCircularProgress() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: self.progressCircularViewContainer.left + 50, y: self.progressCircularViewContainer.bounds.midY), radius: 37, startAngle: -CGFloat.pi, endAngle: CGFloat.pi, clockwise: true)
        progressShapeLayer.path = circularPath.cgPath
        progressShapeLayer.strokeColor = UIColor.rgb(red: 139, green: 203, blue: 187).cgColor
        progressShapeLayer.fillColor = nil
        progressShapeLayer.lineWidth = 10
        progressShapeLayer.lineCap = CAShapeLayerLineCap.round
        progressShapeLayer.strokeEnd = 0
        
        // create track
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.grayish.cgColor
        trackLayer.fillColor = nil
        trackLayer.lineWidth = 10
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        percentText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        percentText.center.x = circularPath.bounds.midX
        percentText.center.y = circularPath.bounds.midY
        percentText.textAlignment = .center
        percentText.textColor = UIColor.lessDark
        percentText.font = UIFont(name: "Futura", size: 15)

        getCurrentStep { curStep in
            DispatchQueue.main.async {
                self.endStep = curStep
                self.animateText(target: 1)

                self.db.checkUserUpdates { data, update, add, delete in
                    if data["historicalSteps"] != nil && (data["historicalSteps"] as? [Any]) != nil {
                        var historicalSteps = data["historicalSteps"] as! [Any]
                        historicalSteps = historicalSteps.sorted(by: {
                            ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                        })
                        let reachedGoal = (historicalSteps[historicalSteps.count - 1] as! [String: Any])["reachedGoal"] as! Bool
                        if reachedGoal == true {
                            self.percentText.text = "Done!"
                            self.percentText.font = UIFont(name: "Futura", size: 13)
                        } else {
                            self.animateText(target: 2)
                        }
                    }
                    if data["stepGoalToday"] != nil && (data["stepGoalToday"] as? Double) != nil{
                        let steps = data["stepGoalToday"] as! Double
                        self.goalText.attributedText = NSMutableAttributedString().normal("Today's Step Goal: ").bold("\(Int(steps))")
                    }
                }

            }
        }
        
        
        progressCircularViewContainer.addSubview(percentText)
        progressCircularViewContainer.layer.addSublayer(trackLayer)
        progressCircularViewContainer.layer.addSublayer(progressShapeLayer)
        
    }
    
    private func loadStepCounts () {

//        let circularPath = UIBezierPath(arcCenter: CGPoint(x: self.progressCircleContainer.center.x - 20, y: self.progressCircleContainer.center.y + 45), radius: 140, startAngle: CGFloat.pi, endAngle: 2 * CGFloat.pi, clockwise: true)
//
//        let gradient = CAGradientLayer()
//        gradient.frame = view.bounds
//        gradient.colors = [UIColor.blue.cgColor, UIColor.green.cgColor]
//
//        progressShapeLayer.path = circularPath.cgPath
//        progressShapeLayer.strokeColor = UIColor.rgb(red: 139, green: 203, blue: 187).cgColor
//        progressShapeLayer.fillColor = nil
//        progressShapeLayer.lineWidth = 10
//        progressShapeLayer.lineCap = CAShapeLayerLineCap.round
//        progressShapeLayer.strokeEnd = 0
//
//        // create track
//        let trackLayer = CAShapeLayer()
//        trackLayer.path = circularPath.cgPath
//        trackLayer.strokeColor = UIColor.grayish.cgColor
//        trackLayer.fillColor = nil
//        trackLayer.lineWidth = 10
//        trackLayer.lineCap = CAShapeLayerLineCap.round
        

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        // add text
        titleText.text = "\(dateFormatter.string(from: Date()))"
//        titleText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
//        titleText.font = UIFont.systemFont(ofSize: 18)
//        titleText.textAlignment = .center
//        titleText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
//        titleText.center.x = progressCircleContainer.center.x - 20
//        titleText.center.y = progressCircleContainer.center.y - 55

//        stepText.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
//        stepText.font = UIFont.boldSystemFont(ofSize: 58)
//        stepText.textAlignment = .center
//        stepText.center.x = progressCircleContainer.center.x - 20
//        stepText.center.y = progressCircleContainer.center.y - 5
//        stepText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)

//        percentText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
//        percentText.textAlignment = .center
//        percentText.center.x = stepCountContainer.center.x - 20
//        percentText.center.y = stepCountContainer.center.y + 45
//        percentText.textColor = UIColor.lightGray

        getCurrentStep { curStep in
            DispatchQueue.main.async {
                self.endStep = curStep
                self.animateText(target: 1)

                self.db.getUserInfo { docSnapshot in
                    for doc in docSnapshot {
                        if doc["stepGoalToday"] != nil && (doc["stepGoalToday"] as? Double) != nil {
                            let stepGoalToday = doc["stepGoalToday"] as! Double
                            self.endPercent = Double(curStep / stepGoalToday) * 100.truncate(places: 2)
                        }
//                        if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil {
//                            var historicalSteps = doc["historicalSteps"] as! [Any]
//                            historicalSteps = historicalSteps.sorted(by: {
//                                ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
//                            })
//                            let reachedGoal = (historicalSteps[historicalSteps.count - 1] as! [String: Any])["reachedGoal"] as! Bool
//                            if reachedGoal == true {
//                                self.percentText.text = "Goal Reached!"
//                            } else {
//                                self.animateText(target: 2)
//                            }
//                        }
                    }
                }

//
//                self.progressCircleContainer.addSubview(self.titleText)
//                self.progressCircleContainer.addSubview(self.stepText)
//                self.progressCircleContainer.addSubview(self.percentText)
            }
        }


//        self.progressCircleContainer.layer.addSublayer(trackLayer)
//        self.stepCountContainer.layer.addSublayer(self.progressShapeLayer)
        setPercentage()
    }
    
//    private func loadStepGoalView() {
//        let stackView = UIStackView(frame: stepGoalContainer.bounds)
//        stackView.axis = .horizontal
//        stackView.alignment = .center
//        stackView.spacing = 10
//        stackView.distribution = .equalCentering
//        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
//        stackView.isLayoutMarginsRelativeArrangement = true
//
//        let goalIcon = UIImage(named: "stepGoal.png")
//        goalIconIv.image = goalIcon
//
//        goalIconIv.layer.shadowColor = UIColor.rgb(red: 124, green: 180, blue: 172).cgColor
//        goalIconIv.layer.shadowOpacity = 0.5
//        goalIconIv.layer.shadowOffset = CGSize(width: 0, height: 2)
//        goalIconIv.layer.shadowRadius = 4
//
//        goalIconIv.translatesAutoresizingMaskIntoConstraints = false
//        goalIconIv.heightAnchor.constraint(equalToConstant: 60).isActive = true
//        goalIconIv.widthAnchor.constraint(equalToConstant: 60).isActive = true
//
//        goalText.text = "Today's Step Goal: 0"
//
//        //        goalText.text = "Today's Step Goal: \(Int(getStepGoalToday()))"
//        db.getUserInfo { docSnapshot in
//            for doc in docSnapshot {
//                if doc["stepGoalToday"] != nil && (doc["stepGoalToday"] as? Double) != nil{
//                    let steps = doc["stepGoalToday"] as! Double
//                    self.goalText.attributedText = NSMutableAttributedString().normal("Today's Step Goal: ").bold("\(Int(steps))")
//                }
//            }
//        }
//        goalText.textColor = UIColor.black
//        goalText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
//
//        stackView.addArrangedSubview(goalIconIv)
//        stackView.addArrangedSubview(goalText)
//
//        stepGoalContainer.addSubview(stackView)
//    }
    
    private func loadBonusView() {

        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["bonusEarnedToday"] != nil && (doc["bonusEarnedToday"] as? Double) != nil{
                    let bonusEarnedToday = (doc["bonusEarnedToday"] as! Double).truncate(places: 2)
                    self.bonusText.attributedText = NSMutableAttributedString().normal("Tokens Earned Today: ").bold("\(bonusEarnedToday)")
                }
            }
        }

        bonusText.text = "Tokens Earned Today: 0"

        db.checkUserUpdates { data, update, addition, deletion in
            if update == true {
                if data["bonusEarnedToday"] != nil && (data["bonusEarnedToday"] as? Double) != nil {
                    let bonusEarnedToday = (data["bonusEarnedToday"] as! Double).truncate(places: 2)
                    self.bonusText.attributedText = NSMutableAttributedString().normal("Tokens Earned Today: ").bold("\(bonusEarnedToday)")
                }
            }
        }

        bonusText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        
        
    }
    
    private func loadCurrentShoe() {

        currentShoeContainerView.backgroundColor = UIColor.background1
        
        shoeNameContainer.backgroundColor = UIColor.background1
        shoeAwardContainer.backgroundColor = UIColor.background1
        shoeExpContainer.backgroundColor = UIColor.background1
        
        shoeNameContainer.layer.cornerRadius = 8
        shoeAwardContainer.layer.cornerRadius = 8
        shoeExpContainer.layer.cornerRadius = 8
        
        currentShoeImg.layer.cornerRadius = 8
        currentShoeImg.layer.shadowColor = UIColor.black.cgColor
        currentShoeImg.layer.shadowOpacity = 0.5
        currentShoeImg.layer.shadowOffset = CGSize(width: 0, height: 2)
        currentShoeImg.layer.shadowRadius = 4
        
        currentShoeName.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        currentShoeAwardPerStep.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        currentShoeExpdate.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)

        db.checkUserUpdates { data, update, added, deleted in
            if added == true || deleted == true || update == true {
                if data["currentShoe"] as? [String: Any] != nil {
                    let currentShoe = data["currentShoe"] as? [String: Any]
                    self.curShoeTitle.attributedText = NSMutableAttributedString().normal("Current Shoe: ").bold("\(currentShoe!["name"] as! String)")
                    if let url = URL(string: currentShoe!["imgUrl"] as! String) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                            guard let imageData = data else { return }
                            DispatchQueue.main.async { [self] in
                                self.currentShoeImg.image = UIImage(data: imageData)
                                self.currentShoeImg.layer.borderColor = nil
                                self.currentShoeImg.layer.borderWidth = 0
                                self.currentShoeImg.heightAnchor.constraint(equalToConstant: 150).isActive = true
                                self.currentShoeImg.widthAnchor.constraint(equalToConstant: 250).isActive = true
                                
                                let df = DateFormatter()
                                df.dateFormat = "MM/dd/YYYY"
                                let expDate = df.string(from: (currentShoe!["expirationDate"] as! Timestamp).dateValue())
                                
                                self.currentShoeName.attributedText = NSMutableAttributedString().bold("\(currentShoe!["name"] as! String)")
                                self.currentShoeAwardPerStep.attributedText = NSMutableAttributedString().bold("\(currentShoe!["awardPerStep"] as! Double)")
                                self.currentShoeExpdate.attributedText = NSMutableAttributedString().bold("\(expDate)")
                                self.chooseChoe.setTitle("Change shoe", for: .normal)

                            }
                        }.resume()
                    }
                } else {
                    self.currentShoeImg.image = nil
                    
                    self.currentShoeName.attributedText = NSMutableAttributedString().bold("NA")
                    self.currentShoeAwardPerStep.attributedText = NSMutableAttributedString().bold("NA")
                    self.currentShoeExpdate.attributedText = NSMutableAttributedString().bold("NA")
                    self.chooseChoe.setTitle("Choose shoe", for: .normal)
                    
                }
            }
        }
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
        getCurrentStep { steps in
            DispatchQueue.main.async {
                self.db.getUserInfo { docSnapshot in
                    for doc in docSnapshot {
                        if doc["stepGoalToday"] != nil && (doc["stepGoalToday"] as? Double) != nil {
                            let stepGoal = doc["stepGoalToday"] as! Double
                            animation.toValue = Double(steps / stepGoal).truncate(places: 2)
                            animation.duration = CFTimeInterval(self.duration - 0.5)
                            animation.fillMode = CAMediaTimingFillMode.forwards
                            animation.isRemovedOnCompletion = false
                            self.progressShapeLayer.add(animation, forKey: "stepPercentage")
                        }
                    }
                }
                
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
    
    //    private func getStepGoalToday() -> Double {
    //
    //    }
    
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
                self.percentText.text = "\(endPercent.truncate(places: 2))%"
            }
        } else {
            let percent = elapsedTime / duration
            
            if target == 1 {
                let val = percent * (endStep - startStep)
                self.stepText.text = "\(Int(val))"
            } else {
                let val = percent * (endPercent - startPercent)
                self.percentText.text = "\(val.truncate(places: 2))%"
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
