//
//  UserAuth.swift
//  ToDoApp
//
//  Code created using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import os.log

protocol AuthenticationFormProtocol {
	var formIsValid: Bool { get }
}

@MainActor // Used to publish all UI updates back on the main thread
class UserAuth: ObservableObject {
	// Firebase user objest
	@Published var userSession: FirebaseAuth.User?
	// User data model
	@Published var currentUser: HomeUser?
	
	@Published var isLoggedIn = false
	
	let log = Logger()
	
	init() {
		self.userSession = Auth.auth().currentUser
		print("DEBUG: Current user is \(userSession)")
//		userSession = nil
		Task {
			await fetchUser()
		}
	}
	
	func signIn(withEmail email: String, password: String) async throws {
		do {
			let result = try await Auth.auth().signIn(withEmail: email, password: password)
			self.userSession = result.user
			await fetchUser()
		} catch {
			log.info("Failed to login user with supplied credentials ")
		}
	}
	
	// Asynchronous function that can (potentially) throw an error
	func createUser(withEmail email: String, password: String, fullname: String) async throws {
		log.info("createUser from UserAuth")
		do {
			let result = try await Auth.auth().createUser(withEmail: email, password: password)
			self.userSession = result.user
			// Create our local user object
			let user = HomeUser(id: result.user.uid, fullname: fullname, email: email)
			let encodedUser = try Firestore.Encoder().encode(user)
			// Upload data to firebase
			try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
			await fetchUser()
			
		} catch {
			log.error("Failed to create user with error \(error.localizedDescription)")
		}
		
	}
	
	func signOut() {
		do {
			try Auth.auth().signOut() 	// Signs out user on backend
			self.userSession = nil		// Wipes out user session (should re-direct to login screen)
			self.currentUser = nil      // Wipes out current user data model 
		} catch {
			log.error("Failed to sign out with error \(error.localizedDescription)")
		}
	}
	
	func deleteAccount() async throws {
		
		log.info("deleteAccount triggered")
		// Ensure there is a user to delete
//		guard let user = Auth.auth().currentUser else { return }
//
//		do {
//			// Delete the user's data from Firestore
//			try await Firestore.firestore().collection("users").document(user.uid).delete()
//			
//			// Delete the user's account from Firebase Authentication
//			try await user.delete()
//
//			// Reset the local user session and current user data
//			self.userSession = nil
//			self.currentUser = nil
//
//			// Additional UI update logic can go here (like navigating to a login screen)
//		} catch {
//			print("DEBUG: Failed to delete user account with error \(error.localizedDescription)")
//			throw error // Rethrow the error to be handled by the caller
//		}
	}

	
	func fetchUser() async {
		guard let uid = Auth.auth().currentUser?.uid else { return }
		guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else { return }
		self.currentUser = try? snapshot.data(as: HomeUser.self)
		
		print("Current user is \(self.currentUser)")
	}
}
