//
//  LocationDetailsView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/31/23.
//
// Initial Maps Code based off tutorial from: https://www.youtube.com/watch?v=gy6rp_pJmbo

import MapKit
import SwiftUI

struct LocationDetailsView: View {
	@Binding var mapSelection: MKMapItem?
	@Binding var show: Bool
	@State private var lookAroundScene: MKLookAroundScene?
	@Binding var getDirections: Bool
	
	var body: some View {
		VStack{
			HStack{
				VStack(alignment: .leading){
					Text(mapSelection?.placemark.name ?? "")
						.font(.title2)
						.fontWeight(.semibold)
					
					Text(mapSelection?.placemark.title ?? "")
						.font(.footnote)
						.foregroundStyle(.gray)
						.lineLimit(2)
						.padding(.trailing)
				}
				
				Spacer()
				
				Button {
					show.toggle()
					mapSelection = nil
				} label: {
					Image(systemName: "xmark.circle.fill")
						.resizable()
						.frame(width: 24, height: 24)
						.foregroundStyle(.gray, Color(.systemGray6))
				}
				
			}
			if let scene = lookAroundScene {
				LookAroundPreview(initialScene: scene)
					.frame(height: 200)
					.cornerRadius(12)
					.padding()
			} else {
				ContentUnavailableView("No preview available",systemImage: "eye.slash")
			}
			
			HStack(spacing: 24){
				Button {
					if let mapSelection {
						mapSelection.openInMaps()
					}
				} label: {
					Text("Open in Maps")
						.font(.headline)
						.foregroundColor(.white)
						.frame(width: 170, height: 48)
						.background(.green)
						.cornerRadius(12)
					
				}
				
				Button{
					// Toggle to true if we want to generate a polyline to see route
					getDirections = true
					show = false
				} label: {
					Text("Get Directions")
						.font(.headline)
						.foregroundColor(.white)
						.frame(width: 170, height: 48)
						.background(.blue)
						.cornerRadius(12)
				}
			}
			.padding(.horizontal)
			
			
		}
		.onAppear {
			print("Calling fetchLookAroundPreview() onAppear")
			fetchLookAroundPreview()
		}
		.onChange(of: mapSelection){ oldValue, newValue in
			print("Calling fetchLookAroundPreview() onChange")
			fetchLookAroundPreview()
		}
		.padding()
    }
}

extension LocationDetailsView {
	func fetchLookAroundPreview(){
		if let mapSelection {
			// Reset lookAroundScene
			lookAroundScene = nil
			Task {
				let request = MKLookAroundSceneRequest(mapItem: mapSelection)
				lookAroundScene = try? await request.scene
			}
		}
	}
}

#Preview {
	LocationDetailsView(mapSelection: .constant(nil), show: .constant(false), getDirections: .constant(false))
}
