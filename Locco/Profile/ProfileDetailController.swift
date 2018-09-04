//
//  ProfileDetailController.swift
//  Locco
//
//  Created by Bartu Atabek on 4.09.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Photos
import Firebase
import AVFoundation
import ReactiveCocoa
import ReactiveSwift

class ProfileDetailController: UITableViewController {
    
    var viewModel: ProfileViewModeling?
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var aboutTextField: UITextField!
    
    @IBOutlet weak var usernameRemainingCharCount: UILabel!
    @IBOutlet weak var aboutRemainingCharCount: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profilePic.tintColor = UIColor(red: 152/255, green: 152/255, blue: 157/255, alpha: 1.0)
        self.viewModel!.controller = self
        bindUIElements()
        setup()
    }
    
    private func bindUIElements() {
        if self.restorationIdentifier == "ProfileDetail" {
            usernameTextField.reactive.text <~ viewModel!.username
            aboutTextField.reactive.text <~ viewModel!.about
            profilePic.reactive.image <~ viewModel!.profilePicture
        }
    }
    
    func setup() {
        if profilePic.image == UIImage(named: "contact") {
            self.viewModel?.getProfilePicture(completion: {(result) in
                if result {
                    self.profilePic.image = self.viewModel?.profilePicture.value
                }
            })
        }
        
        usernameTextField.text = viewModel?.username.value
        aboutTextField.text = viewModel?.about.value
        profilePic.image = viewModel?.profilePicture.value
        
        usernameRemainingCharCount.text = String(25 - (usernameTextField.text?.count)!)
        aboutRemainingCharCount.text = String(80 - (aboutTextField.text?.count)!)
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
extension ProfileDetailController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if textField == usernameTextField {
            aboutTextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileDetailController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.profilePic.image = editedImage
            viewModel?.updateProfilePicture(profilePicture: editedImage)
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
}

