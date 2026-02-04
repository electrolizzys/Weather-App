//
//  LocationService.swift
//  WeatherApp
//

import Foundation
import CoreLocation

enum LocationError: Error {
    case denied
    case restricted
    case unableToDetermine
}

final class LocationService: NSObject {
    static let shared = LocationService()

    private let manager = CLLocationManager()
    private var pendingCompletions: [(Result<CLLocationCoordinate2D, LocationError>) -> Void] = []

    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }

    func requestLocation(completion: @escaping (Result<CLLocationCoordinate2D, LocationError>) -> Void) {
        pendingCompletions.append(completion)

        let status = manager.authorizationStatus
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied:
            completeAll(with: .failure(.denied))
        case .restricted:
            completeAll(with: .failure(.restricted))
        @unknown default:
            completeAll(with: .failure(.unableToDetermine))
        }
    }

    private func completeAll(with result: Result<CLLocationCoordinate2D, LocationError>) {
        let completions = pendingCompletions
        pendingCompletions.removeAll()
        completions.forEach { $0(result) }
    }
}

extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied:
            completeAll(with: .failure(.denied))
        case .restricted:
            completeAll(with: .failure(.restricted))
        case .notDetermined:
            break
        @unknown default:
            completeAll(with: .failure(.unableToDetermine))
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let coordinate = locations.last?.coordinate else {
            completeAll(with: .failure(.unableToDetermine))
            return
        }
        completeAll(with: .success(coordinate))
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        completeAll(with: .failure(.unableToDetermine))
    }
}

