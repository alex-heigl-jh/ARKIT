//
//  Heigl_ARKIT_FINALApp.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//
//  Code augmented using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s

import SwiftUI
import Firebase

@main
struct Augment: App {
	
	@StateObject var viewModel = UserAuth()
	
	let persistenceController = PersistenceController.shared
	
	init() {
		FirebaseApp.configure()
	}
  
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				LoginView()
					.environment(\.managedObjectContext, persistenceController.container.viewContext)
					.environmentObject(viewModel)
			}
		}
	}
}
