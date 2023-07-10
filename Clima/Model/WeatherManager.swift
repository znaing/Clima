//
//  WeatherManager.swift
//  Clima
//
//  Created by Zaid Naing on 1/17/23.
//  Copyright © 2023 App Brewery. All rights reserved.
//

import Foundation
import CoreLocation

protocol WeatherManagerDelegate{
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager{
    
    // Obtain API key from OpenWeatherMap
    // Replace *apiKey* with the API key
    // Run the App
    
    let weatherURL = "https://api.openweathermap.org/data/2.5/weather?appid=  *apiKey*    &units=metric"
    
    var delegate: WeatherManagerDelegate?
    
    func fetchWeather(cityName : String){
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    func fetchWeather(lat: CLLocationDegrees,lon: CLLocationDegrees){
        let urlString = "\(weatherURL)&lat=\(lat)&lon=\(lon)"
        performRequest(with: urlString)
    }
    
    //Networking
    func performRequest(with urlString : String){
        //Create URL ]
        if let url = URL(string: urlString){
            //Create a URL Session
            let session = URLSession(configuration: .default)
            //Give the session a task
            let task = session.dataTask(with: url) { (data, response , error) in
                if error != nil{
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                if let safeData = data {
                    if let weather = self.parseJSON(safeData){
                        self.delegate?.didUpdateWeather(self, weather : weather)
                    }
                }
            }
            //Start the task
            task.resume()
        }
    }
    func parseJSON(_ weatherData : Data)-> WeatherModel?{
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            print(decodedData.name)
            //print(decodedData.main.temp)
            print(decodedData.weather[0].description)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            print(weather.conditionName)
            print(weather.conditionId)
            //print(weather.temperatureString)

            return weather
            
        }catch{
            print(error)
            
            return nil
        }
    }
    
}
