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
	var mediaURL: String? // Can be an image or video URL
	var mediaType: String? // "image" or "video"
	var newsPosterID: String
}

