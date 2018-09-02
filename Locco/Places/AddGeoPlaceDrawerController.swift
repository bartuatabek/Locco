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
        self.viewModel?.isEditing = true
        
        for pinColor in pinColors {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(checkAction))
            pinColor.addGestureRecognizer(gesture)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (viewModel?.activeGeoPlaceIndex)! >= 0 {
            titleLabel.placeholder = viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].title
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
    
    @IBAction func updatePlaceName(_ sender: Any) {
        if !(titleLabel.text?.isEmpty)! {
            viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].title = titleLabel.text
        }
    }
    
    @IBAction func updatePlaceDetail(_ sender: Any) {
        if !(subtitleLabel.text?.isEmpty)! {
            viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].placeDetail = subtitleLabel.text!
        }
    }
    
    @IBAction func editLocation(_ sender: Any) {
        self.pullUpControllerMoveToVisiblePoint(75, animated: true) {
            self.view.isUserInteractionEnabled = false

            if (self.viewModel?.activeGeoPlaceIndex)! >= 0 {
                let currentGeoPlace = self.viewModel!.geoPlaces[(self.viewModel?.activeGeoPlaceIndex)!] as MKAnnotation
                let annotationView = (self.parent as? GeoPlacesController)?.mapView.view(for: currentGeoPlace)
                (self.parent as? GeoPlacesController)?.mapView.setCenter(currentGeoPlace.coordinate, animated: true)
                (self.parent as? GeoPlacesController)?.removeRadiusOverlay(forGeotification: currentGeoPlace as! GeoPlace)
                annotationView?.isDraggable = true
            }
        }
    }

    @IBAction func sliderEditingChanged(_ sender: Any) {
        guard let overlays = (self.parent as? GeoPlacesController)?.mapView?.overlays else { return }
        for overlay in overlays {
            guard let circleOverlay = overlay as? MKCircle else { continue }
            (self.parent as? GeoPlacesController)?.mapView.removeOverlay(circleOverlay)
        }
        (self.parent as? GeoPlacesController)?.mapView?.addOverlay(MKCircle(center: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].coordinate)!, radius: Double(radiusSlider.value)))

        var centerCoordinate = (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].coordinate)!
        centerCoordinate.latitude -= ((self.parent as? GeoPlacesController)?.mapView.region.span.latitudeDelta)! * 0.55
        let region = MKCoordinateRegion.init(center: centerCoordinate, latitudinalMeters: CLLocationDistance(radiusSlider.value*4), longitudinalMeters: CLLocationDistance(radiusSlider.value))
        (self.parent as? GeoPlacesController)?.mapView?.setRegion(region, animated: true)
        
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
        
        if (viewModel?.activeGeoPlaceIndex)! >= 0 {
            let currentGeoPlace = viewModel!.geoPlaces[(viewModel?.activeGeoPlaceIndex)!] as MKAnnotation
            let annotationView = (self.parent as? GeoPlacesController)?.mapView.view(for: currentGeoPlace)
            annotationView?.image = UIImage(named: "Pin")!
                .tintedWithLinearGradientColors(colorsArr: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor.colors)!)
        }
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
}

extension AddGeoPlaceDrawerController: UITextFieldDelegate {
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
