//
//  ProfileController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Firebase

class ProfileController: UIViewController {
    
    var viewModel: ProfileViewModeling?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ProfileViewModel()
        self.viewModel!.controller = self
    }
        
    @IBAction func logout(_ sender: UIButton) {
        do {
            try Firebase.Auth.auth().signOut()
            print("Sign out successful")
            performSegue(withIdentifier: "goToHome", sender: nil)
            navigationController?.popToRootViewController(animated: true)
        } catch {
            print("Sign out failed: ", error)
        }
    }
    
    @IBAction func deleteAlert(sender: UIButton) {
        let alert = UIAlertController(title: "Delete Account", message: "This will delete your entire account and remove you from all Circles.", preferredStyle: .actionSheet)
    
        alert.addAction(UIAlertAction(title: "Delete Account", style: .destructive , handler:{ (UIAlertAction)in
            Firebase.Auth.auth().currentUser?.delete(completion: { (error) in
                if error != nil {
                    print("Account deletion failed: ", error ?? "")
                }
            })
            
            let mainStoryboard = UIStoryboard(name: "Auth", bundle: nil)
            let rootViewController = mainStoryboard.instantiateViewController(withIdentifier: "Auth") as UIViewController
            let navigationController = UINavigationController(rootViewController: rootViewController)
            navigationController.isNavigationBarHidden = true
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            alert.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }

}
