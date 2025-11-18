//
//  UserCard.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 16.11.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct UserCard: View {
    let user: User
    let lastMessageContent: String
    let lastMessageTime: String
    
    var body: some View {
        
        if !lastMessageContent.isEmpty {
            ZStack {
                Color.surface
                    .ignoresSafeArea(edges: .all)
                
                HStack(alignment: .top, spacing: 16) {
                    
                    if !user.avatar.isEmpty {
                        WebImage(url: URL(string: "http:/localhost:8000/static/images/\(user.avatar)"))
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 56, height: 56)
                    } else {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(.textPrimary)
                                .frame(width: 56, height: 56)
                            Image(systemName: "person")
                                .font(.system(size: 30)).bold()
                                .foregroundStyle(.surface)
                        }
                    }
                        
                    
                    VStack(alignment: .leading) {
                        Text(user.fullname)
                            .font(.system(size: 20)).bold()
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        
                        Text(lastMessageContent)
                            .font(.system(size: 17))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        Text(lastMessageTime.extractTime()!)
                            .font(.system(size: 15))
                            .foregroundStyle(.textSecondary)
                        
//                    Text("5")
//                        .padding(5)
//                        .font(.system(size: 13)).bold()
//                        .foregroundStyle(.textPrimary)
//                        .background(
//                            Rectangle()
//                                .fill(Color.blueprimary)
//                                .cornerRadius(.infinity)
//
//                        )
                    }
                }
                .padding(.horizontal, 16)
            }
        } else {
            ZStack {
                Color.surface
                    .ignoresSafeArea(edges: .all)
                
                HStack(alignment: .top, spacing: 16) {
                    
                    if !user.avatar.isEmpty {
                        
                        WebImage(url: URL(string: "http:/localhost:8000/static/images/\(user.avatar)"))
                            .resizable()
                            .scaledToFit()
                            .aspectRatio(contentMode: .fill)
                            .clipShape(Circle())
                            .frame(width: 56, height: 56)
                    } else {
                        ZStack(alignment: .center) {
                            Circle()
                                .fill(.textPrimary)
                                .frame(width: 56, height: 56)
                            Image(systemName: "person")
                                .font(.system(size: 30)).bold()
                                .foregroundStyle(.surface)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text(user.fullname)
                            .font(.system(size: 20)).bold()
                            .foregroundColor(.textPrimary)
                            .lineLimit(1)
                        
                        Text(user.username)
                            .font(.system(size: 17))
                            .foregroundColor(.textSecondary)
                            .lineLimit(1)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
            }

        }
    }
}



