//
//  IAPViewDelegate.swift
//  ToDoApp
//
//  Created by Teacher on 10/15/22.
//
//  Further modified and enhanced by student

import Foundation
import StoreKit

class IAPViewDelegate: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver
{
  //product display
  var productIDs: [String] = []

  var productsArray: [SKProduct] = []

  //purchase
  var selectedProduct:Int!
  var transactionInProgress = false

  override init() {
	super.init()
	//product list
	productIDs.append("edu.jhu.ep.ToDoApp.DisableAds")
	self.requestProductsFromStore()

	//payment
	SKPaymentQueue.default().add(self)
  }

  //product list
  func requestProductsFromStore()
  {
	if SKPaymentQueue.canMakePayments()
	{
	  let productIDArray = NSSet(array: productIDs)
	  let request = SKProductsRequest(productIdentifiers: productIDArray as! Set<String>)
	  request.delegate = self
	  request.start()
	}
	else
	{
	  print("Can't make In App Purchases - please setup a payment plan")
	}
  }

  //SKProductsRequestDelegate
  func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse)
  {
	//the response contains the elements of our SKProducts array
	guard response.products.count != 0 else { print("No products!"); return }
	response.products.forEach({productsArray.append($0)})

	if response.invalidProductIdentifiers.count != 0
	{
	  //print(response.invalidProductIdentifiers.description)
	}
  }

  //payment
  func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction])
  {
	for transaction in transactions
	{
	  switch transaction.transactionState
	  {
	  case .purchased:
		print("Transaction completed successfully.")
		SKPaymentQueue.default().finishTransaction(transaction)
		transactionInProgress = false
		unlockAds()

	  case .failed:
		print("Transaction Failed");
		SKPaymentQueue.default().finishTransaction(transaction)
		transactionInProgress = false

	  default:
		print(transaction.transactionState.rawValue)
	  }
	}
  }

  //unlock functionality
  func unlockAds()
  {
	let defaults = UserDefaults.standard
	defaults.set(false, forKey: "showAds")
  }
}

