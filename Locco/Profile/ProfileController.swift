//
//  ProfileController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorage

class ProfileController: UITableViewController {
    
    var viewModel: ProfileViewModeling?
    let storage = Storage.storage()
    let imageCache = NSCache<NSString, UIImage>()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    @IBOutlet weak var usernameRemainingCharCount: UILabel!
    @IBOutlet weak var aboutRemainingCharCount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ProfileViewModel()
        self.viewModel!.controller = self
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadImageUserFromFirebase()
        
        if self.restorationIdentifier! == "Profile" {
            usernameLabel.text = Firebase.Auth.auth().currentUser?.displayName
        } else if self.restorationIdentifier! == "ProfileDetail" {
            
        }
    }
    
    func downloadImageUserFromFirebase() {
        if let cachedImage = imageCache.object(forKey: "userPicture") {
            self.profilePic.image = cachedImage
        } else {
            // Get a reference to the storage service using the default Firebase App
            let storage = Storage.storage()
            
            // Create a storage reference from our storage service
            let storageRef = storage.reference()
            let imageRef = storageRef.child("/profilePictures/\(Firebase.Auth.auth().currentUser?.uid ?? "").jpeg")
            
            // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
            imageRef.getData(maxSize: 1 * 5120 * 5120) { data, error in
                if let error = error {
                    print("Error: ", error)
                } else {
                    let image = UIImage(data: data!)
                    self.imageCache.setObject(image!, forKey: "userPicture")
                    self.profilePic.image = image
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath == [1,6] {
            do {
                try Firebase.Auth.auth().signOut()
                print("Sign out successful")
                navigationController?.popToRootViewController(animated: true)
                performSegue(withIdentifier: "goToAuth", sender: nil)
            } catch {
                print("Sign out failed: ", error)
            }
        } else if indexPath == [1,7] {
            let alert = UIAlertController(title: "Delete Account", message: "This will delete your entire account and remove you from all Circles.", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive , handler:{ (UIAlertAction)in
                Firebase.Auth.auth().currentUser?.delete(completion: { (error) in
                    if error != nil {
                        print("Account deletion failed: ", error ?? "")
                        return
                    }
                    self.navigationController?.popToRootViewController(animated: true)
                    self.performSegue(withIdentifier: "goToAuth", sender: nil)
                })
            }))
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ProfileController: UITextFieldDelegate {
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            usernameRemainingCharCount.text = String(25 - (usernameTextField.text?.count)!)
        }
        else if textField == aboutTextField {
            aboutRemainingCharCount.text = String(80 - (aboutTextField.text?.count)!)
        }
        return true
    }
}
