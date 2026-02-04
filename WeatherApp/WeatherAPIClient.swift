//
//  WeatherAPIClient.swift
//  WeatherApp
//
//  Created by Lizzy on 03.02.26.
//

import Foundation

enum WeatherAPIError: Error {
    case invalidURL
    case requestFailed(Error)
    case invalidResponse
    case decodingFailed(Error)
    case noData
}

struct CurrentWeatherResponse: Decodable {
    struct Main: Decodable {
        let temp: Double
        let humidity: Int
        let pressure: Int
    }

    struct Weather: Decodable {
        let description: String
        let icon: String
    }

    struct Clouds: Decodable {
        let all: Int
    }

    struct Wind: Decodable {
        let speed: Double
        let deg: Double
    }

    struct Sys: Decodable {
        let country: String?
    }

    let name: String
    let main: Main
    let weather: [Weather]
    let clouds: Clouds
    let wind: Wind
    let sys: Sys?
}

struct ForecastResponse: Decodable {
    struct City: Decodable {
        let name: String
    }

    struct Item: Decodable {
        struct Main: Decodable {
            let temp: Double
        }

        struct Weather: Decodable {
            let description: String
            let icon: String
        }

        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
    }

    let list: [Item]
    let city: City
}

final class WeatherAPIClient {
    static let shared = WeatherAPIClient()
    private let apiKey = "f4f2d547c08d94ca948d92bcb665419e"
    private let session: URLSession

    private init(session: URLSession = .shared) {
        self.session = session
    }

    private func makeURL(path: String, lat: Double, lon: Double) -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.openweathermap.org"
        components.path = "/data/2.5/\(path)"
        components.queryItems = [
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lon", value: String(lon)),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components.url
    }

    func fetchCurrentWeather(
        lat: Double,
        lon: Double,
        completion: @escaping (Result<CurrentWeatherResponse, WeatherAPIError>) -> Void
    ) {
        guard let url = makeURL(path: "weather", lat: lat, lon: lon) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                }
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(CurrentWeatherResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(error)))
                }
            }
        }

        task.resume()
    }

    func fetchFiveDayForecast(
        lat: Double,
        lon: Double,
        completion: @escaping (Result<ForecastResponse, WeatherAPIError>) -> Void
    ) {
        guard let url = makeURL(path: "forecast", lat: lat, lon: lon) else {
            completion(.failure(.invalidURL))
            return
        }

        let task = session.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(.requestFailed(error)))
                }
                return
            }

            guard let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }
            
            guard 200..<300 ~= httpResponse.statusCode else {
                if let data = data, let errorString = String(data: data, encoding: .utf8) {
                }
                DispatchQueue.main.async {
                    completion(.failure(.invalidResponse))
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    completion(.failure(.noData))
                }
                return
            }

            do {
                let decoder = JSONDecoder()
                let result = try decoder.decode(ForecastResponse.self, from: data)
                DispatchQueue.main.async {
                    completion(.success(result))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(.decodingFailed(error)))
                }
            }
        }

        task.resume()
    }
}

