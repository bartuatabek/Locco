//
//  GradientView.swift
//  Locco
//
//  Created by Bartu Atabek on 27.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

@IBDesignable class GradientView: UIView {
    @IBInspectable var topColor: UIColor = UIColor.white
    @IBInspectable var bottomColor: UIColor = UIColor.black
    
    override class var layerClass: AnyClass {
        return CAGradientLayer.self
    }
    
    override func layoutSubviews() {
        (layer as! CAGradientLayer).colors = [topColor.cgColor, bottomColor.cgColor]
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

@IBDesignable class RoundedView: UIView {
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
}

@IBDesignable
class ShadowView: UIView {
    //Shadow
    @IBInspectable var shadowColor: UIColor = UIColor.black {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowOpacity: Float = 0.5 {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowOffset: CGSize = CGSize(width: 3, height: 3) {
        didSet {
            self.updateView()
        }
    }
    @IBInspectable var shadowRadius: CGFloat = 15.0 {
        didSet {
            self.updateView()
        }
    }
    
    //Apply params
    func updateView() {
        self.layer.shadowColor = self.shadowColor.cgColor
        self.layer.shadowOpacity = self.shadowOpacity
        self.layer.shadowOffset = self.shadowOffset
        self.layer.shadowRadius = self.shadowRadius
    }
}
