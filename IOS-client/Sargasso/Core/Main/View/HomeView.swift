//
//  HomeView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct HomeView: View {
    @State private var showMenu: Bool = false
    @State private var contacts: [User] = []
    @State private var lastMessages: [String: Message] = [:]
    @State var isLoading: Bool = false
    
    @EnvironmentObject var authvm: AuthViewModel
    let userService = UserService()
    let chatService = ChatService()
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                Color.surface
                    .ignoresSafeArea(edges: .all)

                
                if isLoading {
                    VStack(alignment: .leading, spacing: 0) {
                        header()
                        
                        chats()
                        
                    }
                } else {
                    Text("Loading...")
                        .font(.largeTitle)
                }
                
                SideMenuView(isShowing: $showMenu)
            }
        }
        .onAppear {
           fetchContacts()
        }
    }
    
    @ViewBuilder
    func header() -> some View {
        NavigationStack {
            ZStack(alignment: .topLeading) {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Sargasso")
                        .foregroundStyle(.textPrimary)
                        .font(.system(size: 34))
                        .padding(.top)
                    
                    ScrollView(.horizontal) {
                        HStack(spacing: 6) {
                            NavigationLink {
                                FindUserView()
                            } label: {
                                Image(systemName: "plus.circle.dashed")
                                    .font(Font.system(size: 64))
                                    .foregroundStyle(.textPrimary)
                            }
                            
                            ForEach(contacts) { user in
                                if !user.avatar.isEmpty {
                                    WebImage(url: URL(string: "http:/localhost:8000/static/images/\(user.avatar)"))
                                        .resizable()
                                        .scaledToFit()
                                        .aspectRatio(contentMode: .fill)
                                        .clipShape(Circle())
                                        .frame(width: 60, height: 60)
                                } else {
                                    ZStack(alignment: .center) {
                                        Circle()
                                            .fill(.textPrimary)
                                            .frame(width: 60, height: 60)
                                        Image(systemName: "person")
                                            .font(.system(size: 30)).bold()
                                            .foregroundStyle(.surface)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.vertical, 24)
                    
//                    HStack(spacing: 20) {
//                        Text("All")
//                            .font(.system(size: 15))
//                            .foregroundStyle(.textPrimary)
//                        Text("Chats")
//                            .font(.system(size: 15))
//                            .foregroundStyle(.textPrimary)
//                        Text("Groups")
//                            .font(.system(size: 15))
//                            .foregroundStyle(.textPrimary)
//                        Text("Channels")
//                            .font(.system(size: 15))
//                            .foregroundStyle(.textPrimary)
//                    }
                    
                }
                .padding(.horizontal, 16)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showMenu.toggle()
                        } label: {
                            Image(systemName: "line.3.horizontal")
                                .font(.system(size: 24))
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink {
                            FindUserView()
                        } label: {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 24))
                                .foregroundStyle(.textPrimary)
                        }
                    }
                }
            }
            .background(
                Image("HomeViewBanner")
                    .resizable()
                    .ignoresSafeArea(.all)
            )
        }
    }
    
    @ViewBuilder
    func chats() -> some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
                ForEach(contacts) { user in
                        
                    NavigationLink {
                        ChatView(contact: user)
                    } label: {
                        UserCard(user: user,
                                 lastMessageContent: lastMessages[user.id!]?.content ?? "",
                                 lastMessageTime: lastMessages[user.id!]?.created_at ?? "")
                    }
                    Rectangle()
                        .frame(height: 1)
                        .offset(x: 88)
                        .foregroundStyle(.border)
                }
                Spacer()
                .onAppear {
                    fetchContacts()
                }
            }
        }
        .padding(.vertical, 16)
    }
    
    
    func fetchContacts() {
        Task {
            
            guard let currentUser = authvm.currentUser,
                  let user_id = currentUser.id else { return }
            
            do {
                let res = try await userService.fetchContacts(user_id: user_id)
                contacts = res
                loadLastMessages(users: res)
            } catch {
                print("error in load contacts in view: \(error.localizedDescription)")
            }
        }
    }
    
    func loadLastMessages(users: [User]) {
        Task {
            do {
                var tempLastMessages: [String: Message] = [:]
                
                let currentUser_id = authvm.currentUser!.id!
                
                for user in users {
                    if let chat_id = try await chatService.findChat(user1_id: min(currentUser_id, user.id!),user2_id: max(currentUser_id, user.id!)) {
                        let messages = try await chatService.get_messages(chat_id: chat_id)
                        if let lastMessage = messages.last {
                            tempLastMessages[user.id!] = lastMessage
                        } else {
                            lastMessages = [:]
                        }
                    }
                }
                
                await MainActor.run {
                    lastMessages = tempLastMessages
                    isLoading = true
                }
                
            } catch {
                print("error in load last message in home view: \(error.localizedDescription)")
            }
        }
    }
}


