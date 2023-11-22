//
//  CustomARViewRepresentable.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4

import Foundation
import SwiftUI
import ARKit
import FocusEntity

// Making this a struct and UIViewRepresentable so I can use in a swiftUI view
struct CustomARViewRepresentable: UIViewRepresentable{
	
	@State private var colors: [Color] = [
		.green,
		.red,
		.blue
	]
    
	
//	typealias UIViewType = ARView
	
	
    func makeUIView(context: Context) -> CustomARView {
		
//		let arConfig = ARWorldTrackingConfiguration()
//		arConfig.planeDetection = [.horizontal, .vertical]
//		arView.session.run(arConfig)
//		_ = FocusEntity(on: arView, style: .classic())
//		return arView
		
		// Will call the convenience initializer
        return CustomARView()
    }
    
    func updateUIView(_ uiView: CustomARView, context: Context) {}
    
}
