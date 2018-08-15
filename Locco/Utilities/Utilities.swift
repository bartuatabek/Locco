//
//  Utilities.swift
//  Locco
//
//  Created by Bartu Atabek on 19.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit
import MapKit

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
    
    func addShadowWithBorders() {
        // add the shadow to the base view
        self.backgroundColor = UIColor.clear
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.layer.shadowOpacity = 0.35
        self.layer.shadowRadius = 1.0
        
        self.layer.shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: 10).cgPath
        self.layer.shouldRasterize = true
        self.layer.rasterizationScale = UIScreen.main.scale
        
        // add the border to subview
        let borderView = UIView()
        borderView.frame = self.bounds
        borderView.layer.cornerRadius = 4
        borderView.layer.borderColor = UIColor.white.cgColor
        borderView.layer.borderWidth = 1.0
        borderView.layer.masksToBounds = true
        self.addSubview(borderView)
    }
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }
    
    func addTopBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addRightBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: self.frame.size.width - width, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
    
    func addBottomBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: self.frame.size.height - width, width: self.frame.size.width, height: width)
        self.layer.addSublayer(border)
    }
    
    func addLeftBorderWithColor(color: UIColor, width: CGFloat) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.size.height)
        self.layer.addSublayer(border)
    }
}

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
    
    func showAlert(withTitle title: String?, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
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

// MARK: Geo Extensions
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

// MARK: - UIImage Extensions
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

// MARK: - Gradient Pin Colors
internal enum PinColors: String {
    case color1, color2, color3, color4, color5, color6, color7, color8, color9, color10
    
    var colors: [CGColor] {
        switch self {
        case .color1:
            return [UIColor(red: 0/255, green: 181/255, blue: 196/255, alpha: 1.0).cgColor, UIColor(red: 0/255, green: 181/255, blue: 196/255, alpha: 1.0).cgColor]
        case .color2:
            return [UIColor(red: 45/255, green: 52/255, blue: 64/255, alpha: 1.0).cgColor, UIColor(red: 41/255, green: 77/255, blue: 121/255, alpha: 1.0).cgColor]
        case .color3:
            return [UIColor(red: 222/255, green: 71/255, blue: 4/255, alpha: 1.0).cgColor, UIColor(red: 255/255, green: 203/255, blue: 131/255, alpha: 1.0).cgColor]
        case .color4:
            return [UIColor(red: 199/255, green: 0/255, blue: 38/255, alpha: 1.0).cgColor, UIColor(red: 255/255, green: 45/255, blue: 85/255, alpha: 1.0).cgColor]
        case .color5:
            return [UIColor(red: 208/255, green: 162/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 255/255, green: 165/255, blue: 165/255, alpha: 1.0).cgColor]
        case .color6:
            return [UIColor(red: 35/255, green: 31/255, blue: 244/255, alpha: 1.0).cgColor, UIColor(red: 88/255, green: 86/255, blue: 214/255, alpha: 1.0).cgColor]
        case .color7:
            return [UIColor(red: 0/255, green: 145/255, blue: 211/255, alpha: 1.0).cgColor, UIColor(red: 90/255, green: 200/255, blue: 250/255, alpha: 1.0).cgColor]
        case .color8:
            return [UIColor(red: 159/255, green: 37/255, blue: 30/255, alpha: 1.0).cgColor, UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0).cgColor]
        case .color9:
            return [UIColor(red: 0/255, green: 195/255, blue: 33/255, alpha: 1.0).cgColor, UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0).cgColor]
        case .color10:
            return [UIColor(red: 0/255, green: 180/255, blue: 255/255, alpha: 1.0).cgColor, UIColor(red: 54/255, green: 216/255, blue: 207/255, alpha: 1.0).cgColor]
        }
    }
}

// MARK: - UITableView Extension
extension UITableView {
    func reloadWithAnimation() {
        self.reloadData()
        let tableViewHeight = self.bounds.size.height
        let cells = self.visibleCells
        var delayCounter = 0
        for cell in cells {
            cell.transform = CGAffineTransform(translationX: 0, y: tableViewHeight)
        }
        for cell in cells {
            UIView.animate(withDuration: 1.6, delay: 0.08 * Double(delayCounter),usingSpringWithDamping: 0.6, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
                cell.transform = CGAffineTransform.identity
            }, completion: nil)
            delayCounter += 1
        }
    }
}

// MARK: - Device Model Recognizer
extension UIDevice {
    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPhone5,1", "iPhone5,2":                  return "iPhone SE"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone SE"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone SE"
            case "iPhone7,2":                               return "iPhone 8"
            case "iPhone7,1":                               return "iPhone 8 Plus"
            case "iPhone8,1":                               return "iPhone 8"
            case "iPhone8,2":                               return "iPhone 8 Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 8"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 8 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "i386", "x86_64":                          return "\(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #endif
        }
        return mapToDevice(identifier: identifier)
    }()
}
