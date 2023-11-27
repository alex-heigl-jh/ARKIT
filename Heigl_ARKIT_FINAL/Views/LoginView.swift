//
//  LoginView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//
//  Code augmented using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s

import SwiftUI

struct LoginView: View {
	
	// EnivornmentObjects only get initialized once
	@EnvironmentObject var viewModel: UserAuth
	
	@State private var networkDataLoaded: Bool = false
	let dataModel: InitialDataIngestor
	private var secondLogin = true

	init() {
		dataModel = InitialDataIngestor()
	}
	
  var body: some View {
    viewToDisplay
  }

  @ViewBuilder
  private var viewToDisplay: some View {
	// If there isn't a user session saved in memory then display the login
    if viewModel.userSession == nil {
		LoginEntryView()
			.environmentObject(viewModel)
    } else {
		if networkDataLoaded == false {
			LoadingView(dataModel: dataModel, networkDataLoaded: $networkDataLoaded)

	} else {
		MainMenuView()
			.environmentObject(viewModel)
      }
    }
  }
}

struct LoginEntryView: View {
	@State private var email = ""
	@State private var password = ""
	
	@EnvironmentObject var viewModel: UserAuth
	
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
					try await viewModel.signIn(withEmail: email, 
											   password: password)
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
			.disabled(!formIsValid)
			.opacity(formIsValid ? 1.0 : 0.5)
			.cornerRadius(10)
			.padding(.top, 24)
			
			
			Spacer()
			
			// Sign up button
			NavigationLink {
				RegistrationView()
					// Need this line to inject this view into view hierarchy of RegistrationView
					.environmentObject(viewModel)
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

//: MARK - AuthenticationFormProtocol

extension LoginEntryView: AuthenticationFormProtocol {
	var formIsValid: Bool {
		return !email.isEmpty
		&& email.contains("@")
		&& !password.isEmpty
		&& password.count > 5
	}
}

struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
      .environmentObject(UserAuth())
  }
}
