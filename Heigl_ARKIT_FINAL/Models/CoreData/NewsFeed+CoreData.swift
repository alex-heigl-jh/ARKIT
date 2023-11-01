//
//  NewsFeed+CoreData.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import Foundation
import CoreData

extension NewsFeed {

  static func createWith(
    newsContent: String,
	newsCreatedOn: Date,
    newsID: UUID,
    newsPicture: String,
    newsPosterID: UUID,
    newsTitle: String,
    newsType: String,
    newsVideo: String,
    in context: NSManagedObjectContext
  ) {
    context.perform {
        let item = NewsFeed(context: context)
        item.newsContent = newsContent
		item.newsCreatedOn = newsCreatedOn
        item.newsID = newsID
        item.newsPicture = newsPicture
        item.newsPosterID = newsPosterID
        item.newsTitle = newsTitle
        item.newsType = newsType
        item.newsVideo = newsVideo
		
		if let user = User.fetchUserBy(userID: newsPosterID, in: context) {
			item.poster = user
			user.addToPost(item)
		}
		
		print("News feed titled \(newsTitle) created.")
		
      do {
        try context.save()
      } catch {
        fatalError("Problem saving NewsFeed to CoreData")
      }
    }
  }
}
