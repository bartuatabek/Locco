//
//  ProfileViewModel.swift
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
import FirebaseStorage

protocol ProfileViewModeling {
    var controller: UIViewController? { get set }
    var username: MutableProperty<String> { get }
    var about: MutableProperty<String> { get }
    var profilePicture: MutableProperty<UIImage> { get }
    
    func getAbout()
    func updateAbout(about: String)
    func updateUsername(username: String)
    func updateProfilePicture(profilePicture: UIImage)
    func getProfilePicture(completion: @escaping (_ result: Bool) ->())
}

class ProfileViewModel: ProfileViewModeling {
    
    // MARK: - Properties
    weak var controller: UIViewController?
    var username:  MutableProperty<String>
    var about:  MutableProperty<String>
    var profilePicture:  MutableProperty<UIImage>
    
    // MARK: - Initialization
    init() {
        username = MutableProperty((Firebase.Auth.auth().currentUser?.displayName)!)
        about = MutableProperty("")
        profilePicture = MutableProperty(UIImage(named: "contact")!.withRenderingMode(.alwaysTemplate))
    }
    
    func getAbout() {
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/getAbout", method: .get, headers: headers)
                .responseJSON { response in
                    self.about.value = JSON(response.result.value!)["data"]["about"].string!
            }
        }
    }
    
    func updateAbout(about: String) {
        self.about.swap(about.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "about": about
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/updateAbout", method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
//                    debugPrint(response)
            }
        }
    }
    
    func updateUsername(username: String) {
        self.username.swap(username.trimmingCharacters(in: .whitespacesAndNewlines))
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges { (error) in
            if let error = error {
                print("Error: ", error)
            } else {
                Firebase.Auth.auth().currentUser?.reload(completion: nil)
            }
        }
        
        let currentUser = Firebase.Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if let error = error  {
                print("Cannot get token: ", error )
                return;
            }
            
            let parameters: Parameters = [
                "displayName": username.trimmingCharacters(in: .whitespacesAndNewlines)
            ]
            
            let headers: HTTPHeaders = [
                "Authorization": "Bearer \(idToken ?? "")"
            ]
            
            Alamofire.request("https://us-central1-locationfinder-e0ce7.cloudfunctions.net/api/updateDisplayName", method: .post, parameters: parameters, headers: headers)
                .responseJSON { response in
//                    debugPrint(response)
            }
        }
    }
    
    func getProfilePicture(completion: @escaping (Bool) -> ()) {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("/profilePictures/\(Firebase.Auth.auth().currentUser?.uid ?? "").jpeg")
        
        imageRef.getData(maxSize: 1 * 5120 * 5120) { data, error in
            if let error = error {
                print("Error: ", error)
                completion(false)
            } else {
                let downloadedImage = UIImage(data: data!)!
                self.profilePicture = MutableProperty(downloadedImage)
                completion(true)
            }
        }
    }
    
    func updateProfilePicture(profilePicture: UIImage) {
        let storage = Storage.storage()
        var data = Data()
        data = profilePicture.pngData()!
        
        // Create a storage reference from our storage service
        let storageRef = storage.reference()
        let imageRef = storageRef.child("/profilePictures/\(Firebase.Auth.auth().currentUser?.uid ?? "").jpeg")
        // Create file metadata including the content type
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(data, metadata: metadata)
        self.profilePicture.swap(profilePicture)
        Firebase.Auth.auth().currentUser?.reload(completion: nil)
    }
}
