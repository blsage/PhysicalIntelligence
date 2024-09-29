//
//  Model+Location.swift
//  PhysicalIntelligence
//
//  Created by Benjamin Sage on 9/29/24.
//

import CoreLocation

extension Model: CLLocationManagerDelegate {
    func requestLocationPermission() {
        self.locationManager = CLLocationManager()
        self.locationManager?.delegate = self
        self.locationManager?.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() async throws {
        guard let locationManager = locationManager else { return }

        locationManager.startUpdatingLocation()

        try await withCheckedThrowingContinuation { continuation in
            self.locationUpdateContinuation = continuation
        }

        locationManager.stopUpdatingLocation()
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }

        self.currentLocation = location.coordinate
        locationUpdateContinuation?.resume(returning: ())
        locationUpdateContinuation = nil
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationUpdateContinuation?.resume(throwing: error)
        locationUpdateContinuation = nil
    }
}
