//
//  CoreLocationHelper.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/29/23.
//

import Foundation
import CoreLocation
import MapKit
import CoreData

enum CoordTranslationError: Error {
  case NoPlacemarkLocation
}

class CoreLocationHelper {

  static func getCoordinatesFor(_ address: String) async throws -> CLLocationCoordinate2D {
	let geoCoder = CLGeocoder()
	let placemark = try await geoCoder.geocodeAddressString(address)[0]
	let location = placemark.location
	guard let location else { throw CoordTranslationError.NoPlacemarkLocation}
	return location.coordinate
  }
}

class ARItemLocation: NSObject, MKAnnotation, Identifiable
{
  var item: MapsData
  var coordinate: CLLocationCoordinate2D

  init(item: MapsData, coordinate: CLLocationCoordinate2D)
  {
	self.item = item
	self.coordinate = coordinate

	super.init()
  }
}
