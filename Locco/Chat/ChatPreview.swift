//
//  ChatPreview.swift
//  Locco
//
//  Created by Bartu Atabek on 9/1/18.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

struct ChatKey {
    static let chatIcon = "chatIcon"
    static let circleName = "circleName"
    static let username = "username"
    static let lastMessage = "lastMessage"
    static let timestamp = "timestamp"
    static let hasNewMessages = "hasNewMessages"
    static let hideAlerts = "hideAlerts"
}

class ChatPreview: NSObject, NSCoding {
    
    var chatIcon: PinColors
    var circleName: String
    var username: String
    var lastMessage: String
    var timestamp: String
    var hasNewMessages: Bool
    var hideAlerts: Bool
    
    init(chatIcon: PinColors, circleName: String, username: String, lastMessage: String, timestamp: String, hasNewMessages: Bool, hideAlerts: Bool) {
        self.chatIcon = chatIcon
        self.circleName = circleName
        self.username = username
        self.lastMessage = lastMessage
        self.timestamp = timestamp
        self.hasNewMessages = hasNewMessages
        self.hideAlerts = hideAlerts
    }
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        let color = decoder.decodeObject(forKey: ChatKey.chatIcon) as! String
        
        if color == PinColors.color1.rawValue {
            chatIcon = PinColors.color1
        } else if color == PinColors.color2.rawValue {
            chatIcon = PinColors.color2
        } else if color == PinColors.color3.rawValue {
            chatIcon = PinColors.color3
        } else if color == PinColors.color4.rawValue {
            chatIcon = PinColors.color4
        } else if color == PinColors.color5.rawValue {
            chatIcon = PinColors.color5
        } else if color == PinColors.color6.rawValue {
            chatIcon = PinColors.color6
        } else if color == PinColors.color7.rawValue {
            chatIcon = PinColors.color7
        } else if color == PinColors.color8.rawValue {
            chatIcon = PinColors.color8
        } else if color == PinColors.color9.rawValue {
            chatIcon = PinColors.color9
        } else if color == PinColors.color10.rawValue {
            chatIcon = PinColors.color10
        } else if color == PinColors.color11.rawValue {
            chatIcon = PinColors.color11
        } else if color == PinColors.color12.rawValue {
            chatIcon = PinColors.color12
        } else if color == PinColors.color13.rawValue {
            chatIcon = PinColors.color13
        } else if color == PinColors.color14.rawValue {
            chatIcon = PinColors.color14
        } else if color == PinColors.color15.rawValue {
            chatIcon = PinColors.color15
        } else {
            chatIcon = PinColors.color3
        }
        
        circleName = decoder.decodeObject(forKey: ChatKey.circleName) as! String
        username = decoder.decodeObject(forKey: ChatKey.username) as! String
        lastMessage = decoder.decodeObject(forKey: ChatKey.lastMessage) as! String
        timestamp = decoder.decodeObject(forKey: ChatKey.timestamp) as! String
        hasNewMessages = decoder.decodeBool(forKey: ChatKey.hasNewMessages)
        hideAlerts = decoder.decodeBool(forKey: ChatKey.hideAlerts)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(chatIcon.rawValue, forKey: ChatKey.chatIcon)
        coder.encode(circleName, forKey: ChatKey.circleName)
        coder.encode(username, forKey: ChatKey.username)
        coder.encode(lastMessage, forKey: ChatKey.lastMessage)
        coder.encode(timestamp, forKey: ChatKey.timestamp)
        coder.encode(hasNewMessages, forKey: ChatKey.hasNewMessages)
        coder.encode(hideAlerts, forKey: ChatKey.hideAlerts)
    }
}
