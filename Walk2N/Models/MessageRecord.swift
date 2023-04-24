//
//  Message.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/20/23.
//

import Foundation


public class Messages: Codable {
    var senderId: String?
    var senderName: String?
    var sentDate: Date?
    var content: String?
    
    init(senderId: String?, senderName: String?, sentDate: Date?, content: String?) {
        self.senderId = senderId
        self.senderName = senderName
        self.sentDate = sentDate
        self.content = content
    }
    
    var firestoreData: [String: Any] {
        return [
            "senderId": senderId as Any,
            "senderName": senderName as Any,
            "sentDate": sentDate as Any,
            "content": content as Any
        ]
    }
}

public class MessageRecord {
    var uid: String?
    var messageList: Array<Messages>?
    
    init(uid: String?, messageList: Array<Messages>?) {
        self.uid = uid
        self.messageList = messageList
    }
}
