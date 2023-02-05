//
//  AuthManager.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/1/23.
//

import Firebase

public class AuthManager {
    
    static let shared = AuthManager()
    
    public func createNewUser(email: String, password: String, completion:@escaping ((Bool, String) -> Void)) {
        
        DatabaseManager.shared.canCreateAcc(email: email) { canCreate in
            if canCreate {
                Auth.auth().createUser(withEmail: email, password: password) { authData, err in
                    if authData != nil, err == nil {
                        completion(true, (authData?.user.uid)!)
                    }else{
                        completion(false, "")
                    }
                }
            }else{
                completion(false, "")
            }
        }
    }
    
    public func login(email: String, password: String, completion:@escaping ((Bool) -> Void)) {

        Auth.auth().signIn(withEmail: email, password: password){ authData, err in
            if authData != nil, err == nil {
                completion(true)
            }else{
                completion(false)
            }
        }
    }
    
    public func logout() {
        try! Auth.auth().signOut()
    }
}

