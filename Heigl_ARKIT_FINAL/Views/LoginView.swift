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
      LoginEntryView(username: $username, password: $password)
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

    @Binding var username: String
    @Binding var password: String
    @EnvironmentObject var userAuth: UserAuth
    
    // State variables for animation
    @State private var rotationAngle: Double = 0
    @State private var scaleValue: CGFloat = 1.0

    var body: some View {
        VStack {
            // Logo for AR - Using "arkit" system symbol
            Image(systemName: "arkit")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.blue) // Coloring it blue for enhanced appeal
                .rotationEffect(Angle(degrees: rotationAngle)) // Rotation animation
                .scaleEffect(scaleValue) // Scale animation
                .padding(30)
            
            Text("AR Creator") // Updated App Name
                .font(.largeTitle)
                .bold()
                .foregroundColor(.purple) // Making title purple for flashiness

            Spacer(minLength: 10)
            
            VStack(alignment: .center) {
                HStack {
                    Spacer(minLength: 50)
                    TextField("Username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer(minLength: 50)
                }
                
                HStack {
                    Spacer(minLength: 50)
                    SecureField("Password", text: $password)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Spacer(minLength: 50)
                }
                
                Button(action: {
                    self.saveUserName(userName: self.username)
                    self.userAuth.login()
                }, label: {
                    Text("Login")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10) // Making button more flashy
                })
                .padding(.top, 20)
            }
            Spacer(minLength: 50)
        }
        .background(
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.purple.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
        ) // Adding a gradient background for enhanced appeal
    }

    func saveUserName(userName: String) {
        UserDefaults.standard.set(userName.lowercased(), forKey: "username")
    }
}



struct LoginView_Previews: PreviewProvider {
  static var previews: some View {
    LoginView()
      .environmentObject(UserAuth())
  }
}
