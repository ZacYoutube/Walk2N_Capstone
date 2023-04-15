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
            "bonusHistory": user.bonusHistory as Any,
            "profileImgUrl": user.profileImgUrl as Any,
            "alertHist": user.alertHist as Any
        ]
        ) {(err) in
            if err == nil {
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
    
    // function to update firestore array type document (push and pop)
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
    
    // get the shoes from shoe store
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
    
    // listener that listens to user collection changes
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
    
    func saveTodayRecom(meal: MealHist) {
        db.collection("mealHist").addDocument(data: [
            "uid": meal.uid as Any,
            "id": UUID().uuidString as Any,
            "breakfast": meal.breakfast?.firestoreData as Any,
            "lunch": meal.lunch?.firestoreData as Any,
            "dinner": meal.dinner?.firestoreData as Any,
            "date": meal.date as Any
        ])
    }
    
    func saveToDietFilter(dietFilter: DietFilter) {
        db.collection("dietFilter").addDocument(data: [
            "uid": dietFilter.uid as Any,
            "bloodSugarLevel": dietFilter.bloodSugarLevel as Any,
            "cholesterolLevel": dietFilter.cholesterolLevel as Any,
            "dietGoal": dietFilter.dietGoal as Any,
            "foodAlergies": dietFilter.foodAlergies as Any,
            "dietaryPreferences": dietFilter.dietaryPreferences as Any,
            "cusinePreferences": dietFilter.cusinePreferences as Any,
            "otherInfo": dietFilter.otherInfo as Any
        ])
    }
    
    func getUserDietaryFilter(_ completion:@escaping(_ docSnapshot:[DocumentSnapshot])->Void ) {
        let uid = Auth.auth().currentUser?.uid
        if uid != nil {
            db.collection("dietFilter").whereField("uid", isEqualTo: uid!).getDocuments { querySnapshot, err in
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
    
    public func updateUserDietaryFilter(uid: String, fieldToUpdate: [String], fieldValues: [Any], _ completion:@escaping(_ bool: Bool) -> Void) {
        db.collection("dietFilter").whereField("uid", isEqualTo: uid).getDocuments { querySnapShot, err in
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
    
    func getRecommendations(_ completion:@escaping(_ docSnapshot:[DocumentSnapshot])->Void ) {
        let uid = Auth.auth().currentUser?.uid
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        
        if uid != nil {
            db.collection("mealHist").whereField("uid", isEqualTo: uid!).whereField("date", isEqualTo: startOfDay).getDocuments { querySnapshot, err in
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
    
    public func updateRecom(uid: String, date: Date, field: String, value: Any, _ completion:@escaping(_ bool: Bool) -> Void) {
        db.collection("mealHist").whereField("uid", isEqualTo: uid).getDocuments { querySnapShot, err in
            if let err = err {
                print(err)
                completion(false)
            }
            else {
                let doc = querySnapShot?.documents.first
                
                doc?.reference.updateData([
                    field : value
                ])
                
                completion(true)
            }
        }
        
    }
    
}
