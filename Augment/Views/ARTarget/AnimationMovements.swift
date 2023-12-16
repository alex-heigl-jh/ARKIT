//
//  AnimationMovements.swift
//  Augment
//
//  Created by Alex Heigl on 12/13/23.
//

#if !targetEnvironment(simulator)
import ARKit
import RealityKit
import Foundation
import simd
import Foundation

// MARK: AnimationMovementStrategies (AMS)
struct AMS {

	static func createQuaternion(rollDegrees: Float, pitchDegrees: Float, yawDegrees: Float) -> simd_quatf {
		let roll = simd_quaternion(rollDegrees * (Float.pi / 180), simd_float3(x: 0, y: 0, z: 1))
		let pitch = simd_quaternion(pitchDegrees * (Float.pi / 180), simd_float3(x: 1, y: 0, z: 0))
		let yaw = simd_quaternion(yawDegrees * (Float.pi / 180), simd_float3(x: 0, y: 1, z: 0))
		
		return roll * pitch * yaw
	}

	static func takeOff(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 2,
			playbackSpeed: 4,
			moveDistance: SIMD3<Float>(0, 2, 2),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: -45, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}

	static func turnRight(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 2,
			playbackSpeed: 2,
			moveDistance: SIMD3<Float>(-1, 0, 0),
			finalRotation: createQuaternion(rollDegrees: 45, pitchDegrees: 45, yawDegrees: -90),
			repeatCount: repeatCount
		)
	}
	
	static func comeBack(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 2,
			playbackSpeed: 2,
			moveDistance: SIMD3<Float>(0, 0, -1),
			finalRotation: createQuaternion(rollDegrees: 45, pitchDegrees: 45, yawDegrees: -90),
			repeatCount: repeatCount
		)
	}

	
	static func landSlow(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 5,
			playbackSpeed: 1,
			moveDistance: SIMD3<Float>(0, -2, -2),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: -45, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}
	
	static func trafficOnGround(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 5,
			playbackSpeed: 0.5,
			moveDistance: SIMD3<Float>(0, 1, 0),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}
	
	static func moveFastStraight(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 5,
			playbackSpeed: 2,
			moveDistance: SIMD3<Float>(0, 0, 2),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}
	
	static func moveBackStraight(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 5,
			playbackSpeed: 1,
			moveDistance: SIMD3<Float>(0, 0, -2),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}
	
	static func moveSlowStraight(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 10,
			playbackSpeed: 1,
			moveDistance: SIMD3<Float>(0, 0, 2),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}
	
	static func moveBackSlowStraight(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 10,
			playbackSpeed: 1,
			moveDistance: SIMD3<Float>(0, 0, -2),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}
	
	static func noMovePlayAnimation(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 10,
			playbackSpeed: 1,
			moveDistance: SIMD3<Float>(0, 0, 0),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}
	
	static func noMoveFastPlayAnimation(repeatCount: Int? = nil) -> AnimationMovementTask {
		return AnimationMovementTask(
			animationName: "global scene animation",
			duration: 10,
			playbackSpeed: 4,
			moveDistance: SIMD3<Float>(0, 0, 0),
			finalRotation: createQuaternion(rollDegrees: 0, pitchDegrees: 0, yawDegrees: 0),
			repeatCount: repeatCount
		)
	}

	// Add more predefined tasks as needed
}


public struct AnimationMovementTask {
	let animationName: String?
	let duration: TimeInterval
	let playbackSpeed: Float
	let moveDistance: SIMD3<Float> // x, y, z distances
	let finalRotation: simd_quatf
	let repeatCount: Int?
}

#endif 
