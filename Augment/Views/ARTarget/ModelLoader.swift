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

