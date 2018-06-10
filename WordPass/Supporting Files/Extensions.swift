//
//  Extensions.swift
//  WordPass
//
//  Created by Apple on 05/04/2018.
//  Copyright © 2018 WordPass. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return topViewController
    }
}

extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
}

extension Int {
    var randomNumber: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        }
        if self < 0 {
            return Int(arc4random_uniform(UInt32(abs(self))))
        }
        else {
            return 0
        }
    }
}

extension Notification.Name {
    static let WPPlayAudio = Notification.Name("WPPlayAudioNotification")
}
