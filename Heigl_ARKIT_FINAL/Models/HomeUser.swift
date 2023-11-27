//
//  User.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/25/23.
//
//  Code created using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s

import Foundation

struct HomeUser: Identifiable, Codable {
	let id: String
	let fullname: String
	let email: String
	
	var initials: String {
		let formatter = PersonNameComponentsFormatter()
		if let components = formatter.personNameComponents(from: fullname) {
			formatter.style = .abbreviated
			return formatter.string(from: components)
		}
		
		return ""
	}
}

extension HomeUser {
	static var MOCK_USER = HomeUser(id: NSUUID().uuidString, fullname: "Kobe Bryant", email: "test@gmail.com")
}
