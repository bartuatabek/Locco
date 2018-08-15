//
//  AuthController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import ReactiveSwift
import ReactiveCocoa
import FBSDKLoginKit
import GoogleSignIn

class AuthHomeController: UIViewController, GIDSignInUIDelegate {
    
    var viewModel: AuthViewModeling?
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = AuthViewModel()
        self.viewModel!.controller = self
        GIDSignIn.sharedInstance().uiDelegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    // MARK: - Button actions
    @IBAction func handleFBLogin(_ sender: UIButton) {
        viewModel!.fbLogin()
    }
    
    @IBAction func handleGoogleLogin(_ sender: UIButton) {
        viewModel!.googleLogin()
    }
    
    @IBAction func handleMailRegister(_ sender: UIButton) {
        performSegue(withIdentifier: "goToMailReg", sender: self)
    }
    
    @IBAction func handlePhoneReg(_ sender: UIButton) {
        performSegue(withIdentifier: "goToPhoneReg", sender: self)
    }
    
    @IBAction func handleLogin(_ sender: UIButton) {
        performSegue(withIdentifier: "goToLogin", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToMailReg" {
            let AuthMailRegController = segue.destination as! AuthMailRegController
            AuthMailRegController.viewModel = viewModel
        } else if segue.identifier == "goToPhoneReg" {
            let AuthPhoneRegController = segue.destination as! AuthPhoneRegController
            AuthPhoneRegController.viewModel = viewModel
        } else if segue.identifier == "goToLogin" {
            let AuthLoginController = segue.destination as! AuthLoginController
            AuthLoginController.viewModel = viewModel
        }
    }
}
