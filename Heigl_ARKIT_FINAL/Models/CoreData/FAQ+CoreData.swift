//
//  FAQ+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

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
      do {
	    print("\(faqTitle) Saved!")
        try context.save()
      } catch {
        fatalError("Problem saving FAQ to CoreData")
      }
    }
  }
}
