//
//  MessageCard.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 16.11.2025.
//

import SwiftUI

struct MessageCard: View {
    let message: Message
    let currentId: String

    var body: some View {
        if message.sender_id == currentId {
            HStack {
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(message.content)
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(message.created_at.extractTime()!)
                        .font(.system(size: 13))
                        .foregroundStyle(.textPrimary)
                        .offset(y: 2)
                        
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blueprimary)
                )
                .padding(.horizontal)
            }
        } else {
            HStack {
                VStack(alignment: .leading) {
                    Text(message.content)
                        .foregroundStyle(.textPrimary)
                        .fixedSize(horizontal: false, vertical: true)
                    Text(message.created_at.extractTime()!)
                        .font(.system(size: 13))
                        .foregroundStyle(.textPrimary)
                        .offset(y: 2)
                        
                }
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.border)
                )
                .padding(.horizontal)
                
                Spacer()
            }
        }
    }
}

