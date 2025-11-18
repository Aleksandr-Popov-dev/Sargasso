//
//  Chat.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

struct Chat: Codable {
    let chat_id: String
    let user1_id: String
    let user2_id: String
    let created_at: String
    let last_message_at: String
}

struct ChatCreate: Codable {
    let user1_id: String
    let user2_id: String
    let message_content: String
    let sender_id: String
}

struct ChatResponse: Codable {
    let status: String
    let chat_id: String?
    let message: String?
}
