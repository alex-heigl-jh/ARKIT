//
//  SettingsFAQSafety.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI
import CoreData
import Foundation
import AVKit

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
								.environment(\.managedObjectContext, managedObjectContext)
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
	@Environment(\.managedObjectContext) private var viewContext
	
	@State var showIAP = false
	var iapDelegate: IAPViewDelegate = IAPViewDelegate()
	@State private var isResearchKitShowing: Bool = false
	@State private var isAdRemoved: Bool = UserDefaults.standard.bool(forKey: "removeAdsPurchased")
	@State private var mapsDisplayEnabled: Bool = UserDefaults.standard.bool(forKey: "mapsDisplayEnabled")
	@State private var metallicBoxesEnabled: Bool = UserDefaults.standard.bool(forKey: "metallicBoxesEnabled")

	@State private var selectedMapStyleIndex: Int

	
	@FetchRequest(
	  sortDescriptors: [SortDescriptor(\.name)]
	) var allIAP: FetchedResults<IAP>
	
//	@FetchRequest(entity: Safety.entity(), sortDescriptors: [])
	
	init() {
		let savedMapStyleRawValue = UserDefaults.standard.integer(forKey: "selectedMapStyle")
		
		// Initialize the state variable directly without using the underscore
		_selectedMapStyleIndex = State(initialValue: savedMapStyleRawValue)
		
		if let mapStyle = MapStyleDropDown(rawValue: savedMapStyleRawValue) {
			print("Loaded saved map style: \(mapStyle.title)")
		} else {
			print("No saved map style found. Set to default: Standard")
			UserDefaults.standard.set(MapStyleDropDown.standard.rawValue, forKey: "selectedMapStyle")
		}
	}
	
	
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

					// App Version Info Section
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
								Text("Delete Account... Coming Soon :)")
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
					
					// IAP Section
					VStack(spacing: 8) {
						Text("In-App Purchases") // Title for IAP Section
							.font(.headline)
							.foregroundColor(.black)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.horizontal)
						
						Divider() // To visually separate the title from the buttons

						if !isAdRemoved {
							Button(action: {
								print("Remove Banners Ads Button Selected")
								self.showIAP.toggle()
							}) {
								HStack {
									Image(systemName: "xmark.circle")
										.foregroundColor(Color.red)
									Text("Remove Banner Ads")
										.foregroundColor(.black)
								}
								.padding(.horizontal)
							}
							.frame(maxWidth: .infinity, alignment: .leading)
						}
						
						
//						Button(action: {
//							// Action to purchase AR Model Pack
//							print("Unlock AR Model Pack Button Selected")
//						}) {
//							HStack {
//								Image(systemName: "cube.box")
//									.foregroundColor(Color.green)
//								Text("Unlock AR Model Pack")
//									.foregroundColor(.black)
//							}
//							.padding(.horizontal)
//						}
//						.frame(maxWidth: .infinity, alignment: .leading)
					}
					.padding(.vertical)
					.background(Color.white)
					.cornerRadius(10)
					.shadow(radius: 1)
					
					// App Settings Section
					VStack(spacing: 8) {
						Text("Configurable App Settings")
							.font(.headline)
							.foregroundColor(.black)
							.frame(maxWidth: .infinity, alignment: .leading)
							.padding(.horizontal)
						
						Divider()

//						Picker("Map Style", selection: $selectedMapStyleIndex) {
//							Text("Standard").tag(0)
//							Text("Satellite").tag(1)
//							Text("Hybrid").tag(2)
//						}
//						.onChange(of: selectedMapStyleIndex) { newValue in
//							UserDefaults.standard.set(newValue, forKey: "selectedMapStyle")
//							if let newMapStyle = MapStyleDropDown(rawValue: newValue) {
//								print("Map style changed to: \(newMapStyle.title)")
//							} else {
//								print("Invalid map style index: \(newValue)")
//							}
//						}

							
						// Title for the Picker
						HStack {
							Text("Map Style:")
								.font(.headline) // You can adjust the font as needed
								.foregroundColor(.black) // Set the color as needed
							
							Picker("Select a style", selection: $selectedMapStyleIndex) {
								Text("Standard").tag(0)
								Text("Satellite").tag(1)
								Text("Hybrid").tag(2)
							}
							.onChange(of: selectedMapStyleIndex) { newValue in
								UserDefaults.standard.set(newValue, forKey: "selectedMapStyle")
								if let newMapStyle = MapStyleDropDown(rawValue: newValue) {
									print("Map style changed to: \(newMapStyle.title)")
								} else {
									print("Invalid map style index: \(newValue)")
								}
							}
							// You may need to adjust the frame or padding here to get the layout you want
							.frame(maxWidth: .infinity)
						}

						.padding()

						HStack {
							Text("Enable Metallic Boxes in AR")
								.foregroundColor(.black) // Ensure the text color is visible against the background
							Toggle("", isOn: $metallicBoxesEnabled)
								.labelsHidden() // This hides the default label of the Toggle
						}
						.onChange(of: metallicBoxesEnabled) { newValue in
							UserDefaults.standard.set(newValue, forKey: "metallicBoxesEnabled")
						}
						.padding()
					}
					.padding(.vertical)
					.background(Color.white)
					.cornerRadius(10)
					.shadow(radius: 1)

				}
				.padding(.horizontal)
			}
			
			.sheet(isPresented: $showIAP, content: {
				NavigationView {
					IAPListing(delegate: self.iapDelegate, context: self.viewContext)
						.navigationBarTitle("In App Purchases")
						.navigationBarItems(trailing: Button("Done"){self.showIAP = false})
				}
			})
		}
	}
}

enum MapStyleDropDown: Int {
	case standard = 0
	case satellite = 1
	case hybrid = 2

	var title: String {
		switch self {
		case .standard: return "Standard"
		case .satellite: return "Satellite"
		case .hybrid: return "Hybrid"
		}
	}
}

// FAQ Content View with dividers and vertical padding
struct FAQView: View {
	@FetchRequest(
		entity: FAQ.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \FAQ.faqTitle, ascending: true)]
	) var faqs: FetchedResults<FAQ>

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 10) {
				ForEach(faqs, id: \.faqID) { faq in
					VStack(alignment: .leading) {
						Text(faq.faqTitle ?? "No Title")
							.font(.headline)
							.foregroundColor(.primary)
						Text(faq.faqContent ?? "No Content")
							.font(.body)
							.foregroundColor(.secondary)
							.padding(.vertical, 4) // Added vertical padding
					}
					.padding()
					.background(Color(.systemBackground))
					.cornerRadius(10)
					.shadow(radius: 3)

					if faqs.last != faq {
						Divider() // Add a divider if it's not the last item
					}
				}
			}
			.padding()
		}
	}
}

struct SafetyView: View {
	@Environment(\.managedObjectContext) private var viewContext
	@FetchRequest(entity: Safety.entity(), sortDescriptors: [])
	private var safetyEntries: FetchedResults<Safety>

	var body: some View {
		VStack {
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

struct SafetyCardView: View {
	var safetyEntry: Safety

	var body: some View {
		VStack {
			Text(safetyEntry.safTitle ?? "No Title")
				.font(.headline)
				.multilineTextAlignment(.center)
				.frame(maxWidth: .infinity)
				.foregroundColor(.black)

			if safetyEntry.mediaType == "image" {
				// Display image
				URLImage(url: safetyEntry.mediaURL ?? "")
					.frame(width: 150, height: 150)
					.cornerRadius(10)
					.padding(.bottom, 10)
			} else if safetyEntry.mediaType == "video" {
				// Display video player
				if let videoURL = URL(string: safetyEntry.mediaURL ?? "") {
					VideoPlayer(player: AVPlayer(url: videoURL))
						.frame(width: 150, height: 150)
						.cornerRadius(10)
						.padding(.bottom, 10)
				}
			}

			Text(safetyEntry.safContent ?? "No Content")
				.font(.body)
				.multilineTextAlignment(.center)
				.padding()
				.frame(maxWidth: .infinity)
				.foregroundColor(.black)
		}
		.padding()
		.frame(width: UIScreen.main.bounds.width - 40, alignment: .center)
		.background(Color.gray)
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
					.scaledToFill()
					.frame(width: 150, height: 150) // Set a fixed frame for the image
					.clipped() // Ensure the image does not exceed the frame
			} else {
				Image(systemName: "photo") // Placeholder image
					.resizable()
					.scaledToFit()
					.frame(width: 150, height: 150)
					.foregroundColor(.gray)
			}
		}
		.cornerRadius(10)
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


