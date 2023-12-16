//
//  MapsData+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData
import os.log

extension MapsData {
	static func createWith(
		dateAdded: Date,
		sceneLocation: String,
		in context: NSManagedObjectContext
	) {
		context.perform {
			let item = MapsData(context: context)
			item.dateAdded = dateAdded
			item.sceneLocation = sceneLocation
			do {
				try context.save()
				print("Successfully saved location to CoreData: \(sceneLocation) on \(dateAdded)")
			} catch {
				print("Error saving MapsData to CoreData: \(error.localizedDescription)")
				if let detailedErrors = error as NSError? {
					if let underlyingErrors = detailedErrors.userInfo[NSDetailedErrorsKey] as? [NSError] {
						for underlyingError in underlyingErrors {
							print("Underlying error: \(underlyingError.localizedDescription)")
						}
					}
				}
			}
		}
	}
}
