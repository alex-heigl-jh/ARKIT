//
//  ARContentView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
//  Code initially based off of tutorial from: https://www.youtube.com/watch?v=KbqbU-cCKf4

import SwiftUI

struct ARContentView: View {
	@State private var selectedColor: Color = .green
	private let colors: [Color] = [.green, .red, .blue]
	
	var body: some View {

		CustomARViewRepresentable()
			.ignoresSafeArea()
			.overlay(alignment: .bottom){
				ScrollView(.horizontal){
					HStack{
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
					}
					.padding()
				}
			}
		
	}
}

#Preview {
    ARContentView()
}
