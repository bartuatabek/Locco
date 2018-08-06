//
//  AddGeoPlaceController.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 19.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import Firebase
import Alamofire
import PullUpController

class AddGeoPlaceController: PullUpController, UIGestureRecognizerDelegate {
    
    var viewModel: GeoPlacesViewModeling?
    
    // MARK: - IBOutlets
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.layer.cornerRadius = separatorView.frame.height/2
        }
    }
    @IBOutlet weak var titleLabel: UITextField!
    @IBOutlet weak var subtitleLabel: UIView!
    @IBOutlet var pinColors: [GradientView]!
    
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
        view.layer.cornerRadius = 16
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
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 300)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return 264
    }
    
    override var pullUpControllerIsBouncingEnabled: Bool {
        return false
    }
}
