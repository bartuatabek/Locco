//
//  ProfileController.swift
//  Locco
//
//  Created by Bartu Atabek on 10.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Firebase
import ReactiveCocoa
import ReactiveSwift

class ProfileController: UITableViewController {
    
    var viewModel: ProfileViewModeling?
    var imagePicker = UIImagePickerController()
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var profilePic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = ProfileViewModel()
        setup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        profilePic.tintColor = UIColor(red: 152/255, green: 152/255, blue: 157/255, alpha: 1.0)
        self.viewModel!.controller = self
        bindUIElements()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToProfileDetail" {
            let profileDetailController = segue.destination as! ProfileDetailController
            profileDetailController.viewModel = viewModel
        }
    }
    
    private func bindUIElements() {
        if self.restorationIdentifier! == "Profile" {
            usernameLabel.reactive.text <~ viewModel!.username
            aboutLabel.reactive.text <~ viewModel!.about
            profilePic.reactive.image <~ viewModel!.profilePicture
        }
    }
    
    func setup() {
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
}
