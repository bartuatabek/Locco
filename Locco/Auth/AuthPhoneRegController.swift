//
//  AuthPhoneRegController.swift
//  Locco
//
//  Created by Bartu Atabek on 27.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Photos
import Firebase
import AVFoundation
import ADCountryPicker

class AuthPhoneRegController: UIViewController {
    
    var viewModel: AuthViewModeling?
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var countryCode: FormTextField!
    @IBOutlet weak var phoneNo: FormTextField!
    
    @IBOutlet var otpField: [FormTextField]!
    
    @IBOutlet weak var usernameTextField: FormTextField!
    @IBOutlet weak var userPicture: RoundedImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.restorationIdentifier! == "PhonePic" {
            let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
            userPicture.isUserInteractionEnabled = true
            userPicture.addGestureRecognizer(tapGestureRecognizer)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel!.controller = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {        
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
    
    // MARK: - Button Actions
    @IBAction func selectCountryCode(_ sender: Any) {
        let picker = ADCountryPicker()
        picker.showCallingCodes = true
        picker.searchBarBackgroundColor = UIColor.white
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            self.countryCode.text = dialCode
            self.countryCode.leftImage = UIImage(named: "assets.bundle/" + code.uppercased() + ".png", in: Bundle(for: ADCountryPicker.self), compatibleWith: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func sendSMS(_ sender: UIButton) {
        let phoneNumber = countryCode.text! + phoneNo.text!
        viewModel?.phoneAvailable(phone: phoneNumber, completion: { (result) in
            if result {
                self.viewModel!.phoneLogin(phoneNumber: phoneNumber, completion: { (result) in
                    if result {
                        self.performSegue(withIdentifier: "goToPhoneVerify", sender: nil)
                    }
                })
            } else {
                self.showAlert(withTitle: "Error", message: "Phone number is already in use for another account.")
            }
        })
    }
    
    @IBAction func resendSMS(_ sender: Any) {
        let phoneNumber = countryCode.text! + phoneNo.text!
        viewModel!.phoneLogin(phoneNumber: phoneNumber, completion: { (result) in
            if result {
                self.showAlert(withTitle: "", message: "Verification code sent.")
            }
        })
    }
    
    @IBAction func VerifyCode(_ sender: Any) {
        let verificationCode = otpField[0].text! + otpField[1].text! + otpField[2].text! + otpField[3].text! + otpField[4].text! + otpField[5].text!
        viewModel!.verifySMS(verificationCode: verificationCode, completion: { (result) in
            if result {
                self.performSegue(withIdentifier: "goToPhoneName", sender: nil)
            }
        })
    }
    
    @IBAction func showOTPKeyboard(_ sender: UITapGestureRecognizer) {
        for textfield in otpField {
            textfield.text = ""
        }
        otpField[0].isUserInteractionEnabled = true;
        otpField[0].becomeFirstResponder()
    }
    
    @IBAction func setUsername(_ sender: Any) {
        viewModel?.setDisplayName(name: usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines))
        performSegue(withIdentifier: "goToPic", sender: nil)
    }
    
    
    @IBAction func FinishRegistration(_ sender: Any) {
        if let profilePic = userPicture.image {
            viewModel?.setUserPicture(profilePhoto: profilePic)
        } else {
            viewModel?.setUserPicture(profilePhoto: UIImage(named: "userpic_placeholder")!)
        }
        
        let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
        let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
        present(rootViewController, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let AuthPhoneRegController = segue.destination as! AuthPhoneRegController
        AuthPhoneRegController.viewModel = viewModel
    }
}

// MARK: - UITextFieldDelegate
extension AuthPhoneRegController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNo {
            phoneNo.text = phoneNo.formattedNumber(number: phoneNo.text!)
            return true
        } else {
            if (textField.text?.count)! < 2  && string.count > 0 {
                if textField == otpField[0] {otpField[0].isUserInteractionEnabled = false; otpField[1].isUserInteractionEnabled = true; otpField[1].becomeFirstResponder()}
                if textField == otpField[1] {otpField[1].isUserInteractionEnabled = false; otpField[2].isUserInteractionEnabled = true; otpField[2].becomeFirstResponder()}
                if textField == otpField[2] {otpField[2].isUserInteractionEnabled = false; otpField[3].isUserInteractionEnabled = true; otpField[3].becomeFirstResponder()}
                if textField == otpField[3] {otpField[3].isUserInteractionEnabled = false; otpField[4].isUserInteractionEnabled = true; otpField[4].becomeFirstResponder()}
                if textField == otpField[4] {otpField[4].isUserInteractionEnabled = false; otpField[5].isUserInteractionEnabled = true; otpField[5].becomeFirstResponder()}
                if textField == otpField[5] {otpField[5].isUserInteractionEnabled = false; otpField[5].resignFirstResponder()}
                
                textField.text = string
                return false
                
            } else if (textField.text?.count)! >= 1 && string.count == 0 {
                if textField == otpField[0] {otpField[0].isUserInteractionEnabled = true; otpField[0].becomeFirstResponder()}
                if textField == otpField[1] {otpField[0].isUserInteractionEnabled = true; otpField[1].isUserInteractionEnabled = false; otpField[0].becomeFirstResponder()}
                if textField == otpField[2] {otpField[1].isUserInteractionEnabled = true; otpField[2].isUserInteractionEnabled = false; otpField[1].becomeFirstResponder()}
                if textField == otpField[3] {otpField[2].isUserInteractionEnabled = true; otpField[3].isUserInteractionEnabled = false; otpField[2].becomeFirstResponder()}
                if textField == otpField[4] {otpField[3].isUserInteractionEnabled = true; otpField[4].isUserInteractionEnabled = false; otpField[3].becomeFirstResponder()}
                if textField == otpField[5] {otpField[4].isUserInteractionEnabled = true; otpField[5].isUserInteractionEnabled = false; otpField[4].becomeFirstResponder()}
                
                textField.text = ""
                return false
                
            } else if (textField.text?.count)! >= 2 {
                textField.text = string
                return false
            }
            return true
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = "\u{200B}"
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AuthPhoneRegController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            self.userPicture.image = editedImage
        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
}
