//
//  IAPListing.swift
//  ToDoApp
//
//  Created by Teacher on 10/15/22.
//

import SwiftUI
import StoreKit

struct IAPListing: View {

  @State var alertIsShowing = false
  var iapDelegate: IAPViewDelegate

  init(delegate: IAPViewDelegate) {
	self.iapDelegate = delegate
  }

  var body: some View {

	List(iapDelegate.productsArray, id: \.self) { item in
	  Text("\(item.localizedTitle) (\(item.price))" ).onTapGesture {
		guard self.iapDelegate.transactionInProgress == false else { return }
		self.alertIsShowing = true
	  }.alert(isPresented: self.$alertIsShowing, content: {
		Alert(title: Text("AR Creator App"), message: Text("Purchase This?"),
		  primaryButton: .default(Text("Buy")) {
			self.iapDelegate.selectedProduct = self.iapDelegate.productsArray.firstIndex(of: item)
			let payment = SKPayment(product: self.iapDelegate.productsArray[self.iapDelegate.selectedProduct] as SKProduct)
			SKPaymentQueue.default().add(payment)
			self.iapDelegate.transactionInProgress = true
			self.alertIsShowing = false
		  },
		  secondaryButton: .cancel(Text("No")){
			self.alertIsShowing = false
		  })
	  })
	}
  }
}
