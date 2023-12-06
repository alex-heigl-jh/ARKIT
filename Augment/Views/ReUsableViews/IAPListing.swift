//
//  IAPListing.swift
//  ToDoApp
//
//  Created by Teacher on 10/15/22.
//

import SwiftUI
import StoreKit
import CoreData

struct IAPListing: View {
	@State var alertIsShowing = false
	@State var purchasedIAPs: Set<String> = []
	var iapDelegate: IAPViewDelegate
	var managedObjectContext: NSManagedObjectContext

	init(delegate: IAPViewDelegate, context: NSManagedObjectContext) {
		self.iapDelegate = delegate
		self.managedObjectContext = context
	}

	var body: some View {
		List(iapDelegate.productsArray.filter { !purchasedIAPs.contains($0.productIdentifier) }, id: \.self) { item in
			// \(item.localizedTitle)
			Text("\(item.localizedTitle) (\(item.price)$)" ).onTapGesture {
				guard self.iapDelegate.transactionInProgress == false else { return }
				self.alertIsShowing = true
			}.alert(isPresented: $alertIsShowing, content: {
				Alert(title: Text("AR Creator App"), message: Text("Would you like to Purchase This?"),
				primaryButton: .default(Text("Buy")) {
					if let selectedProductIndex = self.iapDelegate.productsArray.firstIndex(of: item) {
						self.iapDelegate.selectedProduct = selectedProductIndex
						let payment = SKPayment(product: self.iapDelegate.productsArray[selectedProductIndex])
						SKPaymentQueue.default().add(payment)
						self.iapDelegate.transactionInProgress = true
						self.alertIsShowing = false
					}
				},
				secondaryButton: .cancel(Text("No")) {
					self.alertIsShowing = false
				})
			})
		}
		.onAppear {
			fetchPurchasedIAPs()
		}
	}

	private func fetchPurchasedIAPs() {
		let fetchRequest: NSFetchRequest<IAP> = IAP.fetchRequest()
		fetchRequest.predicate = NSPredicate(format: "purchased == %@", NSNumber(value: true))

		do {
			let results = try managedObjectContext.fetch(fetchRequest)
			purchasedIAPs = Set(results.compactMap { $0.name }) // Make sure 'name' attribute is being used consistently as the identifier for your IAPs
			print("Purchased IAPs: \(purchasedIAPs)")
		} catch {
			print("Error fetching purchased IAPs: \(error)")
		}
	}

	private func updateIAPPurchasedStatus(name: String, context: NSManagedObjectContext) {
		print("Attempting to update IAP purchased status for \(name)")
		
		context.performAndWait {
			let fetchRequest: NSFetchRequest<IAP> = IAP.fetchRequest()
			fetchRequest.predicate = NSPredicate(format: "name == %@", name)
			
			do {
				let results = try context.fetch(fetchRequest)
				if let iap = results.first {
					print("Found IAP entry with name: \(name). Updating purchased status to true.")
					iap.purchased = true // Update the purchased status
					try context.save()
					print("Successfully updated purchased status for \(name).")
				} else {
					print("No IAP entry found with the name \(name).")
				}
			} catch {
				print("Error fetching IAP with name \(name): \(error.localizedDescription)")
			}
		}
	}
}
