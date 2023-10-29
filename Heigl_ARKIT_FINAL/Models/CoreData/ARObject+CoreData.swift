//
//  ARObject+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

extension ARObject {

  static func createWith(
    arID: UUID,
    in context: NSManagedObjectContext
  ) {
    context.perform {
      let item = ARObject(context: context)
      item.arID = arID
      do {
        try context.save()
      } catch {
        fatalError("Problem saving ARObject to CoreData")
      }
    }
  }
}
