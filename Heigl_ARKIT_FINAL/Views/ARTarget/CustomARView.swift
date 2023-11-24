//
//  CustomARView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4
//  Additional code taken from FocusEntity example implementation
//  Code additionally augmented from tutorial from: https://www.youtube.com/watch?v=itGRaAryUxA

import ARKit
import Combine
import RealityKit
import SwiftUI
import FocusEntity

class CustomARView: ARView {
	
	enum FocusStyleChoices {
		case classic
		case material
		case color
	}
	
	let focusStyle: FocusStyleChoices = .classic
	var focusEntity: FocusEntity?
	
	
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
		
//		self.setupConfig()

    }
    
    dynamic required init?(coder decoder: NSCoder){
        fatalError("init (coder:) has not been implemented")
    }
    
	// This is the init that is actually utilized
    convenience init() {
		
        self.init(frame: UIScreen.main.bounds)
		
		self.setupConfig()
		
		//: call enableObjectRemoval to enable removal of individual entities from view
		self.enableObjectRemoval()
		//: Allows AR view to receive commands from ARContentView
		subscribeToActionStream()
    }
	
	private var cancellables: Set<AnyCancellable> = []
	
	// Utilizes Combine framework
	func subscribeToActionStream(){
		ARManager.shared
			.actionStream
		// Whenever an action is sent through action stream .sink will run 
			.sink { [weak self] action in
				switch action {
					case .placeBlock(let color):
						self?.placeBlock(ofColor: color)
					
					case .loadModel(let model):
						print("DEBUG: Placing model")
						self?.placeEntity(from: model)
					
					case .removeAllAnchors:
						self?.scene.anchors.removeAll()
						self?.setupFocusEntity()
				}
				
			}
			.store(in: &cancellables)
	}
	
	func configurationExamples() {
		// Tracks the device relative to its environment
		let configuration = ARWorldTrackingConfiguration()
		session.run(configuration)
		
		// Not supported in all regions, tracks w.r.t. global coordinates
		let _ = ARGeoTrackingConfiguration()
		
		// Tracks faces in the scene
		let _ = ARFaceTrackingConfiguration()
		
		// Tracks bodies in the scene
		let _ = ARBodyTrackingConfiguration()
		
	}
	
	// Even as the user moves around, anchor remains in the same position
	func anchorExamples() {
		// Attach anchors at specific coordinates in the Iphone-centered coordinate system
		// Places coordinate at 0,0,0
		let coordinateAnchor = AnchorEntity(world: .zero)
		
		// Attach anchors to detected planes (This works best of devices with a LIDAR sensor)
		let _ = AnchorEntity(plane: .horizontal)
		let _ = AnchorEntity(plane: .vertical)
		
		// Attach anchors to tracked body parts, such as the face
		let _ = AnchorEntity(.face)
		
		// Attach anchors to tracked images, such as markers or visual codes
		let _ = AnchorEntity(.image(group: "group", name: "name"))
	}
	
	func entityExamples() {
		// Load an entity for a usdz file
		// usdz file: Apple 3D model that is included in application bundle
		let _ = try? Entity.load(named: "usdzFileName")
		
		// Load an entity from a reality file
		let _ = try? Entity.load(named: "realityFileName")
		
		// Generate an entity with code
		let box = MeshResource.generateBox(size: 1)
		let entity = ModelEntity(mesh: box)
		
		// Add entity to an anchor, so its placed in the scene
		let anchor = AnchorEntity()
		anchor.addChild(entity)
		
	}
	
	func placeEntity(from model: Model) {
		if let modelEntity = model.modelEntity?.clone(recursive: true) {  // Clone the model entity

			print("DEBUG: Adding model to scene - \(model.modelName)")
			// Create an anchor for attaching the entity
			let anchor = AnchorEntity(plane: .any) // You can choose .vertical or .horizontal based on your requirement

			// Add the cloned entity as a child of the anchor
			anchor.addChild(modelEntity)

			// Add the anchor to the ARView's scene
			scene.addAnchor(anchor)
			// Generate collision shapes (needed for gestures)
			anchor.generateCollisionShapes(recursive: true)
			// Install gestures
			installGestures([.translation, .rotation, .scale], for: modelEntity)
		} else {
			print("DEBUG: Unable to load modelEntity for - \(model.modelName)")
		}
	}

	
	func placeBlock(ofColor color: Color) {
		
		let block = MeshResource.generateBox(size: 0.5)
		let material = SimpleMaterial(color: UIColor(color), isMetallic: false)
		let entity = ModelEntity(mesh: block, materials: [material])
		
		let anchor = AnchorEntity(plane: .any)
		
		anchor.addChild(entity)
		//: Add to scene
		scene.addAnchor(anchor)
		//: Generate collision shapes (needed for gestures)
		anchor.generateCollisionShapes(recursive: true)
		//:  Install gestures
//		arView.installGestures([.translation, .rotation, .scale], for: anchor)
		installGestures([.translation, .rotation, .scale], for: entity)

		
	}
	// Function to configure the AR view when the convenience initializer is called
	func setupConfig() {
		//		let arView = ARView(frame: .zero)
		//		let arConfig = ARWorldTrackingConfiguration()
		//
		//		arConfig.planeDetection = [.horizontal, .vertical]
		//		arView.session.run(arConfig)
		//
		//		_ = FocusEntity(on: arView, style: .classic())
		
		let config = ARWorldTrackingConfiguration()
		config.planeDetection = [.horizontal, .vertical]
		config.environmentTexturing = .automatic

		// Check for LiDAR sensor and configure if available
		if ARWorldTrackingConfiguration.supportsSceneReconstruction(.mesh) {
			config.sceneReconstruction = .mesh
			print("DEBUG: LiDAR sensor detected, utilizing...")
		} else {
			print("DEBUG: LiDAR sensor not detected...")
		}
		
		// Run the session with the configured settings
		session.run(config)
		
		// Other setup operations
		setupFocusEntity()
	}

	
	func setupFocusEntity(){
		switch self.focusStyle {
		case .color:
			self.focusEntity = FocusEntity(on: self, focus: .plane)
		case .material:
			do {
				let onColor: MaterialColorParameter = try .texture(.load(named: "Add"))
				let offColor: MaterialColorParameter = try .texture(.load(named: "Open"))
				self.focusEntity = FocusEntity(
					on: self,
					style: .colored(
						onColor: onColor, offColor: offColor,
						nonTrackingColor: offColor
					)
				)
			} catch {
				self.focusEntity = FocusEntity(on: self, focus: .classic)
				print("Unable to load plane textures")
				print(error.localizedDescription)
			}
		default:
			self.focusEntity = FocusEntity(on: self, focus: .classic)
		}
	}
}

//: Create extension of ARView to enable longPressGesture to delete AR object
extension ARView {
	//: Create enableObjectRemoval() function to add longPressGesture recognizer
	func enableObjectRemoval(){
		let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(recognizer:)))
		self.addGestureRecognizer(longPressGestureRecognizer)
	}
	
	//: Create selector to handleLongPress
	@objc func handleLongPress(recognizer: UILongPressGestureRecognizer) {
		guard recognizer.state == .began else { return } // Check if the gesture has just begun

		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) {
			entity.removeFromParent() // Directly remove the entity
			print("DEBUG: Removed entity")
		}
	}
}
