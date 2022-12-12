//
//  APIClient .swift
//  WeatherApp
//
//  Created by Saidac Alexandru on 28.11.2022.
//

import Foundation


enum WeatherError: Error{
    case badURL, failedToGetData , badRequest
}

class APIClient{
    
    private let baseUrl = "https://api.openweathermap.org/data/2.5/weather"
    private let apiKey = "08dec42866daae26c7ebf0d8a80b1821"
    
    static let shared = APIClient()
    

    private init(){
        
    }
    
    func getIconUrl(icon: String) -> URL?{
        let url = "https://openweathermap.org/img/w/\(icon).png"
        return URL(string:url)
    }
    
    func getWeather(lat:String , long:String , completion : @escaping (_ weatherData:[String: Any]?) ->Void) {
        //we create the request url.this is a get request
        let request = "\(baseUrl)?lat=\(lat)&lon=\(long)&appid=\(apiKey)&units=metric"
        guard let requestUrl = URL(string: request) else{
            completion(nil)
            return
        }
        //we are making the request to the server using the request url
        URLSession.shared.dataTask(with: requestUrl) { data, response, error in
            //we get back the response in this closure
            if let error = error {
                print(error.localizedDescription)
                completion(nil)
                return
            }
            guard let data = data else{
                return
            }
            print("respons:\(response)")
            do{
                //converts data response to json
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]{
                    completion(json)
                }
            } catch {
                print("failed to convert json")
                completion(nil)
            }
        }.resume()
    }
    func getWeatherWithCodable(lat:String , long:String) async throws -> WeatherModel {
        
        //we create the request url.this is a get request
        let request = "\(baseUrl)?lat=\(lat)&lon=\(long)&appid=\(apiKey)&units=metric"
        guard let url = URL(string: request) else{
            throw WeatherError.badURL
        }
        let urlRequest = URLRequest(url: url)
        do{
            let (data,response) = try await URLSession.shared.data(for: urlRequest)
            let httpResponse = response as! HTTPURLResponse
            if httpResponse.statusCode == 200 {
                let weatherData = try JSONDecoder().decode(WeatherModel.self, from: data)
                return weatherData
            } else{
                throw WeatherError.badRequest
            }
        }catch {
            print("error\(error.localizedDescription)")
            throw WeatherError.failedToGetData
        }
        //we are making the request to the server using the request url
   
        
    }
}
