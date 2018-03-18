//
//  ChangeCityViewController.swift
//  WeatherApp
//
//  Created by Gabriel Bryant on 03/06/2018.
//  Copyright (c) 2018 Phaeroh. All rights reserved.
//

import UIKit


protocol ChangeCityDelegate {
    func userEnteredANewCityName(city: String)
}

class ChangeCityViewController: UIViewController {
    
    var delegate: ChangeCityDelegate?
    
    @IBOutlet weak var changeCityTextField: UITextField!

    //This is the IBAction that gets called when the user taps on the "Get Weather" button:
    @IBAction func getWeatherPressed(_ sender: AnyObject) {
        if let cityName = changeCityTextField.text {
            self.delegate?.userEnteredANewCityName(city: cityName)
            self.performSegue(withIdentifier: "changeCityToWeather", sender: self)
        }
    }

    //This is the IBAction that gets called when the user taps the back button.
    @IBAction func backButtonPressed(_ sender: AnyObject) {
        self.performSegue(withIdentifier: "changeCityToWeather", sender: self)
    }
    
}
