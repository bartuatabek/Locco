//
//  AuthController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit
import ReactiveSwift
import ReactiveCocoa
import ADCountryPicker

class AuthLoginController: UIViewController {
    
    var viewModel: AuthViewModeling?
    
    @IBOutlet weak var emailLoginTextField: UITextField!
    @IBOutlet weak var passwordLoginTextField: UITextField!
    
    @IBOutlet weak var countryCodeTextField: FormTextField!
    @IBOutlet weak var phoneNoTextField: FormTextField!
    
    @IBOutlet weak var emailRecoveryField: FormTextField!
    @IBOutlet var otpField: [FormTextField]!
    
    @IBOutlet weak var recoverPasswordErrorLabel: UILabel!
    @IBOutlet weak var verificationCodeErrorLabel: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel!.controller = self
        bindUIElements()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToVerifyNumber" {
            let AuthLoginController = segue.destination as! AuthLoginController
            AuthLoginController.viewModel = viewModel
        } else if segue.identifier == "goToForgotPassword" {
            let AuthLoginController = segue.destination as! AuthLoginController
            AuthLoginController.viewModel = viewModel
        }
    }
    
    private func bindUIElements() {
        if self.restorationIdentifier! == "ForgotPassword" {
            recoverPasswordErrorLabel.reactive.text <~ viewModel!.errorMessage
            recoverPasswordErrorLabel.reactive.textColor <~ viewModel!.errorLabelTint
        } else if self.restorationIdentifier == "PhoneLoginVerify" {
            verificationCodeErrorLabel.reactive.text <~ viewModel!.errorMessage
        }
    }
    
    // MARK: - Button actions
    @IBAction func selectCountryCode(_ sender: Any) {
        let picker = ADCountryPicker()
        picker.showCallingCodes = true
        picker.searchBarBackgroundColor = UIColor.white
        let pickerNavigationController = UINavigationController(rootViewController: picker)
        self.present(pickerNavigationController, animated: true, completion: nil)
        
        picker.didSelectCountryWithCallingCodeClosure = { name, code, dialCode in
            self.countryCodeTextField.text = dialCode
            self.countryCodeTextField.leftImage = UIImage(named: "assets.bundle/" + code.uppercased() + ".png", in: Bundle(for: ADCountryPicker.self), compatibleWith: nil)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func login(_ sender: Any) {
        if !emailLoginTextField.text!.isEmpty && !passwordLoginTextField.text!.isEmpty {
            viewModel!.mailLogin(email: emailLoginTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines), password: passwordLoginTextField.text!)
        } else if !countryCodeTextField.text!.isEmpty && !phoneNoTextField.text!.isEmpty {
            let phoneNumber = countryCodeTextField.text! + phoneNoTextField.text!
            viewModel?.phoneAvailable(phone: phoneNumber, completion: { (result) in
                if !result {
                    self.viewModel!.phoneLogin(phoneNumber: phoneNumber, completion: { (result) in
                        if result {
                            self.performSegue(withIdentifier: "goToVerifyNumber", sender: nil)
                        }
                    })
                } else {
                    self.showAlert(withTitle: "Login Failed", message: "Account does not exist.")
                }
            })
        } else {
            showAlert(withTitle: "Login Failed", message: "Please try again.")
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        performSegue(withIdentifier: "goToForgotPassword", sender: nil)
    }
    
    @IBAction func sendPasswordResetMail(_ sender: Any) {
        viewModel?.sendPasswordResetMail(email: emailRecoveryField.text!)
    }
    
    @IBAction func showOTPKeyboard(_ sender: UITapGestureRecognizer) {
        for textfield in otpField {
            textfield.text = ""
        }
        otpField[0].isUserInteractionEnabled = true;
        otpField[0].becomeFirstResponder()
    }
    
    @IBAction func sendSMS(_ sender: UIButton) {
        let phoneNumber = countryCodeTextField.text! + phoneNoTextField.text!
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
                let mainStoryboard = UIStoryboard(name: "Home", bundle: nil)
                let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Home") as UIViewController
                self.present(rootViewController, animated: true, completion: nil)
            }
        })
    }
}

extension AuthLoginController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == phoneNoTextField {
            phoneNoTextField.text = phoneNoTextField.formattedNumber(number: phoneNoTextField.text!)
            return true
        } else if textField == countryCodeTextField {
            return true
        } else if textField == emailLoginTextField {
            return true
        } else if textField == passwordLoginTextField {
            return true
        } else if textField == otpField[0] || textField == otpField[1] || textField == otpField[2] || textField == otpField[3] || textField == otpField[4] || textField == otpField[5] {
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
        }
         return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == phoneNoTextField || textField == countryCodeTextField || textField == emailLoginTextField || textField == passwordLoginTextField {
            return
        } else {
            textField.text = "\u{200B}"
        }
    }
    
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
