//
//  ARContentView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4
//  Code then augmented from tutorial from: https://www.youtube.com/watch?v=9R_G0EI-UoI&t=194s

import SwiftUI

struct ARContentView: View {
	
	//: Variable to control whether scroll view or placement view displayed to the user
	@State private var isPlacementEnabled = false
	
	@State private var selectedModel: Model?
	
	@State private var modelConfirmedForPlacement: Model?
	
	
	private var models: [Model] = {
		// Dynamically retrieve our model filenames
		let filemanager = FileManager.default
		
		// Safely unwrap optional value
		guard let path = Bundle.main.resourcePath, let files = try? filemanager.contentsOfDirectory(atPath: path) else{
			return []
		}
		
		var availableModels: [Model] = []
		for filename in files where filename.hasSuffix("usdz"){
			let modelName = filename.replacingOccurrences(of: ".usdz", with: "")
			
			let model = Model(modelName: modelName)
			
			availableModels.append(model)
		}
		
		return availableModels
	}()
	
	var body: some View {
		
		ZStack(alignment: .bottom){
			CustomARViewRepresentable()
				.ignoresSafeArea()

			
			if self.isPlacementEnabled {
				PlacementButtonsView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, modelConfirmedForPlacement: self.$modelConfirmedForPlacement)
			} else {
				ModelPickerView(isPlacementEnabled: self.$isPlacementEnabled, selectedModel: self.$selectedModel, models: self.models)
			}
			
		}
	}
}

struct ModelPickerView: View {
	
	@Binding var isPlacementEnabled: Bool
	@Binding var selectedModel: Model?
	
	@State private var selectedColor: Color = .green
	
	var models: [Model]
	
	private let colors: [Color] = [.green, .red, .blue]
	
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
				
				ForEach(colors, id: \.self) { color in
					Button{
						print("DEBUG: Placing Colored LBock ")
						ARManager.shared.actionStream.send(.placeBlock(color: color))
					} label: {
						color
							.frame(width: 40, height: 40)
							.padding()
							.background(.regularMaterial)
							.cornerRadius(16)
					}
				}
				
				//: "Zero up-to but not including"
				ForEach(0 ..< self.models.count){ index in
						
					Button(action: {
						print("DEBUG: selected model with name \(self.models[index].modelName)")
						
						self.selectedModel = self.models[index]
						
						self.isPlacementEnabled = true
					}) {
						Image(uiImage: self.models[index].image)
							.resizable() // All of these modifiers only act on the image
							.frame(height: 80)
							.aspectRatio(1/1,contentMode: .fit)
							.background(Color.white)
							.cornerRadius(12)
					}
					.buttonStyle(PlainButtonStyle())
				}
			}
		}
		.padding(20)
		.background(Color.black.opacity(0.5))
	}
}


struct PlacementButtonsView: View {
	
	@Binding var isPlacementEnabled: Bool
	@Binding var selectedModel: Model?
	@Binding var modelConfirmedForPlacement: Model?
	
	var body: some View {
		HStack{
			//: Cancel button
			Button(action: {
				print("DEBUG: Model placement CANCELED")
				
				self.resetPlacementParameters()
			}){
				Image(systemName: "xmark")
					.frame(width: 60, height: 60)
					.font(.title)
					.background(Color.white.opacity(0.75))
					.cornerRadius(30)
					.padding(20)
			}

			Button(action: {
				print("DEBUG: model placement CONFIRMED")
				self.modelConfirmedForPlacement = self.selectedModel
				
				if let model = selectedModel {
					
					ARManager.shared.actionStream.send(.loadModel(model))
					print("DEBUG: Sent model through actionStream")
					// Load the actual USDZ file
//					if let modelURL = Bundle.main.url(forResource: modelName, withExtension: "usdz") {
//						ARManager.shared.actionStream.send(.loadModel(modelURL))
//					} else {
//						print("Error: USDZ file not found for model \(modelName)")
//					}

				}
				
				DispatchQueue.main.async{
					self.modelConfirmedForPlacement = nil
				}
				
				self.resetPlacementParameters()
			}){
				Image(systemName: "checkmark")
					.frame(width: 60, height: 60)
					.font(.title)
					.background(Color.white.opacity(0.75))
					.cornerRadius(30)
					.padding(20)
			}
		}
	}
	func resetPlacementParameters() {
		self.isPlacementEnabled = false
		self.selectedModel = nil
	}
}


class 

#Preview {
    ARContentView()
}
