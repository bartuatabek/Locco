//
//  AuthViewModel.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import Foundation
import Firebase
import Alamofire
import SwiftyJSON
import ReactiveSwift
import ReactiveCocoa
import FBSDKLoginKit
import GoogleSignIn

protocol AuthViewModeling {
    var controller: UIViewController? { get set }
    var errorMessage: MutableProperty<String> { get }
    var errorLabelTint: MutableProperty<UIColor> { get }
    var verificationTimer : Timer { get set }
    
    func fbLogin()
    func googleLogin()
    func phoneLogin(phoneNumber: String) -> Bool
    func verifySMS(verificationCode: String) -> Bool
    func addUserMail(email: String)
    func showUserData()
    
    func isValidEmail(email: String?) -> Bool
    func isValidPassword(password: String) -> Bool
    
    func mailLogin(email: String, password: String)
    func mailRegister(email: String, password: String)
    func sendPasswordResetMail(email: String)
    func resendVerificationLink()
    func checkIfTheEmailIsVerified()
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
    }
    
    // MARK: - PhoneLogin
    func phoneLogin(phoneNumber: String) -> Bool {
        let dispatchGroup = DispatchGroup()
        dispatchGroup.enter()
        var result = false
        
        DispatchQueue.global(qos: .default).async {
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    print("Phone auth failed: ", error)
                    self.controller?.showAlert(withTitle: "Error", message: "Phone number is not valid")
                    dispatchGroup.leave()
                    return
                }
                // Sign in using the verificationID and the code sent to the user
                result = true
                print(result)
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                dispatchGroup.leave()
            }
        }
        
        print("before \(result)")
        dispatchGroup.wait(timeout: .now() + 2x)
        print("fin \(result)")
        return result
    }
    
    func verifySMS(verificationCode: String) -> Bool {
        var result = false
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID ?? "",
            verificationCode: verificationCode)
        
        Firebase.Auth.auth().signInAndRetrieveData(with: credential) { (authResult, error) in
            if let error = error {
                print("Verification failed: ", error)
                self.errorMessage.swap("Verification code is not valid")
                return
            }
            // User is signed in
            let currentUser = Firebase.Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error  {
                    print("Cannot get token: ", error )
                    return;
                }
                
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(idToken ?? "")",
                ]
                
                Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/emailExist", method: .post, headers: headers)
                    .responseJSON { response in
                        debugPrint(response)
                        switch response.result {
                        case .success(let value):
                            let json = JSON(value)
                            let status = json["status"].rawString()
                            
                            if status == "true" {
                                let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                                let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                                self.controller?.present(rootViewController, animated: true, completion: nil)
                            }
                            else {
                                self.controller?.performSegue(withIdentifier: "goToPhoneMail", sender: nil)
                            }
                        case .failure(let error):
                            print(error)
                        }
                }
            }
            result = true
        }
        return result
    }
    
    func addUserMail(email: String) {
        // TODO: - Add email to the user & post to firebase
        if isValidEmail(email: email) {
            let currentUser = Firebase.Auth.auth().currentUser
            currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                if let error = error  {
                    print("Cannot get token: ", error )
                    return;
                }
                
                let headers: HTTPHeaders = [
                    "Authorization": "Bearer \(idToken ?? "")",
                ]
                
                let parameters: Parameters = [
                    "email": email,
                    ]
                
                Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/updateEmail", method: .post, parameters: parameters, headers: headers)
                    .responseJSON { response in
                        debugPrint(response)
                }
                
                let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                self.controller?.present(rootViewController, animated: true, completion: nil)
            }
        }
        else {
            errorMessage.swap("Email is not valid")
            self.controller?.showAlert(withTitle: "Error", message: "Email is not valid")
        }
    }
    
    func showUserData() {
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokenString = accessToken?.tokenString else { return }
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokenString)
        
        Firebase.Auth.auth().signInAndRetrieveData(with: credentials, completion: { (user, error) in
            if error != nil {
                print("Something wrong with our FB user: ",  error ?? "")
                return
            }
            print("Successfully logged in with our user: ", user ?? "")
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
    
    func isValidPassword(password: String) -> Bool {
        if password.count > 5 { return true }
        else { return false }
    }
    
    func mailRegister(email: String, password: String) -> Void {
        if !isValidEmail(email: email) {
            errorMessage.swap("Email is not valid")
        }
            
        else if !isValidPassword(password: password) {
            errorMessage.swap("Password must be at least 6 charachters")
        }
            
        else {
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
                        self.controller?.performSegue(withIdentifier: "goToVerify", sender: nil)
                        self.verificationTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.checkIfTheEmailIsVerified) , userInfo: nil, repeats: true)
                    }
                })
            }
        }
    }
    
    func mailLogin(email: String, password: String) {
        Firebase.Auth.auth().signIn(withEmail: email, password: password) {
            (user,error) in
            if error != nil {
                self.errorMessage.swap("Login failed. Please try again.")
                print("Login failed: ", error ?? "")
            } else if (Firebase.Auth.auth().currentUser?.isEmailVerified)! {
                print("Login Successful")
                let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                self.controller?.present(rootViewController, animated: true, completion: nil)
            } else {
                print("Account is not verified")
                let rootViewController = self.controller?.storyboard?.instantiateViewController(withIdentifier: "Verify") as! AuthMailRegController
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
                self.errorMessage.swap("Operation failed. Please try again.")
                print("Verification link send failed: ", error ?? "")
            }
            else {
                print("Verification link sent")
            }
        })
    }
    
    @objc func checkIfTheEmailIsVerified() {
        Firebase.Auth.auth().currentUser?.reload(completion: { (error) in
            if error == nil {
                if  Firebase.Auth.auth().currentUser!.isEmailVerified {
                    self.verificationTimer.invalidate()
                    
                    let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                    let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                    self.controller?.present(rootViewController, animated: true, completion: nil)
                    
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
                        
                        Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/verifyEmail", method: .post, headers: headers)
                            .responseJSON { response in
                                debugPrint(response)
                        }
                    }
                }
            } else { print("Timer error: ", error ?? "") }
        })
    }
}
