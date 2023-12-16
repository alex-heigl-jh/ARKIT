//
//  AnimationManager.swift
//  Augment
//
//  Created by Alex Heigl on 12/10/23.
//

#if !targetEnvironment(simulator)
import ARKit
import RealityKit
import Foundation
import simd


// MARK: Class that handles the queueing of animation tasks so that they can be executed sequentially
class AnimationQueueManager {
	private var taskQueue: [AnimationMovementTask] = []
	private var isExecuting = false

	func enqueue(_ task: AnimationMovementTask, for entity: ModelEntity) {
		taskQueue.append(task)
		executeNextIfPossible(for: entity)
	}

	private func executeNextIfPossible(for entity: ModelEntity) {
		guard !isExecuting, let nextTask = taskQueue.first else { return }
		isExecuting = true
		taskQueue.removeFirst()

		executeTask(nextTask, for: entity) {
			self.isExecuting = false
			self.executeNextIfPossible(for: entity)
		}
	}

//	private func executeTask(_ task: AnimationMovementTask, for entity: ModelEntity, completion: @escaping () -> Void) {
//		// Perform animation if available
//		if let animationName = task.animationName,
//		   let animation = entity.availableAnimations.first(where: { $0.name == animationName }) {
//			let controller = entity.playAnimation(animation.repeat(duration: .infinity),
//												  transitionDuration: 0.5,
//												  separateAnimatedValue: true,
//												  startsPaused: false)
//			controller.speed = task.playbackSpeed
//		}
//
//		// Calculate new position and rotation relative to current transform
//		let currentRotation = entity.transform.rotation
//		let newRotation = currentRotation * task.finalRotation
//		let moveVector = rotate(task.moveDistance, by: currentRotation) // Rotate the vector
//		let newPosition = entity.position + moveVector
//
//		// Apply new transform
//		let newTransform = Transform(scale: entity.transform.scale, rotation: newRotation, translation: newPosition)
//		entity.move(to: newTransform, relativeTo: entity.parent, duration: task.duration, timingFunction: .linear)
//		
//		// Handle repeating the task
//		if let repeatCount = task.repeatCount {
//			for _ in 0..<repeatCount {
//				// Perform the task
//			}
//		} else {
//			// Perform the task infinitely
//		}
//
//
//		// Schedule completion
//		DispatchQueue.main.asyncAfter(deadline: .now() + task.duration, execute: completion)
//	}
	
	
	private func executeTask(_ task: AnimationMovementTask, for entity: ModelEntity, completion: @escaping () -> Void) {
		func performAnimation(repeatCount: Int?) {
			// Perform animation if available
			if let animationName = task.animationName,
			   let animation = entity.availableAnimations.first(where: { $0.name == animationName }) {
				let controller = entity.playAnimation(animation.repeat(duration: .infinity),
													  transitionDuration: 0.5,
													  separateAnimatedValue: true,
													  startsPaused: false)
				controller.speed = task.playbackSpeed
			}

			// Calculate new position and rotation relative to current transform
			let currentRotation = entity.transform.rotation
			let newRotation = currentRotation * task.finalRotation
			let moveVector = rotate(task.moveDistance, by: currentRotation) // Rotate the vector
			let newPosition = entity.position + moveVector

			// Apply new transform
			let newTransform = Transform(scale: entity.transform.scale, rotation: newRotation, translation: newPosition)
			entity.move(to: newTransform, relativeTo: entity.parent, duration: task.duration, timingFunction: .linear)

			// Check if repeat is needed
			if let repeatCount = repeatCount {
				if repeatCount > 1 {
					// Schedule next repetition
					DispatchQueue.main.asyncAfter(deadline: .now() + task.duration) {
						performAnimation(repeatCount: repeatCount - 1)
					}
				} else {
					// No more repetitions, call completion
					DispatchQueue.main.asyncAfter(deadline: .now() + task.duration, execute: completion)
				}
			} else {
				// Infinite repeat, call recursively with nil
				DispatchQueue.main.asyncAfter(deadline: .now() + task.duration) {
					performAnimation(repeatCount: nil)
				}
			}
		}

		// Start the animation process
		performAnimation(repeatCount: task.repeatCount)
	}

	
	
	// Function to rotate a SIMD3<Float> vector by a quaternion
	func rotate(_ vector: SIMD3<Float>, by quaternion: simd_quatf) -> SIMD3<Float> {
		let quaternionVector = SIMD3<Float>(quaternion.vector.x, quaternion.vector.y, quaternion.vector.z)
		let t = 2 * cross(quaternionVector, vector)
		return vector + quaternion.vector.w * t + cross(quaternionVector, t)
	}
}

#endif
