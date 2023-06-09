//
//  ChatGptViewController.swift
//  Walk2N
//
//  Created by Zhiquan You on 4/20/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import Speech

struct Sender: SenderType {
    var senderId: String
    var displayName: String
}

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

class ChatGptViewController:  MessagesViewController, MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate, InputBarAccessoryViewDelegate, SFSpeechRecognizerDelegate {
    
    var textViewHeightConstraint: NSLayoutConstraint?
    var messageInputBarBottomConstraint: NSLayoutConstraint?
    @IBOutlet weak var backBtn: UIButton!

    let db = DatabaseManager.shared

    let currentSender: SenderType = Sender(senderId: Firebase.Auth.auth().currentUser?.uid ?? "1", displayName: "Zac")
    let chatgptSender: SenderType = Sender(senderId: "2", displayName: "ChatGPT")
    var messages: [Message] = []
    var clearButton: InputBarButtonItem?
    let audioEngine = AVAudioEngine()
    let speechRecognizer: SFSpeechRecognizer? = SFSpeechRecognizer()
    let recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
    var recognitionTask: SFSpeechRecognitionTask?
    var startTalking: Bool = false
    
    var isTyping: Bool = false
    let voiceBtn = UIButton(type: .custom)
    let voiceImage = UIImage(named: "mic")!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadMessage()
        print(messageInputBar.sendButton.frame.size.width)
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.backgroundColor = .white
        messagesCollectionView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        messagesCollectionView.refreshControl = UIRefreshControl()
        messagesCollectionView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    
        messageInputBar.delegate = self
        
        messageInputBar.inputTextView.placeholder = "Type a message"
        messageInputBar.inputTextView.placeholderTextColor = UIColor.lightGray
        messageInputBar.inputTextView.layer.borderColor = UIColor.gray.cgColor
        messageInputBar.inputTextView.layer.borderWidth = 0.5
        messageInputBar.inputTextView.layer.cornerRadius = 8
        messageInputBar.sendButton.tintColor = .white
        messageInputBar.backgroundView.backgroundColor = .white

        messageInputBar.backgroundView.center = messageInputBar.superview!.center

        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.backgroundColor = UIColor.white
        messageInputBar.inputTextView.font = UIFont.systemFont(ofSize: 16.0)
        
        messageInputBar.inputTextView.isScrollEnabled = false

        messageInputBar.leftStackView.alignment = .center
        messageInputBar.rightStackView.alignment = .center
        
        // Set up a height constraint for the text view
        textViewHeightConstraint = messageInputBar.inputTextView.heightAnchor.constraint(equalToConstant: 35)
        textViewHeightConstraint?.isActive = true
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            layout.textMessageSizeCalculator.incomingAvatarSize = .zero
        }
        
        backBtn.setOnClickListener {
            self.dismiss(animated: true)
        }
        
        let clearImage = UIImage(named: "clear")
        clearButton = InputBarButtonItem(type: .custom)
        clearButton?.setSize(CGSize(width: 29, height: 29), animated: false)
        clearButton!.image = clearImage
        clearButton!.imageView?.contentMode = .scaleAspectFit
        clearButton!.setOnClickListener {
            let alert = UIAlertController(title: "Clear the history?", message: "", preferredStyle: .actionSheet)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "Clear", style: .default, handler: { action in
                self.db.updateMessages(fieldToUpdate: ["messageList"], fieldValues: [[]])
                self.messages = []
                self.messagesCollectionView.reloadData()
                self.clearButton!.isEnabled = false
            }))
            self.getTopMostViewController()!.present(alert, animated: true)
        }
        
        let sendImage = UIImage(named: "send")!
        messageInputBar.sendButton.image = sendImage
        messageInputBar.sendButton.title = ""
        
        messageInputBar.sendButton.imageView?.contentMode = .scaleAspectFit
        messageInputBar.sendButton.configure { button in
            button.setSize(CGSize(width: 29, height: 29), animated: false)
        }
        messageInputBar.setStackViewItems([messageInputBar.sendButton, clearButton!], forStack: .right, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 100, animated: false)
        messageInputBar.inputTextView.layer.cornerRadius = 8
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 10, bottom: 8, right: 40)

        
        voiceBtn.setImage(voiceImage, for: .normal)
        voiceBtn.setOnClickListener {
            self.voiceProcessing()
        }
        guard let superview = messageInputBar.inputTextView.superview else {
            return
        }
        superview.addSubview(voiceBtn)
        voiceBtn.autoresizingMask = [.flexibleLeftMargin, .flexibleBottomMargin]

        let buttonWidth: CGFloat = 30
        let buttonHeight: CGFloat = 30
        let buttonMargin: CGFloat = 5
        voiceBtn.frame = CGRect(x: superview.bounds.width - buttonWidth - buttonMargin,
                                y: (messageInputBar.inputTextView.bounds.height - buttonHeight) / 2,
                         width: buttonWidth,
                         height: buttonHeight)
        
        messageInputBar.rightStackView.distribution = .fillEqually
        
        reloadInputViews()
        setUpClearBtn()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTapGesture(_:)))
        messagesCollectionView.addGestureRecognizer(tapGesture)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textViewDidChange), name: UITextView.textDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleTapGesture(_ gestureRecognizer: UITapGestureRecognizer) {
        // Hide keyboard when user taps around the screen
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        super.scrollViewWillBeginDragging(scrollView)
        
        // Hide keyboard when user starts scrolling
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lessDark,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)
        ]
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short

        let calendar = NSCalendar.current
        let now = Date()
        let date = message.sentDate
        
        if calendar.isDateInToday(date) {
            dateFormatter.dateFormat = "'Today', h:mm a"
        } else {
            dateFormatter.dateFormat = "MMM d, h:mm a"
        }

        let formattedTime = dateFormatter.string(from: date)
        
        return isFromCurrentSender(message: message) ? NSAttributedString(string: formattedTime, attributes: attributes) : NSAttributedString(string: "", attributes: attributes)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return isFromCurrentSender(message: message) ? 40 : 0
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let attributes = [
            NSAttributedString.Key.foregroundColor: UIColor.lessDark,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)
        ]
        return isFromCurrentSender(message: message) ? NSAttributedString(string: "You", attributes: attributes) : NSAttributedString(string: "WellnessGPT", attributes: attributes)
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func messageTopLabelAlignment(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LabelAlignment? {
        if isFromCurrentSender(message: message) {
            return LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20))
        }
        else {
            return LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 0))
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubbleTail(isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft, .curved)
    }
    
    private func setUpClearBtn() {
        db.getMessages { docSnapshot in
            for doc in docSnapshot {
                let messageList = doc["messageList"] as? [Any]
                if messageList != nil {
                    if messageList!.count > 0 {
                        self.clearButton!.isEnabled = true
                    } else {
                        self.clearButton!.isEnabled = false
                    }
                }
            }
        }
    }
    
    @objc private func didPullToRefresh() {
        // refresh data
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.setUpClearBtn()
            self.loadMessage()
            self.messagesCollectionView.refreshControl?.endRefreshing()
        }
        
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {

    }

    @objc private func keyboardWillHide(_ notification: Notification) {

    }
    
    func voiceProcessing() {
        startTalking = !startTalking

        if startTalking == true {
            startSpeechRecognization()
        }
        else {
            cancelSpeechRecognization()
        }

    }
    
    func setUpAudio() {
        let node = audioEngine.inputNode
        let format = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, time in
            self.recognitionRequest.append(buffer)
        }
    }
    
    func startSpeechRecognization() {
        setUpAudio()
        audioEngine.prepare()
        let tintedImage = self.voiceImage.withTintColor(.red, renderingMode: .alwaysOriginal)
        self.voiceBtn.setImage(tintedImage, for: .normal)
        
        do {
            try audioEngine.start()
        } catch {
            return print(error)
        }
        
        let recognizer = SFSpeechRecognizer()
        if recognizer == nil {
            return
        }
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { result, err in
            if let result = result {
                let str = result.bestTranscription.formattedString
                self.messageInputBar.inputTextView.text = str
            }
            else if let err = err {
                print(err)
            }
        })
    }
    
    func cancelSpeechRecognization() {
        print("cancelled")
        recognitionTask?.cancel()
        recognitionTask = nil
        audioEngine.stop()
        recognitionRequest.endAudio()
        let tintedImage = self.voiceImage.withTintColor(.lightGreen, renderingMode: .alwaysOriginal)
        self.voiceBtn.setImage(tintedImage, for: .normal)
        
        if audioEngine.inputNode.numberOfInputs > 0 {
            audioEngine.inputNode.removeTap(onBus: 0)
        }

    }
    
    func loadMessage() {
        db.getMessages { docSnapshot in
            for doc in docSnapshot {
                let messageList = doc["messageList"] as? [Any]
                if messageList != nil {
                    for i in 0..<messageList!.count {
                        let message = messageList![i] as? [String: Any]
                        if message != nil {
                            let senderId = message!["senderId"] as? String
                            let senderName = message!["senderName"] as? String
                            let sentDate = (message!["sentDate"] as! Timestamp).dateValue()
                            let content = message!["content"] as? String
                            
                            let sender = Sender(senderId: senderId!, displayName: senderName!)
                            
                            if self.checkArrContainsTxt(arr: self.messages, txt: content!) == false {
                                self.messages.append(Message(sender: sender, messageId: UUID().uuidString, sentDate: sentDate, kind: .text(content!)))
                            }
                        }
                    }
                
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }
    
    func checkArrContainsTxt(arr: [Message], txt: String) -> Bool {
        for i in 0..<self.messages.count {
            if self.getTextFromMessage(message: arr[i]) == txt {
                return true;
            }
        }
        return false;
    }
    
    func addMessages(message: [Message]) {
        let uid = Firebase.Auth.auth().currentUser?.uid
        db.getMessages { docSnapshot in
            if docSnapshot.count == 0 {
                var messageList: [Messages] = []
                for i in 0..<message.count {
                    let m = message[i]
                    let messageObj = Messages(senderId: m.sender.senderId, senderName: m.sender.displayName, sentDate: m.sentDate, content: self.getTextFromMessage(message: m))
                    messageList.append(messageObj)
                }
                print("messageList", messageList)
                self.db.addMessageDoc(messageRecord: MessageRecord(uid: uid!, messageList: messageList)) { err in
                    print(err)
                }
            }
            else {
                var messageDictArr = [[String: Any]]()
                for i in 0..<message.count {
                    let m = message[i]
                    let messageDict = [
                        "senderId": m.sender.senderId,
                        "content": self.getTextFromMessage(message: m),
                        "senderName": m.sender.displayName,
                        "sentDate": m.sentDate
                    ]
                    messageDictArr.append(messageDict)
                }
                self.db.updateMessages(fieldToUpdate: ["messageList"], fieldValues: [messageDictArr])
            }
        }
    }
    
    @objc func textViewDidChange() {
        // Update the height constraint based on the text view's intrinsic content size
        textViewHeightConstraint?.constant = messageInputBar.inputTextView.intrinsicContentSize.height
        UIView.animate(withDuration: 0.1) {
            self.view.layoutIfNeeded()
        }
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        var index = indexPath.section
        if index > messages.count - 1{
            index = messages.count - 1
        }
        return messages[index]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? UIColor.lightGreen : UIColor.grayish
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        view.inputViewController?.hidesBottomBarWhenPushed = true
        let senderMessage = Message(sender: currentSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(text))
        messages.append(senderMessage)
        clearButton?.isEnabled = true
        DispatchQueue.main.async {
            self.isTyping = true
            self.setTypingIndicatorViewHidden(!self.isTyping, animated: true)
        }
        messagesCollectionView.reloadData()
        if text != "" {
//            GptApiService().getGptStream(messagePrompt: text) { response, done in
//                self.addChatGptResponse(response)
//
//                if done == true {
//                    self.addMessages(message: self.messages)
//                }
//            }
            cancelSpeechRecognization()
            startTalking = false
            GptApiService().getGptResponse(messagePrompt: text) { response in
                self.addChatGptResponse(response)
                self.addMessages(message: self.messages)
                self.isTyping = false
                DispatchQueue.main.async {
                    self.setTypingIndicatorViewHidden(!self.isTyping, animated: true)
                }
            }
        }
        inputBar.inputTextView.text = ""
        inputBar.sendButton.isEnabled = false
    }
    
    func addChatGptResponse(_ response: String) {
        // Append new lines of text to the existing message
        if let lastMessage = messages.last, lastMessage.sender.senderId == chatgptSender.senderId {
            let updatedText = "\(getTextFromMessage(message: lastMessage)) \(response)"
            let updatedMessage = Message(sender: lastMessage.sender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(updatedText))
            messages[messages.count - 1] = updatedMessage
        } else {
            // Create a new message for ChatGPT response
            let newMessage = Message(sender: chatgptSender, messageId: UUID().uuidString, sentDate: Date(), kind: .text(response))
            messages.append(newMessage)
        }
        DispatchQueue.main.async {
            self.messagesCollectionView.reloadData()
            self.messagesCollectionView.scrollToLastItem(animated: true)
        }
    }
    
    func getTextFromMessage(message: Message) -> String {
        switch message.kind {
            case .text(let text):
                return text
            case .attributedText(_):
                return ""
            case .photo(_):
                return ""
            case .video(_):
                return ""
            case .location(_):
                return ""
            case .emoji(_):
                return ""
            case .audio(_):
                return ""
            case .contact(_):
                return ""
            case .linkPreview(_):
                return ""
            case .custom(_):
                break
            }
        return ""
    }

}

