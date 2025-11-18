//
//  ChatService.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import Foundation

class ChatService {
    let baseURL = "http://localhost:8000"
    
    func createChat(user1_id: String, user2_id: String, content: String) async throws -> String {
        guard let url = URL(string: "\(baseURL)/chat/create") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let chat = ChatCreate(user1_id: user1_id, user2_id: user2_id, message_content: content, sender_id: user1_id)
        request.httpBody = try JSONEncoder().encode(chat)
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        guard chatResponse.status == "success" else {
            throw NSError(domain: chatResponse.message!, code: 1, userInfo: nil)
        }
        
        return chatResponse.chat_id ?? ""
    }
    
    func findChat(user1_id: String, user2_id: String) async throws -> String? {
        guard let url = URL(string: "\(baseURL)/chat/find/\(user1_id)/\(user2_id)") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let chatResponse = try JSONDecoder().decode(ChatResponse.self, from: data)
        
        if chatResponse.status == "success" {
            return chatResponse.chat_id
        } else {
            return nil
        }
    }
    
    func get_messages(chat_id: String) async throws -> [Message] {
        guard let url = URL(string: "\(baseURL)/chats/\(chat_id)/messages") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200...299).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let messagesResponse = try JSONDecoder().decode(MessagesResponse.self, from: data)
        
        guard messagesResponse.status == "success" else {
            throw NSError(domain: "error in get messages(service)", code: 1, userInfo: nil)
        }
        
        return messagesResponse.messages ?? []
    }
    
    func sendMessage(chat_id: String, content: String, sender_id: String) async throws {
        guard let url = URL(string: "\(baseURL)/chat/\(chat_id)/sendMessage") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let message = MessageCreate(chat_id: chat_id, sender_id: sender_id, content: content)
        request.httpBody = try JSONEncoder().encode(message)
        
        let(data, response) = try await URLSession.shared.data(for: request)
        
        guard let htttpResponse = response as? HTTPURLResponse,
              (200...299).contains(htttpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let messageResponse = try JSONDecoder().decode(MessageResponse.self, from: data)
        
        guard messageResponse.status == "success" else {
            throw NSError(domain: "error in send message(service)", code: 1, userInfo: nil)
        }
    }
    
}
