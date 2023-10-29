//
//  Users+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

extension User {

  static func createWith(
    firstName: String,
    lastName: String,
    username: String,
    password: String,
    userID: UUID,
    profilePicURL: String,
    in context: NSManagedObjectContext
  ) {
    context.perform {
      let item = User(context: context)
      item.firstName = firstName
      item.lastName = lastName
      item.username = username
      item.password = password
      item.profilePicURL = profilePicURL
      item.userID = userID
      do {
        try context.save()
      } catch {
        fatalError("Problem saving user")
      }
    }
  }
}
