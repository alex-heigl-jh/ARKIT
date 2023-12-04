//
//  Safety+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

extension Safety {
  static func createWith(
	safContent: String,
	safID: UUID,
	safTitle: String,
	mediaURL: String,
	mediaType: String,
	in context: NSManagedObjectContext
  ) {
	context.perform {
		let item = Safety(context: context)
		item.safContent = safContent
		item.safID = safID
		item.safTitle = safTitle
		item.mediaURL = mediaURL
		item.mediaType = mediaType
		print("DEBUG: Safety object \(safTitle) with ID \(safID) is being created.")

		do {
			try context.save()
			print("DEBUG: Safety object \(safTitle) with ID \(safID) saved successfully.")
		} catch {
			print("ERROR: Problem saving Safety \(safTitle) with ID \(safID) to CoreData. Error: \(error)")
		}
	}
  }
}

