//
//  CoreDataHelper.swift
//  ToDoApp
//
//  Created by Student on 10/29/23.
//

import Foundation
import CoreData

/// A helper struct that contains static methods to help interact with the Core Data database
struct CoreDataHelper {

  /// References the viewContext in the Persistence file
  static let context = PersistenceController.shared.container.viewContext

  //Populating/Clearing methods
  /// Empties the database of all current values.  Useful for testing.
  static func emptyDB() {

    let userFetchRequest: NSFetchRequest<NSFetchRequestResult> = User.fetchRequest()
    let userDeleteRequest = NSBatchDeleteRequest(fetchRequest: userFetchRequest)

    let ARObjectFetchRequest: NSFetchRequest<NSFetchRequestResult> = ARObject.fetchRequest()
    let ARObjectDeleteRequest = NSBatchDeleteRequest(fetchRequest: ARObjectFetchRequest)

    let FAQFetchRequest: NSFetchRequest<NSFetchRequestResult> = FAQ.fetchRequest()
    let FAQDeleteRequest = NSBatchDeleteRequest(fetchRequest: FAQFetchRequest)

    let MapsDataFetchRequest: NSFetchRequest<NSFetchRequestResult> = MapsData.fetchRequest()
    let MapsDataDeleteRequest = NSBatchDeleteRequest(fetchRequest: MapsDataFetchRequest)

    let NewsFeedFetchRequest: NSFetchRequest<NSFetchRequestResult> = NewsFeed.fetchRequest()
    let NewsFeedDeleteRequest = NSBatchDeleteRequest(fetchRequest: NewsFeedFetchRequest)
      
    let NotificationsFetchRequest: NSFetchRequest<NSFetchRequestResult> = Notifications.fetchRequest()
    let NotificationsDeleteRequest = NSBatchDeleteRequest(fetchRequest: NotificationsFetchRequest)
      
    let SettingsPreferencesFetchRequest: NSFetchRequest<NSFetchRequestResult> = SettingsPreferences.fetchRequest()
    let SettingsPreferencesDeleteRequest = NSBatchDeleteRequest(fetchRequest: SettingsPreferencesFetchRequest)

    let SafetyFetchRequest: NSFetchRequest<NSFetchRequestResult> = Safety.fetchRequest()
    let SafetyDeleteRequest = NSBatchDeleteRequest(fetchRequest: SafetyFetchRequest)

    let iapFetchRequest: NSFetchRequest<NSFetchRequestResult> = IAP.fetchRequest()
    let iapDeleteRequest = NSBatchDeleteRequest(fetchRequest: iapFetchRequest)

      do {
        try CoreDataHelper.context.execute(userDeleteRequest)
        try CoreDataHelper.context.execute(ARObjectDeleteRequest)
        try CoreDataHelper.context.execute(FAQDeleteRequest)
        try CoreDataHelper.context.execute(MapsDataDeleteRequest)
        try CoreDataHelper.context.execute(NewsFeedDeleteRequest)
        try CoreDataHelper.context.execute(NotificationsDeleteRequest)
        try CoreDataHelper.context.execute(SettingsPreferencesDeleteRequest)
        try CoreDataHelper.context.execute(SafetyDeleteRequest)
        try CoreDataHelper.context.execute(SafetyDeleteRequest)
    } catch let error as NSError {
      print("Error during bulk deletion \(error.localizedDescription)")
    }
  }

  /// Assigns a user, denoted by a UserJSON, to a ToDoItem, denoted by a ToDoItemJSON
  /// - Parameters:
  ///   - user: a UserJSON that has a populated name field
  ///   - toDoItem: the ToDoItem (uniquely identified by a UUID) to which the user will be assigned
//  static func assign(user: UserJSON, to toDoItem: ToDoItemJSON) {
//    let userFetchRequest = User.fetchRequest()
//    userFetchRequest.predicate = NSPredicate(format: "username == %@", user.username)
//
//    let toDoItemFetchRequest = ToDoItem.fetchRequest()
//    toDoItemFetchRequest.predicate = NSPredicate(format: "uuid == %@", toDoItem.uuid! as CVarArg)
//
//    do {
//      let fetchedUser = try context.fetch(userFetchRequest).first
//      let fetchedToDoItem = try context.fetch(toDoItemFetchRequest).first
//      guard let fetchedUser, let fetchedToDoItem else { return  }
//      fetchedToDoItem.addToWorkingWith(fetchedUser)
//    } catch {
//      print("Problem finding matching user or ToDoItem \(error)")
//    }
//  }

  /// Associates one to do item with another to do item
  /// - Parameters:
  ///   - toDoItem: the first to do item which gets associated with the other item
  ///   - toItem: the to do item to which the first one gets associated
//  static func associate(toDoItem: ToDoItemJSON, toItem: ToDoItemJSON) {
//    let toDoItemFetchRequest = ToDoItem.fetchRequest()
//    toDoItemFetchRequest.predicate = NSPredicate(format: "uuid == %@", toDoItem.uuid! as CVarArg)
//
//    let toDoItemFetchRequest2 = ToDoItem.fetchRequest()
//    toDoItemFetchRequest2.predicate = NSPredicate(format: "uuid == %@", toItem.uuid! as CVarArg)
//
//    do {
//      let fetchedToDoItem = try context.fetch(toDoItemFetchRequest).first
//      let fetchedToDoItem2 = try context.fetch(toDoItemFetchRequest2).first
//      guard let fetchedToDoItem, let fetchedToDoItem2 else { return  }
//      fetchedToDoItem2.addToRelatedTo(fetchedToDoItem)
//    } catch {
//      print("Problem finding matching ToDoItem \(error)")
//    }
//  }

  /// Adds a picture to a ToDoItem
  /// - Parameters:
  ///   - picture: the picture, as a PictureJSON, used to look up that entry in the database
  ///   - toDoItem: the ToDoItem, as a ToDoItemJSON, used to look up that item in the database
//  static func add(picture: PictureJSON, to toDoItem: ToDoItemJSON) {
//    let pictureFetchRequest = Picture.fetchRequest()
//    pictureFetchRequest.predicate = NSPredicate(format: "url == %@", picture.url)
//
//    let toDoItemFetchRequest = ToDoItem.fetchRequest()
//    toDoItemFetchRequest.predicate = NSPredicate(format: "uuid == %@", toDoItem.uuid! as CVarArg)
//
//    do {
//      let fetchedPicture = try context.fetch(pictureFetchRequest).first
//      let fetchedToDoItem = try context.fetch(toDoItemFetchRequest).first
//      guard let fetchedPicture, let fetchedToDoItem else { return  }
//      fetchedToDoItem.addToPictures(fetchedPicture)
//    } catch {
//      print("Problem finding matching picture or ToDoItem \(error)")
//    }
//  }
}
