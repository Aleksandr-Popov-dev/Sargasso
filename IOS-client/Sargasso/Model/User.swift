//
//  User.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI

struct User: Codable, Identifiable {
    let id: String?
    let email: String
    let username: String
    let fullname: String
    var avatar: String
}

struct UserRegisterResponse: Codable {
    let status: String
    let user_id: String?
    let message: String?
}

struct UserLoginResponse: Codable {
    let status: String
    let user_id: String?
    let username: String?
    let fullname: String?
    let avatar: String?
    let message: String?
}

struct UsersResponse: Codable {
    let status: String
    let users: [User]?
    let message: String?
}

struct ContactsResponse: Codable {
    let status: String
    let contacts: [User]?
    let message: String?
}

struct findUserResponse: Codable {
    let status: String
    let user: User?
    let message: String
}


