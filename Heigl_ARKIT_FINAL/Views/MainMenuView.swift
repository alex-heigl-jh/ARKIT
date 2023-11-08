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

    var body: some View {
        VStack(spacing: 30) {
            Spacer()  // Pushes content downwards

            CustomTitleView() // Enhanced Title in the center

            withAnimation(Animation.spring().delay(0.1)) {
                mainButton(label: "View Map", images: ["mappin.and.ellipse.circle", "map.fill", "signpost.right.and.left.fill"], destination: MapsView(), colors: [Color.green, Color.blue])
                    .transition(.move(edge: .bottom))
            }

            withAnimation(Animation.spring().delay(0.2)) {
                mainButton(label: "Augmented Reality", images: ["camera.metering.matrix", "arkit", "figure.walk"], destination: ARContentView(), colors: [Color.orange, Color.red])
                    .transition(.move(edge: .bottom))
            }

            withAnimation(Animation.spring().delay(0.3)) {
                mainButton(label: "News Feed", images: ["figure.socialdance", "newspaper.fill", "captions.bubble"], destination: NewsFeedView(), colors: [Color.purple, Color.pink])
                    .transition(.move(edge: .bottom))
            }

            withAnimation(Animation.spring().delay(0.4)) {
                mainButton(label: "Settings, FAQ, and Safety", images: ["gearshape", "person.fill.questionmark", "exclamationmark.triangle.fill"], destination: SettingsPreferencesSafetyView(), colors: [Color.teal, Color.cyan])
                    .transition(.move(edge: .bottom))
            }

            Spacer()  // Pushes content upwards
        }
        .padding()
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.4), Color.gray.opacity(0.3)]), startPoint: .top, endPoint: .bottom)
        )
        .edgesIgnoringSafeArea(.all) // Ensure the background extends to the edges
    }

    // Updated mainButton function
	func mainButton<T: View>(label: String, images: [String], destination: T, colors: [Color]) -> some View {
		NavigationLink(destination: destination.environment(\.managedObjectContext, self.managedObjectContext)) {
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
            .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.gray, lineWidth: 2))
        }
    }

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

struct MainMenuView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            MainMenuView()
        }
    }
}
