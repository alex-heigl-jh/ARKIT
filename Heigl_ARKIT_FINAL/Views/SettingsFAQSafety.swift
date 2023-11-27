//
//  SettingsFAQSafety.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI
import CoreData
import Foundation

struct SettingsPreferencesSafetyView: View {
	@State private var selectedSection: Int = 0
	private let sections = ["Profile & Settings", "FAQ", "Safety"]
	
	@EnvironmentObject var viewModel: UserAuth
	@Environment(\.managedObjectContext) var managedObjectContext

	var body: some View {
		VStack {
			// Assuming there's a navigation view or some other content above this VStack.
			Picker("Choose a section", selection: $selectedSection) {
				ForEach(0..<sections.count, id: \.self) { index in
					Text(self.sections[index]).tag(index)
				}
			}
			.pickerStyle(SegmentedPickerStyle())
			.padding()

			ScrollView {
				VStack(spacing: 20) {
					Group {
						switch selectedSection {
						case 0:
							ProfileSettingsView()
								.environmentObject(viewModel)
						case 1:
							FAQView()
						case 2:
							SafetyView()
								.environment(\.managedObjectContext, managedObjectContext)
						default:
							Text("Selection not found.")
						}
					}
					.id(selectedSection) // Ensure SwiftUI recreates the view when selection changes
				}
			}
		}
		.background(Color(.systemBackground)) // Use system background color
		.navigationBarTitleDisplayMode(.inline) // If you're within a NavigationView
	}
}

struct ProfileSettingsView: View {
	@EnvironmentObject var viewModel: UserAuth
	
	var body: some View {
		if let user = viewModel.currentUser {
			ScrollView {
				VStack(spacing: 12) {
					// User Profile Section
					VStack(spacing: 8) {
						HStack {
							Text(user.initials)
								.font(.largeTitle)
								.fontWeight(.bold)
								.foregroundColor(.white)
								.frame(width: 72, height: 72)
								.background(Color.gray)
								.clipShape(Circle())

							VStack(alignment: .leading, spacing: 4) {
								Text(user.fullname)
									.font(.title2)
									.fontWeight(.bold)
									.foregroundColor(.black)

								Text(user.email)
									.font(.body)
									.foregroundColor(.black)
								
							}
							Spacer() // Ensures the HStack uses the full width
						}
						.padding(.horizontal) // Apply padding to the content, not the VStack
					}
					.padding(.vertical)
					.background(Color.white)
					.cornerRadius(10)
					.shadow(radius: 1)

					// General Section
					VStack(spacing: 8) {
						HStack {
							Image(systemName: "gear")
								.foregroundColor(Color.gray)
							Text("Version")
								.foregroundColor(.black)
							Spacer() // Pushes the content to the left
							Text("1.0.0")
								.foregroundColor(.gray)
						}
						.padding(.horizontal) // Apply padding to the content
					}
					.padding(.vertical)
					.background(Color.white)
					.cornerRadius(10)
					.shadow(radius: 1)

					// Account Section
					VStack(spacing: 8) {
						Button(action: {
							print("Sign out..")
							viewModel.signOut()
						}) {
							HStack {
								Image(systemName: "arrow.left.circle")
									.foregroundColor(Color.red)
								Text("Sign Out")
									.foregroundColor(.black)
							}
							.padding(.horizontal) // Apply padding to the content
						}
						.frame(maxWidth: .infinity, alignment: .leading) // Ensures the button stretches

						Button(action: {
							print("Delete account..")
							Task {
								do {
									try await viewModel.deleteAccount()
									// Handle any UI updates here, if necessary
								} catch {
									// Handle the error here, e.g., showing an alert to the user
									print("Error deleting account: \(error.localizedDescription)")
								}
							}
						}) {
							HStack {
								Image(systemName: "xmark.circle")
									.foregroundColor(Color.red)
								Text("Delete Account... Not yet implemented :)")
									.foregroundColor(.black)
							}
							.padding(.horizontal) // Apply padding to the content
						}
						.frame(maxWidth: .infinity, alignment: .leading) // Ensures the button stretches

					}
					.padding(.vertical)
					.background(Color.white)
					.cornerRadius(10)
					.shadow(radius: 1)
				}
				.padding(.horizontal)
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
//			Text("Is Context Connected: \(String(describing: viewContext.persistentStoreCoordinator != nil))")
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
	@State private var imageData: Data?

	var body: some View {
		Group {
			if let imageData = imageData, let uiImage = UIImage(data: imageData) {
				Image(uiImage: uiImage)
					.resizable()
					.scaledToFit()
			} else {
				Image(systemName: "photo") // Placeholder image
					.resizable()
					.scaledToFit()
			}
		}
		.frame(height: 200)
		.cornerRadius(10)
		.padding()
		.onAppear {
			loadImage()
		}
	}

	private func loadImage() {
		guard let url = URL(string: url) else {
			print("Invalid URL")
			return
		}

		URLSession.shared.dataTask(with: url) { data, response, error in
			if let data = data {
				DispatchQueue.main.async {
					self.imageData = data
				}
			} else {
				print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
			}
		}.resume()
	}
}
