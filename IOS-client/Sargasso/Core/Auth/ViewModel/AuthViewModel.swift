//
//  AuthViewModel.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import Combine
import SwiftUI
import Foundation

class AuthViewModel: ObservableObject {
    @Published var currentUser: User?
    @Published var userSession: Bool = false
    static let shared = AuthViewModel()
    
    
    init() {
//        self.loadUserFromStorage()
        self.userSession
//        self.currentUser
    }
    
    func login(user: User) {
        currentUser = user
        userSession = true
        saveUserToStorage(user)
    }
    
    func logout() {
        currentUser = nil
        userSession = false
        clearUserFromStorage()
    }
    
    func updateAvatar(url: String) {
        guard let currentUser = currentUser else { return }
        
        let updatedUser = User(
            id: currentUser.id,
            email: currentUser.email,
            username: currentUser.username,
            fullname: currentUser.fullname,
            avatar: url
        )
        
        DispatchQueue.main.async {
            self.currentUser = updatedUser
        }
        
        saveUserToStorage(updatedUser)
    }

    
    private func saveUserToStorage(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: "currentUser")
        }
    }

    
    private func loadUserFromStorage() {
        if let userData = UserDefaults.standard.data(forKey: "currentUser"),
            let user = try? JSONDecoder().decode(User.self, from: userData) {
            self.currentUser = user
            self.userSession = true
        }
    }
    
    private func clearUserFromStorage() {
        UserDefaults.standard.removeObject(forKey: "currentUser")
    }

    
}
