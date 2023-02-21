//
//  DatabaseManager.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import Firebase

public class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let db = Firestore.firestore()
    
    // check whether email is being registered
    public func canCreateAcc(email: String, completion:@escaping ((Bool) -> Void)) {
        let collectionRef = db.collection("users")
        collectionRef.whereField("email", isEqualTo: email).getDocuments { (snapshot, err) in
            if let err = err {
                print("Error getting document: \(err)")
            } else if (snapshot?.isEmpty)! {
                completion(true)
            } else {
                for document in (snapshot?.documents)! {
                    if document.data()["email"] != nil {
                        completion(false)
                    }
                }
            }
        }
    }
    
    // insert user info to the firestore
    public func insertUser(user: User, completion:@escaping ((Bool) -> Void)) {
        db.collection("users").addDocument(data: [
            "uid": user.uid as Any,
            "email": user.email as Any,
            "password": user.password as Any,
            "balance": user.balance as Any,
            "firstName": user.firstName as Any,
            "lastName": user.lastName as Any,
            "weight": user.weight as Any,
            "height": user.height as Any,
            "age": user.age as Any,
            "gender": user.gender as Any,
            "historicalSteps": user.historicalSteps as Any,
            "bonusEarnedToday": user.bonusEarnedToday as Any,
            "stepGoalToday": user.stepGoalToday as Any,
            "boughtShoes": user.boughtShoes as Any,
            "currentShoe": user.currentShoe as Any,
            "bonusHistory": user.bonusHistory as Any
        ]
        ) {(err) in
            if err != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    // retrieve user info object from firestore
    public func getUserInfo(_ completion:@escaping(_ docSnapshot:[DocumentSnapshot])->Void ){
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            db.collection("users").whereField("uid", isEqualTo: uid!).getDocuments { querySnapshot, err in
                if let err = err {
                    print("Error getting docs: \(err)")
                }else{
                    if let doc = querySnapshot?.documents {
                        completion(doc)
                    }
                }
            }
        }
    }
    
    // update user info based on array of fields and values
    public func updateUserInfo(fieldToUpdate: Array<String>, fieldValues: Array<Any>, _ completion:@escaping(_ bool: Bool) -> Void) {
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            db.collection("users").whereField("uid", isEqualTo: uid!).getDocuments { querySnapShot, err in
                if let err = err {
                    print(err)
                    completion(false)
                }
                else {
                    let doc = querySnapShot?.documents.first
                    for i in 0..<fieldToUpdate.count {
                        doc?.reference.updateData([
                            fieldToUpdate[i] : fieldValues[i]
                        ])
                    }
                    completion(true)
                }
            }
        }
    }

    
    public func updateArrayData(fieldName: String, fieldVal: [String: Any], pop: Bool, _ completion:@escaping(_ bool: Bool) -> Void){
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            db.collection("users").whereField("uid", isEqualTo: uid!).getDocuments { querySnapShot, err in
                if let err = err {
                    print(err)
                    completion(false)
                }
                else {
                    let doc = querySnapShot?.documents.first
                    if pop == true {
                        doc?.reference.updateData([
                            fieldName : FieldValue.arrayRemove([fieldVal])
                        ])
                    }
                    else {
                        doc?.reference.updateData([
                            fieldName : FieldValue.arrayUnion([fieldVal])
                        ])
                    }
                    
                    completion(true)
                }
            }
        }
    }
    
    // check whether user has input their weight height age and gender
    public func isUserInfoAvail(completion:@escaping(_ bool: Bool) -> Void) {
        self.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["age"] as AnyObject is NSNull || doc["height"] as AnyObject is NSNull || doc["weight"] as AnyObject is NSNull || doc["gender"] as AnyObject is NSNull{
                    completion(false)
                }else{
                    completion(true)
                }
            }
        }
    }
    
    public func getShoes(completion:@escaping(_ docSnapshot:[DocumentSnapshot])->Void) {
        db.collection("shoeStore").getDocuments { querySnapshot, err in
            if let err = err {
                print("Error getting docs: \(err)")
            }else{
                if let doc = querySnapshot?.documents {
                    completion(doc)
                }
            }
        }
    }
    
    public func checkUserUpdates(completion:@escaping(_ data:[String: Any], _ update: Bool, _ addition: Bool, _ deletion: Bool)->Void) {
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            db.collection("users").whereField("uid", isEqualTo: uid!).addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else { return }
                snapshot.documentChanges.forEach { diff in
                    if diff.type == .modified {
                        completion(diff.document.data(), true, false, false)
                    }
                    else if diff.type == .added {
                        completion(diff.document.data(), false, true, false)
                    }
                    else if diff.type == .removed {
                        completion(diff.document.data(), false, false, true)
                    }
                    else {
                        completion([:], false, false, false)
                    }
                }
            }
        }
    }
    
    func updateBonus() {
        let db = DatabaseManager.shared
        
        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                if doc["historicalSteps"] != nil {
                    var historicalSteps = doc["historicalSteps"] as! [Any]
                    historicalSteps = historicalSteps.sorted(by: {
                        ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                    })
                    let newestStepData = historicalSteps[historicalSteps.count - 1] as! [String: Any]
                    let newestSteps = newestStepData["stepCount"] as! Double
                    
                    let wearShoe = newestStepData["wearShoe"] as! Bool
                    let reachedGoal = newestStepData["reachedGoal"] as! Bool
                    
                    let balance = doc["balance"] as! Double
                    var bonusSoFar = doc["bonusEarnedToday"] as! Double
                    let bonusEarnedDuringRealTimeRun = doc["bonusEarnedDuringRealTimeRun"] as! Double
                    
                    var awardPerStep: Double? = 0.0
                    if doc["currentShoe"] != nil {
                        let currentShoe = doc["currentShoe"] as! [String: Any]
                        awardPerStep = (currentShoe["awardPerStep"] as! Double)
                    }
                    
                    var bonusEarned = 0.0
                    var newEarning = balance
                    
                    if doc["bonusAwardedForReachingStepGoal"] as! Bool == false &&  reachedGoal == true {
                        bonusSoFar += 100.0
                        db.updateUserInfo(fieldToUpdate: ["bonusAwardedForReachingStepGoal", "bonusEarnedToday", "balance"], fieldValues: [true, bonusSoFar, balance + bonusSoFar]) { bool in }
                    }
                    
                    HealthKitManager().gettingStepCount(0) { steps, time in
                        let currentStep = steps[0]
                        
                        if wearShoe == true && newestSteps < currentStep {

                            // do the formula here:
                            bonusEarned = (currentStep - newestSteps) * awardPerStep!
                            newEarning = balance + bonusEarned - bonusEarnedDuringRealTimeRun
                            
                            db.updateUserInfo(fieldToUpdate: ["balance"], fieldValues: [newEarning]) { bool in }
                            db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday"], fieldValues: [bonusSoFar + bonusEarned - bonusEarnedDuringRealTimeRun]) { bool in }
                        }
                    }
                    
                    
                }
//                var isYesterdayBonusCalculated = false
//                if doc["bonusHistory"] != nil {
//                    let bonusHistory = doc["bonusHistory"] as! [Any]
//                    if bonusHistory.count > 0 {
//                        isYesterdayBonusCalculated = self.checkWhetherBonusIsCalculated(historyArr: bonusHistory, date: yesterday)
//                    }
//                }
//                if isYesterdayBonusCalculated == false {
//                    // calculate for yesterday
//                    if doc["historicalSteps"] != nil {
//                        let historicalSteps = doc["historicalSteps"] as! [Any]
//                        let balance = doc["balance"] as! Double
//                        for i in 0..<historicalSteps.count {
//                            let historicalSteps = historicalSteps[i] as! [String: Any]
//                            let stepDate = (historicalSteps["date"] as! Timestamp).dateValue()
//                            let wearShoe = historicalSteps["wearShoe"] as! Bool
//                            let reachedGoal = historicalSteps["reachedGoal"] as! Bool
//
//                            if self.isSameDay(date1: stepDate, date2: yesterday) {
//                                if wearShoe == true {
//                                    let steps = historicalSteps["stepCount"] as! Double
//                                    var awardPerStep: Double? = 0.0
//                                    if doc["currentShoe"] != nil {
//                                        let currentShoe = doc["currentShoe"] as! [String: Any]
//                                        awardPerStep = (currentShoe["awardPerStep"] as! Double)
//                                    }
//
//                                    // do the formula here:
//                                    let earned = steps * awardPerStep! + (reachedGoal == true ? 1.0 : 0.0) * 1.2
//                                    let bonus = Bonus(id: UUID().uuidString, amount: earned, date: yesterday)
//                                    let duplicateEarning = doc["bonusEarnedToday"] as? Double ?? 0.0
//                                    let yesterdayEarning = balance + earned - duplicateEarning
//
//                                    db.updateArrayData(fieldName: "bonusHistory", fieldVal: bonus.firestoreData, pop: false) { bool in }
//                                    db.updateUserInfo(fieldToUpdate: ["balance"], fieldValues: [yesterdayEarning]) { bool in }
//                                    db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday"], fieldValues: [0.0]) { bool in }
//
//                                } else {
//                                    // not wearing shoe, bonus is 0
//                                    let bonus = Bonus(id: UUID().uuidString, amount: 0, date: yesterday)
//                                    db.updateArrayData(fieldName: "bonusHistory", fieldVal: bonus.firestoreData, pop: false) { bool in }
//                                    db.updateUserInfo(fieldToUpdate: ["bonusEarnedToday"], fieldValues: [0.0]) { bool in }
//                                }
//                            }
//                        }
//                    }
//                }
            }
        }
    }
    
    func checkWhetherBonusIsCalculated(historyArr: [Any], date: Date) -> Bool {
        for i in 0..<historyArr.count {
            let bonus = historyArr[i] as! [String: Any]
            let bonusDate = (bonus["date"] as! Timestamp).dateValue()
            
            if isSameDay(date1: bonusDate, date2: date){
                return true
            }
        }
        return false
    }
    
    func isSameDay(date1: Date, date2: Date) -> Bool {
        let diff = Calendar.current.dateComponents([.day], from: date1, to: date2)
        if diff.day == 0 {
            return true
        } else {
            return false
        }
    }
    
    func updateHistoricalSteps() {
        let db = DatabaseManager.shared

        db.getUserInfo { docSnapshot in
            for doc in docSnapshot {
                // check whether there's historical step data available, if not, push the past week's step data
                if doc["historicalSteps"] != nil {
                    var historicalSteps = doc["historicalSteps"] as! [Any]
                    historicalSteps = historicalSteps.sorted(by: {
                        ((($0 as! [String:Any])["date"] as! Timestamp).dateValue()) < ((($1 as! [String:Any])["date"] as! Timestamp).dateValue())
                    })
                    let newestStep = historicalSteps[historicalSteps.count - 1] as! [String: Any]
                    let newestStepDate = (newestStep["date"] as! Timestamp).dateValue()
                    let today = Date()
                    let diffInDays = Calendar.current.dateComponents([.day], from: newestStepDate, to: today).day!
                    
                    // if there is step data in the database check if these are up to date, and push the most recent data into the db
                    if diffInDays > 0 {
                        self.addStepToDB(diffInDays - 1)
                    } else {
                        // if it is the same day, check if steps are the same, if not, update the same day step count
                        HealthKitManager().gettingStepCount(0) { stepArr, timeArr in
                            let stepToday = stepArr[0]
                            let stepCount = newestStep["stepCount"] as! Double
                            if stepToday != stepCount {
                                var newestHistoricalArray = []
                                for i in 0..<historicalSteps.count {
                                    if (historicalSteps[i] as! [String: Any])["id"] as! String == newestStep["id"] as! String {
                                        let elem = historicalSteps[i] as! [String: Any]
                                        let reachedGoal = stepToday >= 1000
                                        let wearShoe = doc["currentShoe"] as? [String: Any]? == nil ? false: true
                                        let newElem = HistoricalStep(id: (elem["id"] as! String), uid: (elem["uid"] as! String), stepCount: Int(stepToday), date: (elem["date"] as! Timestamp).dateValue(), reachedGoal: reachedGoal, wearShoe: wearShoe, stepGoal: (elem["stepGoal"] as! Double))
                                        newestHistoricalArray.append(newElem.firestoreData)
                                    } else {
                                        newestHistoricalArray.append(historicalSteps[i])
                                    }
                                }
                                db.updateUserInfo(fieldToUpdate: ["historicalSteps"], fieldValues: [newestHistoricalArray]) { bool in }
                            }
                        }
                    }
                }
                else {
                    self.addStepToDB(6)
                }
            }
        }
    }

    private func addStepToDB(_ n: Int) {
        if (Auth.auth().currentUser != nil) {
            HealthKitManager().gettingStepCount(n) { stepArr, timeArr in
                for (step, time) in zip(stepArr, timeArr) {
                    let stepGoalToday = 1000.0
                    var reachedGoal = false
                    if step >= stepGoalToday {
                        reachedGoal = true
                    }
                    var stepToday: HistoricalStep?
                    DatabaseManager.shared.getUserInfo { docSnapshot in
                        for doc in docSnapshot {
                            if doc["currentShoe"] as? [String: Any] != nil {
                                stepToday = HistoricalStep(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid, stepCount: Int(step), date: time, reachedGoal: reachedGoal, wearShoe: true, stepGoal: stepGoalToday)
                                self.updateDBWithStep(stepData: stepToday!)
                            } else {
                                stepToday = HistoricalStep(id: UUID().uuidString, uid: Auth.auth().currentUser?.uid, stepCount: Int(step), date: time, reachedGoal: reachedGoal, wearShoe: false, stepGoal: stepGoalToday)
                                self.updateDBWithStep(stepData: stepToday!)
                            }
                        }
                    }
                    
                    
                }
            }
        }
    }
    
    private func updateDBWithStep(stepData: HistoricalStep) {
        DatabaseManager.shared.updateArrayData(fieldName: "historicalSteps", fieldVal: stepData.firestoreData, pop: false) { success in
            if success == true {
                print("successfully added")
            } else {
                print("unsuccessfully added")
            }
        }
    }
    
    
}
