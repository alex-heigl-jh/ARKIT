//
//  Heigl_ARKIT_FINALApp.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI

@main
struct Heigl_ARKIT_FINALApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
