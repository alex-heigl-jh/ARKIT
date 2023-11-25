//
//  ARContentView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4
//  Code then augmented with tutorial from: https://www.youtube.com/watch?v=9R_G0EI-UoI&t=194s


import SwiftUI
import UIKit
import Photos

struct ARContentView: View {

	// Function to load USDZ models
	private static func loadUSDZModels() -> [Model] {
		let filemanager = FileManager.default
		guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else {
			return []
		}

		return files.compactMap { filename in
			filename.hasSuffix("usdz") ? Model(modelName: filename.replacingOccurrences(of: ".usdz", with: "")) : nil
		}
	}

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
			// If the user selects that they would like to place a block, display scroll menu that allows them to select the desired block
			else if self.isBoxColorSelectEnabled {
				SelectBoxColorView(isBoxColorSelectEnabled: self.$isBoxColorSelectEnabled)
			}
			// By default, display ModelPickerView which is gives the user the option of selecting blocks or USDZ models
			else {
				ModelPickerView(
					isBoxColorSelectEnabled: $isBoxColorSelectEnabled,
					isUSDZPlacementEnabled: $isUSDZPlacementEnabled,
					isVideoCaptureEnabled: $isVideoCaptureEnabled)
			}
		}
	}
}

// Default scroll view at the bottom of the view
struct ModelPickerView: View {

	@Binding var isBoxColorSelectEnabled: Bool
	@Binding var isUSDZPlacementEnabled: Bool
	@Binding var isVideoCaptureEnabled: Bool
	
	// Used to control camera button animation used to indicate an image has been captured
	@State private var buttonColor = Color.blue


	let rainbowGradient = LinearGradient(
		gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple]),
		startPoint: .leading,
		endPoint: .trailing
	)

	var body: some View {
		ScrollView(.horizontal, showsIndicators: false){
			HStack(spacing: 30) {
				Button{
					ARManager.shared.actionStream.send(.removeAllAnchors)
				} label:{
					Image(systemName: "trash")
						.resizable()
						.scaledToFit()
						.frame(width: 40, height: 40)
						.padding()
						.background(.regularMaterial)
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
				.background(.regularMaterial)

				//: USDZ selection button
				Button(action: {
					print("DEBUG: USDZ models placement selection button selected")
					isUSDZPlacementEnabled = true
				}) {
					Image(systemName: "camera.macro")
						.font(.system(size: 30)) 		// Adjust the size as needed
						.frame(width: 40, height: 40) 	// Set the frame for the button
						.foregroundColor(.white) 		// Change the color of the symbol
						.padding() 						// Padding inside the button
						.background(Color.blue) 		// Change the background color of the button
						.cornerRadius(16) 				// Rounded corners for the button
				}

				//: Camera selection button
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
					ARManager.shared.actionStream.send(.captureVideo(isVideoCaptureEnabled))
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

			}
		}
		.padding(20)
		.background(Color.black.opacity(0.5))
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
