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

class AddGeoPlaceDrawerController: PullUpController, UIGestureRecognizerDelegate {
    
    var viewModel: GeoPlacesViewModeling?
    var imagePicker = UIImagePickerController()
    
    // MARK: - IBOutlets
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.layer.cornerRadius = separatorView.frame.height/2
        }
    }
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var subtitleLabel: UITextField!
    @IBOutlet weak var radiusSlider: UISlider!
    @IBOutlet var pinColors: [GradientView]!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for pinColor in pinColors {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(checkAction))
            pinColor.addGestureRecognizer(gesture)
        }
        imagePicker.modalPresentationStyle = .overFullScreen
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (viewModel?.activeGeoPlaceIndex)! >= 0 {
            titleLabel.placeholder = viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].name
            subtitleLabel.placeholder = viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].placeDetail
            radiusSlider.value = Float((viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].radius)!)
            
            let pinColor = viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor.rawValue
            
            if pinColor == PinColors.color1.rawValue {
                pinColors[0].addShadowWithBorders()
            } else if pinColor == PinColors.color2.rawValue {
                 pinColors[1].addShadowWithBorders()
            } else if pinColor == PinColors.color3.rawValue {
                 pinColors[2].addShadowWithBorders()
            } else if pinColor! == PinColors.color4.rawValue {
                 pinColors[3].addShadowWithBorders()
            } else if pinColor == PinColors.color5.rawValue {
                 pinColors[4].addShadowWithBorders()
            } else if pinColor == PinColors.color6.rawValue {
                 pinColors[5].addShadowWithBorders()
            } else if pinColor == PinColors.color7.rawValue {
                 pinColors[6].addShadowWithBorders()
            } else if pinColor == PinColors.color8.rawValue {
                pinColors[7].addShadowWithBorders()
            } else if pinColor == PinColors.color9.rawValue {
                 pinColors[8].addShadowWithBorders()
            } else if pinColor == PinColors.color10.rawValue {
                 pinColors[9].addShadowWithBorders()
            }
            
            getAddress(coordinate: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].coordinate)!)
        }
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
    
    func getAddress(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            if (placemarks?.count)! > 0 {
                let pm = placemarks?.first
                let address = (pm?.name)! + " " + (pm?.thoroughfare)! + " " + (pm?.subLocality)! + " " + (pm?.locality)! + ", " + (pm?.administrativeArea)! + " " + (pm?.postalCode)! + " " + (pm?.country)!
                self.addressLabel.text = address
            }
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
        viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].radius = CLLocationDistance(radiusSlider.value)
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
        
        if (viewModel?.activeGeoPlaceIndex)! >= 0 {
            if sender.view?.tag == 0 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color1
            } else if sender.view?.tag == 1 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color2
            } else if sender.view?.tag == 2 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color3
            } else if sender.view?.tag == 3 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color4
            } else if sender.view?.tag == 4 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color5
            } else if sender.view?.tag == 5 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color6
            } else if sender.view?.tag == 6 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color7
            } else if sender.view?.tag == 7 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color8
            } else if sender.view?.tag == 8 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color9
            } else if sender.view?.tag == 9 {
                viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor = PinColors.color10
            }
        }
        
        sender.view?.addShadowWithBorders()
    }
    
    @IBAction func deletePlace(_ sender: Any) {
        viewModel?.remove(geotification: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!])!)
    }
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 400)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return 363
    }
    
//    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
//         return [80]
//    }
}

// MARK: - UIImagePickerControllerDelegate
extension AddGeoPlaceDrawerController:  UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        if let editedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            self.userPicture.image = editedImage
//        }
        
        //Dismiss the UIImagePicker after selection
        picker.dismiss(animated: true, completion: nil)
    }
}
