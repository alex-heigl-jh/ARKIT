//
//  Models.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/21/23.
//
//  Code initially based off tutorial from: https://www.youtube.com/watch?v=9R_G0EI-UoI&t=2820s

import Foundation
import UIKit
import RealityKit
import Combine

class Model {
	var modelName: String
	var image: UIImage
	var modelEntity: ModelEntity?
	var animationNames: [String] = [] // Store animation names
	private var cancellable: AnyCancellable? = nil

	init(modelName: String) {
		self.modelName = modelName
		self.image = UIImage(named: modelName)!

		let filename = modelName + ".usdz"

		self.cancellable = ModelEntity.loadModelAsync(named: filename)
			.sink(receiveCompletion: { [weak self] loadCompletion in
				switch loadCompletion {
				case .failure(let error):
					print("DEBUG: Unable to load modelEntity for modelName: \(self?.modelName ?? ""), error: \(error)")
				case .finished:
					break
				}
			}, receiveValue: { [weak self] modelEntity in
				guard let self = self else { return }
				self.modelEntity = modelEntity
				print("DEBUG: Successfully loaded modelEntity for modelName: \(self.modelName)")
				self.listAnimations(modelEntity) // List available animations
			})
	}

	// Method to list available animations
	private func listAnimations(_ modelEntity: ModelEntity) {
		animationNames = modelEntity.availableAnimations.map { $0.name ?? "" }
		print("DEBUG: Available animations for \(modelName): \(animationNames.joined(separator: ", "))")
	}
}






//import Foundation
//import UIKit
//import RealityKit
//import Combine
//
//class Model {
//	var modelName: String
//	var image: UIImage
//	var modelEntity: ModelEntity?
//	var cancellable: AnyCancellable? = nil
//	var cancellables = Set<AnyCancellable>() // Store multiple AnyCancellable if needed
//
//	init(modelName: String) {
//		self.modelName = modelName
//		self.image = UIImage(named: modelName)!
//		self.loadModelEntity(modelName: modelName)
//	}
//
//	private func loadModelEntity(modelName: String) {
//		let usdzFilename = modelName + ".usdz"
//		let realityFilename = modelName + ".reality"
//
//		// Try to load the USDZ model asynchronously
//		ModelEntity.loadModelAsync(named: usdzFilename)
//			.sink(receiveCompletion: { [weak self] loadCompletion in
//				switch loadCompletion {
//				case .failure(_):
//					// If loading USDZ fails, try loading the Reality model
//					self?.loadModelEntityFromRealityFile(named: realityFilename)
//				case .finished:
//					break
//				}
//			}, receiveValue: { [weak self] modelEntity in
//				// Successfully loaded USDZ model
//				self?.modelEntity = modelEntity
//				print("DEBUG: Successfully loaded USDZ modelEntity for modelName: \(modelName)")
//			})
//			.store(in: &cancellables)
//	}
//
//	private func loadModelEntityFromRealityFile(named modelName: String) {
//		// The modelName should be the name of the .reality file without the extension.
//		guard let realityFileURL = Bundle.main.url(forResource: modelName, withExtension: "reality") else {
//			print("DEBUG: Could not find .reality file for modelName: \(modelName)")
//			return
//		}
//
//		// Load the entire .reality file asynchronously
//		cancellable = Entity.loadAnchorAsync(contentsOf: realityFileURL)
//			.sink(receiveCompletion: { loadCompletion in
//				switch loadCompletion {
//				case .failure(let error):
//					print("DEBUG: Error loading .reality file: \(error.localizedDescription)")
//				case .finished:
//					print("DEBUG: Finished loading .reality file")
//				}
//			}, receiveValue: { [weak self] anchorEntity in
//				// The anchorEntity contains all the content of the .reality file.
//				// If you just want to preload the content, you can keep a reference
//				// to the anchorEntity and add it to the ARView at the appropriate time.
//				self?.modelEntity = anchorEntity // Keep a reference to the loaded content
//				print("DEBUG: Successfully preloaded .reality file for modelName: \(modelName)")
//			})
//	}
//}




// MARK: Origional Implementation

//class Model {
//	var modelName: String
//	var image: UIImage
//	var modelEntity: ModelEntity?
//	
//	private var cancellable : AnyCancellable? = nil
//	
//	
//	init(modelName: String) {
//		self.modelName = modelName
//		
//		self.image = UIImage(named: modelName)!
//		
//		let filename = modelName + ".usdz"
//		
//		self.cancellable = ModelEntity.loadModelAsync(named: filename)
//			.sink(receiveCompletion: { loadCompletion in
//				// Handle our error
//				print("DEBUG: Unable to load modelEntity for modelName: \(self.modelName)")
//			}, receiveValue: { modelEntity in
//				// Get our modelEntity
//				self.modelEntity = modelEntity
//				print("DEBUG: Succesfully loaded modelEntity for modelName: \(self.modelName)")
//			})
//	}
//}
