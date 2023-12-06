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


#if !targetEnvironment(simulator)
class CustomARView: RealityKit.ARView {
	
	enum FocusStyleChoices {
		case classic
		case material
		case color
	}
	
	var lastPlayedAnimationIndex: [ModelEntity: Int] = [:]
	
	let focusStyle: FocusStyleChoices = .classic
	var focusEntity: FocusEntity?
	
	// Variables necessary for video capture of AR view
	var snapshotArray:[[String:Any]] = [[String:Any]]()
	var lastTime:TimeInterval = 0
	var isRecording:Bool = false;

	private let screenRecorder = RPScreenRecorder.shared()
//	weak var delegate: CustomARViewDelegate?
	var coordinator: CustomARViewRepresentable.Coordinator?
	var showPreviewController: Binding<Bool>?
	var previewController: Binding<RPPreviewViewController?>?
	
	var entityModelMap: [ModelEntity: Model] = [:]

	
    required init(frame frameRect: CGRect){
        super.init(frame: frameRect)
    }
    
    dynamic required init?(coder decoder: NSCoder){
        fatalError("init (coder:) has not been implemented")
    }
	
	convenience init() {
		self.init(frame: UIScreen.main.bounds)
		
		self.setupConfig()
		
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
		
		// Add swipe gesture recognizer for a rightward slash
		let swipeRightGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(recognizer:)))
		swipeRightGestureRecognizer.direction = .right
		self.addGestureRecognizer(swipeRightGestureRecognizer)
	}
	
	private var cancellables: Set<AnyCancellable> = []
	
	deinit {
		print("CustomARView is being deinitialized")
	}
	
	
	struct ARViewState {
		var sessionConfiguration: ARWorldTrackingConfiguration
		var anchors: [AnchorEntity]
	}
	
	
	// function to subscribe to action stream from ARContentView, Utilizes Combine framework
	func subscribeToActionStream(){
		ARManager.shared
			.actionStream
		// Whenever an action is sent through action stream .sink will run 
			.sink { [weak self] action in
				switch action {
					// Place a block in the AR view
					case .placeBlock(let color):
						self?.placeBlock(ofColor: color)
						
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
					
				}

			}
			.store(in: &cancellables)
	}
	
	// AR Configuration examples
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
	
	// Entity examples
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
	
	// Function that places a usdz file in the AR view
	func placeEntity(from model: Model) {
		// Clone the model entity
		if let modelEntity = model.modelEntity?.clone(recursive: true) {
			
			// Add the model to the map
			entityModelMap[modelEntity] = model

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

	// Function that places a colored block in the AR view
	func placeBlock(ofColor color: Color) {
		
		// Retrieve the isMetallic value from UserDefaults
		let isMetallic = UserDefaults.standard.bool(forKey: "metallicBoxesEnabled")
		
		let block = MeshResource.generateBox(size: 0.25)
		let material = SimpleMaterial(color: UIColor(color), isMetallic: isMetallic)
		let entity = ModelEntity(mesh: block, materials: [material])
		
		let anchor = AnchorEntity(plane: .any)
		
		anchor.addChild(entity)
		//: Add to scene
		scene.addAnchor(anchor)
		//: Generate collision shapes (needed for gestures)
		anchor.generateCollisionShapes(recursive: true)
		//:  Install gestures
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

	// Function to configure the focus entity (box that shows where AR content is to be placed)
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
	
	
	// Method to pause AR session
	func pauseSession() {
		print("DEBUG: Pausing AR Session")
		self.session.pause()
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

	// Callback method after saving image
	@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
		if let error = error {
			// Handle any errors
			print("ERROR: Error saving photo: \(error.localizedDescription)")
		} else {
			// Image saved successfully
			print("DEBUG: Photo saved successfully")
		}
	}
	
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
	
	// MARK: Function that handles when an entity has been single tapped
	@objc func handleTap(recognizer: UITapGestureRecognizer) {
		print("Single tap detected")
		
		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) as? ModelEntity {
			guard let model = entityModelMap[entity] else { return }
			let animationManager = AnimationQueueManager()
			
			switch model.modelName {
			case "toy_biplane_idle":
				print("Queuing animations for toy_biplane_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 1), for: entity)
				
			case "BONUS_Spiderman_2099":
				print("Queuing animations for BONUS_Spiderman_2099")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 1), for: entity)
				
			case "BONUS_Solar_System_Model_Orrery":
				print("Entering animation sequence case BONUS_Solar_System_Model_Orrery")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 15, playbackSpeed: 0.5), for: entity)
				
				animationManager.enqueue(AnimationTask(name: "Neptune_1_Min_Orbit", duration: 15, playbackSpeed: 0.5), for: entity)
				
			case "toy_drummer_idle":
				print("Entering animation sequence case toy_drummer_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 1), for: entity)
				
				
			case "robot_walk_idle":
				print("Entering animation sequence case robot_walk_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 1), for: entity)
				
				
			// Default Case
			default:
				print("No programmed action for requested entity")
			}
		}
	}
	
	// MARK: Function thjat handles when an entity is double tapped
	@objc func handleDoubleTap(recognizer: UITapGestureRecognizer) {
		print("Double tap detected")
		
		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) as? ModelEntity {
			guard let model = entityModelMap[entity] else { return }
			let animationManager = AnimationQueueManager()

			switch model.modelName {
			case "toy_biplane_idle":
				print("Queuing animations for toy_biplane_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 2), for: entity)

			case "BONUS_Spiderman_2099":
				print("Queuing animations for BONUS_Spiderman_2099")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 2), for: entity)
				
			case "BONUS_Solar_System_Model_Orrery":
				print("Entering animation sequence case BONUS_Solar_System_Model_Orrery")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 15, playbackSpeed: 0.5), for: entity)

				animationManager.enqueue(AnimationTask(name: "Neptune_1_Min_Orbit", duration: 15, playbackSpeed: 0.5), for: entity)
				
				
			case "toy_drummer_idle":
				print("Entering animation sequence case toy_drummer_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 2), for: entity)

				
			case "robot_walk_idle":
				print("Entering animation sequence case robot_walk_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 2), for: entity)
				
				
			// Default Case
			default:
				print("No programmed action for requested entity")
			}
		}
	}

	
	@objc func handleSwipeRight(recognizer: UISwipeGestureRecognizer) {
		// Handle rightward slash
		print("Rightward slash detected")
		
		let location = recognizer.location(in: self)
		if let entity = self.entity(at: location) as? ModelEntity {
			guard let model = entityModelMap[entity] else { return }
			let animationManager = AnimationQueueManager()

			switch model.modelName {
			case "toy_biplane_idle":
				print("Queuing animations for toy_biplane_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 4), for: entity)

			case "BONUS_Spiderman_2099":
				print("Queuing animations for BONUS_Spiderman_2099")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 4), for: entity)
				
			case "BONUS_Solar_System_Model_Orrery":
				print("Entering animation sequence case BONUS_Solar_System_Model_Orrery")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 15, playbackSpeed: 0.5), for: entity)

				animationManager.enqueue(AnimationTask(name: "Neptune_1_Min_Orbit", duration: 15, playbackSpeed: 0.5), for: entity)
				
				
			case "toy_drummer_idle":
				print("Entering animation sequence case toy_drummer_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 4), for: entity)

				
			case "robot_walk_idle":
				print("Entering animation sequence case robot_walk_idle")
				animationManager.enqueue(AnimationTask(name: "global scene animation", duration: 10, playbackSpeed: 4), for: entity)
				
			// Default Case
			default:
				print("No programmed action for requested entity")
			}
		}
	}
	
	
	func playDefaultAnimation(_ entity: ModelEntity) {
		// Existing logic to play the first animation
		if let firstAnimation = entity.availableAnimations.first {
			entity.playAnimation(firstAnimation.repeat(duration: .infinity), transitionDuration: 0.5, startsPaused: false)
		}
	}

}

class AnimationQueueManager {
	private var animationQueue: [AnimationTask] = []
	private var isAnimating = false

	func enqueue(_ task: AnimationTask, for entity: ModelEntity) {
		animationQueue.append(task)
		executeNextIfPossible(for: entity)
	}

	private func executeNextIfPossible(for entity: ModelEntity) {
		guard !isAnimating, let nextTask = animationQueue.first else { return }
		isAnimating = true
		animationQueue.removeFirst()

		playAnimation(task: nextTask, for: entity) {
			self.isAnimating = false
			self.executeNextIfPossible(for: entity) // Trigger next animation
		}
	}

	private func playAnimation(task: AnimationTask, for entity: ModelEntity, completion: @escaping () -> Void) {
		print("Entering playAnimation")
		if let animation = entity.availableAnimations.first(where: { $0.name == task.name }) {
			print("Playing animation: \(task.name)")

			// Play the animation infinitely
			let controller = entity.playAnimation(animation.repeat(duration: .infinity), transitionDuration: 0.5, separateAnimatedValue: true, startsPaused: false)
			controller.speed = task.playbackSpeed

			// Schedule to stop the animation after the specified duration
			DispatchQueue.main.asyncAfter(deadline: .now() + task.duration) {
				// Stop the animation
				controller.stop() // This will stop the animation playback
				
				// Call the completion to proceed to the next animation
				completion()
			}
		}
	}
}



struct AnimationTask {
	let name: String
	let duration: TimeInterval
	let playbackSpeed: Float
}


//: Create extension of ARView to enable longPressGesture to delete AR object
extension RealityKit.ARView {
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


extension CustomARView: RPPreviewViewControllerDelegate {
	func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
		previewController.dismiss(animated: true)
	}
}

#endif