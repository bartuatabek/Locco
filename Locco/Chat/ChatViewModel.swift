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
import FirebaseFirestore

protocol ChatViewModeling {
    var controller: UIViewController? { get set }
    var chatPreviews: [ChatPreview] { get set }
    var activeChatIndex: Int { get set }
    
    func loadChatPreviews()
    func saveChatPreviews()
    func hasNewMessages() -> String?
    func getChatPreview(completion: @escaping (_ result: Bool)->())
    func uploadImage(_ image: UIImage, to circleId: String, completion: @escaping (URL?) -> Void) 
}

class ChatViewModel: ChatViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    var chatPreviews: [ChatPreview]
    var activeChatIndex: Int
    
    let storage = Storage.storage().reference()
    
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
                    if response.result.isSuccess {
                        let placeJSON: JSON = JSON(response.result.value!)
                        for (_, subJson) in placeJSON["data"] {
                            let circleName = subJson["circleName"].string!
                            let circleId = subJson["circleId"].string!
                            let color = subJson["circleIcon"].string!
                            var circleIcon: PinColors

                            if color == PinColors.color1.rawValue {
                                circleIcon = PinColors.color1
                            } else if color == PinColors.color2.rawValue {
                                circleIcon = PinColors.color2
                            } else if color == PinColors.color3.rawValue {
                                circleIcon = PinColors.color3
                            } else if color == PinColors.color4.rawValue {
                                circleIcon = PinColors.color4
                            } else if color == PinColors.color5.rawValue {
                                circleIcon = PinColors.color5
                            } else if color == PinColors.color6.rawValue {
                                circleIcon = PinColors.color6
                            } else if color == PinColors.color7.rawValue {
                                circleIcon = PinColors.color7
                            } else if color == PinColors.color8.rawValue {
                                circleIcon = PinColors.color8
                            } else if color == PinColors.color9.rawValue {
                                circleIcon = PinColors.color9
                            } else if color == PinColors.color10.rawValue {
                                circleIcon = PinColors.color10
                            } else {
                                circleIcon = PinColors.color1
                            }
                            
                            let message = subJson["lastMessage"]["message"].string!
                            let seconds = subJson["lastMessage"]["seconds"].double!
                            let date = NSDate(timeIntervalSince1970: seconds)
                            let timestamp = (date as Date).formatRelativeString()
                            
                            let senderName = "\(subJson["lastMessage"]["senderName"].string!):"
                            
                            self.chatPreviews.append(ChatPreview(circleIcon: circleIcon, circleName: circleName, circleId: circleId, senderName: senderName, message: message, timestamp: timestamp, hasNewMessages: true, hideAlerts: false))
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
    
    func uploadImage(_ image: UIImage, to circleId: String, completion: @escaping (URL?) -> Void) {
        guard let scaledImage = image.scaledToSafeUploadSize, let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        storage.child("circlePictures").child(circleId).child(imageName).putData(data, metadata: metadata) { meta, error in
            self.storage.child("circlePictures").child(circleId).child(imageName).downloadURL { (url, error) in
                guard let downloadURL = url else {
                    // Uh-oh, an error occurred!
                    return
                }
                completion(downloadURL)
            }
        }
    }
}
