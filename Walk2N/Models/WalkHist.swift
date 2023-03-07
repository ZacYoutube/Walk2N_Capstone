//
//  Bonus.swift
//  Walk2N
//
//  Created by Zhiquan You on 2/19/23.
//

import Foundation

public class WalkHist: Codable {
    
    var uid: String?
    var distance: Double?
    var duration: Double?
    var steps: Double?
    var bonus: Double?
    var longitudeArr: [Double]?
    var latitudeArr: [Double]?
    var title: String?
    var description: String?
    var date: Date?
    var id: String?
    
    init(id: String?, uid: String?, distance: Double?, duration: Double?, steps: Double?, bonus: Double?, longitudeArr: [Double]?, latitudeArr: [Double]?, title: String?, description: String?, date: Date?) {
        self.id = id
        self.uid = uid
        self.distance = distance
        self.duration = duration
        self.steps = steps
        self.bonus = bonus
        self.longitudeArr = longitudeArr
        self.latitudeArr = latitudeArr
        self.title = title
        self.description = description
        self.date = date
    }
    
    var firestoreData: [String: Any] {
        return [
            "uid": uid as Any,
            "distance": distance as Any,
            "duration": duration as Any,
            "steps": steps as Any,
            "bonus": bonus as Any,
            "longitudeArr": longitudeArr as Any,
            "latitudeArr": latitudeArr as Any,
            "title": title as Any,
            "description": description as Any,
            "date": date as Any
        ]
    }
}
