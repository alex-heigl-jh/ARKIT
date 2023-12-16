//
//  AnimationSequences.swift
//  Augment
//
//  Created by Alex Heigl on 12/13/23.
//

/*
 Purpose of this file is to store animation sequences for various models when they are
 interacted with by the user with an UITapGestureRecognizer
 
 To have an animation play indefinitely,  do not pass it a repeatCount value
 */

#if !targetEnvironment(simulator)

import Foundation
import RealityKit
import ARKit


public var modelToAnimationStrategiesSingleTap: [String: [AnimationMovementTask]] = [
//	"toy_biplane_idle": [AMS.takeOff(repeatCount:1), AMS.turnRight(repeatCount:1), AMS.landSlow(repeatCount:1), AMS.trafficOnGround()],
	
	"toy_biplane_idle": [AMS.takeOff(repeatCount:1), AMS.turnRight(repeatCount:1)],

	"BONUS_Spiderman_2099": [AMS.noMovePlayAnimation()],
	"toy_drummer_idle": [AMS.noMovePlayAnimation()],
	"robot_walk_idle": [AMS.noMovePlayAnimation()],
	
]

public var modelToAnimationStrategiesDoubleTap: [String: [AnimationMovementTask]] = [
	"toy_biplane_idle": [AMS.takeOff(repeatCount: 1), AMS.turnRight(repeatCount: 1), AMS.comeBack(repeatCount: 1),AMS.landSlow(repeatCount: 1), AMS.trafficOnGround()],
	"BONUS_Spiderman_2099": [AMS.noMovePlayAnimation()],
	"toy_drummer_idle": [AMS.moveSlowStraight()],
	"robot_walk_idle": [AMS.moveSlowStraight()],
	
]

public var modelToAnimationStrategiesTripleTap: [String: [AnimationMovementTask]] = [
	"toy_biplane_idle": [AMS.takeOff(repeatCount: 1), AMS.turnRight(repeatCount: 1), AMS.landSlow(repeatCount: 1), AMS.noMovePlayAnimation()],
	"BONUS_Spiderman_2099": [AMS.noMoveFastPlayAnimation()],
	"toy_drummer_idle": [AMS.moveFastStraight(repeatCount: 1), AMS.moveBackStraight(repeatCount: 1), AMS.noMoveFastPlayAnimation()],
	"robot_walk_idle": [AMS.moveFastStraight(repeatCount: 1), AMS.moveBackStraight(repeatCount: 1), AMS.noMoveFastPlayAnimation()],

]

#endif
