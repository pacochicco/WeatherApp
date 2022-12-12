//
//  ViewController.swift
//  WeatherApp
//
//  Created by Saidac Alexandru on 28.11.2022.
//

import UIKit
import SDWebImage
import CoreLocation
import MapKit



enum GetWeatherMethod{
    case jsonSerializationCompletionHandler, codableAsyncAwait
}

class ViewController: UIViewController {
    var dataFetchMethod: GetWeatherMethod = .codableAsyncAwait
    let locationManager = CLLocationManager()
    
    lazy var weatherIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var temperatureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34, weight: .light)
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var humidityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 34, weight: .light)
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var temperatureTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor.white
        label.text = "Temperature"
        return label
    }()
    
    lazy var humidityTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        label.textColor = UIColor.white
        label.text = "Humidity"
        return label
    }()
    
    lazy var temperatureContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var humidityContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    lazy var locationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.red
        button.setTitle("Location", for: .normal)
        button.addTarget(self, action: #selector(getLocationButtonTapped), for: .touchUpInside)
        return button
    }()
    
    lazy var map: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.backgroundColor = UIColor.clear
        return map
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        authorize()
        setUp()
        style()
        temperatureLabel.text = "--"
        descriptionLabel.text = "--"
        humidityTitleLabel.text = "Humidity"
        humidityLabel.text = "--"
        weatherIcon.image = UIImage(systemName: "cloud")
        
    }
    
    func getInfo(lat:String , long: String){
        switch dataFetchMethod {
        case .jsonSerializationCompletionHandler:
            APIClient.shared.getWeather(lat: lat, long: long) {[weak self] weatherData in
                guard let strongSelf = self else{
                    return
                }
                guard let weatherData = weatherData else{
                    return
                }
               print("\(weatherData)")
                if let data = weatherData["main"] as? [String: Any]{
                        let temp = data["temp"] as! Double
                    DispatchQueue.main.async {
                        strongSelf.temperatureLabel.text = "\(temp) C°"
                    }
                    let humidity = data["humidity"] as! Double
                    DispatchQueue.main.async {
                        strongSelf.humidityLabel.text = "\(humidity)"
                    }
                }
                if let weatherArray = weatherData["weather"] as? [[String:Any]],
                   let weather = weatherArray.first {
                    guard let description = weather["description"] as? String,
                        let icon = weather["icon"] as? String else{
                        return
                    }
                    DispatchQueue.main.async{
                        strongSelf.descriptionLabel.text = description.capitalizingFirstLetter()
                    }
                    var imageUrl = APIClient.shared.getIconUrl(icon: icon)
                    strongSelf.weatherIcon.sd_setImage(with: imageUrl)
                }
            }
        case .codableAsyncAwait:
            Task{
                do{
                    let data = try await APIClient.shared.getWeatherWithCodable(lat: lat, long: long)
                    self.temperatureLabel.text = String(data.main.temp)
                    self.humidityLabel.text = String(data.main.humidity)
                    self.descriptionLabel.text = data.weather[0].description
                    var imageUrl = APIClient.shared.getIconUrl(icon: data.weather[0].icon)
                    self.weatherIcon.sd_setImage(with: imageUrl)
                }catch {
                    print("\(error.localizedDescription)")
                }
                
            }
        }
       
    }
    
    func style(){
        view.backgroundColor = UIColor.orange
    }
    
    func setUp(){
        [weatherIcon,descriptionLabel,temperatureContainerView,humidityContainerView, locationButton, map].forEach {
            subView in view.addSubview(subView)
        }
        
        temperatureContainerView.addSubview(temperatureLabel)
        temperatureContainerView.addSubview(temperatureTitleLabel)
        humidityContainerView.addSubview(humidityLabel)
        humidityContainerView.addSubview(humidityTitleLabel)
        
        NSLayoutConstraint.activate([
        weatherIcon.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
        weatherIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        weatherIcon.heightAnchor.constraint(equalToConstant:45),
        weatherIcon.widthAnchor.constraint(equalToConstant: 45),
        
        descriptionLabel.topAnchor.constraint(equalTo: weatherIcon.bottomAnchor, constant: 20),
        descriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        
        temperatureContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
        temperatureContainerView.widthAnchor.constraint(equalToConstant: view.frame.width/2 - 20),
        temperatureContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
        
        temperatureLabel.topAnchor.constraint(equalTo: temperatureContainerView.topAnchor, constant: 15),
        temperatureLabel.centerXAnchor.constraint(equalTo: temperatureContainerView.centerXAnchor),
        temperatureTitleLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 15),
        temperatureTitleLabel.bottomAnchor.constraint(equalTo: temperatureContainerView.bottomAnchor, constant: 0),
        temperatureTitleLabel.centerXAnchor.constraint(equalTo: temperatureContainerView.centerXAnchor),
        
        humidityContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        humidityContainerView.widthAnchor.constraint(equalToConstant: view.frame.width/2 - 20),
        humidityContainerView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 30),
        
        humidityLabel.topAnchor.constraint(equalTo: humidityContainerView.topAnchor, constant: 15),
        humidityLabel.centerXAnchor.constraint(equalTo: humidityContainerView.centerXAnchor),
        humidityTitleLabel.topAnchor.constraint(equalTo: humidityLabel.bottomAnchor, constant: 15),
        humidityTitleLabel.bottomAnchor.constraint(equalTo: humidityContainerView.bottomAnchor, constant: 0),
        humidityTitleLabel.centerXAnchor.constraint(equalTo: humidityContainerView.centerXAnchor),
        
        locationButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        locationButton.heightAnchor.constraint(equalToConstant: 45),
        locationButton.widthAnchor.constraint(equalToConstant: 100),
        locationButton.topAnchor.constraint(equalTo: humidityTitleLabel.bottomAnchor, constant: 30),
        
        map.topAnchor.constraint(equalTo: locationButton.bottomAnchor, constant: 30),
        map.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
        map.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
        map.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        
        ])
    }
    
    func authorize(){
        locationManager.delegate = self
        switch locationManager.authorizationStatus{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    @objc func getLocationButtonTapped(){
        authorize()
    }

}
extension ViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch locationManager.authorizationStatus{
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .denied:
            break
        case .authorizedAlways:
            locationManager.requestLocation()
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        @unknown default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first{
            let lat = location.coordinate.latitude
            let long = location.coordinate.longitude
            getInfo(lat: String(lat), long: String(long))
            self.map.region.center.latitude = lat
            self.map.region.center.longitude = long
        }
    }
  
}

