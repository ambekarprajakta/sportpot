//
//  SP_ChatViewController.swift
//  SportPot
//
//  Created by Prajakta Ambekar on 19/03/2021.
//  Copyright © 2021 Prajakta Ambekar. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseFirestore

class SP_ChatViewController: MessagesViewController {
    
    let outgoingAvatarOverlap: CGFloat = 17.5
    
    let currentUser = UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? ""
    var pot: Pot!
    
    private var user = User(id: UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? "",
                            name: UserDefaults.standard.string(forKey: UserDefaultsConstants.displayNameKey) ?? "")
    
    private var messages = Array<Message>()
    
    private(set) lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.tintColor = .white
        control.addTarget(self, action: #selector(loadMessages), for: .valueChanged)
        return control
    }()
    
    // MARK: - Private properties
    private let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageKit()
        loadMessages()
        title = pot.name
    }
    
    private func configureMessageKit() {
        guard let flowLayout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            print("Can't get flowLayout")
            return
        }
        if #available(iOS 13.0, *) {
            flowLayout.collectionView?.backgroundColor = .sp_background
        }
        
        messageInputBar.delegate = self
        messageInputBar.inputTextView.placeholder = "Enter message here"
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.refreshControl = refreshControl
        
        
        let incomingUIEdgeInsets = UIEdgeInsets(top: 5, left: 15, bottom: 10, right: 0)
        let outgoingUIEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 10, right: 15)
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingAvatarSize(.zero)
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingAvatarSize(.zero)
        
        //Time
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: incomingUIEdgeInsets))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: outgoingUIEdgeInsets))
        
        //Username
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: incomingUIEdgeInsets))
        messagesCollectionView.messagesCollectionViewFlowLayout.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: outgoingUIEdgeInsets))
        
        
        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messageInputBar.backgroundView.backgroundColor = .sp_navigationBar
        messageInputBar.inputTextView.textColor = .white
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.sendButton.image = UIImage(systemName: "paperplane.fill")
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.tintColor = .sp_mustard
    }
    
    @objc private func loadMessages() {
        Firestore.firestore().collection("chats").document(pot.id ?? "").addSnapshotListener { [weak self] (docSnapShot, error) in
            guard let userData = docSnapShot?.data() else {
                print("Document data was empty.")
                return
            }
            
            if let notificationArr = userData["thread"] as? JSONArray {
                self?.messages.removeAll()
                self?.messages = notificationArr.toArray(of: Message.self, keyDecodingStartegy: .convertFromSnakeCase) ?? []
                self?.refreshControl.endRefreshing()
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    private func sendMessageToFirebase(message: String) {
        
        let messageDict = ["displayName": currentUser,
                           "timeStamp": Double(Date().timeIntervalSince1970),
                           "content": message] as [String : Any]
        
        let chatRef =
            Firestore.firestore().collection("chats").document(pot.id ?? "")
        
        chatRef.updateData([
            "thread": FieldValue.arrayUnion([messageDict])
        ])
    }
    
    // MARK: - Helpers
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messages[indexPath.section].displayName == messages[indexPath.section - 1].displayName
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messages.count else { return false }
        return messages[indexPath.section].displayName == messages[indexPath.section + 1].displayName
    }

}

extension SP_ChatViewController: MessagesDataSource {
    func currentSender() -> SenderType {
        return user
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
}

extension SP_ChatViewController: MessagesLayoutDelegate {
    
    func avatarSize(for message: MessageType, at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        return CGSize(width: 0, height: 8)
    }
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if isTimeLabelVisible(at: indexPath) {
            return 18
        }
        return 0
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 10
    }
    
    //    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
    //        return 15
    //    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        
        if isFromCurrentSender(message: message) {
            return !isPreviousMessageSameSender(at: indexPath) ? 20 : 0
        } else {
            return !isPreviousMessageSameSender(at: indexPath) ? (20 + outgoingAvatarOverlap) : 0
        }
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return (!isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message)) ? 16 : 0
    }
    
}


extension SP_ChatViewController: MessagesDisplayDelegate {
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        //        if message.sender.displayName == user.name {
        //            return .bubbleTail(.bottomRight, .curved)
        //        }
        //        return .bubbleTail(.bottomLeft, .curved)
        var corners: UIRectCorner = []
        
        if isFromCurrentSender(message: message) {
            corners.formUnion(.topLeft)
            corners.formUnion(.bottomLeft)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topRight)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomRight)
            }
        } else {
            corners.formUnion(.topRight)
            corners.formUnion(.bottomRight)
            if !isPreviousMessageSameSender(at: indexPath) {
                corners.formUnion(.topLeft)
            }
            if !isNextMessageSameSender(at: indexPath) {
                corners.formUnion(.bottomLeft)
            }
        }
        
        return .custom { view in
            let radius: CGFloat = 16
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.mask = mask
        }
        
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.frame = .zero
        avatarView.isHidden = true
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            if isTimeLabelVisible(at: indexPath) {
                return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.ubuntuBoldFont(ofSize: 12), NSAttributedString.Key.foregroundColor: UIColor.lightText])
            }
        }
        return nil
    }
    
    //    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
    //        return NSAttributedString(string: "Read", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    //    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.ubuntuBoldFont(ofSize: 14),NSAttributedString.Key.foregroundColor: UIColor.white])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if !isNextMessageSameSender(at: indexPath) && isFromCurrentSender(message: message) {
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: message.sentDate)
            let minute = calendar.component(.minute, from: message.sentDate)
            let dateString = String(format: "%02d:%02d", hour, minute)//"\(hour):\(minute)"
            return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.ubuntuRegularFont(ofSize: 10),NSAttributedString.Key.foregroundColor: UIColor.lightText])
        }
        return nil
    }
    
    
}

extension SP_ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        // Resign first responder for iPad split view
        inputBar.inputTextView.resignFirstResponder()
        
        //Send message to firebase
        sendMessageToFirebase(message: text)
        
        // On completion, execute the below code without delay / sleep
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Enter message here"
//                let message = Message(content: text, timeStamp: Double(Date().timeIntervalSinceNow), displayName: self?.user.displayName ?? "")
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .sp_mustard: .sp_gray
    }
    
    private func insertMessage(_ message: Message) {
        messages.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messages.count - 1])
            if messages.count >= 2 {
                messagesCollectionView.reloadSections([messages.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        })
    }
    
    private func isLastSectionVisible() -> Bool {
        
        guard !messages.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
}
