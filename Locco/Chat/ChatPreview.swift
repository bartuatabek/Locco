//
//  ChatPreview.swift
//  Locco
//
//  Created by Bartu Atabek on 9/1/18.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

struct ChatKey {
    static let circleIcon = "circleIcon"
    static let circleIconImage = "circleIconImage"
    static let circleId = "circleId"
    static let circleName = "circleName"
    static let senderName = "senderName"
    static let message = "message"
    static let timestamp = "timestamp"
    static let hasNewMessages = "hasNewMessages"
    static let hideAlerts = "hideAlerts"
}

class ChatPreview: NSObject, NSCoding {
    
    var circleIcon: PinColors
    var circleIconImage: UIImage
    var circleName: String
    var circleId: String
    var senderName: String
    var message: String
    var timestamp: String
    var hasNewMessages: Bool
    var hideAlerts: Bool
    
    init(circleIcon: PinColors, circleName: String, circleId: String, senderName: String, message: String, timestamp: String, hasNewMessages: Bool, hideAlerts: Bool) {
        self.circleIcon = circleIcon
        
        if circleIcon == PinColors.color1 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color2 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color3 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color4 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color5 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color6 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color7 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color8 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color9 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color10 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color11 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color12 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color13 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color14 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if circleIcon == PinColors.color15 {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else {
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        }
        
        self.circleName = circleName
        self.circleId = circleId
        self.senderName = senderName
        self.message = message
        self.timestamp = timestamp
        self.hasNewMessages = hasNewMessages
        self.hideAlerts = hideAlerts
    }
    
    // MARK: NSCoding
    required init?(coder decoder: NSCoder) {
        let color = decoder.decodeObject(forKey: ChatKey.circleIcon) as! String
        
        if color == PinColors.color1.rawValue {
            circleIcon = PinColors.color1
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color2.rawValue {
            circleIcon = PinColors.color2
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color3.rawValue {
            circleIcon = PinColors.color3
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color4.rawValue {
            circleIcon = PinColors.color4
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color5.rawValue {
            circleIcon = PinColors.color5
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color6.rawValue {
            circleIcon = PinColors.color6
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color7.rawValue {
            circleIcon = PinColors.color7
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color8.rawValue {
            circleIcon = PinColors.color8
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color9.rawValue {
            circleIcon = PinColors.color9
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color10.rawValue {
            circleIcon = PinColors.color10
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color11.rawValue {
            circleIcon = PinColors.color11
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color12.rawValue {
            circleIcon = PinColors.color12
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color13.rawValue {
            circleIcon = PinColors.color13
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color14.rawValue {
            circleIcon = PinColors.color14
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else if color == PinColors.color15.rawValue {
            circleIcon = PinColors.color15
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        } else {
            circleIcon = PinColors.color3
            circleIconImage = UIImage(named: "addPhoto")!.withRenderingMode(.alwaysTemplate)
        }
        
        circleName = decoder.decodeObject(forKey: ChatKey.circleName) as! String
        circleId = decoder.decodeObject(forKey: ChatKey.circleId) as! String
        senderName = decoder.decodeObject(forKey: ChatKey.senderName) as! String
        message = decoder.decodeObject(forKey: ChatKey.message) as! String
        timestamp = decoder.decodeObject(forKey: ChatKey.timestamp) as! String
        hasNewMessages = decoder.decodeBool(forKey: ChatKey.hasNewMessages)
        hideAlerts = decoder.decodeBool(forKey: ChatKey.hideAlerts)
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(circleIconImage, forKey: ChatKey.circleIconImage)
        coder.encode(circleIcon.rawValue, forKey: ChatKey.circleIcon)
        coder.encode(circleName, forKey: ChatKey.circleName)
        coder.encode(circleId, forKey: ChatKey.circleId)
        coder.encode(senderName, forKey: ChatKey.senderName)
        coder.encode(message, forKey: ChatKey.message)
        coder.encode(timestamp, forKey: ChatKey.timestamp)
        coder.encode(hasNewMessages, forKey: ChatKey.hasNewMessages)
        coder.encode(hideAlerts, forKey: ChatKey.hideAlerts)
    }
}
