// Heigl_Final_ARKIT
//
// Created by Alex Heigl on 10/16/23.
//
// Initial Maps Code based off tutorial from: https://www.youtube.com/watch?v=gy6rp_pJmbo

import SwiftUI
import MapKit
import CoreLocation

struct MapsView: View {
	@StateObject private var locationManager = LocationManager()
	@State private var cameraPosition: MapCameraPosition = .region(.userRegion)
	@State private var searchText = " "
	@State private var results = [MKMapItem]()
	@State private var mapSelection: MKMapItem?
	@State private var showDetails = false
	@State private var getDirections = false
	// Variable to track if there is a polyline plotted on map
	@State private var routeDisplaying = false
	// State property for the route itself
	@State private var route: MKRoute?
	// Keeps track of route destination
	@State private var routeDestination: MKMapItem?
	
	var body: some View {
		Map(position: $cameraPosition, selection: $mapSelection){

//			UserAnnotation()
			if let userCoordinate = locationManager.location?.coordinate{
				
				Annotation("My Location", coordinate: userCoordinate){
					ZStack {
						Circle()
							.frame(width: 32, height: 32)
							.foregroundColor(.blue.opacity(0.25))
						Circle()
							.frame(width: 20, height: 20)
							.foregroundColor(.white)
						Circle()
							.frame(width: 12, height: 12)
							.foregroundColor(.blue)
					}
				}
			}
			ForEach(results, id: \.self){ item in
				if routeDisplaying{
					if item == routeDestination {
						let placemark = item.placemark
						Marker(placemark.name ?? "", coordinate: placemark.coordinate)
					}
				} else {
					let placemark = item.placemark
					Marker(placemark.name ?? "", coordinate: placemark.coordinate)
				}

			}
			if let route {
				MapPolyline(route.polyline)
					.stroke(.blue, lineWidth: 6)
			}
		}
		// Code block that displays search bar at top of view
		.overlay(alignment: .top){
			TextField("Search for a location...", text: $searchText)
				.font(.subheadline)
				.padding(12)
				.background(.white)
				.padding()
				.shadow(radius: 10)
		}
		// Any time user searches from a text field this will be executed
		.onSubmit(of: .text){
			print("Search for locations with query:\(searchText)")
			Task { await searchPlaces()}
			
		}
		.onChange(of: getDirections, { oldValue, newValue in
			if newValue {
				fetchRoute()
			}
		})
		.onChange(of: mapSelection, { oldValue, newValue in
			// If the selected value is not nil, show the details to the user
			showDetails = newValue != nil
		})
		.onChange(of: locationManager.location, {oldValue, newValue in
			if let newLocation = newValue {
				let newRegion = MKCoordinateRegion(center: newLocation.coordinate,
												   latitudinalMeters: 10000,
												   longitudinalMeters: 10000)
				cameraPosition = .region(newRegion)
			}
		})
		// Sheet only displays if showDetails == true
		.sheet(isPresented: $showDetails, content: {
			// Load LocationDetailsView
			LocationDetailsView(mapSelection: $mapSelection,
								show: $showDetails,
								getDirections: $getDirections)
				.presentationDetents([.height(340)])
				// Allows user to still interact with map view that is not covered by sheet
				.presentationBackgroundInteraction(.enabled(upThrough: .height(340)))
				.presentationCornerRadius(12)
		})
		// Built-In MapKit controls / buttons / function
		.mapControls {
			MapCompass()
			MapPitchToggle()
			MapUserLocationButton()
		}
	}
}

extension MapsView{
	func searchPlaces() async {
		let request = MKLocalSearch.Request()
		request.naturalLanguageQuery = searchText
		request.region = .userRegion
		// Store results of naturalLanguageQuery Requests
		let results = try? await MKLocalSearch(request: request).start()
		self.results = results?.mapItems ?? []
	}
	
	func fetchRoute() {
		if let mapSelection {
			let request = MKDirections.Request()
			request.source = MKMapItem(placemark: .init(coordinate: .userLocation))
			request.destination = mapSelection
			
			Task {
				let result = try? await MKDirections(request: request).calculate()
				route = result?.routes.first
				routeDestination = mapSelection
				
				withAnimation(.snappy){
					routeDisplaying = true
					showDetails = false
					
					if let rect = route?.polyline.boundingMapRect, routeDisplaying {
						// Camera position will adjust zoom so entire route is visible on screen
						cameraPosition = .rect(rect)
					}
				}
			}
		}
	}
}

extension CLLocationCoordinate2D {
	static var userLocation: CLLocationCoordinate2D {
		return LocationManager().location?.coordinate ?? CLLocationCoordinate2D(latitude: 25.7602, longitude: -80.1959)
	}
}

extension MKCoordinateRegion {
	static var userRegion: MKCoordinateRegion {
		return .init(center: .userLocation, 
					 latitudinalMeters: 10000,
					 longitudinalMeters: 10000)
	}
}


class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
	private var locationManager = CLLocationManager()
	@Published var location: CLLocation?

	override init() {
		super.init()
		self.locationManager.delegate = self
		self.locationManager.requestWhenInUseAuthorization()
		self.locationManager.startUpdatingLocation()
	}

	func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
		guard let newLocation = locations.first else {
			print("Error: Failed to get user's location.")
			return
		}
		location = newLocation
		print("User's location updated: \(newLocation)")
	}

	func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
		print("Error fetching location: \(error)")
	}
}


struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        // Here we provide a mock value for the goBack binding
        MapsView()
    }
}
