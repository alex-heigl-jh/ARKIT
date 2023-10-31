//
//  UsersJSON.swift
//  Heigl_ARKIT_FINAL
//
//  Created by Alex Heigl on 10/30/23.
//

import Foundation

struct UserJSON: Codable {
    var uuid: UUID?
    var firstName: String
    var lastName: String
    var username: String
    var password: String
    var userID: UUID
    var profilePicURL: String
}
