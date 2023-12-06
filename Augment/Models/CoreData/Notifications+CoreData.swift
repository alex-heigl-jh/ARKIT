//
//  Notifications+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

extension Notifications {

  static func createWith(
    notContent: String,
    notID: UUID,
    notTitle: String,
    notType: String,
    in context: NSManagedObjectContext
  ) {
    context.perform {
      let item = Notifications(context: context)
      item.notContent = notContent
      item.notID = notID
      item.notTitle = notTitle
      item.notType = notType
      do {
        try context.save()
      } catch {
        fatalError("Problem saving Notifications to CoreData")
      }
    }
  }
}
