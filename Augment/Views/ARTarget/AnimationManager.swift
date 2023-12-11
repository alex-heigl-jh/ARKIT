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

	private func executeTask(_ task: AnimationMovementTask, for entity: ModelEntity, completion: @escaping () -> Void) {
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

		// Schedule completion
		DispatchQueue.main.asyncAfter(deadline: .now() + task.duration, execute: completion)
	}
	// Function to rotate a SIMD3<Float> vector by a quaternion
	func rotate(_ vector: SIMD3<Float>, by quaternion: simd_quatf) -> SIMD3<Float> {
		let quaternionVector = SIMD3<Float>(quaternion.vector.x, quaternion.vector.y, quaternion.vector.z)
		let t = 2 * cross(quaternionVector, vector)
		return vector + quaternion.vector.w * t + cross(quaternionVector, t)
	}
}

struct AnimationMovementTask {
	let animationName: String?
	let duration: TimeInterval
	let playbackSpeed: Float
	let moveDistance: SIMD3<Float> // x, y, z distances
	let finalRotation: simd_quatf
}

// MARK: AnimationMovementStrategies (AMS)
struct AMS {

	static func createQuaternion(rollDegrees: Float, pitchDegrees: Float, yawDegrees: Float) -> simd_quatf {
		let roll = simd_quaternion(rollDegrees * (Float.pi / 180), simd_float3(x: 0, y: 0, z: 1))
		let pitch = simd_quaternion(pitchDegrees * (Float.pi / 180), simd_float3(x: 1, y: 0, z: 0))
		let yaw = simd_quaternion(yawDegrees * (Float.pi / 180), simd_float3(x: 0, y: 1, z: 0))
		
		return roll * pitch * yaw
	}

	static let takeOff: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 5,
		playbackSpeed: 4,
		moveDistance: SIMD3<Float>(0, 2, 2),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: -45, yawDegrees: 0)
	)

	static let turnRight: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 2.5,
		playbackSpeed: 2,
		moveDistance: SIMD3<Float>(-1, 0, 0),
		finalRotation: createQuaternion(rollDegrees: -45, pitchDegrees: 0, yawDegrees: -90)
	)
	
	static let landSlow: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 5,
		playbackSpeed: 1,
		moveDistance: SIMD3<Float>(0, -2, -2),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: -45, yawDegrees: 0)
	)
	
	static let trafficOnGround: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 5,
		playbackSpeed: 0.5,
		moveDistance: SIMD3<Float>(0, 1, 0),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0)
	)
	
	static let moveFastStraight: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 5,
		playbackSpeed: 2,
		moveDistance: SIMD3<Float>(0, 0, 2),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0)
	)
	
	static let moveBackStraight: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 5,
		playbackSpeed: 1,
		moveDistance: SIMD3<Float>(0, 0, -2),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0)
	)
	
	static let moveSlowStraight: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 10,
		playbackSpeed: 1,
		moveDistance: SIMD3<Float>(0, 0, 2),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0)
	)
	
	static let moveBackSlowStraight: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 10,
		playbackSpeed: 1,
		moveDistance: SIMD3<Float>(0, 0, -2),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0)
	)
	
	static let noMovePlayAnimation: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 10,
		playbackSpeed: 1,
		moveDistance: SIMD3<Float>(0, 0, 0),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0)
	)
	
	static let noMoveFastPlayAnimation: AnimationMovementTask = AnimationMovementTask(
		animationName: "global scene animation",
		duration: 10,
		playbackSpeed: 4,
		moveDistance: SIMD3<Float>(0, 0, 0),
		finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0)
	)

	// Add more predefined tasks as needed
}
#endif
