//
//  ConversationViewController.swift
//  Locco
//
//  Created by Bartu Atabek on 8/21/18.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import Photos
import EventKit
import Lightbox
import Firebase
import EventKitUI
import MessageKit
import AVFoundation

internal class ConversationController: MessagesViewController {
    
    private let db = Firestore.firestore()
    private var lastSnapshot: QueryDocumentSnapshot?
    private var reference: Query?
    
    var circleId: String?
    let refreshControl = UIRefreshControl()
    let eventStore = EKEventStore()
    let storage = Storage.storage()
    
    var viewModel: ChatViewModeling?
    var messageList: [Message] = []
    var messageListener: ListenerRegistration?
    var imagePicker = UIImagePickerController()
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    deinit {
        messageListener?.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iMessage()
        self.viewModel!.controller = self
        self.navigationItem.title = viewModel?.chatPreviews[(viewModel?.activeChatIndex)!].circleName
        
        circleId = viewModel?.chatPreviews[(viewModel?.activeChatIndex)!].circleId
        reference = db.collection("circles").document(circleId!).collection("chat")
            .order(by: "createTime", descending: true)
            .limit(to: 25)
        
        
        reference?.getDocuments(completion: { (querySnapshot, error) in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            guard let lastSnapshot = snapshot.documents.last else {
                // The collection is empty.
                return
            }
            
            self.lastSnapshot = lastSnapshot
            
            snapshot.documents.forEach({ (querySnapshot) in
               self.handleDocumentChange(querySnapshot)
            })
            
            self.messagesCollectionView.scrollToBottom()
            self.messageListener = self.reference!.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    self.handleNewMessages(change)
                }
            }
        })
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.addSubview(refreshControl)
        messagesCollectionView.scrollToBottom()
        refreshControl.addTarget(self, action: #selector(ConversationController.loadMoreMessages), for: .valueChanged)
    }
    
    @objc func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 1) {
            DispatchQueue.main.async {
                let next = self.db.collection("circles").document(self.circleId!).collection("chat")
                .order(by: "createTime", descending: true)
                .limit(to: 25)
                .start(afterDocument: self.lastSnapshot!)

                next.getDocuments(completion: { (querySnapshot, error) in
                    guard let snapshot = querySnapshot else {
                        print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                        return
                    }
                    
                    guard let lastSnapshot = snapshot.documents.last else {
                        // The collection is empty.
                        return
                    }
                    
                    self.lastSnapshot = lastSnapshot
                    
                    snapshot.documents.forEach({ (querySnapshot) in
                        self.handleDocumentChange(querySnapshot)
                    })
                })
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func handleNewMessages(_ change: DocumentChange) {
        guard var message = Message(document: change.document) else {
            return
        }
        
        guard !messageList.contains(message) else {
            return
        }
        
        switch message.kind {
        case .photo:
            if let url = message.mediaUrl {
                message.downloadImage(at: url) { (image) in
                    if let mediaItem = image {
                        message.mediaItem = mediaItem
                        DispatchQueue.main.async {
                            let downloadedMessage = Message(image: mediaItem, sender: message.sender, messageId: message.messageId, date: message.sentDate)
                            let messageIndex = self.messageList.index(of: message)
                            self.messageList[messageIndex!] = downloadedMessage
                            self.messagesCollectionView.reloadData()
                        }
                    }
                    
                    guard !self.messageList.contains(message) else {
                        return
                    }
                    DispatchQueue.main.async {
                        self.messagesCollectionView.reloadDataAndKeepOffset()
                    }
                }
                DispatchQueue.main.async {
                    self.messageList.append(message)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.messagesCollectionView.scrollToBottom()
                }
            } else {
                return
            }
        default:
            DispatchQueue.main.async {
                self.messageList.append(message)
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.messagesCollectionView.scrollToBottom()
            }
        }
    }
    
    func handleDocumentChange(_ document: QueryDocumentSnapshot) {
        guard var message = Message(document: document) else {
            return
        }
        
        guard !messageList.contains(message) else {
            return
        }
        
        switch message.kind {
        case .photo:
            if let url = message.mediaUrl {
                message.downloadImage(at: url) { (image) in
                    if let mediaItem = image {
                        message.mediaItem = mediaItem
                        DispatchQueue.main.async {
                            let downloadedMessage = Message(image: mediaItem, sender: message.sender, messageId: message.messageId, date: message.sentDate)
                            let messageIndex = self.messageList.index(of: message)
                            self.messageList[messageIndex!] = downloadedMessage
                            self.messagesCollectionView.reloadData()
                        }
                    }
                    
                    guard !self.messageList.contains(message) else {
                        return
                    }
                }
                DispatchQueue.main.async {
                    self.messageList.insert(message, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                }
            } else {
                return
            }
        default:
            DispatchQueue.main.async {
                self.messageList.insert(message, at: 0)
                self.messagesCollectionView.reloadDataAndKeepOffset()
            }
        }
    }
    
    // MARK: - Keyboard Style
    func iMessage() {
        defaultStyle()
        messageInputBar.isTranslucent = true
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.inputTextView.placeholder = ""
        messageInputBar.inputTextView.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        messageInputBar.inputTextView.placeholderTextColor = UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        messageInputBar.inputTextView.textContainerInset = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 36)
        messageInputBar.inputTextView.placeholderLabelInsets = UIEdgeInsets(top: 8, left: 20, bottom: 8, right: 36)
        messageInputBar.inputTextView.layer.borderColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1).cgColor
        messageInputBar.inputTextView.layer.borderWidth = 1.0
        messageInputBar.inputTextView.layer.cornerRadius = 16.0
        messageInputBar.inputTextView.layer.masksToBounds = true
        messageInputBar.inputTextView.scrollIndicatorInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setRightStackViewWidthConstant(to: 60, animated: false)
        messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
        messageInputBar.sendButton.contentEdgeInsets = UIEdgeInsets(top: 1, left: 2, bottom: 2, right: 2)
        messageInputBar.sendButton.setSize(CGSize(width: 32, height: 32), animated: false)
        messageInputBar.sendButton.image = #imageLiteral(resourceName: "ic_up")
        messageInputBar.sendButton.title = ""
        messageInputBar.sendButton.imageView?.layer.cornerRadius = 13
        messageInputBar.textViewPadding.left = 10
        messageInputBar.textViewPadding.right = -50
        
        let items = [
            makeButton(named: "camera").onTextViewDidChange { button, textView in
                button.isEnabled = true
            },
            ]
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setStackViewItems(items, forStack: .left, animated: false)
    }
    
    func defaultStyle() {
        let newMessageInputBar = MessageInputBar()
        newMessageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        newMessageInputBar.delegate = self
        messageInputBar = newMessageInputBar
        reloadInputViews()
    }
    
    // MARK: - Helpers
    
    func makeButton(named: String) -> InputBarButtonItem {
        return InputBarButtonItem(type: .system)
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
                $0.tintColor = UIColor(red: 133/255, green: 142/255, blue: 153/255, alpha: 1)
            }.onTouchUpInside { _ in
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
                var image = UIImage(named: "camera")
                var action = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                    self.openCamera()
                })
                
                action.setValue(image, forKey: "image")
                alert.addAction(action)
                
                image = UIImage(named: "picture")
                action = UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
                    self.openGallery()
                })
                
                action.setValue(image, forKey: "image")
                alert.addAction(action)
                
                alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - Open the camera
    func openCamera() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.delegate = self
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Choose image from camera roll
    func openGallery() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.delegate = self
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            })
        } else if photos == .authorized {
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
}

// MARK: - UIImagePickerController Delegate

extension ConversationController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            var imageMessage = Message(image: editedImage, sender: currentSender(), messageId: UUID().uuidString, date: Date())
            viewModel!.uploadImage(editedImage, to: circleId!) { [weak self] url in
                guard let url = url else {
                    return
                }
                
                imageMessage.mediaUrl = url
                self!.db.collection("circles").document(self!.circleId!).collection("chat").addDocument(data: imageMessage.representation) { error in
                    if let e = error {
                        print("Error sending message: \(e.localizedDescription)")
                        return
                    }
                }
            }
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - EKEventEditView Delegate

extension ConversationController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        self.view.endEditing(true)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MessagesDataSource

extension ConversationController: MessagesDataSource {
    
    func currentSender() -> Sender {
        return Sender(id: (Firebase.Auth.auth().currentUser?.uid)!, displayName: (Firebase.Auth.auth().currentUser?.displayName)!)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 10 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section - 1 >= 0 && indexPath.section - 1 < messageList.count {
            if message.sender.id == messageList[indexPath.section-1].sender.id {
                return nil
            }
        }
        if !isFromCurrentSender(message: message) {
            let name = message.sender.displayName
            return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
        }
        return nil
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section + 1 < messageList.count {
            if message.sender.id == messageList[indexPath.section+1].sender.id {
                return nil
            }
        }
        let dateString = message.sentDate.formatRelativeString()
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessagesDisplayDelegate

extension ConversationController: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return isFromCurrentSender(message: message) ? MessageLabel.defaultAttributes: MessageLabel.customAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .emoji:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? UIColor(red: 22/255, green: 118/255, blue: 255/255, alpha: 1.0) : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1.0)
        }
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        if indexPath.section + 1 < messageList.count {
            if message.sender.id == messageList[indexPath.section+1].sender.id {
                return .bubble
            }
        }
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
        //        let configurationClosure = { (view: MessageContainerView) in}
        //        return .custom(configurationClosure)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        Message.getAvatarFor(sender: message.sender, completion: { (avatar) in
            avatarView.set(avatar: avatar!)
        })
    }
}

// MARK: - MessagesLayoutDelegate

extension ConversationController: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        if indexPath.section % 3 == 0 {
            return 10
        }
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

// MARK: - MessageCellDelegate

extension ConversationController: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        // FIXME: Display image & video
        let indexPath = messagesCollectionView.indexPath(for: cell)
        let message = messageForItem(at: indexPath!, in: messagesCollectionView)
        
        switch message.kind {
        case .photo:
            if let image = message.mediaItem {
                let images = [LightboxImage(image: image)]
                let lightbox = LightboxController(images: images)
                lightbox.pageDelegate = self as? LightboxControllerPageDelegate
                lightbox.dismissalDelegate = self as? LightboxControllerDismissalDelegate
                lightbox.dynamicBackground = true
                present(lightbox, animated: true, completion: nil)
            }
        default:
            print("Message tapped")
        }
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ConversationController: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
        // TODO: Add new Place
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
        
        let alert = UIAlertController(title: "", message: MessageKitDateFormatter.shared.string(from: date), preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Create Event", style: .default , handler:{ (UIAlertAction) in
            switch EKEventStore.authorizationStatus(for: EKEntityType.event) {
            case EKAuthorizationStatus.notDetermined:
                self.eventStore.requestAccess(to: .event, completion: { (isAllowed, error) in
                    if let error = error {
                        print(error)
                    }
                    if isAllowed {
                        let eventViewController = EKEventEditViewController()
                        eventViewController.event = EKEvent(eventStore: self.eventStore)
                        eventViewController.eventStore = self.eventStore
                        eventViewController.editViewDelegate = self
                        self.present(eventViewController, animated:true, completion: nil)
                    }
                })
                
            case EKAuthorizationStatus.authorized:
                let eventViewController = EKEventEditViewController()
                eventViewController.event = EKEvent(eventStore: self.eventStore)
                eventViewController.eventStore = self.eventStore
                eventViewController.editViewDelegate = self
                self.present(eventViewController, animated:true, completion: nil)
                
            case EKAuthorizationStatus.restricted, EKAuthorizationStatus.denied:
                self.eventStore.requestAccess(to: .event, completion: { (isAllowed, error) in
                    if let error = error {
                        print(error)
                    }
                    if isAllowed {
                        let eventViewController = EKEventEditViewController()
                        eventViewController.event = EKEvent(eventStore: self.eventStore)
                        eventViewController.eventStore = self.eventStore
                        eventViewController.editViewDelegate = self
                        self.present(eventViewController, animated:true, completion: nil)
                    }
                })
            }
        }))
        
        alert.addAction(UIAlertAction(title: "Show in Calendar", style: .default , handler:{ (UIAlertAction) in
            guard let calendar = URL(string: "calshow://") else { return }
            UIApplication.shared.open(calendar, options: [:], completionHandler: nil)
        }))
        
        alert.addAction(UIAlertAction(title: "Copy Event", style: .default , handler:{ (UIAlertAction) in
            UIPasteboard.general.string = MessageKitDateFormatter.shared.string(from: date)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
        guard let number = URL(string: "tel://" + phoneNumber) else { return }
        UIApplication.shared.open(number, options: [:], completionHandler: nil)
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
        UIApplication.shared.open(url)
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ConversationController: MessageInputBarDelegate {
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        
        // Each NSTextAttachment that contains an image will count as one empty character in the text: String
        
        for component in inputBar.inputTextView.components {
            if let image = component as? UIImage {
                var imageMessage = Message(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                viewModel!.uploadImage(image, to: circleId!) { [weak self] url in
                    guard let url = url else {
                        return
                    }
                    
                    imageMessage.mediaUrl = url
                    self!.db.collection("circles").document(self!.circleId!).collection("chat").addDocument(data: imageMessage.representation) { error in
                        if let e = error {
                            print("Error sending message: \(e.localizedDescription)")
                            return
                        }
                    }
                    self!.messageList.append(imageMessage)
                    self!.messagesCollectionView.insertSections([self!.messageList.count - 1])
                }
            } else if let text = component as? String {
                if text.containsOnlyEmoji && text.count < 4 {
                    let message = Message(emoji: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                    self.db.collection("circles").document(self.circleId!).collection("chat").addDocument(data: message.representation) { error in
                        if let e = error {
                            print("Error sending message: \(e.localizedDescription)")
                            return
                        }
                    }
                } else {
                    let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                    self.db.collection("circles").document(self.circleId!).collection("chat").addDocument(data: message.representation) { error in
                        if let e = error {
                            print("Error sending message: \(e.localizedDescription)")
                            return
                        }
                    }
                    
                }
            }
        }
        
        inputBar.inputTextView.text = String()
        messagesCollectionView.scrollToBottom()
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, textViewTextDidChangeTo text: String) {
        if text.containsOnlyEmoji && text.count < 4 {
            inputBar.inputTextView.font = UIFont.systemFont(ofSize: 40)
        } else {
            inputBar.inputTextView.font = UIFont.systemFont(ofSize: 15)
        }
    }
    
}
