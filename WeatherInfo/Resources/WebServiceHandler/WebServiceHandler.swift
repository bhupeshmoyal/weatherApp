//
//  WebServiceHandler.swift
//  WeatherInfo
//
//  Created by Bhupesh on 21/11/17.
//  Copyright © 2017 Bhupesh. All rights reserved.
//

import Foundation
import SystemConfiguration
import UIKit

class WebServiceHandler: NSObject {
    
    func callWebServiceWithPost(aStrURL:String,aView:UIView?,parameter:AnyObject?,accessToken:String?,CompletionHandler: @escaping (_ json:[String:AnyObject])-> Void){
        
        if self.isInternetAvailable() == false{
            
            AppDelegate.appDelegate.showAlertWithOkButton(strMessage:
                NSLocalizedString("Please check internet connection", comment: "Please check internet connection"))
            if aView != nil  {
                WeatherIndicator.shared.hideProgressView()
            }
            return
        }
        guard let url = URL(string: aStrURL) else {
            print("Error: cannot create URL")
            return
        }
        
        let urlRequest = URLRequest(url: url)
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            
            guard error == nil else {
                
                print(error.debugDescription)
                return
            }
            guard let responseData = data else {
                print("Error: did not receive data")
                return
            }
            do {
                guard let weatherData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: AnyObject] else {
                    print("error trying to convert data to JSON")
                    return
                }
                CompletionHandler(weatherData)
                               
            } catch  {
                print("error trying to convert data to JSON")
                return
            }
        }
        
        task.resume()
    }
    
    func isInternetAvailable() -> Bool
    {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        return (isReachable && !needsConnection)
    }
}
