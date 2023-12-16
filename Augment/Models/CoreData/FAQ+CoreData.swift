//
//  FAQ+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData
import os.log

let log = Logger()

extension FAQ {

  static func createWith(
	faqContent: String,
	faqID: UUID,
	faqTitle: String,
	mediaURL: String,
	mediaType: String,
	in context: NSManagedObjectContext
  ) {
	context.perform {
	  let item = FAQ(context: context)
	  item.faqContent = faqContent
	  item.faqID = faqID
	  item.faqTitle = faqTitle
	  item.mediaURL = mediaURL
	  item.mediaType = mediaType

		log.info("Attempting to save FAQ with Title: \(faqTitle)")

	  do {
		try context.save()
		  log.info("\(faqTitle) Successfully Saved!")
	  } catch {
		  log.error("Error saving FAQ with Title: \(faqTitle)")
		  log.error("Error Details: \(error.localizedDescription)")
		// If you want the app to continue running, replace `fatalError` with the print statements.
		// fatalError("Problem saving FAQ to CoreData")
	  }
	}
  }
}

