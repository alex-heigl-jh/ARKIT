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
    
    private let sections = ["Profile", "Settings", "FAQ", "Safety"]

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
						ProfileView()
					case 1:
                        SettingsView()
                    case 2:
                        FAQView()
                    case 3:
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

struct ProfileView: View {
	var body: some View {
		List {
			Section {
				HStack{
					Text(HomeUser.MOCK_USER.initials)
						.font(.title)
						.fontWeight(.semibold)
						.foregroundColor(.white)
						.frame(width: 72, height: 72)
						.background(Color(.systemGray3))
						.clipShape(Circle())
					
					VStack(alignment: .leading, spacing: 4) {
						Text(HomeUser.MOCK_USER.fullname)
							.font(.subheadline)
							.fontWeight(.semibold)
							.padding(.top, 4)
						
						Text(HomeUser.MOCK_USER.email)
							.font(.footnote)
							.foregroundColor(.gray)
					}
				}
			}
			
			Section("General") {
				HStack {
					SettingsRowView(imageName: "gear",
									title: "Version",
									tintColor: Color(.systemGray))
					Spacer()
					
					Text("1.0.0")
						.font(.subheadline)
						.foregroundColor(.gray)
				}

			}
			
			Section("Account") {
				Button {
					print("Sign out..")
				} label: {
					SettingsRowView(imageName: "arrow.left.circle.view",
									title: "Sign Out",
									tintColor: Color(.red))
				}
				Button {
					print("Delete account..")
				} label: {
					SettingsRowView(imageName: "xmark.circle.view",
									title: "Delete Account",
									tintColor: Color(.red))
				}
			}
		}
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
