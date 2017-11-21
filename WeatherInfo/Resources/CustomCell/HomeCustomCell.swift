//
//  HomeCustomCell.swift
//  WeatherInfo
//
//  Created by Bhupesh on 21/11/17.
//  Copyright © 2017 Bhupesh. All rights reserved.
//

import Foundation
import UIKit


class HomeCustomCell: UITableViewCell{
    
    @IBOutlet weak var imageBG: UIImageView!
    @IBOutlet weak var lblCityName: UILabel!
    @IBOutlet weak var lblTemprature: UILabel!

    func configureCell(data:weatherInfo, withIndex index:IndexPath) {
        lblCityName.text = data.name
        lblTemprature.text = "\(data.temprature)\u{00B0}"
        imageBG.image = UIImage(named: "image-\(index.row+1)")
        
    }
}
