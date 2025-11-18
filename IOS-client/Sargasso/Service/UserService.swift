//
//  UserService.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import Foundation

class UserService {
    
    let baseURL = "http://localhost:8000"
    
    func getUsers(user_id: String) async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/users/\(user_id)/get") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let usersResponse = try JSONDecoder().decode(UsersResponse.self, from: data)
        
        guard usersResponse.status == "success" else {
            throw NSError(domain: "cant get all users", code: 1, userInfo: nil)
        }
        
        return usersResponse.users ?? []
    }
    
    func fetchContacts(user_id: String) async throws -> [User] {
        guard let url = URL(string: "\(baseURL)/contacts/fetch/\(user_id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let usersResponse = try JSONDecoder().decode(ContactsResponse.self, from: data)
        
        guard usersResponse.status == "success" else {
            throw NSError(domain: "error in fetch contacts", code: 1, userInfo: nil)
        }
        
        return usersResponse.contacts ?? []
    }
    
    private func convertStringToData(_ string: String) -> Data {
        return Data(string.utf8)
    }
    
    func uploadAvatar(user_id: String, selectedImageData: Data?) async throws -> String {
        guard let imageData = selectedImageData else {
            throw NSError(domain: "image dont selected", code: 1)
        }
        
        guard let url = URL(string: "\(baseURL)/users/\(user_id)/avatar") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        // "file" for FastAPI
        body.append(convertStringToData("--\(boundary)\r\n"))
        body.append(convertStringToData("Content-Disposition: form-data; name=\"file\"; filename=\"avatar.jpg\"\r\n"))
        body.append(convertStringToData("Content-Type: image/jpeg\r\n\r\n"))
        body.append(imageData)
        body.append(convertStringToData("\r\n"))
        body.append(convertStringToData("--\(boundary)--\r\n"))

        request.httpBody = body
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let avatarResponse = try JSONDecoder().decode(AvatarResponse.self, from: data)
        
        guard avatarResponse.status == "success" else {
            throw NSError(domain: "error in load avatar", code: 1)
        }
        
        return avatarResponse.avatar ?? ""
    }
    
    func getAvatar(user_id: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/users/\(user_id)/getAvatar") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let avatarResponse = try JSONDecoder().decode(AvatarResponse.self, from: data)
        
        guard avatarResponse.status == "success" else {
            throw NSError(domain: "error in get avatar", code: 1)
        }
        
        return avatarResponse.avatar ?? ""
    }
}
