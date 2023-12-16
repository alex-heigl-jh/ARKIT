//
//  NewsFeed+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData
import os.log

extension NewsFeed {
	static func createWith(
		newsContent: String,
		newsCreatedOn: Date,
		newsID: UUID,
		mediaURL: String?,
		mediaType: String?,
		newsPosterID: String,
		in context: NSManagedObjectContext
	) {
		context.perform {
			let item = NewsFeed(context: context)
			item.newsContent = newsContent
			item.newsCreatedOn = newsCreatedOn
			item.newsID = newsID
			item.mediaURL = mediaURL
			item.mediaType = mediaType 
		
		if let user = User.fetchUserBy(userID: newsPosterID, in: context) {
			item.poster = user
			user.addToPost(item)
		}
		
			print("News feed with ID \(newsID) created.")
		
      do {
        try context.save()
      } catch {
		  print("Problem saving NewsFeed to CoreData")
      }
    }
  }
}
