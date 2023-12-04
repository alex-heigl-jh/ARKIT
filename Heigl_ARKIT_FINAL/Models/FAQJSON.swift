//
//  FAQJSON.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 12/3/23.
//

import Foundation

struct FAQJSON: Codable {
	var faqContent: String
	var faqID: UUID
	var faqTitle: String
	var mediaURL: String // Can be an image or video URL
	var mediaType: String // "image" or "video"
	
}
