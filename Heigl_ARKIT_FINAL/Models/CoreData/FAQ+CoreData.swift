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
    faqPicture1: String,
    faqPicture2: String,
    faqTitle: String,
    faqVideo: String,
    in context: NSManagedObjectContext
  ) {
    context.perform {
        let item = FAQ(context: context)
        item.faqContent = faqContent
        item.faqID = faqID
        item.faqPicture1 = faqPicture1
        item.faqPicture2 = faqPicture2
        item.faqTitle = faqTitle
        item.faqVideo = faqVideo
      do {
        try context.save()
      } catch {
        fatalError("Problem saving FAQ to CoreData")
      }
    }
  }
}
