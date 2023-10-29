//
//  MapsData+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

extension MapsData {

  static func createWith(
    dateAdded: Date,
    landmarkID: UUID,
    lastModified: Date,
    locationType: String,
    sceneLocation: String,
    userID: UUID,
    in context: NSManagedObjectContext
  ) {
    context.perform {
        let item = MapsData(context: context)
        item.dateAdded = dateAdded
        item.landmarkID = landmarkID
        item.lastModified = lastModified
        item.locationType = locationType
        item.sceneLocation = sceneLocation
        item.userID = userID
      do {
        try context.save()
      } catch {
        fatalError("Problem saving MapsData to CoreData")
      }
    }
  }
}
