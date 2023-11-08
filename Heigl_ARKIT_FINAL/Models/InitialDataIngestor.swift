//
//  InitialDataIngestor.swift
//  ToDoApp
//

import Foundation
import SwiftUI
import CoreData

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
	@Published var newsFeed: [NewsFeedJSON]?
	@Published var safety: [SafetyJSON]?
    
	// Function for generating dates at different offsets
	func dateOffsetBy(minutes: Int) -> Date {
		return Calendar.current.date(byAdding: .minute, value: -minutes, to: Date())!
	}

	//MARK: -- Hardcoded Data
	func loadSampleUsers() throws {
		// Generate sample users
		let user1 = UserJSON(uuid: UUID(), firstName: "John", lastName: "Doe", username: "johndoe", password: "password123", userID: UUID(), profilePicURL: "https://images.unsplash.com/photo-1547425260-76bcadfb4f2c?auto=format&fit=crop&q=80&w=3270&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
		let user2 = UserJSON(uuid: UUID(), firstName: "Jane", lastName: "Smith", username: "janesmith", password: "password456", userID: UUID(), profilePicURL: "https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&q=80&w=3388&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
		let user3 = UserJSON(uuid: UUID(), firstName: "Alice", lastName: "Johnson", username: "alicejohnson", password: "password789", userID: UUID(), profilePicURL: "https://images.unsplash.com/photo-1491349174775-aaafddd81942?auto=format&fit=crop&q=80&w=3387&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
		let user4 = UserJSON(uuid: UUID(), firstName: "Bob", lastName: "Williams", username: "bobwilliams", password: "password012", userID: UUID(), profilePicURL: "https://plus.unsplash.com/premium_photo-1674777843203-da3ebb9fbca0?auto=format&fit=crop&q=80&w=2473&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")
		let user5 = UserJSON(uuid: UUID(), firstName: "Charlie", lastName: "Brown", username: "charliebrown", password: "password345", userID: UUID(), profilePicURL: "https://i.pinimg.com/564x/8a/9f/e1/8a9fe1802c659be4edfed58f778ae2b5.jpg")
		
		// Store sample users in the published variable
		self.users = [user1, user2, user3, user4, user5]
	}
	
	func loadSampleNewsFeed() throws {
		// Assuming you have users loaded already
		guard let users = self.users, users.count >= 5 else {
			print("Please ensure users are loaded first")
			return
		}
		
		let news1 = NewsFeedJSON(
			newsContent: "Enjoying a delicious cheeseburger at AJ Bombers in Milwaukee. The cheese curds here are to die for!",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 0),
			newsID: UUID(),
			newsPicture: "https://pbs.twimg.com/media/FA4Lh22XsAgzsBN?format=jpg&name=large",
			newsPosterID: users[0].userID,
			newsTitle: "Cheeseburger Heaven",
			newsType: "Food",
			newsVideo: nil
		)
		
		let news2 = NewsFeedJSON(
			newsContent: "Exploring the beautiful Milwaukee Art Museum and its stunning architecture. A must-visit for art lovers!",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 1),
			newsID: UUID(),
			newsPicture: "https://lp-cms-production.imgix.net/2022-03/United%20States%20Milwaukee%20Izzet%20Keribar%20GettyImages-525734479%20RFE%20crop.jpg",
			newsPosterID: users[1].userID,
			newsTitle: "Art Museum Exploration",
			newsType: "Art",
			newsVideo: nil
		)
		
		let news3 = NewsFeedJSON(
			newsContent: "Biking along the Oak Leaf Trail on a sunny day in Milwaukee. The scenery is breathtaking!",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 2),
			newsID: UUID(),
			newsPicture: "https://www.railstotrails.org/media/550728/oak-leaf-trail-06559-courtesy-wisconsin-bike-fed-copy.jpg?crop=0,0,0.3559420289855072,0&cropmode=percentage&width=880&height=460&rnd=131613518230000000",
			newsPosterID: users[2].userID,
			newsTitle: "Scenic Bike Ride",
			newsType: "Outdoor",
			newsVideo: nil
		)
		
		let news4 = NewsFeedJSON(
			newsContent: "Milwaukee Bucks showing how to actually trust a process at Fiserv Forum tonight - Meanwhile, the 76ers are still processing... Bucks in 6!!",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 3),
			newsID: UUID(),
			newsPicture: "https://phantom-marca.unidadeditorial.es/e89728cbbdf7774ffa2c09d2bada05e5/resize/828/f/jpg/assets/multimedia/imagenes/2023/10/27/16983751324397.jpg",
			newsPosterID: users[3].userID,
			newsTitle: "Bucks Game Night",
			newsType: "Sports",
			newsVideo: nil
		)
		
		let news5 = NewsFeedJSON(
			newsContent: "Visiting the Harley-Davidson Museum and admiring the iconic motorcycles. A piece of American history!",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 4),
			newsID: UUID(),
			newsPicture: "https://www.harley-davidson.com/content/dam/h-d/images/content-images/short-hero/museum-night-short-hero.jpg",
			newsPosterID: users[4].userID,
			newsTitle: "Harley-Davidson Museum Visit",
			newsType: "Museum",
			newsVideo: nil
		)
		
		let news6 = NewsFeedJSON(
			newsContent: "Savoring some custard at Kopp's Frozen Custard. Best dessert in Milwaukee!",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 5),
			newsID: UUID(),
			newsPicture: "https://kopps.com/wp-content/uploads/2023/02/Greenfield.jpg",
			newsPosterID: users[0].userID,
			newsTitle: "Custard Delight",
			newsType: "Food",
			newsVideo: nil
		)
		
		let news7 = NewsFeedJSON(
			newsContent: "Exploring the Milwaukee County Zoo and meeting some amazing animals.",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 6),
			newsID: UUID(),
			newsPicture: "https://www.travelwisconsin.com/uploads/places/4f/4ff458ad-e148-486a-ad43-9ba9312166bf-elephants-in-pool-07-2021-37-e.jpg",
			newsPosterID: users[1].userID,
			newsTitle: "Zoo Adventure",
			newsType: "Adventure",
			newsVideo: nil
		)
		
		let news8 = NewsFeedJSON(
			newsContent: "Hiking at Kettle Moraine State Forest. The trails offer a peaceful escape from the city.",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 7),
			newsID: UUID(),
			newsPicture: "https://emke.uwm.edu/wp-content/uploads/2018/04/KettleMoraine_01.jpg",
			newsPosterID: users[2].userID,
			newsTitle: "Nature Hike",
			newsType: "Outdoor",
			newsVideo: nil
		)
		
		let news9 = NewsFeedJSON(
			newsContent: "Exploring the historic Pabst Brewery in Milwaukee. Cheers to local beer!",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 8),
			newsID: UUID(),
			newsPicture: "https://www.jsonline.com/gcdn/-mm-/1fecae5856e58374cc9e1c0fd6dcc3c6aae79d4e/c=0-293-5760-3547/local/-/media/2018/05/06/WIGroup/Milwaukee/636612474576008288-sunset-pabst-jesu-desisti-sisti-3237.JPG",
			newsPosterID: users[3].userID,
			newsTitle: "Brewery Tour",
			newsType: "Brewery",
			newsVideo: nil
		)
		
		let news10 = NewsFeedJSON(
			newsContent: "Dancing the night away at Summerfest, Milwaukee's biggest music festival.",
			newsCreatedOn: dateOffsetBy(minutes: 10 * 9),
			newsID: UUID(),
			newsPicture: "https://dynamic-media-cdn.tripadvisor.com/media/photo-o/0f/df/b4/7e/summerfest-grounds.jpg?w=1200&h=-1&s=1",
			newsPosterID: users[4].userID,
			newsTitle: "Summerfest Party",
			newsType: "Music",
			newsVideo: nil
		)
		
		self.newsFeed = [news1, news2, news3, news4, news5, news6, news7, news8, news9, news10]
	}
	
	func loadSafetyData() throws {
		// Generate sample safety data
		let safety1 = SafetyJSON(
			safContent: "When using AR apps, it's important to be aware of your surroundings to avoid tripping over obstacles or colliding with objects.",
			safID: UUID(),
			safPicture: "https://allrisktraining.com/allrisktraining/wp-content/uploads/2013/10/blog3.jpg",
			safTitle: "Be Aware of Your Surroundings",
			safVideo: nil
		)
		let safety2 = SafetyJSON(
			safContent: "Prolonged use of AR apps may cause eye strain or fatigue. Remember to take regular breaks to rest your eyes.",
			safID: UUID(),
			safPicture: "https://www.eyesightassociates.com/wp-content/uploads/2017/02/iStock-492322226-low-res-400x300.jpg",
			safTitle: "Prevent Eye Strain",
			safVideo: nil
		)
		let safety3 = SafetyJSON(
			safContent: "AR applications may use a lot of battery power. Ensure your device is sufficiently charged before extended use.",
			safID: UUID(),
			safPicture: "https://support.apple.com/library/content/dam/edam/applecare/images/en_US/iOS/ios-16-1-iphone-13-pro-settings-battery.png",
			safTitle: "Monitor Battery Usage",
			safVideo: nil
		)
		let safety4 = SafetyJSON(
			safContent: "Using headphones while using AR apps can lead to reduced awareness of your surroundings. Use at a low volume or use open-ear headphones.",
			safID: UUID(),
			safPicture: "https://static.vecteezy.com/system/resources/thumbnails/005/863/329/small_2x/no-headphones-sign-headphones-forbidden-icon-illustration-free-vector.jpg",
			safTitle: "Sound Safety",
			safVideo: nil
		)
		let safety5 = SafetyJSON(
			safContent: "Ensure that your AR app has appropriate privacy settings. This application requires access to the camera and the users location to function properly.",
			safID: UUID(),
			safPicture: "https://support.apple.com/library/content/dam/edam/applecare/images/en_US/iOS/ios-16-iphone-14-pro-maps-allow-maps-to-access-location-while-using-app.png",
			safTitle: "Privacy Concerns",
			safVideo: nil
		)
		
		// Store sample safety data in a variable or use them as needed
		self.safety = [safety1, safety2, safety3, safety4, safety5]
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
		print("Storing \(users.count) users in database...")
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
    
	func storeNewsFeedInDatabase(newsFeeds: [NewsFeedJSON]) {
		print("Storing \(newsFeeds.count) news feeds in database...")
		let backgroundContext = PersistenceController.shared.newTaskContext()
		newsFeeds.forEach { news in
			NewsFeed.createWith(
				newsContent: news.newsContent,
				newsCreatedOn: news.newsCreatedOn,
				newsID: news.newsID,
				newsPicture: news.newsPicture ?? "nil",
				newsPosterID: news.newsPosterID,
				newsTitle: news.newsTitle,
				newsType: news.newsType,
				newsVideo: news.newsVideo ?? "nil",
				in: backgroundContext
			)
		}
	}
		
	func storeSafetyInDatabase(safety: [SafetyJSON]) {
		print("Storing \(safety.count) Safety object in database...")
		let backgroundContext = PersistenceController.shared.newTaskContext()
		safety.forEach { saf in
			Safety.createWith(
				safContent: saf.safContent,
				safID: saf.safID,
				safPicture: saf.safPicture ?? "nil",
				safTitle: saf.safTitle,
				safVideo: saf.safVideo ?? "nil",
				in: backgroundContext
			)
		}

		// Save context
		do {
			try backgroundContext.save()
		} catch {
			print("Error saving news feed data to CoreData:", error)
		}
	}
	
    //MARK: -- SINGLE METHOD TO LOAD DATA FROM A GIVEN SOURCE
    func loadAllData(from: LoadingType, isLoaded: Binding<Bool>) async {
        CoreDataHelper.emptyDB()
        do {
            switch from {
            case .Local:
                try loadSampleUsers()
				try loadSampleNewsFeed()
				try loadSafetyData()
                print("Loading Samples Locally")
            case .LocalJSON:
                print("Local JSON Option selected, laoding from this not functional at this time")
            case .Web:
                print("Web JSON Option selected, laoding from this not functional at this time")
            }
            
            //add code here to take the read in data from any of the techniques and store it to the database
            storeUsersInDatabase(users: users ?? [])
			storeNewsFeedInDatabase(newsFeeds: newsFeed ?? [])
			storeSafetyInDatabase(safety: safety ?? [])
            
            try PersistenceController.shared.container.viewContext.save()
            
        } catch {
            print("Error saving to core data \(error)")
        }
        isLoaded.wrappedValue = true
    }
}
