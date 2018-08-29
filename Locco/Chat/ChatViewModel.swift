//
//  ChatViewModel.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import Firebase
import Alamofire
import ReactiveSwift
import ReactiveCocoa

protocol ChatViewModeling {
    var controller: UIViewController? { get set }
    
    func getChatPreview()
}

class ChatViewModel: ChatViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    
    // MARK: - Initialization
    init() {
    }
    
    func getChatPreview() {
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
            }
        }
    }
}
