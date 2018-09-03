//
//  InviteContactController.swift
//  Locco
//
//  Created by Bartu Atabek on 3.09.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import PullUpController

class InviteDrawerController: PullUpController {
    
    var viewModel: CirclesViewModeling?
    
    @IBOutlet weak var separatorView: UIView! {
        didSet {
            separatorView.layer.cornerRadius = separatorView.frame.height/2
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    
    @IBAction func inviteContact(_ sender: Any) {
        (parent as? CirclesController)?.performSegue(withIdentifier: "goToInviteContacts", sender: self)
    }
    
    // MARK: - PullUpController
    override var pullUpControllerPreferredSize: CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 200)
    }
    
    override var pullUpControllerPreviewOffset: CGFloat {
        return 185
    }
}


