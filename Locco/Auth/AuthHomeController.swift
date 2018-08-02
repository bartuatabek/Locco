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
        performSegue(withIdentifier: "goToRegister", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToRegister" {
            let AuthRegisterController = segue.destination as! AuthRegisterController
            AuthRegisterController.viewModel = viewModel
        } else if segue.identifier == "goToPhoneReg" {
            let AuthPhoneRegController = segue.destination as! AuthPhoneRegController
            AuthPhoneRegController.viewModel = viewModel
        }
    }
}
