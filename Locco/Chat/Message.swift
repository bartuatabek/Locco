//
//  MockMessage.swift
//  Locco
//
//  Created by Bartu Atabek on 8/21/18.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import Firebase
import Foundation
import MessageKit
import CoreLocation
import FirebaseFirestore

protocol DatabaseRepresentation {
    var representation: [String: Any] { get }
}

private struct PhotoMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}

internal struct Message: MessageType {
    
    var messageId: String
    var sender: Sender
    var sentDate: Date
    var kind: MessageKind
    var message: String?
    var mediaUrl: URL?
    var mediaItem: UIImage?
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.sender = sender
        self.messageId = messageId
        self.sentDate = date
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
        message = text
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = PhotoMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
        self.mediaItem = image
    }
    
    init(emoji: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .emoji(emoji), sender: sender, messageId: messageId, date: date)
        message = emoji
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let sentDate = data["createTime"] as? Date else {
            return nil
        }
        guard let kind = data["kind"] as? String else {
            return nil
        }
        guard let senderID = data["senderId"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        
        switch kind {
        case "text":
            self.init(kind: .text((data["message"] as? String)!), sender: Sender(id: senderID, displayName: senderName), messageId: document.documentID, date: sentDate)
            message = data["message"] as? String
        case "photo":
            let mediaItem = PhotoMediaItem(image: UIImage())
            self.init(kind: .photo(mediaItem), sender:  Sender(id: senderID, displayName: senderName), messageId: document.documentID, date: sentDate)
        case "emoji":
            self.init(kind: .emoji((data["message"] as? String)!), sender: Sender(id: senderID, displayName: senderName), messageId: document.documentID, date: sentDate)
            message = data["message"] as? String
        default:
            return nil
        }
    }
}

extension Message: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "createTime": sentDate,
            "senderId": sender.id,
            "senderName": sender.displayName
        ]
        
        switch kind {
        case .text:
            rep["kind"] = "text"
            rep["message"] = message
        case .photo:
            rep["kind"] = "photo"
            rep["url"] = mediaUrl?.absoluteString ?? ""
            rep["message"] = message
        case .emoji:
            rep["kind"] = "emoji"
            rep["message"] = message
        default:
            rep["kind"] = "text"
        }
        
        return rep
    }
    
    func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: imageData))
        }
    }
    
    static func getAvatarFor(sender: Sender, completion: @escaping (Avatar?) -> Void)  {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("/profilePictures/thumb_\(sender.id).jpeg")
        
        imageRef.getData(maxSize: 1 * 5120 * 5120) { data, error in
            if let error = error {
                print("Error: ", error)
                let initials = sender.displayName.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }
                let avatar = Avatar(initials: initials)
                completion(avatar)
            } else {
                let downloadedImage = UIImage(data: data!)!
                let initials = sender.displayName.components(separatedBy: " ").reduce("") { ($0 == "" ? "" : "\($0.first!)") + "\($1.first!)" }
                let avatar = Avatar(image: downloadedImage, initials: initials)
                completion(avatar)
            }
        }
    }
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.messageId == rhs.messageId
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
