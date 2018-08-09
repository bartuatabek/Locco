//
//  AuthRegisterController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 7/21/18.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class AuthMailRegController: UIViewController {
    
    var viewModel: AuthViewModeling?
    var credientials: String?
    
    @IBOutlet weak var emailTextField: FormTextField!
    @IBOutlet weak var passwordTextField: FormTextField!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel!.controller = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    
    // MARK: - Button actions
    @IBAction func checkMailAvailability(_ sender: Any) {
        viewModel?.mailAvailable(email: emailTextField.text, completion: { (result) in
            if result {
                self.credientials = self.emailTextField.text
                self.performSegue(withIdentifier: "goToMailPassword", sender: nil)
            }
        })
    }
    
    @IBAction func checkPassword(_ sender: Any) {
        viewModel?.isValidPassword(password: passwordTextField.text, completion: { (result) in
            if result {
                self.viewModel?.mailRegister(email: self.credientials!, password: self.passwordTextField.text!)
                self.performSegue(withIdentifier: "goToVerify", sender: nil)
            }
        })
    }
    
    @IBAction func resendVerificationLink(_ sender: UIButton) {
        viewModel!.resendVerificationLink()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMailPassword" {
            let AuthMailRegController = segue.destination as! AuthMailRegController
            AuthMailRegController.viewModel = viewModel
            AuthMailRegController.credientials = credientials
        }
        else if segue.identifier == "goToVerify" {
            let AuthMailRegController = segue.destination as! AuthMailRegController
            AuthMailRegController.viewModel = viewModel
        }
    }
}
