//
//  MainPageViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import UIKit
import Firebase
import SideMenu

class MainPageViewController: UIViewController {
    
    @IBOutlet weak var stepGoalContainer: UIView!
    @IBOutlet weak var progressCircularViewContainer: UIView!
    @IBOutlet weak var stepCountContainer: UIView!
    @IBOutlet weak var weightContainer: UIView!
    @IBOutlet weak var bonusContainer: UIView!
    @IBOutlet weak var dateChanger: UIButton!
    @IBOutlet weak var dateContainer: UIView!

    @IBOutlet weak var askGptContainer: UIView!
    @IBOutlet weak var ask: UIButton!
    @IBOutlet weak var sv: UIScrollView!
    
    @IBOutlet weak var weightText: UILabel!
    @IBOutlet weak var bonusText: UILabel!
    
    @IBOutlet weak var stepGoalTitle: UILabel!
    @IBOutlet weak var stepCountTitle: UILabel!
    @IBOutlet weak var distanceText: UILabel!
    @IBOutlet weak var weightTitleText: UILabel!
    @IBOutlet weak var bonusTitleText: UILabel!
    
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var logMeal: UIButton!


//    @IBOutlet weak var titleText: UILabel!
    @IBOutlet weak var stepText: UILabel!
    @IBOutlet weak var goalText: UILabel!
//    @IBOutlet weak var bonusText: UILabel!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var activeCal: UILabel!
    @IBOutlet weak var activityLevel: UILabel!
    @IBOutlet weak var mealCal: UILabel!
    @IBOutlet weak var TDEEText: UILabel!
    @IBOutlet weak var caloriesContainer: UIView!
    @IBOutlet weak var dailyCalContainer: UIView!
    
    @IBOutlet weak var askGptTextView: UITextView!
    
    let progressShapeLayer = CAShapeLayer()
    
    var tokenEarnedText = UILabel()
    let dateFormatter = DateFormatter()
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
//    let curShoeTitle = UILabel()
    let addShoe = UIButton()
    let db = DatabaseManager.shared
    let goalPredictor = GoalPredictManager.shared
    let waveView = WaveView()
    var menu: SideMenuNavigationController?
    
    
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
        
        self.setUpNavbar(text: "Dashboard")
        
        authorizeHealthKit()
        contentView.backgroundColor = UIColor.white
        progressCircularViewContainer.backgroundColor = .background1
        stepGoalContainer.backgroundColor = UIColor.background1
        stepCountContainer.backgroundColor = UIColor.background1
        weightContainer.backgroundColor = UIColor.background1
        bonusContainer.backgroundColor = UIColor.background1
        dateContainer.backgroundColor = UIColor.background1
        caloriesContainer.backgroundColor = UIColor.background1
        dailyCalContainer.backgroundColor = UIColor.background1
        askGptContainer.backgroundColor = UIColor.background1
        askGptTextView.backgroundColor = .background1
        
        stepCountContainer.layer.cornerRadius = 8
        stepGoalContainer.layer.cornerRadius = 8
        weightContainer.layer.cornerRadius = 8
        bonusContainer.layer.cornerRadius = 8
        dateContainer.layer.cornerRadius = 8
        caloriesContainer.layer.cornerRadius = 8
        dailyCalContainer.layer.cornerRadius = 8
        askGptContainer.layer.cornerRadius = 8
                
        stepGoalTitle.textColor = .lessDark
        stepCountTitle.textColor = .lessDark
        stepText.textColor = .lightGreen
        distanceText.textColor = .lightGreen
        goalText.textColor = .lightGreen
        weightText.textColor = .lightGreen
        weightTitleText.textColor = .lessDark
        bonusTitleText.textColor = .lessDark
        bonusText.textColor = .lightGreen
        dateFormatter.dateFormat = "MMM d, yyyy"
        let d = "\(dateFormatter.string(from: Date()))"
        dateChanger.setTitle(d, for: .normal)
        dateChanger.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        dateChanger.setTitleColor(.lessDark, for: .normal)
        styleView(view: [ progressCircularViewContainer])
        
        logMeal.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let mealListViewController = storyboard.instantiateViewController(identifier: "mealList") as! NutritionalGuidanceViewController
            mealListViewController.title = "Meal List"

            let nav = UINavigationController(rootViewController: mealListViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
        ask.setOnClickListener {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let chatgptViewController = storyboard.instantiateViewController(identifier: "chat") as! ChatGptViewController
            chatgptViewController.title = "Health QA"

            let nav = UINavigationController(rootViewController: chatgptViewController)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true)
        }
        
        checkStepGoal()
        loadStepCounts()
        loadCircularProgressView()
        setUpWeightText()
        loadBonusView()
        getActivities()
        
        UpdateManager().updateBonusAndHistoricalSteps()
        AlertPredictManager().predictAndSetupNotification()
        
        sv.refreshControl = UIRefreshControl()
        sv.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        leftIcon.isUserInteractionEnabled = true
        leftIcon.addGestureRecognizer(tapGestureRecognizer)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification(_:)), name:NSNotification.Name(rawValue: "MyNotificationName"), object: nil)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        checkAuth()
        checkUserInfo()

//        leftIcon.transform = .identity
//
//        UIView.animate(withDuration: 2.0, delay: 0, options: [.repeat, .autoreverse], animations: {
//            self.leftIcon.transform = CGAffineTransform(translationX: -10.0, y: 0)
//        }, completion: nil)
//
        
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
    
    @objc func handleNotification(_ notification: NSNotification) {
        if let date = notification.userInfo?["date"] as? Date {
            updateMetrics(date: date)
        }
        
    }
    
    @objc private func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let calendarPopover = storyboard.instantiateViewController(identifier: "calendarVC")
        calendarPopover.modalPresentationStyle = .overCurrentContext
        calendarPopover.modalTransitionStyle = .coverVertical
        present(calendarPopover, animated: true)
    }
    
    @objc private func didPullToRefresh() {
        // refresh data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setUpNavbar(text: "Dashboard")
            
            let d = "\(self.dateFormatter.string(from: Date()))"
            self.dateChanger.setTitle(d, for: .normal)
            
            self.checkStepGoal()
            self.loadStepCounts()
            self.loadCircularProgressView()
            self.setUpWeightText()
            self.loadBonusView()
            self.getActivities()
            
            UpdateManager().updateBonusAndHistoricalSteps()
            AlertPredictManager().predictAndSetupNotification()
            
            self.sv.refreshControl?.endRefreshing()
        }
    }
    
        private func getActivities() {
            db.getUserInfo { docSnapshot in
                for doc in docSnapshot {
                    if doc["weight"] != nil && doc["weight"] as? Double != nil
                        && doc["height"] != nil && doc["height"] as? Double != nil
                        && doc["gender"] != nil && doc["gender"] as? String != nil
                        && doc["age"] != nil && doc["age"] as? Double != nil
                    {
                        var activeLevel: String = ""
                        var activeLevelFactor: Double = 0
                        HealthKitManager().gettingActivityLevel(date: Date()) { cal in
                            print("active level", cal)
                            if Double(cal).truncate(places: 2) <= 1000.0 {
                                activeLevel = "Sedantary"
                                activeLevelFactor = 1.2
                            }
                            else if Double(cal).truncate(places: 2) > 1000.0 && Double(cal).truncate(places: 2) <= 2000.0 {
                                activeLevel = "Low Active"
                                activeLevelFactor = 1.375
                            }
                            else if Double(cal).truncate(places: 2) > 2000.0 && Double(cal).truncate(places: 2) <= 3000.0 {
                                activeLevel = "Active"
                                activeLevelFactor = 1.55
                            }
                            else {
                                activeLevel = "Very Active"
                                activeLevelFactor = 1.725
                            }
                            let weight = doc["weight"] as! Double
                            let height = doc["height"] as! Double
                            let age = doc["age"] as! Double
                            let gender = doc["gender"] as! String
    
                            var s: Double = 0
    
                            if gender == "Male" {
                                s = 5
                            }
                            else {
                                s = -161
                            }
    
                            let BMR = 10 * weight + 6.25 * height - 5 * age + s
                            let TDEE = BMR * activeLevelFactor
                            var mealCal: Double? = 0
    
                            let mealHist = doc["mealHist"] as? [Any]
                            let today = Date()
                            if mealHist == nil || mealHist!.count == 0 {
                                mealCal = 0
                            } else {
                                for i in 0..<mealHist!.count {
                                    let meal = mealHist![i] as! [String: Any]
                                    let breakfast = meal["breakfast"] as? [String: Any]
                                    let lunch = meal["lunch"] as? [String: Any]
                                    let dinner = meal["dinner"] as? [String: Any]
    
                                    var breakfastCal = 0.0
                                    if breakfast != nil {
                                        breakfastCal = breakfast!["mealCalories"] as? Double ?? 0.0
                                    }
                                    var lunchCal = 0.0
                                    if lunch != nil {
                                        lunchCal = lunch!["mealCalories"] as? Double ?? 0.0
                                    }
                                    var dinnerCal = 0.0
                                    if dinner != nil {
                                        dinnerCal = dinner!["mealCalories"] as? Double ?? 0.0
                                    }
    
                                    let date = (meal["date"] as! Timestamp).dateValue()
                                    if self.isSameDay(today, date) {
                                        mealCal = breakfastCal + lunchCal + dinnerCal
                                    }
                                }
                            }
    
                            DispatchQueue.main.async {
                                self.activeCal.text = "\(Double(cal).truncate(places: 2))"
                                self.activityLevel.text = activeLevel
                                self.TDEEText.text = "\(TDEE.truncate(places: 2))"
                                self.mealCal.text = "\(String(describing: mealCal!))"
                            }
                        }
                    }
                }
            }
    
        }
    
    func updateMetrics(date: Date) {
        print(date)
        
        HealthKitManager().gettingDistOnSpecificDate(date) { dist in
            DispatchQueue.main.sync {
                if dist != nil {
                    let distInKm = Double(dist / 1000).truncate(places: 2)
                    self.distanceText.text = "\(distInKm) km"
                }
            }
        }
        
        HealthKitManager().gettingActivityLevel(date: date) { cals in
            DispatchQueue.main.async {
                self.activeCal.text = "\(cals.truncate(places: 2))"
            }
        }
        
        DatabaseManager.shared.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["historicalSteps"] != nil && (doc["historicalSteps"] as? [Any]) != nil {
                    var historicalSteps = (doc["historicalSteps"] as! [Any])
                    for i in 0..<historicalSteps.count {
                        let step = historicalSteps[i] as! [String: Any]
                        if self.isSameDay((step["date"] as! Timestamp).dateValue(), date) {
                            let stepCount = step["stepCount"] as! Double
                            let stepGoal = step["stepGoal"] as! Double
                            let animation = CABasicAnimation(keyPath: "strokeEnd")
                            var bonusEarned = 0

                            if step["bonusEarned"] != nil {
                                bonusEarned = Int(step["bonusEarned"] as! Double)
                            }

                            animation.toValue = Double(stepCount / stepGoal).truncate(places: 2)
                            animation.duration = CFTimeInterval(self.duration - 0.5)
                            animation.fillMode = CAMediaTimingFillMode.forwards
                            animation.isRemovedOnCompletion = false

                            self.progressShapeLayer.removeAllAnimations()
                            self.progressShapeLayer.add(animation, forKey: "stepPercentage")

                            self.endStep = stepCount

                            self.endPercent = Double(stepCount / stepGoal) * 100.truncate(places: 2)

                            self.dateFormatter.dateFormat = "MMM d, yyyy"
                            let d = "\(self.dateFormatter.string(from: date))"
                            self.dateChanger.setTitle(d, for: .normal)
                            self.goalText.text = "\(step["stepGoal"] as! Int)"
                            self.bonusText.text = "\(bonusEarned)"
                            
                            let percent: Double = Double(stepCount / stepGoal).truncate(places: 2)
                            self.waveView.setupProgress(percent)
                        }
                    }
                }
                if doc["mealHist"] != nil && (doc["mealHist"] as? [Any]) != nil {
                    let mealHist = doc["mealHist"] as! [Any]
                    for i in 0..<mealHist.count {
                        let meal = mealHist[i] as! [String: Any]
                        let day = (meal["date"] as! Timestamp).dateValue()
                        if self.isSameDay(date, day) {
                            let breakfast = meal["breakfast"] as? [String: Any]
                            let lunch = meal["lunch"] as? [String: Any]
                            let dinner = meal["dinner"] as? [String: Any]

                            var breakfastCal = 0.0
                            if breakfast != nil {
                                breakfastCal = breakfast!["mealCalories"] as? Double ?? 0.0
                            }
                            var lunchCal = 0.0
                            if lunch != nil {
                                lunchCal = lunch!["mealCalories"] as? Double ?? 0.0
                            }
                            var dinnerCal = 0.0
                            if dinner != nil {
                                dinnerCal = dinner!["mealCalories"] as? Double ?? 0.0
                            }

                            self.mealCal.text = "\(breakfastCal + lunchCal + dinnerCal)"
                        }
                    }
                }
            }
        }
    }
    
    func isSameDay(_ date1: Date, _ date2: Date) -> Bool {
        let calendar = Calendar.current
        let components1 = calendar.dateComponents([.year, .month, .day], from: date1)
        let components2 = calendar.dateComponents([.year, .month, .day], from: date2)
        return components1.year == components2.year &&
        components1.month == components2.month &&
        components1.day == components2.day
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
    
    private func setUpWeightText() {
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["weight"] != nil && (doc["weight"] as? Double) != nil {
                    let weight = doc["weight"] as! Double
                    self.weightText.text = "\(weight) kg"
                }
            }
        }
    }
    
    private func loadCircularProgressView() {
        
        waveView.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
        waveView.center.x = progressCircularViewContainer.bounds.midX
        waveView.center.y = progressCircularViewContainer.bounds.midY
        progressCircularViewContainer.addSubview(waveView)
                
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
                    }
                    if data["stepGoalToday"] != nil && (data["stepGoalToday"] as? Double) != nil{
                        let steps = data["stepGoalToday"] as! Double
                        self.goalText.text = "\(Int(steps))"
                        let percent: Double = (curStep/steps)
                        self.waveView.setupProgress(percent)
                    }
                    
                    
                }
                
            }
        }
        
        HealthKitManager().gettingDistOnSpecificDate(Date()) { dist in
            DispatchQueue.main.sync {
                if dist != nil {
                    let distInKm = Double(dist / 1000).truncate(places: 2)
                    self.distanceText.text = "\(distInKm) km"
                }
            }
            
        }
        
    }
    
    private func loadCircularProgress() {
        let circularPath = UIBezierPath(arcCenter: CGPoint(x: self.progressCircularViewContainer.bounds.midX, y: self.progressCircularViewContainer.bounds.midY), radius: 120, startAngle: -CGFloat.pi, endAngle: CGFloat.pi, clockwise: true)
        progressShapeLayer.path = circularPath.cgPath
        progressShapeLayer.strokeColor = UIColor.lightGreen.cgColor
        progressShapeLayer.fillColor = nil
        progressShapeLayer.lineWidth = 15
        progressShapeLayer.lineCap = CAShapeLayerLineCap.round
        progressShapeLayer.strokeEnd = 0
        
//        percentText.center = self.progressCircularViewContainer.center
        
        // create track
        let trackLayer = CAShapeLayer()
        trackLayer.path = circularPath.cgPath
        trackLayer.strokeColor = UIColor.lessDark.cgColor
        trackLayer.fillColor = nil
        trackLayer.lineWidth = 2
        trackLayer.lineCap = CAShapeLayerLineCap.round
        
        percentText.frame = CGRect(x: 0, y: 0, width: 150, height: 40)
        percentText.center.x = circularPath.bounds.midX
        percentText.center.y = circularPath.bounds.midY
        percentText.textAlignment = .center
        percentText.textColor = UIColor.lessDark
        percentText.font = UIFont(name: "Futura", size: 40)
                
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
                            self.percentText.font = UIFont(name: "Futura", size: 40)
                        } else {
                            self.animateText(target: 2)
                        }
                    }
                    if data["stepGoalToday"] != nil && (data["stepGoalToday"] as? Double) != nil{
                        let steps = data["stepGoalToday"] as! Double
                        self.goalText.text = "\(Int(steps))"
                    }
                }
                
            }
        }
        
        HealthKitManager().gettingDistOnSpecificDate(Date()) { dist in
            DispatchQueue.main.sync {
                if dist != nil {
                    let distInKm = Double(dist / 1000).truncate(places: 2)
                    self.distanceText.text = "\(distInKm) km"
                }
            }
            
        }
        
        
        progressCircularViewContainer.addSubview(percentText)
        progressCircularViewContainer.layer.addSublayer(trackLayer)
        progressCircularViewContainer.layer.addSublayer(progressShapeLayer)
            
    }
    
    private func loadStepCounts () {

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
                    }
                }
            }
        }
        setPercentage()
    }
    
    private func loadBonusView() {

        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["bonusEarnedToday"] != nil && (doc["bonusEarnedToday"] as? Double) != nil{
                    let bonusEarnedToday = (doc["bonusEarnedToday"] as! Double).truncate(places: 2)
                    self.bonusText.text = "\(bonusEarnedToday)"
                }
            }
        }

        bonusText.text = "Tokens Earned: 0"

        db.checkUserUpdates { data, update, addition, deletion in
            if update == true {
                if data["bonusEarnedToday"] != nil && (data["bonusEarnedToday"] as? Double) != nil {
                    let bonusEarnedToday = (data["bonusEarnedToday"] as! Double).truncate(places: 2)
                    self.bonusText.text = "\(bonusEarnedToday)"
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
                self.stepText.text = "\(Int(endStep)) steps"
            } else {
                if endPercent >= 100.0 {
                    self.percentText.text = "Done!"
                } else {
                    self.percentText.text = "\(endPercent.truncate(places: 2))%"
                }
            }
        } else {
            let percent = elapsedTime / duration

            if target == 1 {
                let val = percent * (endStep - startStep)
                self.stepText.text = "\(Int(val)) steps"
            } else {
                let val = percent * (endPercent - startPercent)
                if val >= 100.0 {
                    self.percentText.text = "Done!"
                } else {
                    self.percentText.text = "\(val.truncate(places: 2))%"
                }
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
    
}

