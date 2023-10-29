//
//  UserAuth.swift
//  ToDoApp
//
//  Created by Teacher on 9/11/22.
//

import Foundation

class UserAuth: ObservableObject {

  @Published var isLoggedIn = false

  func login() {
    self.isLoggedIn = true
  }

  func logout() {
    self.isLoggedIn = false
  }
}
