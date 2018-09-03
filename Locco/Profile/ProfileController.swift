//
//  ProfileController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Photos
import Firebase
import AVFoundation
import ReactiveCocoa
import ReactiveSwift

class ProfileController: UITableViewController {
    
    var viewModel: ProfileViewModeling?
    var imagePicker = UIImagePickerController()
    
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
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bindUIElements()
    }
    
    private func bindUIElements() {
        if self.restorationIdentifier! == "Profile" {
            usernameLabel.reactive.text <~ viewModel!.username
            aboutLabel.reactive.text <~ viewModel!.about
            profilePic.reactive.image <~ viewModel!.profilePicture
        } else if self.restorationIdentifier == "ProfileDetail" {
            usernameTextField.reactive.placeholder <~ viewModel!.username
            aboutTextField.reactive.placeholder <~ viewModel!.about
            profilePic.reactive.image <~ viewModel!.profilePicture
        }
    }
    
    func setup() {
        self.viewModel!.controller = self
        self.viewModel?.getAbout()
        self.viewModel?.getProfilePicture(completion: {(result) in
            if result {
                self.profilePic.image = self.viewModel?.profilePicture.value
            }
        })
        
        extendedLayoutIncludesOpaqueBars = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
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
    
    // MARK: Button actions
    @IBAction func editProfilePicture(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        var image = UIImage(named: "camera")
        var action = UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
            self.openCamera()
        })
        
        action.setValue(image, forKey: "image")
        alert.addAction(action)
        
        image = UIImage(named: "picture")
        action = UIAlertAction(title: "Photo Library", style: .default, handler: { _ in
            self.openGallery()
        })
        
        action.setValue(image, forKey: "image")
        alert.addAction(action)
        
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Open the camera
    func openCamera() {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                if UIImagePickerController .isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.camera
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.delegate = self
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Choose image from camera roll
    func openGallery() {
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized {
                    self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
                    self.imagePicker.allowsEditing = true
                    self.imagePicker.delegate = self
                    self.present(self.imagePicker, animated: true, completion: nil)
                }
            })
        } else if photos == .authorized {
            self.imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
            self.imagePicker.allowsEditing = true
            self.imagePicker.delegate = self
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }
    
    @IBAction func usernameTextFieldDidChange(_ sender: Any) {
        usernameRemainingCharCount.text = String(25 - (usernameTextField.text?.count)!)
    }
    
    @IBAction func aboutTextFieldDidChange(_ sender: Any) {
        aboutRemainingCharCount.text = String(80 - (aboutTextField.text?.count)!)
    }
    
    @IBAction func usernameChanged(_ sender: Any) {
        if !(usernameTextField.text?.isEmpty)! {
            viewModel?.updateUsername(username: usernameTextField.text!)
        }
    }
    
    @IBAction func aboutChanged(_ sender: Any) {
        if !(aboutTextField.text?.isEmpty)! {
            viewModel?.updateAbout(about: aboutTextField.text!)
        }
    }
}

// MARK: - UITextFieldDelegate
extension ProfileController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profilePic.image = editedImage
            viewModel?.updateProfilePicture(profilePicture: editedImage)
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
}
