//
//  Message.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import Foundation


struct Message: Codable {
    let id: String
    let chat_id: String
    let sender_id: String
    let content: String
    let created_at: String
}


struct MessageCreate: Codable {
    let chat_id: String
    let sender_id: String
    let content: String
}


struct MessageResponse: Codable {
    let status: String
    let message_id: String?
    let message: String?
}


struct MessagesResponse: Codable {
    let status: String
    let messages: [Message]?
    let message: String?
}

