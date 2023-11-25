//
//  ARAction.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4

import SwiftUI

//ARAction that we want to implement
enum ARAction{
	case captureImage
	case captureVideo(Bool)
	case loadModel(Model)
	case placeBlock(color: Color)
	case removeAllAnchors
	
}


