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
	
	var profilePicURL: String {
		"https://media.licdn.com/dms/image/C4D03AQFRq4PURvVlYQ/profile-displayphoto-shrink_200_200/0/1589837964485?e=1706745600&v=beta&t=X4V2LaBq6Gee2ahrah3N-VTfTf03VePlOZ0HdYFyc14"
	}

	var firstName: String {
		nameComponents?.givenName ?? ""
	}

	var lastName: String {
		nameComponents?.familyName ?? ""
	}

	private var nameComponents: PersonNameComponents? {
		let formatter = PersonNameComponentsFormatter()
		return formatter.personNameComponents(from: fullname)
	}

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

