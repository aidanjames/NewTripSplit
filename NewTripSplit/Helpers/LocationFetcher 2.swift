//
//  LocationFetcher.swift
//  NewTripSplit
//
//  Created by Aidan Pendlebury on 25/01/2020.
//  Copyright © 2020 Aidan Pendlebury. All rights reserved.
//

import CoreLocation

class LocationFetcher: NSObject, CLLocationManagerDelegate, ObservableObject {
    
    static let shared = LocationFetcher()
    
    let manager = CLLocationManager()
    var lastKnownLocation: CLLocationCoordinate2D?
    @Published var hasPermission: Bool = true
        
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func start() {
        manager.requestWhenInUseAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        lastKnownLocation = locations.first?.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        print("Authorisation status changed to \(status.rawValue)")
        if status.rawValue < 3 {
            self.hasPermission = false
        } else {
            self.hasPermission = true
        }
    }
    
    
}
