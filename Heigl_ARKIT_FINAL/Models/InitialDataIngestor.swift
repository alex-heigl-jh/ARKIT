//
//  InitialDataIngestor.swift
//  ToDoApp
//
//  Created by Teacher on 9/17/22.
//

import Foundation
import SwiftUI

enum NetworkError: Error {
  case InvalidCode
  case InvalidURL
}

enum LoadingType {
  case Local
  case LocalJSON
  case Web
}

class InitialDataIngestor: NSObject, ObservableObject {

//  @Published var users: [UserJSON]?
//  @Published var iap: [IAPJSON]?
//  @Published var pictures: [PictureJSON]?
//  @Published var rkResults: [RKResultJSON]?
//  @Published var toDoItems: [ToDoItemJSON]?

  //MARK: -- Sample Hardcoded Data
//  func loadSamplePicture() throws {
//    pictures = [PictureJSON(uuid: UUID(), url: "http://159.203.191.136/Josh.png")]
//  }
//
//  func loadSampleUsers() throws {
//    let user1 = UserJSON(uuid: UUID(), firstName: "Josh", lastName: "Steele", username: "jsteele", address: "Columbia, MD", profilePicURL: "http://159.203.191.136/Josh.png")
//    let user2 = UserJSON(uuid: UUID(), firstName: "John", lastName: "Smith", username: "jsmith", address: "Columbia, MD", profilePicURL: "http://159.203.191.136/johnsmith.png")
//    let user3 = UserJSON(uuid: UUID(), firstName: "Jane", lastName: "Doe", username: "janedoe", address: "Blacksburg, VA", profilePicURL: "http://159.203.191.136/janedoe.png")
//    let user4 = UserJSON(uuid: UUID(), firstName: "Tony", lastName: "Stark", username: "tonystark", address: "New York, NY", profilePicURL: "http://159.203.191.136/tonystark.png")
//    users = [user1, user2, user3, user4]
//  }
//
//    func loadSampleToDoItems() throws {
//        let currentDate = Date()
//        let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
//        let dayAfterTomorrowDate = Calendar.current.date(byAdding: .day, value: 2, to: currentDate)!
//
//        let toDoItem1 = ToDoItemJSON(uuid: UUID(), name: "Write a program", dueDate: currentDate, desc: "Write the ToDo App", relatedTo: [], workingWith: [], location: "Eldersburg, MD", completed: true)
//        let toDoItem2 = ToDoItemJSON(uuid: UUID(), name: "Review project proposal", dueDate: currentDate, desc: "Review the proposal sent by the marketing team", relatedTo: [], workingWith: [], location: "Jessup, MD", completed: false)
//        let toDoItem3 = ToDoItemJSON(uuid: UUID(), name: "Plan team meeting", dueDate: tomorrowDate, desc: "Plan for the next sprint", relatedTo: [], workingWith: [], location: "Laurel, MD", completed: true)
//        let toDoItem4 = ToDoItemJSON(uuid: UUID(), name: "Buy groceries", dueDate: tomorrowDate, desc: "Pick up groceries for the week", relatedTo: [], workingWith: [], location: "Towson, MD", completed: false)
//        let toDoItem5 = ToDoItemJSON(uuid: UUID(), name: "Send invoices", dueDate: dayAfterTomorrowDate, desc: "Send invoices for completed projects", relatedTo: [], workingWith: [], location: "Sykesville, MD", completed: true)
//        let toDoItem6 = ToDoItemJSON(uuid: UUID(), name: "Update resume", dueDate: dayAfterTomorrowDate, desc: "Update the resume with recent projects", relatedTo: [], workingWith: [], location: "Edgewater, MD", completed: false)
//
//        toDoItems = [toDoItem1, toDoItem2, toDoItem3, toDoItem4, toDoItem5, toDoItem6]
//    }


  //MARK: -- JSON DATA FROM LOCAL FILE
  func loadAllDataFromLocalJSON() {
    do {
//      users = try getResourcesFromJSON(resourceName: "users")
//      iap = try getResourcesFromJSON(resourceName: "iap")
//      pictures = try getResourcesFromJSON(resourceName: "pictures")
//      rkResults = try getResourcesFromJSON(resourceName: "rkResults")
//      toDoItems = try getResourcesFromJSON(resourceName: "toDoItems")
    } catch {
      print("An error occurred during decoding \(error)")
    }
  }

  private func getResourcesFromJSON<T: Decodable>(resourceName: String) throws -> [T]? {
    if let bundlePath = Bundle.main.path(forResource: resourceName, ofType: "json"),
       let jsonData = try String(contentsOfFile: bundlePath).data(using: .utf8) {
      let decoder = JSONDecoder()
      return try decoder.decode([T].self, from: jsonData)
    }
    return nil
  }

  //MARK: -- LOAD DATA FROM NETWORKED JSON FILES
  //add code here to read in from the network JSON files
  func loadJSON<T: Codable>(from urlString: String, for: T.Type) async throws -> [T]
  {
    guard let url = URL(string: urlString) else { throw NetworkError.InvalidURL }
    let request = URLRequest(url: url)
    let (data, response) = try await URLSession.shared.data(for: request)

    guard let httpResponse = response as? HTTPURLResponse, (200..<300).contains(httpResponse.statusCode) else {
      throw NetworkError.InvalidCode
    }
    let jsonObjects: [T] = try JSONDecoder().decode([T].self, from: data)
    return jsonObjects
  }

  //add code here to save the different types to core Data
//  func storeUsersInDatabase(users: [UserJSON]) {
//    let backgroundContext = PersistenceController.shared.newTaskContext()
//    users.forEach { user in
//      User.createWith(firstName: user.firstName,
//                      lastName: user.lastName,
//                      username: user.username,
//                      address: user.address,
//                      profilePicURL: user.profilePicURL,
//                      in: backgroundContext)
//    }
//  }
//
//  func storePicturesInDatabase(pictures: [PictureJSON]) {
//    let backgroundContext = PersistenceController.shared.newTaskContext()
//    pictures.forEach { picture in
//      Picture.createWith(url: picture.url,
//                         in: backgroundContext)
//    }
//  }
//
//  func storeToDoItemsInDatabase(toDoItems: [ToDoItemJSON]) {
//    let backgroundContext = PersistenceController.shared.newTaskContext()
//    toDoItems.forEach { toDoItem in
//      ToDoItem.createWith(name: toDoItem.name,
//                          dueDate: toDoItem.dueDate,
//                          desc: toDoItem.desc,
//                          location: toDoItem.location,
//                          completed: toDoItem.completed,
//                          in: backgroundContext)
//    }
//  }
//
//  func storeIAPInDatabase(iap: [IAPJSON]) {
//    let backgroundContext = PersistenceController.shared.newTaskContext()
//    iap.forEach{ iapItem in
//      IAP.createWith(name: iapItem.name,
//                     desc: iapItem.desc,
//                     price: iapItem.price,
//                     purchased: iapItem.purchased,
//                     in: backgroundContext)
//    }
//  }
//
//  func storeRKResultsInDatabase(rkResults: [RKResultJSON]) {
//    let backgroundContext = PersistenceController.shared.newTaskContext()
//    rkResults.forEach { result in
//      RKResult.createWith(answer1: result.answerOne,
//                          answer2: result.answerTwo,
//                          answer3: result.answerThree,
//                          in: backgroundContext)
//    }
//  }

  //MARK: -- SINGLE METHOD TO LOAD DATA FROM A GIVEN SOURCE
  func loadAllData(from: LoadingType, isLoaded: Binding<Bool>) async {
    CoreDataHelper.emptyDB()
    do {
//      switch from {
//      case .Local:
//        try loadSampleUsers()
//        try loadSamplePicture()
//        try loadSampleToDoItems()
//      case .LocalJSON:
//        loadAllDataFromLocalJSON()
//      case .Web:
//        users = try await loadJSON(from: "http://159.203.191.136/resources/users.json", for: UserJSON.self)
//        iap = try await loadJSON(from: "http://159.203.191.136/resources/iap.json", for: IAPJSON.self)
//        pictures = try await loadJSON(from: "http://159.203.191.136/resources/pictures.json", for: PictureJSON.self)
//        rkResults = try await loadJSON(from: "http://159.203.191.136/resources/rkResults.json", for: RKResultJSON.self)
//        toDoItems = try await loadJSON(from: "http://159.203.191.136/resources/toDoItems.json", for: ToDoItemJSON.self)
      }

      //add code here to take the read in data from any of the techniques and store it to the database
//      storeUsersInDatabase(users: users ?? [])
//      storeIAPInDatabase(iap: iap ?? [])
//      storePicturesInDatabase(pictures: pictures ?? [])
//      storeRKResultsInDatabase(rkResults: rkResults ?? [])
//      storeToDoItemsInDatabase(toDoItems: toDoItems ?? [])
//      try PersistenceController.shared.container.viewContext.save()

      //add code to assign the second user (users[1]) to the first to do item
//      guard let users, let toDoItems, let pictures else { return }
//      CoreDataHelper.assign(user: users[1], to: toDoItems[0])
      //add code to add the first picture to the first to do item
//      CoreDataHelper.add(picture: pictures[0], to: toDoItems[0])
//    } catch {
//      print("Error saving to core data \(error)")
//    }
//    isLoaded.wrappedValue = true
  }
}
