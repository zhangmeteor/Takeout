//
//  LocationManager.swift
//  TakeOut
//
//  Created by xiaomeng on 12/11/22.
//

import Foundation
import CoreLocation
import RxSwift

class LocationManager: NSObject, CLLocationManagerDelegate {
    lazy var manager = {
        let location = CLLocationManager()
        location.pausesLocationUpdatesAutomatically = true
        location.desiredAccuracy = kCLLocationAccuracyHundredMeters
        location.distanceFilter = 100

        return location
    }()
    
    var currentLocaltion = BehaviorSubject<String>(value: "")

    override init() {
        super.init()
        manager.delegate = self
    }
    
    func start() {
        manager.requestAlwaysAuthorization()
        manager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task {
            await updateGeoCity(locations.first)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("get location Error:\(error)")
    }
    
    private func updateGeoCity(_ fromLocation: CLLocation?) async {
        guard let location = fromLocation else {
            print("Update Location with none new location found")
            return
        }
        
        let geoCoder = CoreLocation.CLGeocoder.init()
        
        do {
            // get GeoInfo
            let geo = try await geoCoder.reverseGeocodeLocation(location)
            
            guard let firstGeo = geo.first else {
                print("geo infomation not found")
                return
            }
            
            guard let city = firstGeo.locality else {
                // If city not found, using area
                if let area = firstGeo.administrativeArea {
                    print("get Geo area: \(area)")
                    currentLocaltion.onNext(area)
                }
                return
            }
            
           
            var address = "\(city)"
            if let district = firstGeo.subLocality {
                address = address + ", \(district)"
            }
            
            if let street = firstGeo.thoroughfare {
                address = address + ", \(street)"
            }
            
            if let subThoroughfare = firstGeo.subThoroughfare {
                address = address + ", \(subThoroughfare)"
            }
            
            print("get Geo city: \(address)")
            currentLocaltion.onNext(address)
        } catch {
            print("get Geo Error:\(error)")
        }
    }
}
