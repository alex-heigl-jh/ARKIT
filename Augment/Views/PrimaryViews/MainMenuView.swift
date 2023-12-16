//
//  MainMenuView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI
import CoreData
import StoreKit
import os.log

struct MainMenuView: View {
	@State private var selectedView: Int? = nil
	@Environment(\.managedObjectContext) var managedObjectContext
	@EnvironmentObject var viewModel: UserAuth

	// Define an array of colors to cycle through
	private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple]
	// State variable to track the current color
	@State private var currentColorIndex = 0
	@State private var colorTransitionProgress: CGFloat = 0
	
	let log = Logger()

	// Timer to change the color
//	let timer = Timer.publish(every: 1.5, on: .main, in: .common).autoconnect()
	
	@State private var showAd = true // State to control ad visibility
	@State private var adBannerHeight: CGFloat = 100 // Variable to adjust ad banner height

	// Banner Ad View
	var adBanner: some View {
		VStack {
			Spacer()
			Text("SwiftUI Challenges?\nConnect with a Tutor Now!")
				.foregroundColor(.white)
				.font(.system(size: 24, weight: .bold, design: .default)) // Set font size and weight
				.multilineTextAlignment(.center) // Center the text
				.lineLimit(2) // Limit text to two lines
				.frame(maxWidth: .infinity, maxHeight: adBannerHeight)
				.background(Color.red)
				.onTapGesture {
					openAdURL()
				}
				.onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
					checkIAPStatus()
				}
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
		.edgesIgnoringSafeArea(.all)
	}
	

	var body: some View {
		ZStack {
			VStack(spacing: 30) {
				Spacer()  // Pushes content upwards

				CustomTitleView() // Enhanced Title in the center

				mainButton(label: "View Map", images: ["mappin.and.ellipse.circle", "map.fill", "signpost.right.and.left.fill"], destination: MapsView().environment(\.managedObjectContext, managedObjectContext), colors: [Color.green, Color.blue])
					.transition(.move(edge: .bottom))

				mainButton(label: "Augmented Reality", images: ["camera.metering.matrix", "arkit", "figure.walk"], destination: ARContentView().environment(\.managedObjectContext, managedObjectContext), colors: [Color.orange, Color.red])
					.transition(.move(edge: .bottom))

				mainButton(label: "News Feed", images: ["figure.socialdance", "newspaper.fill", "captions.bubble"], destination: NewsFeedView().environment(\.managedObjectContext, managedObjectContext), colors: [Color.purple, Color.pink])
					.transition(.move(edge: .bottom))
					.environmentObject(viewModel)

				mainButton(label: "Settings, FAQ, and Safety", images: ["gearshape", "person.fill.questionmark", "exclamationmark.triangle.fill"], destination: SettingsPreferencesSafetyView().environment(\.managedObjectContext, managedObjectContext), colors: [Color.teal, Color.cyan])
					.transition(.move(edge: .bottom))
					.environmentObject(viewModel)

				Spacer()  // Pushes content downwards
			}
			.padding([.leading, .trailing], 20)
			.edgesIgnoringSafeArea(.top)

			// Ad Banner positioned absolutely at the bottom
			if showAd {
				adBanner
			}
		}		
		.onAppear(){
			checkIAPStatus()
		}
	}

    // Updated mainButton function
	func mainButton<T: View>(label: String, images: [String], destination: T, colors: [Color]) -> some View {
		NavigationLink(destination: setupDestinationView(destination)) {
            VStack {
                HStack {
                    ForEach(images, id: \.self) { imageName in
                        Image(systemName: imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: (UIScreen.main.bounds.width - 120) / 3) // Divide by 3 because we have 3 images
                            .foregroundColor(colors[1]) // Set the color of the SF Symbol
                    }
                }
                .frame(height: 50)

                Text(label)
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(10)
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white, lineWidth: 2))
        }
    }
	private func setupDestinationView<T: View>(_ destination: T) -> some View {
		if let destinationView = destination as? NewsFeedView {
			// Pass both the managedObjectContext and viewModel to the NewsFeedView
			return AnyView(destinationView
				.environment(\.managedObjectContext, self.managedObjectContext)
				.environmentObject(viewModel))
		} else {
			// For other views, just pass the viewModel
			return AnyView(destination.environmentObject(viewModel))
		}
	}
	
	// Function to open the ad URL
	private func openAdURL() {
		if let url = URL(string: "https://www.linkedin.com/in/alex-heigl-939452b1/") {
			UIApplication.shared.open(url)
		}
	}

	// Function to check IAP status
	private func checkIAPStatus() {
		// Check if the user has purchased the IAP to disable ads
		let hasPurchasedRemoveAds = UserDefaults.standard.bool(forKey: "removeAdsPurchased")
		showAd = !hasPurchasedRemoveAds
		log.debug("showAd set to \(showAd)")
	}
	
	// Initialize UserDefaults if they don't exist
	private func initializeUserDefaults() {
		if UserDefaults.standard.object(forKey: "selectedMapStyle") == nil {
			UserDefaults.standard.set(0, forKey: "selectedMapStyle") // 0 for .standard
		}
		if UserDefaults.standard.object(forKey: "metallicBoxesEnabled") == nil {
			UserDefaults.standard.set(false, forKey: "metallicBoxesEnabled")
		}
	}

	
	struct CustomTitleView: View {
		var body: some View {
			Image(systemName: "house.circle") // Replace with your desired SF symbol
				.resizable()
				.aspectRatio(contentMode: .fit)
				.frame(width: 50, height: 50) 
				.padding()
				.background(
					LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing)
						.frame(width: 100, height: 100) // Adjust frame size as needed
						.cornerRadius(50) // Makes it fully rounded
						.shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 5)
				)
				.foregroundColor(.white)
		}
	}

}

struct BackgroundColorModifier: AnimatableModifier {
	var progress: CGFloat
	var colors: [Color]

	var animatableData: CGFloat {
		get { progress }
		set { progress = newValue }
	}

	func body(content: Content) -> some View {
		let totalColors = CGFloat(colors.count)
		let progressInCycle = (progress.truncatingRemainder(dividingBy: totalColors)) / totalColors
		let scaledProgress = progressInCycle * totalColors

		let startIndex = Int(scaledProgress)
		let endIndex = (startIndex + 1) % colors.count
		let interpolation = scaledProgress - CGFloat(startIndex)

		let startColor = colors[startIndex]
		let endColor = colors[endIndex]
		let interpolatedColor = Color.interpolate(from: startColor, to: endColor, with: interpolation)

		return content.background(interpolatedColor)
	}
}

extension Color {
	static func interpolate(from startColor: Color, to endColor: Color, with fraction: CGFloat) -> Color {
		guard let startComponents = startColor.components, let endComponents = endColor.components else { return startColor }

		let red = startComponents.red + fraction * (endComponents.red - startComponents.red)
		let green = startComponents.green + fraction * (endComponents.green - startComponents.green)
		let blue = startComponents.blue + fraction * (endComponents.blue - startComponents.blue)
		let alpha = startComponents.alpha + fraction * (endComponents.alpha - startComponents.alpha)

		return Color(red: red, green: green, blue: blue, opacity: alpha)
	}
	var components: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)? {
		var red: CGFloat = 0
		var green: CGFloat = 0
		var blue: CGFloat = 0
		var alpha: CGFloat = 0
		return UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) ? (red, green, blue, alpha) : nil
	}
}

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainMenuView()
        }
    }
}
