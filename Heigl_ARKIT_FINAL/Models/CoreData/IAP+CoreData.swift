//
//  IAP+CoreData.swift
//  ToDoApp
//
//  Created by Teacher on 9/17/22.
//

import Foundation
import CoreData

extension IAP {
	static func createWith(
		name: String,
		desc: String,
		price: Double,
		purchased: Bool,
		in context: NSManagedObjectContext
	) {
		context.perform {
			let item = IAP(context: context)
			item.name = name
			item.desc = desc
			item.price = price
			item.purchased = purchased
			
			do {
				try context.save()
				// Print statement to log that the IAP has been successfully added and saved
				print("Successfully added and saved IAP: \(name), Price: \(price), Purchased: \(purchased)")
			} catch {
				// Updated to print error instead of fatalError to prevent app crash and log error
				print("Error saving in app purchase: \(error.localizedDescription)")
			}
		}
	}
}
