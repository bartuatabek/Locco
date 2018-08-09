//
//  RoundedImage.swift
//  Locco
//
//  Created by macmini-stajyer-2 on 9.08.2018.
//  Copyright © 2018 Bartu Atabek. All rights reserved.
//

import UIKit

@IBDesignable
class RoundedImage: UIImageView {
    @IBInspectable var isRounded: Bool = false {
        didSet {
            if isRounded { setRounded() }
        }
    }
    
    func setRounded() {
        let radius = self.frame.size.width / 2
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
