//
//  ARClassExtensions.swift
//  Augment
//
//  Created by Alex Heigl on 12/10/23.
//

#if !targetEnvironment(simulator)
import Foundation
import ARKit
import RealityKit
import Combine
import FocusEntity
import Photos
import ReplayKit
import SwiftUI
import simd

// MARK: Create extension of ARView to enable longPressGesture to delete AR object
extension RealityKit.ARView {
	//: Create enableObjectRemoval() function to add longPressGesture recognizer
	func enableObjectRemoval(){
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
		self.addGestureRecognizer(longPressGestureRecognizer)
	}
	
	//: Create selector to handleLongPress
	@objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
		guard recognizer.state == .began else { return } // Check if the gesture has just begun

		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) {
			entity.removeFromParent() // Directly remove the entity
			print("DEBUG: Removed entity")
		}
	}
}


extension CustomARView: RPPreviewViewControllerDelegate {
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		previewController.dismiss(animated: true)
	}
}

#endif
