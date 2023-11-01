//
//  SafetyJSON.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/1/23.
//

import Foundation

struct SafetyJSON: Codable {
	var safContent: String
	var safID: UUID
	var safPicture: String?
	var safTitle: String
	var safVideo: String?
	
}
