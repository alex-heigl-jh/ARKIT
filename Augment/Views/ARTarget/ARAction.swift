//
//  ARAction.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4

import SwiftUI
import Foundation

// MARK: AR Actions that can be called by ARContentView
enum ARAction{
	case captureImage
	case disableEnableFocusEntity(Bool)
	case loadModel(Model)
	case placeBlock(color: Color, meshType: MeshType)
	case removeAllAnchors
	case deallocateARSession
}
