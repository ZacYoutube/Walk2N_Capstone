////
////  ChatUIViewController.swift
////  Walk2N
////
////  Created by Zhiquan You on 4/20/23.
////
//
//import UIKit
//import MessageKit
//import InputBarAccessoryView
//import Firebase
//
//struct Sender: SenderType {
//    var senderId: String
//    var displayName: String
//}
//
//struct Message: MessageType {
//    var sender: SenderType
//    var messageId: String
//    var sentDate: Date
//    var kind: MessageKind
//}
//
//class ChatUIViewController: MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate {
//    var textViewHeightConstraint: NSLayoutConstraint?
//    var messageInputBarBottomConstraint: NSLayoutConstraint?
//    private lazy var keyboardManager = KeyboardManager()
//
//    let db = DatabaseManager.shared
//
//    let currentSender: SenderType = Sender(senderId: Firebase.Auth.auth().currentUser?.uid ?? "1", displayName: "Zac")
//    let chatgptSender: SenderType = Sender(senderId: "2", displayName: "ChatGPT")
//    var messages: [Message] = []
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        loadMessage()
//        messagesCollectionView.messagesDataSource = self
//        messagesCollectionView.messagesLayoutDelegate = self
//        messagesCollectionView.messagesDisplayDelegate = self
//        messagesCollectionView.backgroundColor = .background1
//        messagesCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
//        messageInputBar.delegate = self
//
//        messageInputBar.inputTextView.placeholder = "Type a message"
//        messageInputBar.inputTextView.placeholderTextColor = UIColor.lightGray
//        messageInputBar.sendButton.tintColor = .white
//        messageInputBar.backgroundView.backgroundColor = .white
//
//        messageInputBar.backgroundView.center = messageInputBar.superview!.center
//
//        messageInputBar.separatorLine.isHidden = true
//        messageInputBar.inputTextView.backgroundColor = UIColor.white
//        messageInputBar.inputTextView.font = UIFont.systemFont(ofSize: 16.0)
//
//        messageInputBar.inputTextView.isScrollEnabled = false
//
//        messageInputBar.leftStackView.alignment = .center
//        messageInputBar.rightStackView.alignment = .center
//
//        // Set up a height constraint for the text view
//        textViewHeightConstraint = messageInputBar.inputTextView.heightAnchor.constraint(equalToConstant: 80)
//        textViewHeightConstraint?.isActive = true
//
//        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
//            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
//            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
//        }
//
//        messagesCollectionView.reloadData()
//        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
//    }
//
//    override func viewDidAppear(_ animated: Bool) {
//         super.viewDidAppear(animated)
//        self.becomeFirstResponder()
//     }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        NotificationCenter.default.removeObserver(self)
//    }
//
//    @objc private func keyboardWillShow(_ notification: Notification) {
//
//    }
//
//    @objc private func keyboardWillHide(_ notification: Notification) {
//
//    }
//
//    func loadMessage() {
//        db.getMessages { docSnapshot in
//            print("doc found!!", docSnapshot)
//            for doc in docSnapshot {
//                let messageList = doc["messageList"] as? [Any]
//                if messageList != nil {
//                    for i in 0..<messageList!.count {
//                        let message = messageList![i] as? [String: Any]
//                        if message != nil {
//                            let senderId = message!["senderId"] as? String
//                            let senderName = message!["senderName"] as? String
//                            let sentDate = (message!["sentDate"] as! Timestamp).dateValue()
//                            let content = message!["content"] as? String
//
//                            let sender = Sender(senderId: senderId!, displayName: senderName!)
//                            self.messages.append(Message(sender: sender, messageId: UUID().uuidString, sentDate: sentDate, kind: .text(content!)))
//
//                            print(self.messages, sender)
//                        }
//                    }
//                    self.messagesCollectionView.reloadData()
//                }
//            }
//        }
//    }
//
//    func addMessages(message: [Message]) {
//        let uid = Firebase.Auth.auth().currentUser?.uid
//        db.getMessages { docSnapshot in
//            if docSnapshot.count == 0 {
//                var messageList: [Messages] = []
//                for i in 0..<message.count {
//                    let m = message[i]
//                    let messageObj = Messages(senderId: m.sender.senderId, senderName: m.sender.displayName, sentDate: m.sentDate, content: self.getTextFromMessage(message: m))
//                    messageList.append(messageObj)
//                }
//                print("messageList", messageList)
//                self.db.addMessageDoc(messageRecord: MessageRecord(uid: uid!, messageList: messageList)) { err in
//                    print(err)
//                }
//            }
//            else {
//                var messageDictArr = [[String: Any]]()
//                for i in 0..<message.count {
//                    let m = message[i]
//                    let messageDict = [
//                        "senderId": m.sender.senderId,
//                        "content": self.getTextFromMessage(message: m),
//                        "senderName": m.sender.displayName,
//                        "sentDate": m.sentDate
//                    ]
//                    messageDictArr.append(messageDict)
//                }
//                self.db.updateMessages(fieldToUpdate: ["messageList"], fieldValues: [messageDictArr])
//            }
//        }
//    }
//
//    @objc func textViewDidChange() {
//        // Update the height constraint based on the text view's intrinsic content size
//        textViewHeightConstraint?.constant = messageInputBar.inputTextView.intrinsicContentSize.height
//        UIView.animate(withDuration: 0.1) {
//            self.view.layoutIfNeeded()
//        }
//    }
//
//    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
//        return messages[indexPath.section]
//    }
//
//    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
//        return messages.count
//    }
//
//    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
//        return isFromCurrentSender(message: message) ? UIColor.lightGreen : UIColor.grayish
//    }
//
//    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
//        view.inputViewController?.hidesBottomBarWhenPushed = true
//        let senderMessage = Message(sender: currentSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
//        messages.append(senderMessage)
//        messagesCollectionView.reloadData()
//        if text != "" {
//            GptApiService().getGptStream(messagePrompt: text) { response, done in
//                self.addChatGptResponse(response)
//
//                if done == true {
//                    self.addMessages(message: self.messages)
//                }
//            }
//        }
//        inputBar.inputTextView.text = ""
//        inputBar.sendButton.isEnabled = false
//    }
//
//    func addChatGptResponse(_ response: String) {
//        // Append new lines of text to the existing message
//        if let lastMessage = messages.last, lastMessage.sender.senderId == chatgptSender.senderId {
//            let updatedText = "\(getTextFromMessage(message: lastMessage)) \(response)"
//            let updatedMessage = Message(sender: lastMessage.sender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(updatedText))
//            messages[messages.count - 1] = updatedMessage
//        } else {
//            // Create a new message for ChatGPT response
//            let newMessage = Message(sender: chatgptSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(response))
//            messages.append(newMessage)
//        }
//        DispatchQueue.main.async {
//            self.messagesCollectionView.reloadData()
//            self.messagesCollectionView.scrollToLastItem(animated: true)
//        }
//    }
//
//    func getTextFromMessage(message: Message) -> String {
//        switch message.kind {
//            case .text(let text):
//                return text
//            case .attributedText(_):
//                return ""
//            case .photo(_):
//                return ""
//            case .video(_):
//                return ""
//            case .location(_):
//                return ""
//            case .emoji(_):
//                return ""
//            case .audio(_):
//                return ""
//            case .contact(_):
//                return ""
//            case .linkPreview(_):
//                return ""
//            case .custom(_):
//                break
//            }
//        return ""
//    }
//}
