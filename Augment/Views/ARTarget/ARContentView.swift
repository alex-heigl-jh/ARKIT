//
//  ARContentView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4
//  Code then augmented with tutorial from: https://www.youtube.com/watch?v=9R_G0EI-UoI&t=194s


import AVFoundation
import AVKit
import Photos
import ReplayKit
import SwiftUI
import UIKit
import CoreLocation
import CoreData
import Photos

#if !targetEnvironment(simulator)

struct ARContentView: View {
	
	// Function to load USDZ models
	private static func loadUSDZModels() -> [Model] {
		let filemanager = FileManager.default
		guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
			return []
		}
		
		return files.compactMap { filename in
			if filename.hasSuffix("usdz") && !filename.hasPrefix("BONUS_") {
				return Model(modelName: filename.replacingOccurrences(of: ".usdz", with: ""))
			}
			return nil
		}
	}

	
	// Function to load .reality models (similar to loadUSDZModels)
	private static func loadBonusModels() -> [Model] {
		let filemanager = FileManager.default
		guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
			return []
		}
		
		return files.compactMap { filename in
			if filename.hasSuffix("usdz") && filename.hasPrefix("BONUS_") {
				return Model(modelName: filename.replacingOccurrences(of: ".usdz", with: ""))
			}
			return nil
		}
	}

	
	@StateObject private var locationManager = LocationManager()
	
	@Environment(\.presentationMode) var presentationMode
	
	@Environment(\.managedObjectContext) var managedObjectContext
	
	//: Variable to control if box color selection scroll view is displayed to the user
	@State private var isBoxColorSelectEnabled = false
	//: Variable to contol if usdz placement view is displayed to user
	@State private var isUSDZPlacementEnabled = false
	//: Variable to control if a video capture should be started on the camera view
	@State private var isVideoCaptureEnabled = false
	//: Variable used to indicate if a video capture should be completed and saved to the users photos
	@State private var isVideoCaptureOver = false
	//: TODO --> What is the purpose of this variable?
	@State private var selectedModel: Model?
	//: Variable to hold the usdz models
	@State private var usdzModels: [Model] = loadUSDZModels()
	
	@State private var isFocusEntityEnabled = true
	
	@State private var showPreviewController = false
	@State private var previewController: RPPreviewViewController?
	
	// Variable for controlling RealityPlacementButtonsView
	@State private var isBonusModelsPlacementEnabled = false
	// Variable to hold the reality models
	@State private var realityModels: [Model] = loadBonusModels()
	
	@State private var isFlashlightOn = false
	
	var body: some View {
		
		ZStack(alignment: .bottom){
			
			// The ARView
			CustomARViewRepresentable()
				.ignoresSafeArea()
			
			// If the user selects that they would like to place a USDZ model, display scroll menu that allows them to select the desired block
			if self.isUSDZPlacementEnabled {
				USDZPlacementButtonsView(selectedModel: self.$selectedModel,
										 isUSDZPlacementEnabled: self.$isUSDZPlacementEnabled,
										 models: usdzModels)
			}
			// Display RealityPlacementButtonsView when isRealityPlacementEnabled is true
			else if self.isBonusModelsPlacementEnabled {
				BonusModelsPlacementButtonsView(selectedModel: self.$selectedModel,
												isBonusModelsPlacementEnabled: self.$isBonusModelsPlacementEnabled,
												models: realityModels)
			}
			// If the user selects that they would like to place a block, display scroll menu that allows them to select the desired block
			else if self.isBoxColorSelectEnabled {
				SelectBoxColorView(isBoxColorSelectEnabled: self.$isBoxColorSelectEnabled)
			}
			// By default, display ModelPickerView which is gives the user the option of selecting blocks or USDZ models
			else {
				ModelPickerView(
					isBoxColorSelectEnabled: $isBoxColorSelectEnabled,
					isUSDZPlacementEnabled: $isUSDZPlacementEnabled,
					isVideoCaptureEnabled: $isVideoCaptureEnabled,
					isFocusEntityEnabled: $isFocusEntityEnabled,
					isBonusModelsPlacementEnabled: $isBonusModelsPlacementEnabled,
					isFlashlightOn: $isFlashlightOn,
					presentationMode: _presentationMode,
					locationManager: locationManager,
					managedObjectContext: managedObjectContext,
					startRecording: startScreenRecording,
					stopRecording: stopScreenRecording)
			}
		}
		.navigationBarHidden(true)
		.sheet(isPresented: $showPreviewController) {
			if let controller = previewController {
				PreviewControllerWrapper(previewController: controller) {
					self.showPreviewController = false
				}
			}
		}
	}
	// Start screen recording
	func startScreenRecording() {
		let screenRecorder = RPScreenRecorder.shared()
		guard screenRecorder.isAvailable else {
			print("Screen recording is not available")
			return
		}
		
		// Set up the audio session
		let audioSession = AVAudioSession.sharedInstance()
		do {
			try audioSession.setCategory(.playAndRecord, mode: .default)
			try audioSession.setActive(true)
			print("Audio session set to play and record")
		} catch {
			print("Failed to set audio session category. Error: \(error)")
			return // If setting up the audio session fails, return early.
		}
		
		// Enable the microphone
		screenRecorder.isMicrophoneEnabled = true
		print("Microphone is enabled for recording")
		
		// Delay the recording start
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
			screenRecorder.startRecording { error in
				if let error = error {
					print("Failed to start recording: \(error.localizedDescription)")
				} else {
					print("Screen recording started successfully with microphone")
				}
			}
		}
	}
	
	// Stop screen recording
	func stopScreenRecording() {
		let screenRecorder = RPScreenRecorder.shared()
		screenRecorder.stopRecording { (previewController, error) in
			if let error = error {
				print("Failed to stop recording: \(error.localizedDescription)")
			} else {
				print("Screen recording stopped. Is preview controller nil? \(previewController == nil)")
				DispatchQueue.main.async {
					self.previewController = previewController
					self.showPreviewController = previewController != nil
					print("Will present preview controller? \(self.showPreviewController )")
					if self.showPreviewController == true {
						print("Preview controller should now be showing.")
					}
				}

			}
		}
	}

}


// Default scroll view at the bottom of the view
struct ModelPickerView: View {
	
	@Binding var isBoxColorSelectEnabled: Bool
	@Binding var isUSDZPlacementEnabled: Bool
	@Binding var isVideoCaptureEnabled: Bool
	@Binding var isFocusEntityEnabled: Bool
	@Binding var isBonusModelsPlacementEnabled: Bool
	@Binding var isFlashlightOn: Bool
	@Environment(\.presentationMode) var presentationMode
	
	var locationManager: LocationManager
	var managedObjectContext: NSManagedObjectContext
	
	// Used to control camera button animation used to indicate an image has been captured
	@State private var buttonColor = Color.blue
	
	var startRecording: () -> Void
	var stopRecording: () -> Void
	
	
	
	let rainbowGradient = LinearGradient(
		gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple]),
		startPoint: .leading,
		endPoint: .trailing
	)
	
	var body: some View {
		ScrollView(.horizontal, showsIndicators: false){
			HStack(spacing: 30) {
				
				Button {
					print("disableEnableTarget button selected")
					isFocusEntityEnabled.toggle()
					ARManager.shared.actionStream.send(.disableEnableFocusEntity(isFocusEntityEnabled))
				} label: {
					Image(systemName: "scope")
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.padding()
						.foregroundColor(.white)
						.background(isFocusEntityEnabled ? Color.green : Color.red)
						.cornerRadius(16)
				}
				
				// MARK: Flashlight button
				Button {
					isFlashlightOn.toggle() // Toggle the flashlight state
					toggleFlashlight(on: isFlashlightOn) // Call the function to actually toggle the flashlight
				} label: {
					Image(systemName: isFlashlightOn ? "flashlight.off.circle" : "flashlight.on.circle.fill")
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.padding()
						.foregroundColor(.white)
						.background(isFlashlightOn ? Color.yellow : Color.red)
						.cornerRadius(16)
				}
				
				//: Block selection button
				Button(action: {
					print("DEBUG: Box placement selection button selected")
					isBoxColorSelectEnabled = true
				}) {
					Rectangle()
						.fill(rainbowGradient)
						.frame(width: 40, height: 40)
						.cornerRadius(8) // Optional, for rounded corners
				}
				.padding()
				.background(Color.blue)
				.cornerRadius(16)
				
				//: USDZ selection button
				Button(action: {
					print("DEBUG: USDZ models placement selection button selected")
					isUSDZPlacementEnabled = true
				}) {
					Image(systemName: "apple.logo")
						.font(.system(size: 30)) 		// Adjust the size as needed
						.frame(width: 40, height: 40) 	// Set the frame for the button
						.foregroundColor(.white) 		// Change the color of the symbol
						.padding() 						// Padding inside the button
						.background(Color.blue) 		// Change the background color of the button
						.cornerRadius(16) 				// Rounded corners for the button
				}
				
				// New Bonus model selection button
				Button(action: {
					print("DEBUG: Bonus models placement selection button selected")
					isBonusModelsPlacementEnabled.toggle()
					print("isBonusModelsPlacementEnabled set to \(isBonusModelsPlacementEnabled)")
				}) {
					Image(systemName: "cube.transparent")
						.font(.system(size: 30))       // Adjust the size as needed
						.frame(width: 40, height: 40)  // Set the frame for the button
						.foregroundColor(.white)       // Change the color of the symbol
						.padding()                     // Padding inside the button
						.background(Color.blue)        // Change the background color of the button
						.cornerRadius(16)              // Rounded corners for the button
				}
				
				Button {
					print("Mark location button")
					markCurrentLocation()
		
				} label: {
					Image(systemName: "location.viewfinder")
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.padding()
						.foregroundColor(.white)
						.background(Color.blue)
						.cornerRadius(16)
				}

				// MARK: Camera selection button
				Button(action: {
					print("DEBUG: Capture image button selected")
					ARManager.shared.actionStream.send(.captureImage)
					
					// Change the color to indicate capture
					buttonColor = Color.green // Change to your preferred 'capture' color
					
					// Revert the color back after a short delay
					DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
						buttonColor = Color.blue // Revert to original color
					}
				}) {
					Image(systemName: "camera.circle")
						.font(.system(size: 30))        // Adjust the size as needed
						.frame(width: 40, height: 40)   // Set the frame for the button
						.foregroundColor(.white)        // Change the color of the symbol
						.padding()                      // Padding inside the button
						.background(buttonColor)        // Use the dynamic background color
						.cornerRadius(16)               // Rounded corners for the button
				}
				
				//: Camera selection button
				Button(action: {
					print("DEBUG: Capture video button selected")
					isVideoCaptureEnabled.toggle() // Toggle the recording state
					
					if isVideoCaptureEnabled {
						// Start recording
						startRecording()
						print("Starting screen recording")
					} else {
						// Stop recording
						stopRecording()
						print("Stopping screen recording")
					}
				}) {
					// Toggle the image based on whether video is being captured
					Image(systemName: isVideoCaptureEnabled ? "record.circle.fill" : "record.circle")
						.font(.system(size: 30))        // Adjust the size as needed
						.frame(width: 40, height: 40)   // Set the frame for the button
						.foregroundColor(.white)       // Change the color of the symbol
						.padding()                      // Padding inside the button
						.background(isVideoCaptureEnabled ? Color.red : Color.blue) // Dynamic background color
						.cornerRadius(16)               // Rounded corners for the button
				}
				Button{
					ARManager.shared.actionStream.send(.removeAllAnchors)
				} label:{
					Image(systemName: "trash")
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.padding()
						.background(Color.blue)
						.foregroundColor(.white)
						.cornerRadius(16)
				}
				Button {
					print("Home button selected")
					self.presentationMode.wrappedValue.dismiss()
				} label: {
					Image(systemName: "house.circle")
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.padding()
						.foregroundColor(.white)
						.background(Color.blue)
						.cornerRadius(16)
				}
			}
		}
		.padding(20)
		.background(Color.black.opacity(0.5))
	}
	func markCurrentLocation() {
	  Task {
		  do {
			  // Fetch current coordinates
			  guard let currentLocation = locationManager.location else {
				  print("Current location is unavailable.")
				  return
			  }
			  let coordinates = currentLocation.coordinate

			  // Save to CoreData
			  MapsData.createWith(dateAdded: Date(),
								  sceneLocation: "\(coordinates.latitude), \(coordinates.longitude)",
								  in: managedObjectContext)
		  } catch {
			  print("Error marking location: \(error)")
		  }
		}
	}
	
	private func toggleFlashlight(on: Bool) {
		guard let device = AVCaptureDevice.default(for: AVMediaType.video),
			  device.hasTorch else { return }

		do {
			try device.lockForConfiguration()
			device.torchMode = on ? .on : .off
			device.unlockForConfiguration()
		} catch {
			print("Flashlight could not be used")
		}
	}
}

// Once user has selected they want to place a box
struct SelectBoxColorView: View {

	@Binding var isBoxColorSelectEnabled: Bool

	//: Color Options for the user to select from
	private let colors: [Color] = [.green, .red, .blue, .orange, .purple, .pink, .gray, .black, .white]

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false){
			HStack{
				//: Back button
				Button(action: {
					print("DEBUG: Box placement back button selected")
					isBoxColorSelectEnabled = false
				}){
					Image(systemName: "arrowshape.turn.up.backward.fill")
						.frame(width: 60, height: 60)
						.font(.title)
						.background(Color.white.opacity(0.75))
						.cornerRadius(30)
						.padding(20)
				}

				// Display the options for colored boxes
				ForEach(colors, id: \.self) { color in
					Button{
						print("DEBUG: Placing Colored LBock with color: \(color)")
						ARManager.shared.actionStream.send(.placeBlock(color: color))
					} label: {
						color
							.frame(width: 40, height: 40)
							.padding()
							.background(.regularMaterial)
							.cornerRadius(16)
					}
				}
			}
		}
		.padding(20)
		.background(Color.black.opacity(0.5))
	}
}

//: View displayed to the user if the usdz view button is selected
struct USDZPlacementButtonsView: View {

	@Binding var selectedModel: Model?
	@Binding var isUSDZPlacementEnabled: Bool

	var models: [Model]

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false){
			HStack{
				//: Back button
				Button(action: {
					print("DEBUG: usdz placement back button selected")
					isUSDZPlacementEnabled = false
				}){
					Image(systemName: "arrowshape.turn.up.backward.fill")
						.frame(width: 60, height: 60)
						.font(.title)
						.background(Color.white.opacity(0.75))
						.cornerRadius(30)
						.padding(20)
				}

				//: "Zero up-to but not including"
				ForEach(0 ..< self.models.count){ index in

					Button(action: {
						print("DEBUG: selected model with name \(models[index].modelName)")

						selectedModel = models[index]

						if let model = selectedModel {

							ARManager.shared.actionStream.send(.loadModel(model))
							print("DEBUG: Sent model through actionStream")
						}

						DispatchQueue.main.async{
							selectedModel = nil
						}

					}) {
						Image(uiImage: self.models[index].image)
							.resizable() // All of these modifiers only act on the image
							.frame(height: 80)
							.aspectRatio(1/1,contentMode: .fit)
							.background(Color.white)
							.cornerRadius(12)
					}
					.buttonStyle(PlainButtonStyle())
					.padding()
				}

			}
		}
		.padding(20)
		.background(Color.black.opacity(0.5))
	}
}

// View displayed to the user if the reality model placement button is selected
struct BonusModelsPlacementButtonsView: View {

	@Binding var selectedModel: Model?
	@Binding var isBonusModelsPlacementEnabled: Bool

	var models: [Model] // This should be your array of reality models

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false) {
			HStack {
				// Back button
				Button(action: {
					print("DEBUG: Reality model placement back button selected")
					isBonusModelsPlacementEnabled = false
				}) {
					Image(systemName: "arrowshape.turn.up.backward.fill")
						.frame(width: 60, height: 60)
						.font(.title)
						.background(Color.white.opacity(0.75))
						.cornerRadius(30)
						.padding(20)
				}

				// Display the options for reality models
				ForEach(0 ..< self.models.count) { index in
					Button(action: {
						print("DEBUG: selected reality model with name \(models[index].modelName)")
						selectedModel = models[index]

						if let model = selectedModel {
							ARManager.shared.actionStream.send(.loadModel(model))
							print("DEBUG: Sent reality model through actionStream")
						}

						DispatchQueue.main.async {
							selectedModel = nil
						}
					}) {
						Image(uiImage: self.models[index].image)
							.resizable()
							.frame(height: 80)
							.aspectRatio(1/1, contentMode: .fit)
							.background(Color.white)
							.cornerRadius(12)
					}
					.buttonStyle(PlainButtonStyle())
					.padding()
				}
			}
		}
		.padding(20)
		.background(Color.black.opacity(0.5))
	}
}


struct PreviewControllerWrapper: UIViewControllerRepresentable {
	let previewController: RPPreviewViewController
	let onDismiss: () -> Void

	func makeUIViewController(context: Context) -> UIViewController {
		let controller = previewController
		controller.previewControllerDelegate = context.coordinator
		return controller
	}



	func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

	class Coordinator: NSObject, RPPreviewViewControllerDelegate {
		let onDismiss: () -> Void

		init(onDismiss: @escaping () -> Void) {
			self.onDismiss = onDismiss
		}

		func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
			print("DEBUG: Preview controller finished and dismissing")
			previewController.dismiss(animated: true, completion: onDismiss)
		}

	}

	func makeCoordinator() -> Coordinator {
		return Coordinator(onDismiss: onDismiss)
	}
}
#else
// Alternative structure for the simulator
struct ARContentView: View {
	var body: some View {
		Text("AR View not available in the iOS simulator!")
			.font(.title)
			.foregroundColor(.red)
			.multilineTextAlignment(.center)
			.padding()
	}
}

#endif
