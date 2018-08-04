//
//  Utilities.swift
//  Location Tracker
//
//  Created by Bartu Atabek on 19.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit

// MARK: ViewController Extensions
extension UIViewController {
    func customizeStatusBar() {
        // Add blur effect on status bar
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.extraLight)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(blurEffectView)
        blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        blurEffectView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        blurEffectView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        if #available(iOS 11.0, *) {
            blurEffectView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        }
    }
}

// MARK: MapView Extensions
extension MKMapView {
    func zoomToUserLocation() {
        guard let coordinate = userLocation.location?.coordinate else { return }
        let region = MKCoordinateRegion.init(center: coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        setRegion(region, animated: true)
    }
}

// MARK: UIView Extensions
extension UIView {
    func fadeIn(_ duration: TimeInterval = 0.25, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)  }
    
    func fadeOut(_ duration: TimeInterval = 0.25, delay: TimeInterval = 0.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}

// MARK: Geo Extensions
extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
}

extension GeoPlacesViewModel {
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        controller?.present(alert, animated: true, completion: nil)
    }
}

// MARK: - Random Generator
extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}

// MARK: UIImage Extensions
extension UIImage {
    func colorized(color : UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        if let context = UIGraphicsGetCurrentContext() {
            context.setBlendMode(.multiply)
            context.translateBy(x: 0, y: self.size.height)
            context.scaleBy(x: 1.0, y: -1.0)
            context.draw(self.cgImage!, in: rect)
            context.clip(to: rect, mask: self.cgImage!)
            context.setFillColor(color.cgColor)
            context.fill(rect)
        }
        
        let colorizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        return colorizedImage!
    }
    
    func tintedWithLinearGradientColors(colorsArr: [CGColor]) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        guard let context = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        context.translateBy(x: 0, y: self.size.height)
        context.scaleBy(x: 1, y: -1)
        
        context.setBlendMode(.normal)
        let rect = CGRect.init(x: 0, y: 0, width: size.width, height: size.height)
        
        // Create gradient
        let colors = colorsArr as CFArray
        let space = CGColorSpaceCreateDeviceRGB()
        let gradient = CGGradient(colorsSpace: space, colors: colors, locations: nil)
        
        // Apply gradient
        context.clip(to: rect, mask: self.cgImage!)
        context.drawLinearGradient(gradient!, start: CGPoint(x: 0, y: 0), end: CGPoint(x: 0, y: self.size.height), options: .drawsAfterEndLocation)
        let gradientImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return gradientImage!
    }
}
