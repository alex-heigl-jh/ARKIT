import UIKit
import RealityKit
import ARKit
import SwiftUI

// https://www.youtube.com/watch?v=mPJiRtNzIHw&t=61s

var greeting = "Hello, playground"

// 1. Import Frameworks

// 2. Create ARViewContainer (UIViewRepresentable)
// 3a. Implement makeUIView func to setup arView and enableTapGesture
// 3b. Implement updateUIView but leave empty

// 4. Extend ARView to implment tap gesture

// 4a. Create enableTapGesture function to add tapGestureRecognizer to ARView

// 4b. Create handleTap function to implement the raycasting logic
// 4b-i. If raycast intersects an AR object, place a new object on top of it at the 3D point of intersection
// 4b-ii. else, place an object on a real-world plane (if present)

// 5. Create helper method to place cube at 3D position
// NOTE: make sure to generateCollisionShapes for modelEntity

// 6. Extend UIColor to randomly generate a UIColor

// 2. Create SwiftUI Content View
// 2a. Create struct for ContentView
// 2b. Assign instance pf ContentView to current PlaygroundPage lineView
struct ContentView: View {
	var body: some View {
		return ARViewContainer()
	}
}

PlaygroundPage.current.setLiveView(ContentView())
