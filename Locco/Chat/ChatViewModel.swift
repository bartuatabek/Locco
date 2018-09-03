//
//  ChatViewModel.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import Firebase
import Alamofire
import SwiftyJSON
import ReactiveSwift
import ReactiveCocoa

protocol ChatViewModeling {
    var controller: UIViewController? { get set }
    var chatPreviews: [ChatPreview] { get set }
    var activeChatIndex: Int { get set }
    
    func loadChatPreviews()
    func saveChatPreviews()
    func hasNewMessages() -> String?
    func getChatPreview(completion: @escaping (_ result: Bool)->())
}

class ChatViewModel: ChatViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    var chatPreviews: [ChatPreview]
    var activeChatIndex: Int
    
    // MARK: - Initialization
    init() {
        chatPreviews = []
        activeChatIndex = -1
    }
    
    func hasNewMessages() -> String? {
        var newMessageCount = 0
        for chatPreview in chatPreviews {
            if chatPreview.hasNewMessages {
                newMessageCount += 1
            }
        }
        if newMessageCount > 0 {
            return "\(newMessageCount)"
        } else {
            return nil
        }
    }
    
    func getChatPreview(completion: @escaping (_ result: Bool)->()) {
        chatPreviews = []
        
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/getChats", method: .get, headers: headers)
                .responseJSON { response in
                    debugPrint(response)
                    if response.result.isSuccess {
                        let placeJSON: JSON = JSON(response.result.value!)
                        for (_, subJson) in placeJSON["data"] {
                            let circleName = subJson["circleName"].string!
                            let lastMessage = subJson["lastMessage"].string!
                            let timestamp = subJson["time"].string!
                            let username = "\(subJson["username"].string!):"
                            
//                            let color = subJson["chatIcon"].string!
//                            var chatIcon: PinColors
//
//                            if color == PinColors.color1.rawValue {
//                                chatIcon = PinColors.color1
//                            } else if color == PinColors.color2.rawValue {
//                                chatIcon = PinColors.color2
//                            } else if color == PinColors.color3.rawValue {
//                                chatIcon = PinColors.color3
//                            } else if color == PinColors.color4.rawValue {
//                                chatIcon = PinColors.color4
//                            } else if color == PinColors.color5.rawValue {
//                                chatIcon = PinColors.color5
//                            } else if color == PinColors.color6.rawValue {
//                                chatIcon = PinColors.color6
//                            } else if color == PinColors.color7.rawValue {
//                                chatIcon = PinColors.color7
//                            } else if color == PinColors.color8.rawValue {
//                                chatIcon = PinColors.color8
//                            } else if color == PinColors.color9.rawValue {
//                                chatIcon = PinColors.color9
//                            } else if color == PinColors.color10.rawValue {
//                                chatIcon = PinColors.color10
//                            } else {
//                                chatIcon = PinColors.color1
//                            }
                            
//                            let interval = Double()
//                            let date = NSDate(timeIntervalSince1970: interval)
//                            let timestamp = (date as Date).formatRelativeString()
                            
                            self.chatPreviews.append(ChatPreview(chatIcon: PinColors.color1, circleName: circleName, username: username, lastMessage: lastMessage, timestamp: timestamp, hasNewMessages: true, hideAlerts: false))
                        }
                        self.saveChatPreviews()
                        completion(true)
                    } else {
                        completion(false)
                        print("Error: \(response.result.error ?? "" as! Error)")
                    }
            }
        }
    }
    
    // MARK: Loading and saving functions
    func loadChatPreviews() {
        chatPreviews = []
        guard let savedItems = UserDefaults.standard.array(forKey: PreferencesKeys.savedChatPreviews) else { return }
        for savedItem in savedItems {
            guard let chatPreview = NSKeyedUnarchiver.unarchiveObject(with: savedItem as! Data) as? ChatPreview else { continue }
            chatPreviews.append(chatPreview)
        }
    }
    
    func saveChatPreviews() {
        var items: [Data] = []
        for chatPreview in chatPreviews {
            let item = NSKeyedArchiver.archivedData(withRootObject: chatPreview)
            items.append(item)
        }
        UserDefaults.standard.set(items, forKey: PreferencesKeys.savedChatPreviews)
    }
}
