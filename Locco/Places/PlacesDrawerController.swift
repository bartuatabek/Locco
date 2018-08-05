//
//  SearchViewController.swift
//  PullUpControllerDemo
//
//  Created by Mario on 03/11/2017.
//  Copyright © 2017 Mario. All rights reserved.
//

import UIKit
import MapKit
import PullUpController

class PlacesDrawerController: PullUpController {
    
    // MARK: - IBOutlets
    @IBOutlet private weak var visualEffectView: UIVisualEffectView!
    @IBOutlet private weak var searchBoxContainerView: UIView!
    @IBOutlet private weak var searchSeparatorView: UIView! {
        didSet {
            searchSeparatorView.layer.cornerRadius = searchSeparatorView.frame.height/2
        }
    }
    @IBOutlet private weak var firstPreviewView: UIView!
    @IBOutlet private weak var secondPreviewView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    
    private var locations = [(title: String, location: CLLocationCoordinate2D)]()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.attach(to: self)
        setupDataSource()
//        willMoveToStickyPoint = { point in
//            print("willMoveToStickyPoint \(point)")
//        }
        
        didMoveToStickyPoint = { point in
            print("didMoveToStickyPoint \(point)")
        }
        
//        onDrag = { point in
//            print("onDrag: \(point)")
//        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.layer.cornerRadius = 16
    }
    
    private func setupDataSource() {
        locations.append(("Rome", CLLocationCoordinate2D(latitude: 41.9004041, longitude: 12.4432921)))
        locations.append(("Milan", CLLocationCoordinate2D(latitude: 45.4625319, longitude: 9.1574741)))
        locations.append(("Turin", CLLocationCoordinate2D(latitude: 45.0705805, longitude: 7.6593106)))
        locations.append(("London", CLLocationCoordinate2D(latitude: 51.5287718, longitude: -0.2416817)))
        locations.append(("Paris", CLLocationCoordinate2D(latitude: 48.8589507, longitude: 2.2770201)))
        locations.append(("Amsterdam", CLLocationCoordinate2D(latitude: 52.354775, longitude: 4.7585401)))
        locations.append(("Dublin", CLLocationCoordinate2D(latitude: 53.3244431, longitude: -6.3857869)))
        locations.append(("Reykjavik", CLLocationCoordinate2D(latitude: 64.1335484, longitude: -21.9224815)))
    }
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: secondPreviewView.frame.maxY)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return searchBoxContainerView.frame.height + 175
    }
    
    override var pullUpControllerMiddleStickyPoints: [CGFloat] {
        return [firstPreviewView.frame.maxY]
    }
    
    override var pullUpControllerIsBouncingEnabled: Bool {
        return true
    }
}

// MARK: - UISearchBarDelegate
extension PlacesDrawerController: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if let lastStickyPoint = pullUpControllerAllStickyPoints.last {
            pullUpControllerMoveToVisiblePoint(lastStickyPoint, animated: true, completion: nil)
        }
        searchBar.showsCancelButton = true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
}

extension PlacesDrawerController: UITableViewDataSource, UITableViewDelegate {
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard
            let cell = tableView.dequeueReusableCell(withIdentifier: "PlaceCell", for: indexPath) as? PlaceCell
            else {return UITableViewCell()}
        
        cell.configure(pinColor: "Blue", title: locations[indexPath.row].title, subtitle: "About my places..")
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        view.endEditing(true)
        pullUpControllerMoveToVisiblePoint(pullUpControllerMiddleStickyPoints[0], animated: true, completion: nil)
        
        (parent as? GeoPlacesController)?.zoom(to: locations[indexPath.row].location)
    }
}

// MARK: - PlaceCell
class PlaceCell: UITableViewCell {
    @IBOutlet weak var pinImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    func configure(pinColor: String, title: String, subtitle: String) {
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}

extension PlaceCell: UICollectionViewDataSource {
    // TODO: Get photos from firebase
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 12
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCell
        cell.imageView.layer.cornerRadius = 8.0
        cell.imageView.clipsToBounds = true
        return cell
    }
    
}

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
}
