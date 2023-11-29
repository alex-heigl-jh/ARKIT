//
//  NewsFeedVieew.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//
import AVKit
import CoreData
import SwiftUI
import UIKit


struct NewsFeedView: View {
	// Needed for CoreData Context
	@Environment(\.managedObjectContext) private var viewContext
	// Needed for HomeUser Context
	@EnvironmentObject var viewModel: UserAuth
	
	@State private var showingAddPostSheet = false // State property for sheet presentation
	
	@State private var player = AVPlayer()

	@FetchRequest(
		entity: NewsFeed.entity(),
		sortDescriptors: [NSSortDescriptor(keyPath: \NewsFeed.newsCreatedOn, ascending: false)]
	) var newsFeeds: FetchedResults<NewsFeed>

	var body: some View {
		NavigationView {
			ZStack(alignment: .bottomTrailing) { // Use a ZStack to overlay the button
				// The list or content of the feed
				if newsFeeds.isEmpty {
					Text("No news available")
						.onAppear {
							print("No news items found.")
						}
				} else {
					List(newsFeeds) { feed in
						VStack(alignment: .leading, spacing: 10) {
							HStack(spacing: 15) {
								if let poster = feed.poster, let urlString = poster.profilePicURL, let url = URL(string: urlString) {
									AsyncImage(url: url, content: { image in
										image
									 		.resizable()
											.scaledToFit()
											.frame(width: 60, height: 60)
											.clipShape(Circle())
									}, placeholder: {
										Text("Loading...")
									})
									.onAppear {
										print("Loading profile picture from URL: \(urlString)")
									}
								} else {
									Image(systemName: "person.fill")
										.resizable()
										.scaledToFit()
										.frame(width: 60, height: 60)
										.clipShape(Circle())
										.onAppear {
											print("Profile picture URL is either nil or invalid.")
										}
								}
								
								VStack(alignment: .leading) {
									HStack {
										Text("\(feed.poster?.firstName ?? "") \(feed.poster?.lastName ?? "")")
											.font(.headline)
											.onAppear {
												print("Displaying username: \(feed.poster?.firstName ?? "Unknown") \(feed.poster?.lastName ?? "Unknown")")
											}
										
										Spacer() // Pushes the date to the right end of the HStack
										
										Text(feed.newsCreatedOn ?? Date(), style: .date) // Display the date
											.font(.subheadline)
											.foregroundColor(Color.gray) // Give the date a subtle color
									}
									
									Text(feed.newsContent ?? "")
										.font(.subheadline)
										.onAppear {
											print("Displaying news content: \(feed.newsContent ?? "No Content")")
										}
								}
							}
							// Check media type and display accordingly
							if let mediaURLString = feed.mediaURL, let mediaType = feed.mediaType {
								if mediaType == "image" {
									// Display the image
									AsyncImage(url: URL(string: mediaURLString), content: { image in
										image.resizable().scaledToFit().cornerRadius(10)
									}, placeholder: {
										Text("Loading news image...")
									})
								} else if mediaType == "video", let videoURL = URL(string: mediaURLString) {
									VideoPlayerView(url: videoURL)
										 .frame(height: 200) // Adjust the height as needed
										 .cornerRadius(10)
										 .onAppear {
											 player.play()
										 }
								}
							}
						}
						.onAppear {
							print("Attempting to display a news feed item.")
						}
					}
				}
				
				// Floating Action Button
				Button(action: {
					self.showingAddPostSheet = true // Trigger sheet presentation
				}) {
					Image(systemName: "plus")
						.padding()
						.background(Color.blue)
						.foregroundColor(.white)
						.clipShape(Circle())
						.shadow(radius: 3)
						.padding(.trailing, 20)
						.padding(.bottom, 20)
				}
			}
			.navigationBarTitle("News Feed", displayMode: .inline)
			// Inside NewsFeedView
			.sheet(isPresented: $showingAddPostSheet) {
				AddPostView().environment(\.managedObjectContext, self.viewContext)
							 .environmentObject(viewModel) // Pass viewModel here
			}
		}
	}
}



// Helper enum to distinguish between media types
enum MediaType {
	case photo
	case video
}

struct AddPostView: View {
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.managedObjectContext) var viewContext
	@EnvironmentObject var viewModel: UserAuth
	@State private var postContent: String = ""
	@State private var showMediaPicker: Bool = false
	@State private var mediaURL: URL?
	@State private var mediaType: MediaType?
	@State private var selectedImage: UIImage? // To hold the selected image
	
	
	var body: some View {
		NavigationView {
			Form {
				Section(header: Text("Post Content")) {
					TextField("What's on your mind?", text: $postContent)
				}
				
				Section {
					Button(action: {
						self.showMediaPicker = true
					}) {
						HStack {
							Image(systemName: "photo.on.rectangle.angled")
							Text(mediaURL == nil ? "Select a photo or video" : "Change Selection")
						}
					}
					// Display the selected image or a video icon
					if let selectedImage = selectedImage {
						Image(uiImage: selectedImage)
							.resizable()
							.scaledToFit()
							.frame(height: 200)
							.cornerRadius(10)
					} else if mediaType == .video {
						// Display a placeholder or thumbnail for video
						VideoThumbnailView(url: mediaURL)
							.frame(height: 200)
							.cornerRadius(10)
					}
				}
			}
			
			.navigationBarItems(leading: Button("Cancel") {
				presentationMode.wrappedValue.dismiss()
			}, trailing: Button("Post") {
				handlePost()
				presentationMode.wrappedValue.dismiss()
			})
			.sheet(isPresented: $showMediaPicker) {
				MediaPicker(mediaURL: $mediaURL, mediaType: $mediaType, selectedImage: $selectedImage, isShown: $showMediaPicker)
			}
		}
		.onAppear() {
			if let user = viewModel.currentUser {
				print("CHECK: User Name: \(user.fullname)")
			}
		}
	}
	
	private func handlePost() {
		let newPost = NewsFeed(context: viewContext)
		newPost.newsContent = postContent
		newPost.newsID = UUID() // Generate a new UUID
		newPost.newsCreatedOn = Date() // Set to current date and time
		
		// Fetch or create user and link to the post
		if let currentUser = viewModel.currentUser {
			newPost.newsPosterID = currentUser.id // Use the userID from the viewModel
			
			// Fetch the user by userID, if the user doesn't exist, create a new one
			if let user = User.fetchUserBy(userID: currentUser.id, in: viewContext) {
				newPost.poster = user
			} else {
				// User not found, create a new user
				let newUser = User(context: viewContext)
				newUser.userID = currentUser.id
				newUser.firstName = currentUser.firstName
				newUser.lastName = currentUser.lastName
				newUser.profilePicURL = currentUser.profilePicURL
				
				newPost.poster = newUser
			}
		}
		
		// Add media information if available
		if let mediaURL = mediaURL {
			newPost.mediaURL = mediaURL.absoluteString
			newPost.mediaType = (mediaType == .photo) ? "image" : "video"
		}
		
		// Save context
		do {
			try viewContext.save()
		} catch {
			print("Error saving new post: \(error)")
		}
	}
}

struct MediaPicker: UIViewControllerRepresentable {
	@Binding var mediaURL: URL?
	@Binding var mediaType: MediaType?
	@Binding var selectedImage: UIImage?
	@Binding var isShown: Bool

	func makeUIViewController(context: Context) -> UIImagePickerController {
		let picker = UIImagePickerController()
		picker.delegate = context.coordinator
		picker.mediaTypes = ["public.image", "public.movie"] // Allow both images and videos
		return picker
	}

	func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

	func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
		let parent: MediaPicker

		init(_ parent: MediaPicker) {
			self.parent = parent
		}

		func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
			if let mediaType = info[.mediaType] as? String {
				if mediaType == "public.image", let image = info[.originalImage] as? UIImage {
					parent.selectedImage = image // Assign the selected image
					if let imageURL = info[.imageURL] as? URL {
						parent.mediaURL = imageURL
					}
					parent.mediaType = .photo
				} else if mediaType == "public.movie", let videoURL = info[.mediaURL] as? URL {
					parent.selectedImage = thumbnailImage(for: videoURL) // Get thumbnail for video
					parent.mediaURL = videoURL
					parent.mediaType = .video
				}
			}
			parent.isShown = false
		}

		func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
			parent.isShown = false
		}
		// Helper function to extract a thumbnail from a video
		private func thumbnailImage(for url: URL) -> UIImage? {
			let asset = AVAsset(url: url)
			let assetImageGenerator = AVAssetImageGenerator(asset: asset)
			assetImageGenerator.appliesPreferredTrackTransform = true
			
			var time = asset.duration
			time.value = min(time.value, 2)
			
			do {
				let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
				return UIImage(cgImage: imageRef)
			} catch {
				return nil
			}
		}
	}
}

struct VideoThumbnailView: View {
	var url: URL?
	
	var body: some View {
		ZStack {
			if let url = url, let thumbnail = thumbnailImage(for: url) {
				Image(uiImage: thumbnail)
					.resizable()
					.scaledToFit()
			} else {
				Image(systemName: "video.fill")
					.font(.largeTitle)
					.padding()
					.foregroundColor(.gray)
			}
		}
	}
	
	private func thumbnailImage(for url: URL) -> UIImage? {
		let asset = AVAsset(url: url)
		let assetImageGenerator = AVAssetImageGenerator(asset: asset)
		assetImageGenerator.appliesPreferredTrackTransform = true
		
		var time = asset.duration
		time.value = min(time.value, 2)
		
		do {
			let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
			return UIImage(cgImage: imageRef)
		} catch {
			return nil
		}
	}
}

struct VideoPlayerView: View {
	var url: URL
	@State private var player: AVPlayer?

	var body: some View {
		VideoPlayer(player: player)
			.onAppear {
				player = AVPlayer(url: url)
				player?.play()
			}
			.onDisappear {
				player?.pause()
				player = nil
			}
			.frame(height: 200) // Set a fixed height for the player
			.cornerRadius(10)
	}
}
