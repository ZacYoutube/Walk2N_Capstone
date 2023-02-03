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
    public func insertUser(email: String, uid: String, completion:@escaping ((Bool) -> Void)) {
        db.collection("users").addDocument(data: [
            "uid": uid,
            "email": email,
            "password": "",
            "balance": 1000,
            "firstName":"",
            "lastName":"",
            "historicalSteps":[],
            "reachedStepGoal": false,
            "stepGoalToday": 0,
            "boughtShoes":[],
            "currentShoe":""]
        ) {(err) in
            if err != nil {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
}
