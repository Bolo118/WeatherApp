//
//  ViewController.swift
//  WeatherApp
//
//  Created by Adithep on 7/29/20.
//  Copyright © 2020 Adithep. All rights reserved.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var backgroundImage: UIImageView!
    
    @IBOutlet weak var weatherConditionImage: UIImageView!
    @IBOutlet weak var weatherConditionLabel: UILabel!
    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var celciusTemp: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    
    var weatherManager = WeatherManager()
    
    // this object will be responsible for getting hold of the current GPS
    // location of the phone
    let locationManager = CLLocationManager()
    
    var timer = Timer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // you need to initial for delegate before others method for CLLocationManagerDelegate
        locationManager.delegate = self
        
        // before we can use the object, we need to ask for the permission from the user before
        // get their location because the user's location is a private piece of data
        // we also need to add new property in info.plist
        // (privacy - location when in use usage description) for the new property
        locationManager.requestWhenInUseAuthorization()
        
        // request one time of user's current location
        locationManager.requestLocation()
        // for gps app or some track gps app you may need this function instead
        // locationManager.startUpdatingLocation()
        
        searchTextField.delegate = self
        weatherManager.delegate = self
        
        let setImage = weatherManager.setBackground()
        backgroundImage.image = UIImage(named: setImage)
        
        getCurrentTime()
    }
    
    @IBAction func searchButtonPressed(_ sender: UIButton) {
        searchTextField.endEditing(true)
    }
    
    @IBAction func currentLocationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
    
    func getCurrentTime() {
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.currentTime), userInfo: nil, repeats: true)
    }
    
    @objc func currentTime() {
        timeLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        dateLabel.text = DateFormatter.localizedString(from: Date(), dateStyle: .medium, timeStyle: .none)
        
    }
}

//MARK: - UITextFieldDelegate
extension WeatherViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchTextField.endEditing(true)
        if searchTextField.text != "" {
            return true
        } else {
            searchTextField.placeholder = "Type Something"
            return false
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            weatherManager.fetchWeather(cityName: city)
        }
    }
}

//MARK: - WeatherManagerDelegate
extension WeatherViewController: WeatherManagerDelegate {
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        // we need a DispatchQueue.main.async here because long-running tasks
        // wait for session complete their task and send data through didUpdateWeather function
        // session task might be interrupted by something
        DispatchQueue.main.async {
            self.celciusTemp.text = weather.temperatureString
            self.weatherConditionImage.image = UIImage(systemName: weather.conditionName)
            self.weatherConditionLabel.text = weather.description
            self.cityName.text = weather.cityName
        }
    }
    
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate
extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
