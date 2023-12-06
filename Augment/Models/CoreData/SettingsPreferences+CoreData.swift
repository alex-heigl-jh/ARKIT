//
//  SettingsPreferences+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

extension SettingsPreferences {

  static func createWith(
    lightDark: Bool,
    mapView: Bool,
    signOut: Bool,
    userID: UUID,
    in context: NSManagedObjectContext
  ) {
    context.perform {
      let item = SettingsPreferences(context: context)
      item.lightDark = lightDark
      item.signOut = signOut
      item.mapView = mapView
      item.userID = userID
      do {
        try context.save()
      } catch {
        fatalError("Problem saving SettingsPreferences to CoreData")
      }
    }
  }
}
