//
//  ConversationViewController.swift
//  Locco
//
//  Created by Bartu Atabek on 8/21/18.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import EventKit
import Lightbox
import Firebase
import EventKitUI
import MessageKit

internal class ConversationController: MessagesViewController {
    
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    
    let refreshControl = UIRefreshControl()
    let eventStore = EKEventStore()
    
    var viewModel: ChatViewModeling?
    var messageList: [Message] = []
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.iMessage()
        //        self.viewModel!.controller = self
        //        self.navigationItem.title = viewModel?.chatPreviews[(viewModel?.activeChatIndex)!].circleName
        
        //        reference = db.collection(<#T##collectionPath: String##String#>)
        
        let messagesToFetch = UserDefaults.standard.mockMessagesCount()
        DispatchQueue.global(qos: .userInitiated).async {
            SampleData.shared.getMessages(count: messagesToFetch) { messages in
                DispatchQueue.main.async {
                    self.messageList = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom()
                }
            }
        }
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messagesCollectionView.scrollToBottom()
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(ConversationController.loadMoreMessages), for: .valueChanged)
    }
    
    @objc func loadMoreMessages() {
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: DispatchTime.now() + 4) {
            SampleData.shared.getMessages(count: 10) { messages in
                DispatchQueue.main.async {
                    self.messageList.insert(contentsOf: messages, at: 0)
                    self.messagesCollectionView.reloadDataAndKeepOffset()
                    self.refreshControl.endRefreshing()
                }
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
                button.isEnabled = textView.text.isEmpty
            },
        ]
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
        return InputBarButtonItem()
            .configure {
                $0.spacing = .fixed(10)
                $0.image = UIImage(named: named)?.withRenderingMode(.alwaysTemplate)
                $0.setSize(CGSize(width: 30, height: 30), animated: true)
                $0.tintColor = UIColor(red: 133/255, green: 142/255, blue: 153/255, alpha: 1)
            }.onTouchUpInside { _ in
                print("Item Tapped")
        }
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
        return SampleData.shared.currentSender
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
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section + 1 < messageList.count {
            if message.sender.id == messageList[indexPath.section+1].sender.id {
                return nil
            }
        }
        let dateString = formatter.string(from: message.sentDate)
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
        if isFromCurrentSender(message: message) {
            avatarView.isHidden = true
            if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
                layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
            }
        } else {
            let avatar = SampleData.shared.getAvatarFor(sender: message.sender)
            avatarView.set(avatar: avatar)
        }
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
            let images = [LightboxImage(image: message.mediaItem!)]
            let lightbox = LightboxController(images: images)
            lightbox.pageDelegate = self as? LightboxControllerPageDelegate
            lightbox.dismissalDelegate = self as? LightboxControllerDismissalDelegate
            lightbox.dynamicBackground = true
            present(lightbox, animated: true, completion: nil)
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
                let imageMessage = Message(image: image, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                messageList.append(imageMessage)
                messagesCollectionView.insertSections([messageList.count - 1])
            } else if let text = component as? String {
                if text.containsOnlyEmoji && text.count < 4 {
                    let message = Message(emoji: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                    messageList.append(message)
                } else {
                    let message = Message(text: text, sender: currentSender(), messageId: UUID().uuidString, date: Date())
                    messageList.append(message)
                }
                messagesCollectionView.insertSections([messageList.count - 1])
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
