//
//  ChatView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct ChatView: View {
    
    let contact: User
    @State private var messages: [Message] = []
    @State private var chat_id: String = ""
    @State private var newMessage: String = ""
    
    @EnvironmentObject var authvm: AuthViewModel
    let service = ChatService()
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        if let user = authvm.currentUser {
            NavigationStack {
                ZStack {
                    
                    Color.surface.edgesIgnoringSafeArea(.all)
                    
                    VStack {
                        
                        ZStack(alignment: .top) {
                            messagesList(user: user)
                            header(user: user)
                        }
                        
                        Spacer()
                        
                        bottom(user: user)
                    }
                    .navigationBarBackButtonHidden()
                    .onAppear {
                        find_chat()
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func header(user: User) -> some View {
        VStack {
            HStack(alignment: .center) {
                
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .font(.system(size: 24))
                        .foregroundStyle(.textPrimary)
                }
                .padding(.horizontal, 16)
                
                HStack(alignment: .top, spacing: 16) {
                    if !contact.avatar.isEmpty {
                        WebImage(url: URL(string: "http:/localhost:8000/static/images/\(contact.avatar)"))
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
                        Text(contact.fullname)
                            .font(.system(size: 24))
                            .foregroundStyle(.textPrimary)
                        Text(contact.username)
                            .font(.system(size: 17))
                            .foregroundStyle(.textPrimary)
                    }
                }
                Spacer()
                
                Button {
                    print(contact.avatar)
                } label: {
                    Image(systemName: "ellipsis")
                        .rotationEffect(Angle(degrees: 90))
                        .font(.system(size: 24))
                        .foregroundStyle(.textPrimary)
                }
                .padding(.horizontal, 16)
            }
            .padding(16)
        }
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
    
    @ViewBuilder
    func messagesList(user: User) -> some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack {
                    
                    Color.surface
                        .frame(height: 80)
                    
                    ForEach(messages, id: \.id) { message in
                        MessageCard(message: message, currentId: user.id!)
                    }
                }
            }
            .onAppear {
                guard let lastMessage = messages.last else { return }
                
                withAnimation(.none) {
                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                }
            }
            .onChange(of: messages.count) { oldValue, newValue in
                if newValue > oldValue {
                    guard let lastMessage = messages.last else { return }
                    
                    withAnimation(.none) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func bottom(user: User) -> some View {
        
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(.textPrimary)
        
        HStack {
            TextField("New message", text: $newMessage)
                .foregroundColor(.textPrimary)
                .padding()
                .foregroundStyle(.surface)
                .placeholder(when: newMessage.isEmpty) {
                    Text("New message")
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal)
                }
            Button {
                if newMessage.isEmpty { return } else {
                    
                    if messages.isEmpty {
                        Task {
                            do {
                                let res = try await service.createChat(user1_id: user.id!, user2_id: contact.id!, content: newMessage)
                                chat_id = res
                                newMessage = ""
                                loadMessages()
                            } catch {
                                print(error.localizedDescription)
                            }
                        }
                    } else {
                        Task {
                            do {
                                try await service.sendMessage(chat_id: chat_id, content: newMessage, sender_id: user.id!)
                                newMessage = ""
                                loadMessages()
                            } catch {
                                print("error in send message(view): \(error.localizedDescription)")
                            }
                        }
                    }
                }
            } label: {
                Image(systemName: "paperplane.fill")
                    .foregroundStyle(.blueprimary)
                    .font(Font.system(size: 24))
                    .padding()
            }
        }
            
    }
    
    func loadMessages() {
        Task {
            do {
                let res = try await service.get_messages(chat_id: chat_id)
                messages = res
            } catch {
                print("error in load messages(view): \(error.localizedDescription)")
            }
            
            try await Task.sleep(for: .seconds(1))
            loadMessages()
        }
    }
    
    func find_chat() {
        Task {
            do {
                let user1_id = authvm.currentUser!.id
                if let res = try await service.findChat(user1_id: user1_id! , user2_id: contact.id!) {
                    chat_id = res
                    loadMessages()
                } else {
                    chat_id = ""
                }
            } catch {
                print("error in find chat(view): \(error.localizedDescription)")
            }
        }
    }
}

//#Preview {
//    ChatView()
//}

