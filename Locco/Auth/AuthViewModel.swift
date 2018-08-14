//
//  AuthViewModel.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import Firebase
import Alamofire
import Foundation
import SwiftyJSON
import GoogleSignIn
import ReactiveSwift
import ReactiveCocoa
import FBSDKLoginKit
import FirebaseStorage

protocol AuthViewModeling {
    var controller: UIViewController? { get set }
    var errorMessage: MutableProperty<String> { get }
    var errorLabelTint: MutableProperty<UIColor> { get }
    var verificationTimer : Timer { get set }
    
    func fbLogin()
    func googleLogin()
    func phoneLogin(phoneNumber: String, completion: @escaping (_ result: Bool)->())
    func verifySMS(verificationCode: String, completion: @escaping (_ result: Bool)->())
    func showUserData()
    
    func isValidEmail(email: String?) -> Bool
    func phoneAvailable(phone: String?, completion: @escaping (_ result: Bool)->())
    func mailAvailable(email: String?, completion: @escaping (_ result: Bool)->())
    func isValidPassword(password: String?, completion: @escaping (_ result: Bool)->())
    
    func mailLogin(email: String, password: String)
    func mailRegister(email: String, password: String)
    func sendPasswordResetMail(email: String)
    func resendVerificationLink()
    func checkIfTheEmailIsVerified()
    
    func setDisplayName(name: String)
    func setUserPicture(profilePhoto: UIImage)
    
    func sendRegistrationToken()
}

class AuthViewModel: AuthViewModeling {
    
    // MARK: - Properties
    let errorMessage: MutableProperty<String>
    let errorLabelTint: MutableProperty<UIColor>
    
    weak var controller: UIViewController?
    var verificationTimer : Timer = Timer()
    
    // MARK: - Initialization
    init() {
        self.errorMessage = MutableProperty("")
        self.errorLabelTint = MutableProperty(UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0))
    }
    
    // MARK: - FBLogin
    func fbLogin() {
        FBSDKLoginManager().logIn(withReadPermissions: ["email", "public_profile"], from: controller) { (result, error) in
            if error != nil {
                print("FB Login failed: ", error!)
                return
            }
            self.showUserData()
        }
    }
    
    // MARK: - GoogleLogin
    func googleLogin() {
        GIDSignIn.sharedInstance()?.signIn()
        self.sendRegistrationToken()
    }
    
    // MARK: - PhoneLogin
    func phoneLogin(phoneNumber: String, completion: @escaping (_ result: Bool)->()) {
        PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
            if let error = error {
                print("Phone auth failed: ", error)
                self.controller?.showAlert(withTitle: "Error", message: "Phone number is not valid")
                completion(false)
                return
            }
            // Sign in using the verificationID and the code sent to the user
            UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
            completion(true)
        }
    }
    
    func verifySMS(verificationCode: String, completion: @escaping (_ result: Bool)->()) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID ?? "",
            verificationCode: verificationCode)
        
        Firebase.Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print("Verification failed: ", error)
                self.errorMessage.swap("Verification code is not valid")
                completion(false)
                return
            }
            // User is signed in
            let currentUser = Firebase.Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error  {
                    print("Cannot get token: ", error )
                    completion(false)
                    return;
                }
                self.sendRegistrationToken()
                completion(true)
            }
        }
    }
    
    func showUserData() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Firebase.Auth.auth().signInAndRetrieveData(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something wrong with our FB user: ",  error ?? "")
                self.controller?.showAlert(withTitle: "Error", message: "Something went wrong. Please try again.")
                return
            }
            print("Successfully logged in with our user: ", user ?? "")
            self.sendRegistrationToken()
            let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
            let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
            self.controller?.present(rootViewController, animated: true, completion: nil)
        })
        //        Code for printing user data
        //        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields" : "id, name, email"]).start { (connection, result, error) in
        //            if error != nil {
        //                print("Failed to start graph request: ", error ?? "")
        //                return
        //            }
        //
        //            print(result ?? "")
        //        }
    }
    
    // MARK: - MailLogin
    func isValidEmail(email: String?) -> Bool {
        guard email != nil else { return false }
        let regEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let pred = NSPredicate(format:"SELF MATCHES %@", regEx)
        return pred.evaluate(with: email)
    }
    
    func mailAvailable(email: String?, completion: @escaping (_ result: Bool)->()) {
        if isValidEmail(email: email) {
            Firebase.Auth.auth().fetchProviders(forEmail: email!, completion: {
                (providers, error) in
                if error != nil {
                    print("Operation failed: ", error ?? "")
                    return
                } else if providers != nil {
                    self.controller?.showAlert(withTitle: "Error", message: "Mail address is already in use for another account.")
                    completion(false)
                } else {
                    completion(true)
                }
            })
        } else {
            self.controller?.showAlert(withTitle: "Error", message: "Mail address is not valid.")
            completion(false)
        }
    }
    
    func phoneAvailable(phone: String?, completion: @escaping (_ result: Bool)->()) {
        let allowedCharset = CharacterSet
            .decimalDigits
            .union(CharacterSet(charactersIn: "+"))
        
        let filteredText = String(phone!.unicodeScalars.filter(allowedCharset.contains))
        
        let parameters: Parameters = [
            "phoneNumber": filteredText,
            ]
        
        Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api2/phoneExist", method: .get, parameters: parameters)
            .responseJSON { response in
                debugPrint(response)
                switch response.result {
                case .success(let value):
                    let json = JSON(value)
                    let status = json["status"].rawString()
                    
                    if status == "true" {
                        completion(false)
                    }
                    else {
                        completion(true)
                    }
                case .failure(let error):
                    print(error)
                }
        }
    }
    
    func isValidPassword(password: String?, completion: @escaping (_ result: Bool)->()) {
        if password!.count > 5 { completion(true) }
        else {
            self.controller?.showAlert(withTitle: "Error", message: "Password must be at least 6 characters.")
            completion(false)
        }
    }
    
    func mailRegister(email: String, password: String) {
        Firebase.Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            if error != nil {
                self.errorMessage.swap("User already exists. Try logging in.")
                print("Registration failed: ", error ?? "")
            }
        }
        
        print("Register Successful")
        Firebase.Auth.auth().addStateDidChangeListener { (auth, user) in
            Firebase.Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                if error != nil {
                    self.errorMessage.swap("Could not send verification mail. Please try again.")
                    print("Verification link send failed: ", error ?? "")
                }
                else {
                    print("Verification link sent")
                    self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkIfTheEmailIsVerified) , userInfo: nil, repeats: true)
                }
            })
        }
    }
    
    func mailLogin(email: String, password: String) {
        Firebase.Auth.auth().signIn(withEmail: email, password: password) {
            (user,error) in
            if error != nil {
                self.controller?.showAlert(withTitle: "Error", message: "Mail is not valid")
                print("Login failed: ", error ?? "")
            } else if (Firebase.Auth.auth().currentUser?.isEmailVerified)! {
                print("Login Successful")
                let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                self.controller?.present(rootViewController, animated: true, completion: nil)
            } else {
                print("Account is not verified")
                let rootViewController = self.controller?.storyboard?.instantiateViewController(withIdentifier: "Verify") as! AuthMailRegController
                rootViewController.viewModel = self
                self.controller?.navigationController?.pushViewController(rootViewController, animated: true)
                self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkIfTheEmailIsVerified) , userInfo: nil, repeats: true)
            }
        }
    }
    
    func sendPasswordResetMail(email: String) {
        if !email.isEmpty {
            Firebase.Auth.auth().sendPasswordReset(withEmail: email) { (error) in
                if let error = error  {
                    self.errorMessage.swap("Operation failed. Please try again.")
                    self.errorLabelTint.swap(UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0))
                    print("Cannot send password reset mail: ", error )
                    return;
                }
                self.errorLabelTint.swap(UIColor(red: 0/255, green: 122/255, blue: 255/255, alpha: 1.0))
                self.errorMessage.swap("Reset link sent. Please check your mail.")
            }
        } else {
            self.errorMessage.swap("Mail cannot be empty.")
            self.errorLabelTint.swap(UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0))
        }
    }
    
    func resendVerificationLink() {
        Firebase.Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
            if error != nil {
                self.controller?.showAlert(withTitle: "Error", message: "Operation failed. Please try again.")
                print("Verification link send failed: ", error ?? "")
            }
            else {
                print("Verification link sent")
                self.controller?.showAlert(withTitle: "", message: "Verification link sent. Please check your mail.")
            }
        })
    }
    
    @objc func checkIfTheEmailIsVerified() {
        Firebase.Auth.auth().currentUser?.reload(completion: { (error) in
            if error == nil {
                if  Firebase.Auth.auth().currentUser!.isEmailVerified {
                    self.verificationTimer.invalidate()
                    
                    self.sendRegistrationToken()
                    let mainStoryboard = UIStoryboard(name: "Auth", bundle: nil)
                    let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "PhoneName") as! AuthPhoneRegController
                    rootViewController.viewModel = self
                    self.controller?.navigationController?.pushViewController(rootViewController, animated: true)
                    
                    // http request for email validation
                    let currentUser = Firebase.Auth.auth().currentUser
                    currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                        if let error = error  {
                            print("Cannot get token: ", error )
                            return;
                        }
                        
                        let headers: HTTPHeaders = [
                            "Authorization": "Bearer \(idToken ?? "")",
                        ]
                        
                        Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/verifyEmail", method: .get, headers: headers)
                            .responseJSON { response in
                                debugPrint(response)
                        }
                    }
                }
            } else { print("Timer error: ", error ?? "") }
        })
    }
    
    // MARK: - Update user data
    func setDisplayName(name: String) {
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "displayName": name
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/updateDisplayName", method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
                    debugPrint(response)
            }
        }
    }
    
    func setUserPicture(profilePhoto: UIImage) {
        let storage = Storage.storage()
        var data = Data()
        data = profilePhoto.pngData()!
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        let imageRef = storageRef.child("/profilePictures/\(Firebase.Auth.auth().currentUser?.uid ?? "").jpeg")
        // Create file metadata including the content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(data, metadata: metadata)
    }
    
    func sendRegistrationToken() {
        print("ghoooo")
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                let currentUser = Firebase.Auth.auth().currentUser
                currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                    if let error = error  {
                        print("Cannot get token: ", error )
                        return;
                    }
                    
                    let parameters: Parameters = [
                        "token": result.token
                    ]
                    
                    let headers: HTTPHeaders = [
                        "Authorization": "Bearer \(idToken ?? "")"
                    ]
                    
                    Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/updateRegistrationToken", method: .post, parameters: parameters, headers: headers)
                        .responseJSON { response in
                            debugPrint(response)
                    }
                }
            }
        }
    }
}
