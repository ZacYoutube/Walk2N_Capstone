//
//  MainPageViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase

class MainPageViewController: UIViewController {
    
    @IBOutlet weak var progressCircleContainer: UIView!
    @IBOutlet weak var stepGoalContainer: UIView!
    @IBOutlet weak var bonusEarnedContainer: UIView!
    @IBOutlet weak var currentShoeContainer: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    let progressShapeLayer = CAShapeLayer()
    let titleText = UILabel()
    var stepText = UILabel()
    let goalText = UILabel()
    var tokenEarnedText = UILabel()
    let bonusText = UILabel()
    var percentText = UILabel()
    var startStep: Double = 0
    var endStep: Double = 0
    var startPercent: Double = 0.0
    var endPercent: Double = 0.0
    let duration: Double = 1
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
        navigationItem.title = "Home"
        authorizeHealthKit()
        contentView.backgroundColor = UIColor.background
        progressCircleContainer.backgroundColor = .white
        stepGoalContainer.backgroundColor = .white
        bonusEarnedContainer.backgroundColor = .white
        currentShoeContainer.backgroundColor = .white
//        goalPredictor.predict()
    }

    override func viewWillAppear(_ animated: Bool) {
        self.setUpNavbar()
        checkAuth()
        checkUserInfo()
        checkStepGoal()
        loadCircularProgress()
        loadCurrentShoe()
        loadStepGoalView()
        loadBonusView()
        addShoe.addTarget(self, action: #selector(openModal), for: .touchUpInside)
        db.updateBonusAndHistoricalSteps()
        AlertPredictManager().predictAndSetupNotification()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        goalText.text = ""
        bonusText.text = ""
        goalIconIv.image = nil
        bonusIconIv.image = nil
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
    
    private func checkStepGoal() {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["stepGoalToday"] == nil || (doc["stepGoalToday"] as? Double) == nil {
                    GoalPredictManager.shared.predict()
                }
            }
        }
    }

    private func loadCircularProgress () {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: self.progressCircleContainer.center.x - 20, y: self.progressCircleContainer.center.y + 45), radius: 140, startAngle: CGFloat.pi, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.blue.cgColor, UIColor.green.cgColor]
        
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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        // add text
        titleText.text = "\(dateFormatter.string(from: Date()))"
        titleText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        titleText.font = UIFont.systemFont(ofSize: 18)
        titleText.textAlignment = .center
        titleText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        titleText.center.x = progressCircleContainer.center.x - 20
        titleText.center.y = progressCircleContainer.center.y - 55
        
        stepText.frame = CGRect(x: 0, y: 0, width: 200, height: 100)
        stepText.font = UIFont.boldSystemFont(ofSize: 58)
        stepText.textAlignment = .center
        stepText.center.x = progressCircleContainer.center.x - 20
        stepText.center.y = progressCircleContainer.center.y - 5
        stepText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        
        percentText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        percentText.textAlignment = .center
        percentText.center.x = progressCircleContainer.center.x - 20
        percentText.center.y = progressCircleContainer.center.y + 45
        percentText.textColor = UIColor.lightGray
        
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
                        if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil {
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
    
                
                self.progressCircleContainer.addSubview(self.titleText)
                self.progressCircleContainer.addSubview(self.stepText)
                self.progressCircleContainer.addSubview(self.percentText)
            }
        }
        
        
        self.progressCircleContainer.layer.addSublayer(trackLayer)
        self.progressCircleContainer.layer.addSublayer(self.progressShapeLayer)
        setPercentage()
    }
    
    private func loadStepGoalView() {
        let stackView = UIStackView(frame: stepGoalContainer.bounds)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .equalCentering
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let goalIcon = UIImage(named: "stepGoal.png")
        goalIconIv.image = goalIcon
        
        goalIconIv.layer.shadowColor = UIColor.rgb(red: 124, green: 180, blue: 172).cgColor
        goalIconIv.layer.shadowOpacity = 0.5
        goalIconIv.layer.shadowOffset = CGSize(width: 0, height: 2)
        goalIconIv.layer.shadowRadius = 4
        
        goalIconIv.translatesAutoresizingMaskIntoConstraints = false
        goalIconIv.heightAnchor.constraint(equalToConstant: 60).isActive = true
        goalIconIv.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
//        goalText.text = "Today's Step Goal: \(Int(getStepGoalToday()))"
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["stepGoalToday"] != nil && (doc["stepGoalToday"] as? Double) != nil{
                    let steps = doc["stepGoalToday"] as! Double
                    self.goalText.attributedText = NSMutableAttributedString().normal("Today's Step Goal: ").bold("\(Int(steps))")
                }
            }
        }
        goalText.textColor = UIColor.black
        goalText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        
        stackView.addArrangedSubview(goalIconIv)
        stackView.addArrangedSubview(goalText)
        
        stepGoalContainer.addSubview(stackView)
    }
    
    private func loadBonusView() {
        let stackView = UIStackView(frame: bonusEarnedContainer.bounds)
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.distribution = .equalCentering
        stackView.layoutMargins = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 25)
        stackView.isLayoutMarginsRelativeArrangement = true

        let bonusIcon = UIImage(named: "bonusEarned.png")
        bonusIconIv.image = bonusIcon
        bonusIconIv.layer.cornerRadius = 10
        
        bonusIconIv.layer.shadowColor = UIColor.rgb(red: 124, green: 180, blue: 172).cgColor
        bonusIconIv.layer.shadowOpacity = 0.5
        bonusIconIv.layer.shadowOffset = CGSize(width: 0, height: 2)
        bonusIconIv.layer.shadowRadius = 4
        
        bonusIconIv.translatesAutoresizingMaskIntoConstraints = false
        bonusIconIv.heightAnchor.constraint(equalToConstant: 60).isActive = true
        bonusIconIv.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["bonusEarnedToday"] != nil && (doc["bonusEarnedToday"] as? Double) != nil{
                    let bonusEarnedToday = (doc["bonusEarnedToday"] as! Double).truncate(places: 2)
//                    self.bonusText.text = "Tokens Earned Today: \(bonusEarnedToday)"
                    self.bonusText.attributedText = NSMutableAttributedString().normal("Tokens Earned Today: ").bold("\(bonusEarnedToday)")
                }
            }
        }
        
        db.checkUserUpdates { data, update, addition, deletion in
            if update == true {
                if data["bonusEarnedToday"] != nil && (data["bonusEarnedToday"] as? Double) != nil {
                    let bonusEarnedToday = (data["bonusEarnedToday"] as! Double).truncate(places: 2)
                    self.bonusText.attributedText = NSMutableAttributedString().normal("Tokens Earned Today: ").bold("\(bonusEarnedToday)")
                }
            }
        }
        
        bonusText.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        
        stackView.addArrangedSubview(bonusIconIv)
        stackView.addArrangedSubview(bonusText)
        
        bonusEarnedContainer.addSubview(stackView)
    }
    
    private func loadCurrentShoe() {
        
        let stackView = UIStackView(frame: currentShoeContainer.bounds)
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.distribution = .equalSpacing
        
        stackView.layoutMargins = UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20)
        stackView.isLayoutMarginsRelativeArrangement = true

        curShoeTitle.textAlignment = .center
        curShoeTitle.textColor = UIColor.rgb(red: 73, green: 81, blue: 88)
        
        addShoe.setTitleColor(UIColor.lightGreen, for: .normal)
        addShoe.setTitle("My Shoes", for: .normal)
        addShoe.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.bold)
        addShoe.layer.cornerRadius = 8
        
        addShoe.translatesAutoresizingMaskIntoConstraints = false
        addShoe.widthAnchor.constraint(equalToConstant: 140).isActive = true
        addShoe.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        curShoe.layer.cornerRadius = 10
        curShoe.layer.shadowColor = UIColor.black.cgColor
        curShoe.layer.shadowOpacity = 0.5
        curShoe.layer.shadowOffset = CGSize(width: 0, height: 2)
        curShoe.layer.shadowRadius = 4
        
        curShoe.translatesAutoresizingMaskIntoConstraints = false
                
        db.checkUserUpdates { data, update, added, deleted in
            if added == true || deleted == true || update == true {
                if data["currentShoe"] as? [String: Any] != nil {
                    let currentShoe = data["currentShoe"] as? [String: Any]
                    self.curShoeTitle.attributedText = NSMutableAttributedString().normal("Current Shoe: ").bold("\(currentShoe!["name"] as! String)")
                    if let url = URL(string: currentShoe!["imgUrl"] as! String) {
                        URLSession.shared.dataTask(with: url) { (data, response, error) in
                          guard let imageData = data else { return }
                            DispatchQueue.main.async { [self] in
                                self.curShoe.image = UIImage(data: imageData)
                                self.curShoe.layer.borderColor = nil
                                self.curShoe.layer.borderWidth = 0
                                self.curShoe.heightAnchor.constraint(equalToConstant: 100).isActive = true
                                self.curShoe.widthAnchor.constraint(equalToConstant: 200).isActive = true
                          }
                        }.resume()
                      }
                } else {
//                    self.curShoe.image = UIImage(named: "emptyShoe")
                    self.curShoe.layer.borderColor = UIColor.lessDark.cgColor
                    self.curShoe.layer.masksToBounds = true
                    self.curShoe.layer.cornerRadius = 8
                    self.curShoe.layer.borderWidth = 2
                    self.curShoe.contentMode = .scaleToFill
                    self.curShoeTitle.attributedText = NSMutableAttributedString().normal("Select a shoe to wear")
                    self.curShoe.heightAnchor.constraint(equalToConstant: 160).isActive = true
                    self.curShoe.widthAnchor.constraint(equalToConstant: 200).isActive = true
                }
            }
        }
        
//        curShoe.layer.borderColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0).cgColor
//        curShoe.layer.masksToBounds = true
//        curShoe.layer.cornerRadius = 10
//        curShoe.contentMode = .scaleToFill
//        curShoe.layer.borderWidth = 2
        
//        self.currentShoeContainer.addSubview(curShoeTitle)
//        self.currentShoeContainer.addSubview(addShoe)
//        self.currentShoeContainer.addSubview(curShoe)
        stackView.addArrangedSubview(curShoeTitle)
        stackView.addArrangedSubview(curShoe)
        stackView.addArrangedSubview(addShoe)
        
        currentShoeContainer.addSubview(stackView)
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
