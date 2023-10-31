//
//  InitialDataIngestor.swift
//  ToDoApp
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
    
    @Published var users: [UserJSON]?
    
    
    //MARK: -- Sample Hardcoded Data
    
	func loadSampleUsers() throws {
		// Generate sample users
		let user1 = UserJSON(uuid: UUID(), firstName: "John", lastName: "Doe", username: "johndoe", password: "password123", userID: UUID(), profilePicURL: "http://example.com/johndoe.jpg")
		let user2 = UserJSON(uuid: UUID(), firstName: "Jane", lastName: "Smith", username: "janesmith", password: "password456", userID: UUID(), profilePicURL: "http://example.com/janesmith.jpg")
		let user3 = UserJSON(uuid: UUID(), firstName: "Alice", lastName: "Johnson", username: "alicejohnson", password: "password789", userID: UUID(), profilePicURL: "http://example.com/alicejohnson.jpg")
		let user4 = UserJSON(uuid: UUID(), firstName: "Bob", lastName: "Williams", username: "bobwilliams", password: "password012", userID: UUID(), profilePicURL: "http://example.com/bobwilliams.jpg")
		let user5 = UserJSON(uuid: UUID(), firstName: "Charlie", lastName: "Brown", username: "charliebrown", password: "password345", userID: UUID(), profilePicURL: "http://example.com/charliebrown.jpg")
		
		// Store sample users in the published variable
		self.users = [user1, user2, user3, user4, user5]
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
    func storeUsersInDatabase(users: [UserJSON]) {
        let backgroundContext = PersistenceController.shared.newTaskContext()
        users.forEach { user in
            User.createWith(firstName: user.firstName,
                            lastName: user.lastName,
                            username: user.username,
                            password: user.password,
                            userID: user.userID,
                            profilePicURL: user.profilePicURL,
                            in: backgroundContext)
        }
    }
    
    //MARK: -- SINGLE METHOD TO LOAD DATA FROM A GIVEN SOURCE
    func loadAllData(from: LoadingType, isLoaded: Binding<Bool>) async {
        CoreDataHelper.emptyDB()
        do {
            switch from {
            case .Local:
                try loadSampleUsers()
                print("Loading Samples Locally")
            case .LocalJSON:
                print("Local JSON Option selected, laoding from this not functional at this time")
            case .Web:
                print("Web JSON Option selected, laoding from this not functional at this time")
            }
            
            //add code here to take the read in data from any of the techniques and store it to the database
            storeUsersInDatabase(users: users ?? [])
            
            //      try PersistenceController.shared.container.viewContext.save()
            
        } catch {
            print("Error saving to core data \(error)")
        }
        isLoaded.wrappedValue = true
    }
}

