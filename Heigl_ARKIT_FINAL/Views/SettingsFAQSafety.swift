//
//  SettingsFAQSafety.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI
import CoreData

struct SettingsPreferencesSafetyView: View {
    @State private var dummyText: String = "Dummy Text"
    @State private var selectedSection: Int = 0
    
    private let sections = ["Settings", "FAQ", "Safety"]

    var body: some View {
        VStack(spacing: 20) {
            Picker(selection: $selectedSection, label: Text("Choose a section")) {
                ForEach(sections.indices, id: \.self) { index in
                    Text(sections[index]).tag(index)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)

            ScrollView { // Added ScrollView
                VStack(spacing: 20) {

                    Divider()

                    switch selectedSection {
                    case 0:
                        SettingsView()
                    case 1:
                        FAQView()
                    case 2:
                        SafetyView()
                    default:
                        EmptyView()
                    }
                }
            }
        }
        .padding()
    }
}

// Settings Content View
struct SettingsView: View {
    var body: some View {
        VStack {
            Text("Settings Content")
            // Add more UI components specific to settings here
        }
    }
}

// FAQ Content View
struct FAQView: View {
    var body: some View {
        VStack {
            Text("FAQ Content")
            // Add more UI components specific to FAQ here
        }
    }
}

struct SafetyView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(entity: Safety.entity(), sortDescriptors: [])
	private var safetyEntries: FetchedResults<Safety>

	var body: some View {
		VStack {
			Text("Safety Content")
				.font(.title)
			ScrollView {
				LazyVStack {
					ForEach(safetyEntries, id: \.self) { entry in
						SafetyCardView(safetyEntry: entry)
					}
				}
			}
		}
	}
}

struct SettingsPreferencesSafetyView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsPreferencesSafetyView()
    }
}


struct SafetyCardView: View {
	var safetyEntry: Safety

	var body: some View {
		VStack {
			Text(safetyEntry.safTitle ?? "No Title")
				.font(.headline)
			URLImage(url: safetyEntry.safPicture ?? "")
			Text(safetyEntry.safContent ?? "No Content")
				.font(.body)
				.padding()
		}
		.padding()
		.background(Color.white)
		.cornerRadius(10)
		.shadow(radius: 5)
	}
}

struct URLImage: View {
	var url: String
	
	var body: some View {
		if let imageUrl = URL(string: url), let imageData = try? Data(contentsOf: imageUrl), let image = UIImage(data: imageData) {
			return Image(uiImage: image)
				.resizable()
				.scaledToFit()
				.frame(height: 200)
				.cornerRadius(10)
				.padding()
		} else {
			// If the image can't be loaded, use a placeholder
			return Image(systemName: "photo")
				.resizable()
				.scaledToFit()
				.frame(height: 200)
				.cornerRadius(10)
				.padding()
		}
	}
}
