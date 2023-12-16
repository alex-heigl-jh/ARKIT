//
//  LoginView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/23/23.
//
//  Code augmented using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s

import SwiftUI
import os.log

struct LoginView: View {
	@EnvironmentObject var viewModel: UserAuth
	@State private var networkDataLoaded: Bool = false
	@State private var secondLogin = false // Make it @State to be mutable

	let dataModel: InitialDataIngestor

	init() {
		dataModel = InitialDataIngestor()
	}

	var body: some View {
		viewToDisplay
	}

	@ViewBuilder
	private var viewToDisplay: some View {
		if viewModel.userSession == nil {
			LoginEntryView()
				.environmentObject(viewModel)
		} else {
			if !networkDataLoaded {
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
	
	let log = Logger()
	
	@EnvironmentObject var viewModel: UserAuth
	
	var body: some View{
		NavigationStack{
			Image("applicationLogo")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.padding(30)
			
			Text("Augment")
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
					log.info("Logging user in..")
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
