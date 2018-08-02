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

class AuthRegisterController: UIViewController {
    
    var viewModel: AuthViewModeling?
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var registerErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.viewModel!.controller = self
        bindUi()
    }
    
    private func bindUi() {
        registerErrorLabel.reactive.text <~ viewModel!.errorMessage
    }
    
    // MARK: - Button actions
    @IBAction func handleMailRegister(_ sender: Any) {
        viewModel!.mailRegister(email: emailTextField.text!, password: passwordTextField.text!)
    }
    
    // MARK: - Keyboard actions

}
