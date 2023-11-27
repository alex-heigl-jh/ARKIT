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
import ReplayKit

struct CustomARViewRepresentable: UIViewRepresentable {
	func makeUIView(context: Context) -> CustomARView {
		return CustomARView()
	}

	func updateUIView(_ uiView: CustomARView, context: Context) {}

	func makeCoordinator() -> Coordinator {
		return Coordinator(self)
	}

	class Coordinator: NSObject {
		var parent: CustomARViewRepresentable

		init(_ parent: CustomARViewRepresentable) {
			self.parent = parent
		}
	}
}
