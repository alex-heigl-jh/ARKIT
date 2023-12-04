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
	userID: String,
	profilePicURL: String,
	in context: NSManagedObjectContext
  ) {
	context.perform {
	  let item = User(context: context)
	  item.firstName = firstName
	  item.lastName = lastName
	  item.profilePicURL = profilePicURL
	  item.userID = userID
	  print("User \(firstName) \(lastName) created.")
	  do {
		try context.save()
	  } catch {
		fatalError("Problem saving user")
	  }
	}
  }

  // Function to fetch a user by userID
  static func fetchUserBy(userID: String, in context: NSManagedObjectContext) -> User? {
	let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
	fetchRequest.predicate = NSPredicate(format: "userID == %@", userID as CVarArg)
	fetchRequest.fetchLimit = 1

	do {
	  let results = try context.fetch(fetchRequest)
	  return results.first
	} catch {
	  print("Error fetching user by ID:", error)
	  return nil
	}
  }
}

