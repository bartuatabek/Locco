//
//  RoundedButton.swift
//  Locco
//
//  Created by Bartu Atabek on 23.07.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedButton: UIButton {
    override func layoutSubviews() {
        super.layoutSubviews()
        updateCornerRadius()
    }
    
    @IBInspectable var rounded: CGFloat = 0 {
        didSet {
          updateCornerRadius()
        }
    }
    
    func updateCornerRadius() {
        layer.cornerRadius = rounded
    }
    
    let gradientLayer = CAGradientLayer()
    
    @IBInspectable
    var topGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    @IBInspectable
    var bottomGradientColor: UIColor? {
        didSet {
            setGradient(topGradientColor: topGradientColor, bottomGradientColor: bottomGradientColor)
        }
    }
    
    @IBInspectable
    var enableTimeOutBuffer: Bool = false {
        didSet {
            if enableTimeOutBuffer {
                self.addTarget(self, action: #selector(self.bufferAction), for:.touchUpInside)
            }
        }
    }
    
    private func setGradient(topGradientColor: UIColor?, bottomGradientColor: UIColor?) {
        if let topGradientColor = topGradientColor, let bottomGradientColor = bottomGradientColor {
            gradientLayer.frame = bounds
            gradientLayer.colors = [topGradientColor.cgColor, bottomGradientColor.cgColor]
            gradientLayer.borderColor = layer.borderColor
            gradientLayer.borderWidth = layer.borderWidth
            gradientLayer.cornerRadius = layer.cornerRadius
            gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            layer.insertSublayer(gradientLayer, at: 0)
        } else {
            gradientLayer.removeFromSuperlayer()
        }
    }
    
    @objc func bufferAction() {
        self.isEnabled = false
        Timer.scheduledTimer(timeInterval: 10, target: self, selector:  #selector(self.enableButton), userInfo: nil, repeats: false)
    }
    
    @objc private func enableButton() {
        self.isEnabled = true
    }
}
