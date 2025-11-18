//
//  FindUserView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI

struct FindUserView: View {
    @State private var users: [User] = []
    @State private var searchText = ""
//    @State private var searchResult: [User] = []
    
    
    var filteredUsers: [User] {
            if searchText.isEmpty {
                return users
            } else {
                return users.filter {
                    $0.username.localizedCaseInsensitiveContains(searchText)
                }
            }
        }
    
    let service = UserService()
    @EnvironmentObject var authvm: AuthViewModel
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color.surface.edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(filteredUsers) { user in
                            
                            NavigationLink {
                                ChatView(contact: user)
                            } label: {
                                UserCard(user: user, lastMessageContent: "", lastMessageTime: "")
                            }
                            Rectangle()
                                .frame(height: 1)
                                .offset(x: 88)
                                .foregroundStyle(.border)
                        }
                    }
                }
                .searchable(text: $searchText, prompt: "Search by username...")
            }
        }
        .onAppear {
            findUsers()
        }
    }

        
    func findUsers() {
        Task {
            do {
                let user_id = authvm.currentUser!.id!
                let res = try await service.getUsers(user_id: user_id)
                users = res
            } catch {
                print("error in find users(view): \(error.localizedDescription)")
            }
        }
    }
}

#Preview {
    FindUserView()
}
