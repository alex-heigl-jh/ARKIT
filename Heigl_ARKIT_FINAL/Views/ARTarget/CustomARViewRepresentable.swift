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


struct CustomARViewRepresentable: UIViewRepresentable {
//	var viewModel: ARViewModel
	
	// Calls the convenience initializer in CustomARView
	func makeUIView(context: Context) -> CustomARView {
		let view = CustomARView()
//		view.viewModel = viewModel
//		viewModel.customARView = view // Set the reference
		return view
	}

	func updateUIView(_ uiView: CustomARView, context: Context) {}
}
