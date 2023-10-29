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
    safPicture: String,
    safTitle: String,
    safVideo: String,
    in context: NSManagedObjectContext
  ) {
    context.perform {
        let item = Safety(context: context)
        item.safContent = safContent
        item.safID = safID
        item.safPicture = safPicture
        item.safTitle = safTitle
        item.safVideo = safVideo
      do {
        try context.save()
      } catch {
        fatalError("Problem saving Saftey to CoreData")
      }
    }
  }
}
