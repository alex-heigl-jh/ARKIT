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
            } catch {
                fatalError("Problem saving in app purchase")
            }
        }
    }
}
