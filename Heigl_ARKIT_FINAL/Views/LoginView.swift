//
//  LoginView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//

import SwiftUI

struct LoginView: View {
  @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
  @State private var password: String = ""
	
	
  @EnvironmentObject var userAuth: UserAuth
	
  @State private var networkDataLoaded: Bool = false
  let dataModel: InitialDataIngestor

  init() {
    dataModel = InitialDataIngestor()
  }

  var body: some View {
    viewToDisplay
  }

  @ViewBuilder
  private var viewToDisplay: some View {
    if !userAuth.isLoggedIn {
//		LoginEntryView(username: $username, password: $password)
		LoginEntryView()
    } else {
		if networkDataLoaded == false {
			LoadingView(dataModel: dataModel, networkDataLoaded: $networkDataLoaded)

	} else {
		MainMenuView()
      }
    }
  }
}

struct LoginEntryView: View {
	@State private var email = ""
	@State private var password = ""
	
	@StateObject var viewModel = UserAuth()
	
	var body: some View{
		NavigationStack{
			// Logo for AR - Using "arkit" system symbol
			Image(systemName: "arkit")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.foregroundColor(.blue)
				.padding(30)

			Text("AR Creator")
				.font(.largeTitle)
				.bold()
				.foregroundColor(.purple)
			
			// Form Fields
			VStack(spacing: 24) {
				InputView(text: $email, 
						  title: "Email Address",
						  placeholder: "name@example.com")
				.autocapitalization(.none)
				
				InputView(text: $password,
						  title: "Password",
						  placeholder: "Enter your password",
						  isSecureField: true)
			}
			.padding(.horizontal)
			.padding(.top, 12)
			
			// Sign in button
			Button {
				Task {
					print("DEBUG: Logging user in..")
					try await viewModel.signIn(withEmail: email, password: password)
				}

			} label: {
				HStack {
					Text("SIGN IN")
						.fontWeight(.semibold)
					Image(systemName: "arrow.right")
				}
				.foregroundColor(.white)
				.frame(width: UIScreen.main.bounds.width - 32, height: 48)
			}
			.background(Color(.systemBlue))
			.cornerRadius(10)
			.padding(.top, 24)
			
			
			Spacer()
			
			// Sign up button
			NavigationLink {
				RegistrationView()
					.navigationBarBackButtonHidden(true)
			} label: {
				HStack(spacing: 3) {
					Text("Don't have an account?")
					Text("Sign up")
						.fontWeight(.bold)
				}
				.font(.system(size: 14))
			}
		}
	}
}



//struct LoginView: View {
//  @State private var username: String = UserDefaults.standard.string(forKey: "username") ?? ""
//  @State private var password: String = ""
//  @EnvironmentObject var userAuth: UserAuth
//  @State private var networkDataLoaded: Bool = false
//  let dataModel: InitialDataIngestor
//
//  init() {
//    dataModel = InitialDataIngestor()
//  }
//
//  var body: some View {
//    viewToDisplay
//  }
//
//  @ViewBuilder
//  private var viewToDisplay: some View {
//    if !userAuth.isLoggedIn {
//      LoginEntryView(username: $username, password: $password)
//    } else {
//      if networkDataLoaded == false {
//        LoadingView(dataModel: dataModel, networkDataLoaded: $networkDataLoaded)
//          
//      } else {
//        MainMenuView()
//      }
//    }
//  }
//}
//
//struct LoginEntryView: View {
//
//    @Binding var username: String
//    @Binding var password: String
//    @EnvironmentObject var userAuth: UserAuth
//    
//    // State variables for animation
//    @State private var rotationAngle: Double = 0
//    @State private var scaleValue: CGFloat = 1.0
//
//    var body: some View {
//        VStack {
//            // Logo for AR - Using "arkit" system symbol
//            Image(systemName: "arkit")
//                .resizable()
//                .aspectRatio(contentMode: .fit)
//                .foregroundColor(.blue) // Coloring it blue for enhanced appeal
//                .rotationEffect(Angle(degrees: rotationAngle)) // Rotation animation
//                .scaleEffect(scaleValue) // Scale animation
//                .padding(30)
//            
//            Text("AR Creator") // Updated App Name
//                .font(.largeTitle)
//                .bold()
//                .foregroundColor(.purple) // Making title purple for flashiness
//
//            Spacer(minLength: 10)
//            
//            VStack(alignment: .center) {
//                HStack {
//                    Spacer(minLength: 50)
//                    TextField("Username", text: $username)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Spacer(minLength: 50)
//                }
//                
//                HStack {
//                    Spacer(minLength: 50)
//                    SecureField("Password", text: $password)
//                        .textFieldStyle(RoundedBorderTextFieldStyle())
//                    Spacer(minLength: 50)
//                }
//                
//                Button(action: {
//                    self.saveUserName(userName: self.username)
//                    self.userAuth.login()
//                }, label: {
//                    Text("Login")
//                        .padding()
//                        .background(Color.blue)
//                        .foregroundColor(.white)
//                        .cornerRadius(10) // Making button more flashy
//                })
//                .padding(.top, 20)
//            }
//            Spacer(minLength: 50)
//        }
//        .background(
//            LinearGradient(gradient: Gradient(colors: [Color.white, Color.purple.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
//                .edgesIgnoringSafeArea(.all)
//        ) // Adding a gradient background for enhanced appeal
//    }
//
//    func saveUserName(userName: String) {
//        UserDefaults.standard.set(userName.lowercased(), forKey: "username")
//    }
//}



struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
      .environmentObject(UserAuth())
  }
}
