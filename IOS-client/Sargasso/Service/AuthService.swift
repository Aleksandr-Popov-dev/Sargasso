//
//  AuthService.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import Foundation

class AuthService {
    private let baseURL = "http:/localhost:8000"
    
    func register(email: String, password: String, username: String, fullname: String, avatar: String) async throws -> String {
        
        guard let url = URL(string: "\(baseURL)/register") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData = [
            "email": email,
            "password": password,
            "username": username,
            "fullname": fullname,
            "avatar": avatar
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let userResponse = try JSONDecoder().decode(UserRegisterResponse.self, from: data)
        
        guard userResponse.status == "success" else {
            throw NSError(domain: userResponse.message!, code: 400)
        }
        
        return userResponse.user_id ?? ""
    }
    
    func login(email: String, password: String) async throws -> UserLoginResponse {
        guard let url = URL(string: "\(baseURL)/login") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let userData = [
            "email": email,
            "password": password
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: userData)
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let userResponse = try JSONDecoder().decode(UserLoginResponse.self, from: data)
        
        guard userResponse.status == "success" else {
            throw NSError(domain: userResponse.message!, code: 400, userInfo: nil)
        }
        
        return userResponse
    }
}
