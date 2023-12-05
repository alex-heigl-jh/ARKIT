//
//  RegistrationView.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 11/25/23.
//
//  Code created using tutorial from: https://www.youtube.com/watch?v=QJHmhLGv-_0&t=161s

import SwiftUI

struct RegistrationView: View {
	@State private var email = ""
	@State private var fullname = ""
	@State private var password = ""
	@State private var confirmPassword = ""
	@Environment(\.dismiss) var dismiss
	@EnvironmentObject var viewModel: UserAuth
	
	
	var body: some View {
		VStack{
			Image("applicationLogo")
				.resizable()
				.aspectRatio(contentMode: .fit)
				.padding(30)
			// Form Fields
			VStack(spacing: 24) {
				InputView(text: $email,
						  title: "Email Address",
						  placeholder: "name@example.com")
				.autocapitalization(.none)
				
				InputView(text: $fullname,
						  title: "Full Name",
						  placeholder: "Enter your name")
				
				InputView(text: $password,
						  title: "Password",
						  placeholder: "Enter your password",
						  isSecureField: true)
				
				ZStack(alignment: .trailing){
					InputView(text: $confirmPassword,
							  title: "Confirm Password",
							  placeholder: "Confirm your Password",
							  isSecureField: true)
					
					if !password.isEmpty && !confirmPassword.isEmpty {
						if password == confirmPassword{
							Image(systemName: "checkmark.circle.fill")
								.imageScale(.large)
								.fontWeight(.bold)
								.foregroundColor(Color(.systemGreen))
						} else {
							Image(systemName: "xmark.circle.fill")
								.imageScale(.large)
								.fontWeight(.bold)
								.foregroundColor(Color(.systemRed))
						}
					}
				}
			}
			.padding(.horizontal)
			.padding(.top, 12)
			
			// Sign in button
			Button {
				print("DEBUG: Sign user up button selected")
				Task{
					try await viewModel.createUser(withEmail: email,
												   password: password,
												   fullname: fullname)
					dismiss()
				}
			} label: {
				HStack {
					Text("SIGN UP")
						.fontWeight(.semibold)
					Image(systemName: "arrow.right")
				}
				.foregroundColor(.white)
				.disabled(!formIsValid)
				.opacity(formIsValid ? 1.0 : 0.5)
				.frame(width: UIScreen.main.bounds.width - 32, height: 48)
			}
			.background(Color(.systemBlue))
			.cornerRadius(10)
			.padding(.top, 24)
			
			Spacer()
			
			Button {
				dismiss()
			} label: {
				HStack(spacing: 3) {
					Text("Already have an account?")
					Text("Sign in")
						.fontWeight(.bold)
				}
				.font(.system(size: 14))
			}
		}

    }
}


//: MARK - AuthenticationFormProtocol

extension RegistrationView: AuthenticationFormProtocol {
	var formIsValid: Bool {
		return !email.isEmpty
		&& email.contains("@")
		&& !password.isEmpty
		&& password.count > 5
		&& confirmPassword == password
		&& !fullname.isEmpty
		
	}
}

#Preview {
    RegistrationView()
}
