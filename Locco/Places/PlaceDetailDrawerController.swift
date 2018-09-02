//
//  PlaceDetailDrawerController.swift
//  Locco
//
//  Created by macmini-stajyer-2 on 15.08.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import PullUpController

class PlaceDetailDrawerController: PullUpController {

    var viewModel: GeoPlacesViewModeling?
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.layer.cornerRadius = separatorView.frame.height/2
        }
    }
    @IBOutlet weak var pinIcon: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var placeDetailLabel: UILabel!
    @IBOutlet weak var peopleInPlaceCollection: UICollectionView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadData()
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
    
    @IBAction func dismiss(_ sender: Any) {
        let currentGeoPlace = viewModel!.geoPlaces[(viewModel?.activeGeoPlaceIndex)!] as MKAnnotation
        (parent as? GeoPlacesController)?.mapView.deselectAnnotation(((parent as? GeoPlacesController)?.mapView.annotations[((parent as? GeoPlacesController)!.mapView.annotations as NSArray).index(of: currentGeoPlace)])!, animated: true)
    }
    
    @IBAction func editPlace(_ sender: Any) {
        (parent as? GeoPlacesController)?.editPlaceDrawerPullUpController()
        
        let currentGeoPlace = self.viewModel!.geoPlaces[(self.viewModel?.activeGeoPlaceIndex)!] as MKAnnotation
        viewModel?.unmodifiedGeoPlace = (currentGeoPlace as! GeoPlace).copy() as? GeoPlace
        var centerCoordinate = currentGeoPlace.coordinate
        centerCoordinate.latitude -= ((self.parent as? GeoPlacesController)?.mapView.region.span.latitudeDelta)! * 0.35
        (self.parent as? GeoPlacesController)?.mapView.setCenter(centerCoordinate, animated: true)
    }
    
    func loadData() {
        pinIcon.image = pinIcon.image!.tintedWithLinearGradientColors(colorsArr: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].pinColor.colors)!)
        placeNameLabel.text = viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].title
        
        let myLocation = (self.parent as? GeoPlacesController)?.mapView.userLocation.location
        let placeCoordinates = CLLocation(latitude: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].coordinate.latitude)!, longitude: (viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].coordinate.longitude)!)
        let distance = myLocation!.distance(from: placeCoordinates)
        
        placeDetailLabel.text = "\(viewModel?.geoPlaces[(viewModel?.activeGeoPlaceIndex)!].placeDetail ?? "") ∙ \((distance/1000).rounded()) km"
        
        DispatchQueue.main.async {
            self.peopleInPlaceCollection.reloadData()
        }
    }
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 200)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return 185
    }
}

extension PlaceDetailDrawerController: UICollectionViewDelegate, UICollectionViewDataSource {
    // TODO: Get photos from firebase
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageView.image = UIImage(named: "bartu")
        cell.usernameLabel.text = "Username"
        cell.distanceLabel.text = "5.0 mi"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let selectedCell = collectionView.cellForItem(at: indexPath) as! PhotoCell
    }
}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
}

