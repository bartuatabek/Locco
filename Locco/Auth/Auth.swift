//
//  File.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//
import Firebase
import FBSDKCoreKit
import GoogleSignIn

struct Auth {
    // MARK: - Properties
    
    let userId: String
    let username:String
    let email: String
    
     // MARK: - Initialization
    
    init(userId: String, username: String, email: String) {
        self.userId = userId
        self.username = username
        self.email = email
    }
    
//    func reauthenticateUser() {
//        if let providerData = Firebase.Auth.auth().currentUser?.providerData {
//            for userInfo in providerData {
//                switch userInfo.providerID {
//                case "facebook.com":
//                    let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
//                case "google.com":
//                    let authentication = Firebase.Auth.auth().currentUser?.authentication
//                    let credential = GoogleAuthProvider.credentialWithIDToken(authentication.idToken, accessToken: authentication.accessToken)
//                default:
//                    let credential = FIREmailPasswordAuthProviderID.credentialWithEmail(email, password: password)
//                }
//            }
//        }
//    }
}
