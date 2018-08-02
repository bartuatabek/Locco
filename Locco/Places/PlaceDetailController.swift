//
//  PlaceDetailController.swift
//  Location Tracker
//
//  Created by macmini-stajyer-2 on 24.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import Foundation
import Pulley

class PlaceDetailController: UIViewController {
    
    var viewModel: GeoPlacesViewModeling?
    
    @IBOutlet var gripperView: UIView!
    @IBOutlet var topSeparatorView: UIView!
    @IBOutlet var bottomSeperatorView: UIView!
    @IBOutlet weak var CircleCollectionView: UICollectionView!
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var addressField: UITextView!
    
    
    @IBOutlet var gripperTopConstraint: NSLayoutConstraint!
    
    // We adjust our 'header' based on the bottom safe area using this constraint
    @IBOutlet var headerSectionHeightConstraint: NSLayoutConstraint!
    
    fileprivate var drawerBottomSafeArea: CGFloat = 0.0 {
        didSet {
            self.loadViewIfNeeded()
            
            // We'll configure our UI to respect the safe area. In our small demo app, we just want to adjust the contentInset for the tableview.
//            tableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: drawerBottomSafeArea, right: 0.0)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        gripperView.layer.cornerRadius = 2.5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        self.viewModel!.controller = self
        // You must wait until viewWillAppear -or- later in the view controller lifecycle in order to get a reference to Pulley via self.parent for customization.
        
        // UIFeedbackGenerator is only available iOS 10+. Since Pulley works back to iOS 9, the .feedbackGenerator property is "Any" and managed internally as a feedback generator.
        if #available(iOS 10.0, *) {
            let feedbackGenerator = UISelectionFeedbackGenerator()
            self.pulleyViewController?.feedbackGenerator = feedbackGenerator
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // The bounce here is optional, but it's done automatically after appearance as a demonstration.
        //        Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(bounceDrawer), userInfo: nil, repeats: false)
    }
    
    @IBAction func dismissDetailSheet(_ sender: UIButton) {
        let primaryContent = UIStoryboard(name: "Places", bundle: nil).instantiateViewController(withIdentifier: "PlacesDrawerController")
        
        pulleyViewController?.setDrawerPosition(position: .partiallyRevealed, animated: false)
        pulleyViewController?.setDrawerContentViewController(controller: primaryContent, animated: false)
    }
    
    @IBAction func share(_ sender: UIButton) {
        // Create a custom view for testing...
        let customView = CircleCollectionView
        customView!.translatesAutoresizingMaskIntoConstraints = false
        
        // Set the custom view to a fixed height. In a real world application, you could use autolayouted content for height constraints
        customView!.addConstraint(NSLayoutConstraint(item: customView!,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: 100))
        
        // Create the alert and show it
        let alert = UIAlertController(title: "Tap to share with your circles",
                                      customView: customView!,
                                      fallbackMessage: "This should display all circles",
                                      preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension UIAlertController {
    
    /// Creates a `UIAlertController` with a custom `UIView` instead the message text.
    /// - Note: In case anything goes wrong during replacing the message string with the custom view, a fallback message will
    /// be used as normal message string.
    ///
    /// - Parameters:
    ///   - title: The title text of the alert controller
    ///   - customView: A `UIView` which will be displayed in place of the message string.
    ///   - fallbackMessage: An optional fallback message string, which will be displayed in case something went wrong with inserting the custom view.
    ///   - preferredStyle: The preferred style of the `UIAlertController`.
    convenience init(title: String?, customView: UIView, fallbackMessage: String?, preferredStyle: UIAlertController.Style) {
        
        let marker = "__CUSTOM_CONTENT_MARKER__"
        self.init(title: title, message: marker, preferredStyle: preferredStyle)
        
        // Try to find the message label in the alert controller's view hierarchie
        if let customContentPlaceholder = self.view.findLabel(withText: marker),
            let customContainer =  customContentPlaceholder.superview {
            
            // The message label was found. Add the custom view over it and fix the autolayout...
            customContainer.addSubview(customView)
            
            customView.translatesAutoresizingMaskIntoConstraints = false
            customContainer.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[customView]-|", options: [], metrics: nil, views: ["customView": customView]))
            customContainer.addConstraint(NSLayoutConstraint(item: customContentPlaceholder,
                                                             attribute: .top,
                                                             relatedBy: .equal,
                                                             toItem: customView,
                                                             attribute: .top,
                                                             multiplier: 1,
                                                             constant: 0))
            customContainer.addConstraint(NSLayoutConstraint(item: customContentPlaceholder,
                                                             attribute: .height,
                                                             relatedBy: .equal,
                                                             toItem: customView,
                                                             attribute: .height,
                                                             multiplier: 1,
                                                             constant: 0))
            customContentPlaceholder.text = ""
        } else { // In case something fishy is going on, fall back to the standard behaviour and display a fallback message string
            self.message = fallbackMessage
        }
    }
}

private extension UIView {
    
    /// Searches a `UILabel` with the given text in the view's subviews hierarchy.
    ///
    /// - Parameter text: The label text to search
    /// - Returns: A `UILabel` in the view's subview hierarchy, containing the searched text or `nil` if no `UILabel` was found.
    func findLabel(withText text: String) -> UILabel? {
        if let label = self as? UILabel, label.text == text {
            return label
        }
        
        for subview in self.subviews {
            if let found = subview.findLabel(withText: text) {
                return found
            }
        }
        
        return nil
    }
}


extension PlaceDetailController: PulleyDrawerViewControllerDelegate {
    
    func collapsedDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 68.0 + bottomSafeArea
    }
    
    func partialRevealDrawerHeight(bottomSafeArea: CGFloat) -> CGFloat
    {
        // For devices with a bottom safe area, we want to make our drawer taller. Your implementation may not want to do that. In that case, disregard the bottomSafeArea value.
        return 264.0 + bottomSafeArea
    }
    
    func supportedDrawerPositions() -> [PulleyPosition] {
        return PulleyPosition.all // You can specify the drawer positions you support. This is the same as: [.open, .partiallyRevealed, .collapsed, .closed]
    }
    
    // This function is called by Pulley anytime the size, drawer position, etc. changes. It's best to customize your VC UI based on the bottomSafeArea here (if needed). Note: You might also find the `pulleySafeAreaInsets` property on Pulley useful to get Pulley's current safe area insets in a backwards compatible (with iOS < 11) way. If you need this information for use in your layout, you can also access it directly by using `drawerDistanceFromBottom` at any time.
    func drawerPositionDidChange(drawer: PulleyViewController, bottomSafeArea: CGFloat)
    {
        // We want to know about the safe area to customize our UI. Our UI customization logic is in the didSet for this variable.
        drawerBottomSafeArea = bottomSafeArea
        
        /*
         Some explanation for what is happening here:
         1. Our drawer UI needs some customization to look 'correct' on devices like the iPhone X, with a bottom safe area inset.
         2. We only need this when it's in the 'collapsed' position, so we'll add some safe area when it's collapsed and remove it when it's not.
         3. These changes are captured in an animation block (when necessary) by Pulley, so these changes will be animated along-side the drawer automatically.
         */
        if drawer.drawerPosition == .collapsed
        {
            headerSectionHeightConstraint.constant = 68.0 + drawerBottomSafeArea
        }
        else
        {
            headerSectionHeightConstraint.constant = 68.0
        }
        
        if drawer.currentDisplayMode == .leftSide
        {
            topSeparatorView.isHidden = drawer.drawerPosition == .collapsed
            bottomSeperatorView.isHidden = drawer.drawerPosition == .collapsed
        }
        else
        {
            topSeparatorView.isHidden = false
            bottomSeperatorView.isHidden = true
        }
    }
    
    /// This function is called when the current drawer display mode changes. Make UI customizations here.
    func drawerDisplayModeDidChange(drawer: PulleyViewController) {
        
        print("Drawer: \(drawer.currentDisplayMode)")
        gripperTopConstraint.isActive = drawer.currentDisplayMode == .bottomDrawer
    }
}
