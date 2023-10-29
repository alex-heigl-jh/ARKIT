//
//  MapView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

// Heigl_Final_ARKIT
//
// Created by Alex Heigl on 10/16/23.

import SwiftUI
import MapKit
import CoreLocation

struct IdentifiableLocation: Identifiable {
    let id = UUID() // Unique identifier
    let location: CLLocation
}


struct MapsView: View {
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.0389, longitude: -87.9065), // Default to Milwaukee, Wisconsin
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05) // Specifying the span directly
    )
    
    @State private var userTrackingMode: MapUserTrackingMode = .follow

    @State private var showSecondaryMenu = false
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        VStack {
            Text("Map View [1]")
                .font(.headline)
                .padding()

            Map(coordinateRegion: $region, showsUserLocation: true, userTrackingMode: $userTrackingMode, annotationItems: [locationManager.lastLocation].compactMap { $0 }) { identifiableLocation in
                MapPin(coordinate: identifiableLocation.location.coordinate, tint: .blue)
            }
            
            Spacer()
            
            VStack {
                Button(action: {
                    showSecondaryMenu.toggle()
                }) {
                    Text("Search")
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .shadow(radius: 3)
                
                if showSecondaryMenu {
                    Text("Secondary Menu")
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .shadow(radius: 3)
                }
            }
            .padding()
        }
        .onAppear {
            if let location = locationManager.lastLocation {
//                region.center = location.coordinate
            }
        }
    }
}

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager = CLLocationManager()
    @Published var lastLocation: IdentifiableLocation?  // Change this line to use IdentifiableLocation
    
    override init() {
        super.init()
        self.locationManager.delegate = self
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            lastLocation = IdentifiableLocation(location: location)
        }
    }
}


struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        // Here we provide a mock value for the goBack binding
        MapsView()
    }
}
