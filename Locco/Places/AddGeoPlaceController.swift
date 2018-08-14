//
//  AddGeoPlaceController.swift
//  Locco
//
//  Created by Bartu Atabek on 19.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Photos
import MapKit
import Firebase
import Alamofire
import AVFoundation
import PullUpController

class AddGeoPlaceController: PullUpController, UIGestureRecognizerDelegate {
    
    var viewModel: GeoPlacesViewModeling?
    var imagePicker = UIImagePickerController()
    
    // MARK: - IBOutlets
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.layer.cornerRadius = separatorView.frame.height/2
        }
    }
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var subtitleLabel: UIView!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet var pinColors: [GradientView]!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for pinColor in pinColors {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(checkAction))
            pinColor.addGestureRecognizer(gesture)
        }
        pinColors[1].addShadowWithBorders()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
       
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        } else {
            // Fallback on earlier versions
        }
    }
    
    @IBAction func addPhoto(_ sender: Any) {
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
    
    @IBAction func editLocation(_ sender: Any) {
        
    }
    
    @IBAction func sliderEditingChanged(_ sender: Any) {
        
    }
    
    @objc func checkAction(sender : UITapGestureRecognizer) {
        for pinColor in pinColors {
            for view in pinColor.subviews {
                view.removeFromSuperview()
            }
            pinColor.layer.shadowOffset = CGSize(width: 0, height: 0)
            pinColor.layer.shadowColor = UIColor.clear.cgColor
            pinColor.layer.shadowRadius = 0.0
            pinColor.layer.shadowOpacity = 0.0
        }
        sender.view?.addShadowWithBorders()
    }
    
    @IBAction func deletePlace(_ sender: Any) {
        
    }
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 400)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return 363
    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddGeoPlaceController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            self.userPicture.image = editedImage
//        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
}
