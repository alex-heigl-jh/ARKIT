//
//  MainMenuView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//


import SwiftUI
import CoreData

struct MainMenuView: View {
	@State private var selectedView: Int? = nil
	@Environment(\.managedObjectContext) var managedObjectContext
	@EnvironmentObject var viewModel: UserAuth

	// Define an array of colors to cycle through
	private let colors: [Color] = [.red, .blue, .green, .yellow, .orange, .purple]
	// State variable to track the current color
	@State private var currentColorIndex = 0
	@State private var colorTransitionProgress: CGFloat = 0
	
//	@StateObject private var modelData = SharedModelData()

	// Timer to change the color
	let timer = Timer.publish(every: 2.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 30) {
            Spacer()  // Pushes content downwards

            CustomTitleView() // Enhanced Title in the center


			mainButton(label: "View Map", images: ["mappin.and.ellipse.circle", "map.fill", "signpost.right.and.left.fill"], destination: MapsView(), colors: [Color.green, Color.blue])
				.transition(.move(edge: .bottom))
            

			mainButton(label: "Augmented Reality", images: ["camera.metering.matrix", "arkit", "figure.walk"], destination: ARContentView(), colors: [Color.orange, Color.red])
				.transition(.move(edge: .bottom))


			mainButton(label: "News Feed", images: ["figure.socialdance", "newspaper.fill", "captions.bubble"], destination: NewsFeedView(), colors: [Color.purple, Color.pink])
				.transition(.move(edge: .bottom))
            

			mainButton(label: "Settings, FAQ, and Safety", images: ["gearshape", "person.fill.questionmark", "exclamationmark.triangle.fill"], destination: SettingsPreferencesSafetyView().environment(\.managedObjectContext, managedObjectContext), colors: [Color.teal, Color.cyan])

				.transition(.move(edge: .bottom))
				.environmentObject(viewModel)
            

            Spacer()  // Pushes content upwards
        }
		.padding()
//		.modifier(BackgroundColorModifier(progress: colorTransitionProgress, colors: colors))
		.edgesIgnoringSafeArea(.all)
//		.onReceive(timer) { _ in
//			withAnimation(.linear(duration: 5)) {
//				colorTransitionProgress += 1
//			}
//		}
//		.onAppear {
//			modelData.loadModels()
//		}
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
                            .frame(width: (UIScreen.main.bounds.width - 40) / 3) // Divide by 3 because we have 3 images
                            .foregroundColor(colors[1]) // Set the color of the SF Symbol
                    }
                }
                .frame(height: 50) // You can adjust this based on your needs

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
			// Assuming NewsFeedView requires a managedObjectContext
			return AnyView(destinationView.environment(\.managedObjectContext, self.managedObjectContext))
		} else {
			return AnyView(destination.environmentObject(viewModel))
		}
	}
//	func mainButton<T: View>(label: String, images: [String], destination: T, colors: [Color]) -> some View {
//		if let destinationView = destination as? ARContentView {
//			return AnyView(
//				NavigationLink(destination: destinationView.environmentObject(viewModel).environmentObject(modelData)) {
//					ButtonView(label: label, images: images, colors: colors)
//				}
//			)
//		} else {
//			return AnyView(
//				NavigationLink(destination: destination.environmentObject(viewModel)) {
//					ButtonView(label: label, images: images, colors: colors)
//				}
//			)
//		}
//	}
//
//	private func ButtonView(label: String, images: [String], colors: [Color]) -> some View {
//		VStack {
//			HStack {
//				ForEach(images, id: \.self) { imageName in
//					Image(systemName: imageName)
//						.resizable()
//						.aspectRatio(contentMode: .fit)
//						.frame(width: (UIScreen.main.bounds.width - 40) / 3)
//						.foregroundColor(colors[1])
//				}
//			}
//			.frame(height: 50)
//
//			Text(label)
//				.font(.headline)
//				.frame(maxWidth: .infinity, alignment: .center)
//				.padding()
//				.background(LinearGradient(gradient: Gradient(colors: colors), startPoint: .leading, endPoint: .trailing))
//				.foregroundColor(.white)
//				.cornerRadius(10)
//		}
//		.padding(10)
//		.overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 2))
//	}


    struct CustomTitleView: View {
        var body: some View {
            Text("Main Menu")
                .font(Font.system(size: 32, weight: .bold, design: .rounded))
                .padding(.bottom, 10)
                .background(
                    LinearGradient(gradient: Gradient(colors: [Color.blue, Color.purple]), startPoint: .leading, endPoint: .trailing) // Using a gradient that matches the style
                        .frame(width: 250, height: 60)
                        .cornerRadius(10)
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
}

extension Color {
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
