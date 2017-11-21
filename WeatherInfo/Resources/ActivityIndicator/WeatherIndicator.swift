//
//  WeatherIndicator.swift
//  WeatherInfo
//
//  Created by Bhupesh on 21/11/17.
//  Copyright © 2017 Bhupesh. All rights reserved.
//

import Foundation
import UIKit

open class WeatherIndicator {
    
    var containerView = UIView()
    var progressView = UIView()
    var activityIndicator = UIActivityIndicatorView()
    
    open class var shared: WeatherIndicator {
        struct Static {
            static let instance: WeatherIndicator = WeatherIndicator()
        }
        return Static.instance
    }
    
    open func showProgressView(_ view: UIView) {
        
        DispatchQueue.main.async {
            self.containerView.frame = view.frame
            self.containerView.frame.origin.y = self.containerView.frame.origin.y - 44
            //self.containerView.center = view.center
            self.containerView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.3)
            
            self.progressView.frame = CGRect(x: 0, y:0, width: 80, height: 80)
            self.progressView.center = self.containerView.center
            self.progressView.backgroundColor = UIColor(hex: 0x444444, alpha: 0.7)
            self.progressView.clipsToBounds = true
            self.progressView.layer.cornerRadius = 10
            
            self.activityIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            self.activityIndicator.activityIndicatorViewStyle = .whiteLarge
            self.activityIndicator.center = CGPoint(x: self.progressView.bounds.width / 2, y: self.progressView.bounds.height / 2)
            
            self.progressView.addSubview(self.activityIndicator)
            self.containerView.addSubview(self.progressView)
            view.addSubview(self.containerView)
            
            self.activityIndicator.startAnimating()
        }
        
    }
    
    open func hideProgressView() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            self.containerView.removeFromSuperview()
        }
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
