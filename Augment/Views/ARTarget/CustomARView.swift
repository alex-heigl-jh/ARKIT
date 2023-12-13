//
//  CustomARView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4
//  Additional code taken from FocusEntity example implementation
//  Code additionally augmented from tutorial from: https://www.youtube.com/watch?v=itGRaAryUxA
//  Video recording code taken from tutorial from: https://medium.com/ar-tips-and-tricks/arkit-how-to-record-and-save-video-in-swift-73cd899c21c7

/*
 
 This file handles the actual AR actions, it takes its queue from an action stream
 that originates in ARContentView.swift.
 
 */

#if !targetEnvironment(simulator)
import ARKit
import RealityKit
#endif

import Combine
import FocusEntity
import Photos
import ReplayKit
import SwiftUI
import simd


#if !targetEnvironment(simulator)
class CustomARView: RealityKit.ARView {
	
	var lastPlayedAnimationIndex: [ModelEntity: Int] = [:]
	
	let focusStyle: FocusStyleChoices = .classic
	var focusEntity: FocusEntity?
	
	// Variables necessary for video capture of AR view
	var snapshotArray:[[String:Any]] = [[String:Any]]()
	var lastTime:TimeInterval = 0
	var isRecording:Bool = false;

	private let screenRecorder = RPScreenRecorder.shared()
	var coordinator: CustomARViewRepresentable.Coordinator?
	var showPreviewController: Binding<Bool>?
	var previewController: Binding<RPPreviewViewController?>?
	
	var entityModelMap: [ModelEntity: Model] = [:]
	
	// Use a dictionary to store the entity type
	var entityTypes: [Entity: EntityType] = [:]
	// Dictionary to map entities to their anchors
	var entityToAnchorMap: [Entity: AnchorEntity] = [:]
	
	private var collisionSubscriptions: Set<AnyCancellable> = []
	
	var activeEntity: Entity?
	
	private let gestureDelegate = GestureRecognizerDelegate()
	
	var modelToAnimationStrategiesSingleTap: [String: [AnimationMovementTask]] = [
		"toy_biplane_idle": [AMS.takeOff, AMS.turnRight,AMS.turnRight,AMS.turnRight,AMS.landSlow,AMS.trafficOnGround],
		"BONUS_Spiderman_2099": [AMS.noMovePlayAnimation],
		"toy_drummer_idle": [AMS.noMovePlayAnimation],
		"robot_walk_idle": [AMS.noMovePlayAnimation],
//		"BONUS_Solar_System_Model_Orrery": [AnimationMovementStrategies.noMovePlayAnimation],
	]

	var modelToAnimationStrategiesDoubleTap: [String: [AnimationMovementTask]] = [
		"toy_biplane_idle": [AMS.takeOff, AMS.turnRight,AMS.turnRight,AMS.landSlow,AMS.trafficOnGround],
		"BONUS_Spiderman_2099": [AMS.noMovePlayAnimation],
		"toy_drummer_idle": [AMS.moveSlowStraight, AMS.moveBackSlowStraight,AMS.noMovePlayAnimation],
		"robot_walk_idle": [AMS.moveSlowStraight, AMS.moveBackSlowStraight,AMS.noMovePlayAnimation],
//		"BONUS_Solar_System_Model_Orrery": [AnimationMovementStrategies.noMovePlayAnimation],
	]
	
	var modelToAnimationStrategiesTripleTap: [String: [AnimationMovementTask]] = [
		"toy_biplane_idle": [AMS.takeOff, AMS.turnRight,AMS.landSlow],
		"BONUS_Spiderman_2099": [AMS.noMoveFastPlayAnimation],
		"toy_drummer_idle": [AMS.moveFastStraight, AMS.moveBackStraight,AMS.noMoveFastPlayAnimation],
		"robot_walk_idle": [AMS.moveFastStraight, AMS.moveBackStraight, AMS.noMoveFastPlayAnimation],
//		"BONUS_Solar_System_Model_Orrery": [AnimationMovementStrategies.noMovePlayAnimation],
	]
	
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
    }
    
    dynamic required init?(coder decoder: NSCoder){
        fatalError("init (coder:) has not been implemented")
    }
	
	convenience init() {
		self.init(frame: UIScreen.main.bounds)
		
		self.setupConfig()
		
		self.setupCollisionDetection()
		
		// call enableObjectRemoval to enable removal of individual entities from view
		self.enableObjectRemoval()
		// Allows AR view to receive commands from ARContentView
		self.subscribeToActionStream()

		// Add tap gesture recognizer
		let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap(recognizer:)))
		self.addGestureRecognizer(tapGestureRecognizer)
		
		// Add double tap gesture recognizer
		let doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap(recognizer:)))
		doubleTapGestureRecognizer.numberOfTapsRequired = 2
		self.addGestureRecognizer(doubleTapGestureRecognizer)

		// Ensure single tap doesn't interfere with double tap
		tapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
		
		// Add double tap gesture recognizer
		let tripleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTripleTap(recognizer:)))
		tripleTapGestureRecognizer.numberOfTapsRequired = 3
		self.addGestureRecognizer(tripleTapGestureRecognizer)

		// Ensure single tap doesn't interfere with double tap
		doubleTapGestureRecognizer.require(toFail: tripleTapGestureRecognizer)
		
		// Setup swipe gestures for each direction to identify active entity
		let directions: [UISwipeGestureRecognizer.Direction] = [.left, .right, .up, .down]
		for direction in directions {
			let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
			swipeGestureRecognizer.direction = direction
			self.addGestureRecognizer(swipeGestureRecognizer)
		}
		
		let swipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(recognizer:)))
		swipeGestureRecognizer.delegate = gestureDelegate
		self.addGestureRecognizer(swipeGestureRecognizer)

		
		swipeGestureRecognizer.delegate = self
		
		// Implement the delegate method
		func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
			// Decide if you want to recognize simultaneously
			return true
		}

	}
	
	private var cancellables: Set<AnyCancellable> = []
	
	struct ARViewState {
		var sessionConfiguration: ARWorldTrackingConfiguration
		var anchors: [AnchorEntity]
	}
	
	// MARK: Function to subscribe to action stream from ARContentView, Utilizes Combine framework
	func subscribeToActionStream(){
		ARManager.shared
			.actionStream
		// Whenever an action is sent through action stream .sink will run 
			.sink { [weak self] action in
				switch action {
					// Place a block in the AR view
					case .placeBlock(let color, let meshType):
						self?.placeBlock(ofColor: color, meshType: meshType)
						
					// Load a usdz model into the ARview
					case .loadModel(let model):
						print("DEBUG: Placing model")
						self?.placeEntity(from: model)
						
					// Remove all entities from the AR view
					case .removeAllAnchors:
						self?.scene.anchors.removeAll()
						self?.setupFocusEntity()
						
					// Capture an image of the current ARview
					case .captureImage:
						print("DEBUG: Capture image command received in CustomARView")
						self?.captureImageFromCamera()
						print("DEBUG: Completed captureImageFromCamera()")
		
					// Disable the focus entity
					case .disableEnableFocusEntity(let focusEntityEnable):
						print("DEBUG: User set focusEntity display to \(focusEntityEnable)")
						self?.toggleFocusEntity(isEnabled: focusEntityEnable)
					
				case .deallocateARSession:
					print("deallocateARSessionEnable AR Session")
					self?.pauseSession()
				}

			}
			.store(in: &cancellables)
	}
	
	// MARK: AR Configuration examples
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
	
	// MARK: Anchor Examples
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
	
	// MARK: Entity examples
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
	
	// MARK: Function that places a usdz file in the AR view
	func placeEntity(from model: Model) {
		// Clone the model entity
		if let modelEntity = model.modelEntity?.clone(recursive: true) {
			
			// Add the model to the map
			entityModelMap[modelEntity] = model

			print("DEBUG: Adding model to scene - \(model.modelName)")
			// Create an anchor for attaching the entity
			let anchor = AnchorEntity(plane: .any)
			
			// For use in collision detection --> handleCollision()
			entityTypes[modelEntity] = .model
			entityToAnchorMap[modelEntity] = anchor
			modelEntity.name = model.modelName

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

	// MARK: Function that places a colored geometric shape in the AR view
	func placeBlock(ofColor color: Color, meshType: MeshType) {
		// Retrieve the isMetallic value from UserDefaults
		let isMetallic = UserDefaults.standard.bool(forKey: "metallicBoxesEnabled")
		
		let mesh: MeshResource
		switch meshType {
		case .box:
			mesh = MeshResource.generateBox(size: 0.25)
		case .sphere:
			mesh = MeshResource.generateSphere(radius: 0.25)
		case .plane:
			mesh = MeshResource.generatePlane(width: 0.25, depth: 0.25)
		}

		let material = SimpleMaterial(color: UIColor(color), isMetallic: isMetallic)
		
		let entity = ModelEntity(mesh: mesh, materials: [material])

		let anchor = AnchorEntity(plane: .any)
		
		// For use in collision detection --> handleCollision()
		entityTypes[entity] = .block
		entityToAnchorMap[entity] = anchor

		anchor.addChild(entity)
		//: Add to scene
		scene.addAnchor(anchor)
		//: Generate collision shapes (needed for gestures)
		anchor.generateCollisionShapes(recursive: true)
		//: Install gestures
		installGestures([.translation, .rotation, .scale], for: entity)
	}

	
	// MARK: Function to configure the AR view when the convenience initializer is called
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

	// MARK: Function to configure the focus entity (box that shows where AR content is to be placed)
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
	
	// MARK: Method to pause AR session
	func pauseSession() {
		self.session.pause()
		print("DEBUG: pauseSession() called, AR Session paused")
	}
	
	func captureImageFromCamera() {
		print("Entering captureImageFromCamera()")
		// Use the instance method to take a snapshot
		self.snapshot(saveToHDR: false) { [weak self] image in
			guard let self = self, let snapshot = image else { return }
			// Use the snapshot, which is a UIImage
			// Save it to the photo library
			UIImageWriteToSavedPhotosAlbum(snapshot, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
		}
	}
	
	// MARK: Function that toggles the focus entity on/off
	func toggleFocusEntity(isEnabled: Bool) {
		if isEnabled {
			// If focus entity is to be enabled
			if focusEntity == nil {
				// If focusEntity is not already created, create it
				setupFocusEntity()
			}
			focusEntity?.isEnabled = true // Enable the focus entity
		} else {
			// If focus entity is to be disabled
			focusEntity?.isEnabled = false // Disable the focus entity
		}
	}
	
	// MARK: Function intended to configure collision detection between models placed in the view
	func setupCollisionDetection() {
		print("Setting up collision detection")

		// Iterate over ModelEntity objects only
		for modelEntity in entityModelMap.keys {
			modelEntity.generateCollisionShapes(recursive: true)
			let collisionFilter = CollisionFilter(group: .default, mask: .all)
			modelEntity.collision = CollisionComponent(shapes: [.generateBox(size: modelEntity.visualBounds(relativeTo: modelEntity).extents)], mode: .trigger, filter: collisionFilter)
		}

		// Subscribe to collision events on the scene
		self.scene.subscribe(to: CollisionEvents.Began.self) { [weak self] event in
			self?.handleCollision(event: event)
		}.store(in: &collisionSubscriptions)
		print("Subscribed to collision events")
	}


	// MARK: Modify handleCollision() to check for model-block collision
	private func handleCollision(event: CollisionEvents.Began) {
		let entityA = event.entityA
		let entityB = event.entityB

		let typeA = entityTypes[entityA, default: .block]
		let typeB = entityTypes[entityB, default: .block]

		// Check if one of the entities is the currently active entity
		let initiator = (entityA === activeEntity ? entityA : (entityB === activeEntity ? entityB : nil))

		switch (typeA, typeB) {
		case (.block, .block):
			if let initiator = initiator {
				// Handle the case where the initiator is known
				print("Block initiated by \(initiator.name) collided with another block.")
			} else {
				// Fallback case if initiator is not known
				stackBlocks(blockA: entityA, blockB: entityB)
			}
		case (.model, .block), (.block, .model):
			let modelEntity = (typeA == .model ? entityA : entityB)
			let blockEntity = (typeA == .block ? entityA : entityB)
			print("Collision detected between model \(modelEntity.name) and block.")
			// Handle model-block collision
		default:
			print("Collision detected between \(entityA.name) and \(entityB.name)")
		}
	}

	private func stackBlocks(blockA: Entity, blockB: Entity) {
		// Determine the active block and the other block
		let activeBlock: Entity? = (blockA === activeEntity ? blockA : (blockB === activeEntity ? blockB : nil))
		let otherBlock: Entity? = (blockA !== activeBlock ? blockA : blockB)

		if let activeBlock = activeBlock, let otherBlock = otherBlock {
			// Calculate new position for the active block
			var newPosition = otherBlock.position
			newPosition.y += otherBlock.visualBounds(relativeTo: otherBlock).extents.y / 2
			newPosition.y += activeBlock.visualBounds(relativeTo: activeBlock).extents.y / 2

			// Move the active block on top of the other block
			activeBlock.move(to: Transform(translation: newPosition), relativeTo: otherBlock.parent, duration: 0.1, timingFunction: .easeInOut)
		} else {
			print("No active block identified for stacking")
		}
	}


	
	// MARK: Callback method after saving image
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			// Handle any errors
			print("ERROR: Error saving photo: \(error.localizedDescription)")
		} else {
			// Image saved successfully
			print("DEBUG: Photo saved successfully")
		}
	}
	
	// MARK: Function that handles when an entity is single tapped
	@objc func handleTap(recognizer: UITapGestureRecognizer) {
		print("Single tap detected")
		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) as? ModelEntity, let model = entityModelMap[entity] {
			let animationManager = AnimationQueueManager()

			// Retrieve the sequence of tasks for the model
			if let tasks = modelToAnimationStrategiesSingleTap[model.modelName] {
				// Enqueue each task in the sequence
				tasks.forEach { animationManager.enqueue($0, for: entity) }
			} else {
				print("No animation strategy defined for model \(model.modelName)")
			}
		}
	}

	// MARK: Function that handles when an entity is double tapped
	@objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
		print("Double tap detected")
		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) as? ModelEntity, let model = entityModelMap[entity] {
			let animationManager = AnimationQueueManager()

			// Retrieve the sequence of tasks for the model
			if let tasks = modelToAnimationStrategiesDoubleTap[model.modelName] {
				// Enqueue each task in the sequence
				tasks.forEach { animationManager.enqueue($0, for: entity) }
			} else {
				print("No animation strategy defined for model \(model.modelName)")
			}
		}

	}
	
	// MARK: Function that handles when an entity is tripple tapped
	@objc func handleTripleTap(recognizer: UITapGestureRecognizer) {
		print("Triple tap detected")
		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) as? ModelEntity, let model = entityModelMap[entity] {
			let animationManager = AnimationQueueManager()

			// Retrieve the sequence of tasks for the model
			if let tasks = modelToAnimationStrategiesTripleTap[model.modelName] {
				// Enqueue each task in the sequence
				tasks.forEach { animationManager.enqueue($0, for: entity) }
			} else {
				print("No animation strategy defined for model \(model.modelName)")
			}
		}
		
	}
	

	
	// Swipe gesture handler function
	@objc func handleSwipe(recognizer: UISwipeGestureRecognizer) {
		let location = recognizer.location(in: self)

		// Perform a ray cast to find anchors in the 3D space
		let rayCastResults = self.raycast(from: location, allowing: .estimatedPlane, alignment: .any)

		if let firstResult = rayCastResults.first {
			// Get the anchor from the raycast result
			if let anchor = firstResult.anchor {
				// Iterate through the entity-to-anchor map
				for (entity, associatedAnchor) in entityToAnchorMap {
					if associatedAnchor.anchorIdentifier == anchor.identifier {
						// Check if the entity is a ModelEntity and set it as the active entity
						if let modelEntity = entity as? ModelEntity {
							self.activeEntity = modelEntity
							print("Active entity set to: \(modelEntity.name)")
							break
						}
					}
				}
			} else {
				print("No anchor found at swipe location")
			}
		}
	}

	// MARK: Function that properly de-initialzes the AR Session when the user exits the view
	deinit {
		pauseSession() // Explicitly pause the AR session
		print("deinit: CustomARView is being deinitialized and ARSession paused")
	}
}

class GestureRecognizerDelegate: NSObject, UIGestureRecognizerDelegate {
	func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
		return gestureRecognizer is UISwipeGestureRecognizer && otherGestureRecognizer is UIPanGestureRecognizer
	}
}

#endif
