//
//  UserAuth.swift
//  ToDoApp
//
//  Created by Teacher on 9/11/22.
//

import Foundation
import Firebase

class UserAuth: ObservableObject {
	@Published var userSession: FirebaseAuth.User?
	@Published var currentUser: User?
	@Published var isLoggedIn = false
	
	init() {
		
	}
	
	func signIn(withEmail email: String, password: String) async throws {
		
	}
	
	func createUser(withEmail email: String, password: String, fullname: String) async throws {
		
	}
	
	func signOut() {
		
	}
	
	func deleteAccount() {
		
	}
	
	func fetchUser() async {
		
	}
	
	func login() {
			self.isLoggedIn = true
	}
	
	func logout() {
		self.isLoggedIn = false
	}
	
}
//class UserAuth: ObservableObject {
//
//  @Published var isLoggedIn = false
//
//  func login() {
//    self.isLoggedIn = true
//  }
//
//  func logout() {
//    self.isLoggedIn = false
//  }
//}
