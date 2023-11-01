//
//  NewsFeedVieew.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI
import CoreData


struct NewsFeedView: View {
	
	@Environment(\.managedObjectContext) private var viewContext
	
	@FetchRequest(
		entity: NewsFeed.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \NewsFeed.newsCreatedOn, ascending: false)]
	) var newsFeeds: FetchedResults<NewsFeed>

	var body: some View {
		NavigationView {
			// Check if newsFeeds is empty
			if newsFeeds.isEmpty {
				Text("No news available")
					.onAppear {
						print("No news items found.")
					}
			} else {
				List(newsFeeds) { feed in
					VStack(alignment: .leading, spacing: 10) {
						HStack(spacing: 15) {
							if let poster = feed.poster, let urlString = poster.profilePicURL, let url = URL(string: urlString) {
								AsyncImage(url: url, content: { image in
									image
										.resizable()
										.scaledToFit()
										.frame(width: 60, height: 60)
										.clipShape(Circle())
								}, placeholder: {
									Text("Loading...")
								})
								.onAppear {
									print("Loading profile picture from URL: \(urlString)")
								}
							} else {
								Image(systemName: "person.fill")
									.resizable()
									.scaledToFit()
									.frame(width: 60, height: 60)
									.clipShape(Circle())
									.onAppear {
										print("Profile picture URL is either nil or invalid.")
									}
							}
							
							VStack(alignment: .leading) {
								HStack {
									Text("\(feed.poster?.firstName ?? "") \(feed.poster?.lastName ?? "")")
										.font(.headline)
										.onAppear {
											print("Displaying username: \(feed.poster?.firstName ?? "Unknown") \(feed.poster?.lastName ?? "Unknown")")
										}

									Spacer() // Pushes the date to the right end of the HStack

									Text(feed.newsCreatedOn ?? Date(), style: .date) // Display the date
										.font(.subheadline)
										.foregroundColor(Color.gray) // Give the date a subtle color
								}

								Text(feed.newsContent ?? "")
									.font(.subheadline)
									.onAppear {
										print("Displaying news content: \(feed.newsContent ?? "No Content")")
									}
							}
						}
						
						if let newsImageUrlString = feed.newsPicture, let newsImageUrl = URL(string: newsImageUrlString) {
							AsyncImage(url: newsImageUrl, content: { image in
								image
									.resizable()
									.scaledToFit()
									.cornerRadius(10)
							}, placeholder: {
								Text("Loading news image...")
							})
							.onAppear {
								print("Loading news image from URL: \(newsImageUrlString)")
							}
						}
					}
					.onAppear {
						print("Attempting to display a news feed item.")
					}
				}
			}
		}
		.navigationBarTitle("News Feed", displayMode: .inline) // Moved outside the if-else block
	}
}

struct NewsFeedView_Previews: PreviewProvider {
	static var previews: some View {
		NewsFeedView()
	}
}
