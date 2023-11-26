//
//  Heigl_ARKIT_FINALApp.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI
import ARVideoKit

@main
struct Heigl_ARKIT_FINAL: App {
	@StateObject var viewModel = UserAuth()
	
	let persistenceController = PersistenceController.shared
  
	var body: some Scene {
		WindowGroup {
			NavigationStack {
				LoginView()
					.environment(\.managedObjectContext, persistenceController.container.viewContext)
					.environmentObject(UserAuth())
			}
		}
	}
}
