//
//  AuthController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa

class AuthLoginController: UIViewController {
    
    var viewModel: AuthViewModeling?
    
    @IBOutlet weak var emailLoginTextField: UITextField!
    @IBOutlet weak var passwordLoginTextField: UITextField!
    @IBOutlet weak var loginErrorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.viewModel!.controller = self
        bindUi()
    }
    
    private func bindUi() {
        loginErrorLabel.reactive.text <~ viewModel!.errorMessage
    }
    
    // MARK: - Button actions
    @IBAction func handleMailLogin(_ sender: Any) {
        viewModel!.mailLogin(email: emailLoginTextField.text!, password: passwordLoginTextField.text!)
    }
}
