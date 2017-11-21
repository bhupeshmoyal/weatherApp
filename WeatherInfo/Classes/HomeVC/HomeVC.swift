//
//  ViewController.swift
//  WeatherInfo
//
//  Created by Bhupesh on 21/11/17.
//  Copyright © 2017 Bhupesh. All rights reserved.
//

import UIKit
import CoreData

class HomeVC: UITableViewController {
    
    let arrayCityID = ["2147714","4163971","2174003"]
    var arrayWeatherData = [weatherInfo]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Weather information"

        self.callWebServiceToFetchWeatherInformation()

        // API call will execute in every 5 mins
        Timer.scheduledTimer(withTimeInterval: (60.0 * 5), repeats: true) { [weak self] (timer) in
            self?.callWebServiceToFetchWeatherInformation()
        }
        // set background image in View
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: "bg")!)
        self.tableView.tableFooterView = UIView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - table view delegate methods and data source methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayWeatherData.count;
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: HomeCustomCell = tableView.dequeueReusableCell(withIdentifier: "cell") as! HomeCustomCell
        
        cell.configureCell(data: arrayWeatherData[indexPath.row],withIndex: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let objWeatherDetailVC: WeatherDetailVC = self.storyboard!.instantiateViewController(withIdentifier: "WeatherDetailVC") as! WeatherDetailVC
        objWeatherDetailVC.weatherObject = arrayWeatherData[indexPath.row]
        self.navigationController?.pushViewController(objWeatherDetailVC, animated: true)
    }
    
    // MARK: - webservice call
    
    func callWebServiceToFetchWeatherInformation() {
        WeatherIndicator.shared.showProgressView(self.view)
        
        DispatchQueue.global(qos: .background).async {
            self.arrayCityID.forEach { (cityId) in
                let objweb: WebServiceHandler = WebServiceHandler()
                let strURL: String = "http://api.openweathermap.org/data/2.5/weather?id=\(cityId)&units=metric&APPID=57041bda9afe78da3403cc8e07badee5"
                
                objweb.callWebServiceWithPost(aStrURL: strURL, aView: nil, parameter: nil, accessToken: nil) { (weatherData) in
                    self.fillDataInArray(weatherData: weatherData)
                    WeatherIndicator.shared.hideProgressView()
                }
            }
        }
    }
    // function to fill the array
    func fillDataInArray(weatherData:[String:AnyObject]) {
        guard let weatherDetails = weatherData["weather"] as? [AnyObject] else {
            print("Could not get weather from JSON")
            return
        }
        
        guard let mainDetails = weatherData["main"] as? [String:AnyObject] else {
            print("Could not get main from JSON")
            return
        }
        
        guard let windDetails = weatherData["wind"] as? [String:AnyObject] else {
            print("Could not get main from JSON")
            return
        }
        
        let weatherDescripton = weatherDetails[0]["description"] as! String
        let weatherType = weatherDetails[0]["main"] as! String
        let humidity = String(describing: mainDetails["humidity"] as! NSNumber)
        let name = weatherData["name"] as! String
        let temprature = String(describing: mainDetails["temp"] as! NSNumber)
        let minTemprature = String(describing: mainDetails["temp_min"] as! NSNumber)
        let maxTemprature = String(describing: mainDetails["temp_max"] as! NSNumber)
        let visibility = String(describing: weatherData["visibility"] as! NSNumber)
        let windSpeed = String(describing: windDetails["speed"] as! Float)
        
        let data: weatherInfo = weatherInfo(name: name, temprature: temprature, minTemprature: minTemprature, maxTemprature: maxTemprature, weatherDescription: weatherDescripton, humidity: humidity, visibility: visibility, windSpeed: windSpeed, weatherType:weatherType)
        
        
        DispatchQueue.main.async {
            // Update the array based on existing temprature
            if let index = self.arrayWeatherData.index(where: { $0.name == data.name }) {
                self.arrayWeatherData[index] = data
            } else {
                self.arrayWeatherData.append(data)
            }
            
            self.tableView.reloadData()
            self.saveDataInDB()
        }
    }
    
    // MARK: - Insertation operation
    
    func saveDataInDB() {
        //resetAllRecords(in: "WeatherData")
        self.arrayWeatherData.forEach { (weatherData) in
            self.insertDataInDatabase(data: weatherData)
        }
    }
    
    func insertDataInDatabase(data:weatherInfo) {
        
        let name: String = String(describing: data.name)
        let temprature: String = String(describing:data.temprature)
        let minTemprature:String = String(describing: data.minTemprature)
        let maxTemprature:String = String(describing: data.maxTemprature)
        let weatherDescription:String = String(describing: data.weatherDescription)
        let humidity:String = String(describing: data.humidity)
        let visibility:String = String(describing: data.visibility)
        let windSpeed:String = String(describing: data.windSpeed)
        
        let context = AppDelegate.appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "WeatherData")
        fetchRequest.predicate = NSPredicate(format: "name = %@", data.name)
        
        var results: [NSManagedObject] = []
        do {
            results = try context.fetch(fetchRequest)
        } catch {
            print("error executing fetch request: \(error)")
        }
        
        if let aWeatherInfo = results.first {
            
            if let currentTemp = aWeatherInfo.value(forKey: "temprature") as? String {
                
                if currentTemp != temprature {
                    // update the data
                    aWeatherInfo.setValue(temprature, forKey: "temprature")
                    aWeatherInfo.setValue(minTemprature, forKey: "minTemprature")
                    aWeatherInfo.setValue(maxTemprature, forKey: "maxTemprature")
                    aWeatherInfo.setValue(weatherDescription, forKey: "weatherDescription")
                    aWeatherInfo.setValue(humidity, forKey: "humidity")
                    aWeatherInfo.setValue(visibility, forKey: "visibility")
                    aWeatherInfo.setValue(windSpeed, forKey: "windSpeed")
                    
                    do {
                        try context.save()
                        fetchDataFromDB() // fetch the inserted data here I have displayed name in log
                    } catch {
                        print("error in saving")
                    }
                }
            }
        } else {
            
            let saveWeatherData = NSEntityDescription.insertNewObject(forEntityName: "WeatherData", into: context)
            // insert the data
            saveWeatherData.setValue(name, forKey: "name")
            saveWeatherData.setValue(temprature, forKey: "temprature")
            saveWeatherData.setValue(minTemprature, forKey: "minTemprature")
            saveWeatherData.setValue(maxTemprature, forKey: "maxTemprature")
            saveWeatherData.setValue(weatherDescription, forKey: "weatherDescription")
            saveWeatherData.setValue(humidity, forKey: "humidity")
            saveWeatherData.setValue(visibility, forKey: "visibility")
            saveWeatherData.setValue(windSpeed, forKey: "windSpeed")
            
            do {
                try context.save()
                fetchDataFromDB() // fetch the inserted data here I have displayed name in log
            } catch {
                print("error in saving")
            }
        }
    }
    
    // function to fetch data from database
    func fetchDataFromDB() {
        
        let context = AppDelegate.appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult> (entityName: "WeatherData")
        request.returnsObjectsAsFaults = false
        
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "name") as? String {
                        print(name)
                    }
                }
            }
        } catch {
            print("no data found")
        }
    }
    
    func resetAllRecords(in entity: String) {
        
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try context.execute(deleteRequest)
            try context.save()
            print("All records deleted")
        } catch {
            print ("There was an error")
        }
    }
}

