//
//  ViewController.swift
//  WeatherApp
//
//  Created by Gabriel Bryant on 03/06/2018.
//  Copyright (c) 2018 Phaeroh. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire
import SwiftyJSON

enum TempType {
    case Fahrenheit
    case Celsius
    case Kelvin
    case Rankine
    
    mutating func next() {
        switch self {
        case .Fahrenheit:
            self = .Celsius
        case .Celsius:
            self = .Kelvin
        case .Kelvin:
            self = .Rankine
        case .Rankine:
            self = .Fahrenheit
        }
    }
    
    var letter: String {
        switch self {
        case .Fahrenheit:
            return "F"
        case .Celsius:
            return "C"
        case .Kelvin:
            return "K"
        case .Rankine:
            return "R"
        }
    }
}

class WeatherViewController: UIViewController, CLLocationManagerDelegate, ChangeCityDelegate {
    
    //Constants
    let WEATHER_URL = "http://api.openweathermap.org/data/2.5/weather"
    let APP_ID = "e72ca729af228beabd5d20e3b7749713"
    

    //Variables
    let locationManager = CLLocationManager()
    var weatherDataModel = WeatherDataModel()
    var temperatureType: TempType = .Fahrenheit

    
    //Pre-linked IBOutlets
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
        //fancy tap gesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(WeatherViewController.tappedOnTemp))
        temperatureLabel.addGestureRecognizer(tap)
    }
    
    
    //MARK: - Networking
    /***************************************************************/
    
    func getWeatherData(url: String, parameters: [String: String]) {
        Alamofire.request(url, method: .get, parameters: parameters).responseJSON {
            response in
            if response.result.isSuccess {
                print("Success! We got the weather data!")
                let weatherJSON : JSON = JSON(response.result.value!)
                self.updateWeatherData(json: weatherJSON)
            } else {
                print("\(String(describing: response.result.error))")
                self.cityLabel.text = "Connection Issues"
            }
        }
    }
    
    //MARK: - JSON Parsing
    /***************************************************************/
   
    func updateWeatherData(json : JSON) {
        if let temperature = json["main"]["temp"].double { //dang swiftyJSON, you convenient!
            //convert Kelvin to Fahrenheit, then round
            self.weatherDataModel.temperature = temperature
            weatherDataModel.city = json["name"].stringValue
            let condition = json["weather"][0]["id"].intValue
            weatherDataModel.condition = condition
            weatherDataModel.weatherIconName = weatherDataModel.updateWeatherIcon(condition: condition)

            self.updateUIWithWeatherData()
        } else {
            self.cityLabel.text = "Weather Unavailable"
        }
    }

    
    //MARK: - UI Updates
    /***************************************************************/
    
    func updateUIWithWeatherData() {
        cityLabel.text = weatherDataModel.city
        temperatureLabel.text = "\(self.getTempFromKelvin(temp: weatherDataModel.temperature))°\(temperatureType.letter)"
        weatherIcon.image = UIImage(named: weatherDataModel.weatherIconName)
    }
    
    func getTempFromKelvin(temp: Double) -> Int {
        switch temperatureType {
        case .Fahrenheit:
            return Int(1.8*(temp - 273.15) + 32.0)
        case .Celsius:
            return Int(temp - 273.15)
        case .Kelvin:
            return Int(temp)
        case .Rankine:
            return Int(1.8*temp)
        }
    }
    
    @objc func tappedOnTemp() {
        self.temperatureType.next()
        updateUIWithWeatherData()
    }
    
    @IBAction func locateMePressed(_ sender: Any) {
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    //MARK: - Location Manager Delegate Methods
    /***************************************************************/
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            if location.horizontalAccuracy > 0 {
                locationManager.stopUpdatingLocation() //save the battery, we found you
                locationManager.delegate = nil //kill it to prevent async events
                
                print("longitude =  \(location.coordinate.longitude) and latitude = \(location.coordinate.latitude)")
                
                let latitude = location.coordinate.latitude
                let longitude = location.coordinate.longitude
                
                let params : [String : String] = [
                    "lat" : "\(latitude)",
                    "lon" : "\(longitude)",
                    "appid" : APP_ID
                ]
                
                getWeatherData(url: WEATHER_URL, parameters: params)
                
            }
        }

    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        cityLabel.text = "Location Unavailable"
    }
    
    //MARK: - Change City Delegate and Segue Methods
    /***************************************************************/
    
    func userEnteredANewCityName(city: String) {
        let params : [String : String] = ["q" : city, "appid" : APP_ID]
        getWeatherData(url: WEATHER_URL, parameters: params)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "changeCityName" {
            let destinationVC = segue.destination as! ChangeCityViewController
            destinationVC.delegate = self
        }
    }
    
    override func unwind(for unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        let segue = UnwindSlideSegue(identifier: unwindSegue.identifier, source: unwindSegue.source, destination: unwindSegue.destination)
        segue.perform()
    }
    
    @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
        //Any work that needs to be done before unwinding?
    }
    
    
    
    
}


