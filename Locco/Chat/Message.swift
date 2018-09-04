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
    var mediaUrl: String?
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
    
}

extension Message: DatabaseRepresentation {
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "createTime": sentDate,
            "senderID": sender.id,
            "senderName": sender.displayName
        ]
        
        switch kind {
        case .text:
            rep["kind"] = "text"
            rep["message"] = message
        case .photo:
            rep["kind"] = "photo"
            rep["url"] = mediaUrl ?? ""
        case .emoji:
            rep["kind"] = "emoji"
            rep["message"] = message
        default:
            rep["kind"] = "text"
        }
        
        return rep
    }
    
}

