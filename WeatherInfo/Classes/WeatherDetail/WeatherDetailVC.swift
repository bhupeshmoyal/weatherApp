//
//  WeatherDetailVC.swift
//  WeatherInfo
//
//  Created by Bhupesh on 21/11/17.
//  Copyright © 2017 Bhupesh. All rights reserved.
//

import Foundation
import UIKit

class WeatherDetailVC: UIViewController {
    
    @IBOutlet weak var imageView: UIView!
    @IBOutlet weak var imageWeatherType: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblMaxTemp: UILabel!
    @IBOutlet weak var lblMinTemp: UILabel!
    @IBOutlet weak var lblWindSpeed: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    @IBOutlet weak var lblHumidity: UILabel!
    @IBOutlet weak var lblVisibility: UILabel!
    @IBOutlet weak var lblTemprature: UILabel!
    
    
    var weatherObject: weatherInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            guard let weatherobject = weatherObject else{
        
                return
            }
        
            self.setImageForWeatherType(weatherobject: weatherobject)
        
            lblName.text = weatherobject.name
            lblTemprature.text = "\(weatherobject.temprature)\u{00B0}"
            lblMinTemp.text = "\(weatherobject.minTemprature)\u{00B0}"
            lblMaxTemp.text = "\(weatherobject.maxTemprature)\u{00B0}"
            lblWindSpeed.text = weatherobject.windSpeed + "Km/hr"
            lblHumidity.text = weatherobject.humidity
            lblDescription.text = weatherobject.weatherDescription
            lblVisibility.text = weatherobject.visibility
        
            imageView.rotate360Degrees()

     }
    
    func setImageForWeatherType(weatherobject:weatherInfo){
        
        var strImgWeatherType = ""
        
        if weatherobject.weatherType == "Clouds"{
            
            strImgWeatherType = "cloud"
            
        }else if (weatherobject.weatherType == "Rain") || (weatherobject.weatherType == "Drizzle") {
            
            strImgWeatherType = "rain"
            
        }else if weatherobject.weatherType == "Mist"{
            
            strImgWeatherType = "mist"
            
        }else if weatherobject.weatherType == "Haze"{
            
            strImgWeatherType = "haze"
            
        }else if weatherobject.weatherType == "Thunderstorm"{
            
            strImgWeatherType = "storm"
            
        }
        else {
            
            strImgWeatherType = "sun"
            
        }
        imageWeatherType.image = UIImage(named: strImgWeatherType)
    }
}

// extension for view animation
extension UIView {
    func rotate360Degrees(duration: CFTimeInterval = 1.5) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let radians = CGFloat.pi / 4
        rotateAnimation.fromValue = radians
        rotateAnimation.toValue = radians + .pi
        rotateAnimation.isRemovedOnCompletion = false
        rotateAnimation.duration = duration
        rotateAnimation.repeatCount = Float.infinity
        self.layer.add(rotateAnimation, forKey: nil)
    }
}
