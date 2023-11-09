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
	@State private var selectedColor: Color = .green
	private let colors: [Color] = [.green, .red, .blue]
	
	var models: [String] = ["fender_stratocaster","flower_tulip","toy_drummer_idle","tv_retro","gramophone","hab_en","LunarRover_English","CosmonautSuit_en","pancakes","robot_walk_idle","toy_biplane_idle","toy_car"]
	
	var body: some View {
		
		//: All of the usdz / reality kit models that will be accesible to user
		

		ZStack(alignment: .bottom){
			CustomARViewRepresentable()
				.ignoresSafeArea()
			
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
							
						Button(action: {print("DEBUG: selected models with name \(self.models[index])")
						}) {
							Image(uiImage: UIImage(named:self.models[index])!)
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
}


//struct ARContentView: View {
//	@State private var selectedColor: Color = .green
//	private let colors: [Color] = [.green, .red, .blue]
//	
//	var body: some View {
//
//		CustomARViewRepresentable()
//			.ignoresSafeArea()
//			.overlay(alignment: .bottom){
//				ScrollView(.horizontal){
//					HStack{
//						Button{
//							ARManager.shared.actionStream.send(.removeAllAnchors)
//						} label:{
//							Image(systemName: "trash")
//								.resizable()
//								.scaledToFit()
//								.frame(width: 40, height: 40)
//								.padding()
//								.background(.regularMaterial)
//								.cornerRadius(16)
//						}
//						
//						ForEach(colors, id: \.self) { color in
//							Button{
//								ARManager.shared.actionStream.send(.placeBlock(color: color))
//							} label: {
//								color
//									.frame(width: 40, height: 40)
//									.padding()
//									.background(.regularMaterial)
//									.cornerRadius(16)
//							}
//						}
//					}
//					.padding()
//				}
//			}
//		
//	}
//}

#Preview {
    ARContentView()
}
