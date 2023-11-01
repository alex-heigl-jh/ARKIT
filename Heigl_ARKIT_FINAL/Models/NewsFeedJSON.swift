//
//  NewsFeedJSON.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/1/23.
//

import Foundation

struct NewsFeedJSON: Codable {
	
	var newsContent: String
	var newsCreatedOn: Date
	var newsID: UUID
	var newsPicture: String?
	var newsPosterID: UUID
	var newsTitle: String
	var newsType: String
	var newsVideo: String?
	
}
