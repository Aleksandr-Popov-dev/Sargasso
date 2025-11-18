//
//  LoginView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String = ""
    
    let service = AuthService()
    @EnvironmentObject var authvm: AuthViewModel
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea(edges: .all)
                
                VStack(alignment: .center) {
                    Text("Login")
                        .font(.system(size: 40))
                        .foregroundStyle(.textPrimary)
                        .padding(20)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("", text: $email)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.textPrimary)
                                    .placeholder(when: email.isEmpty) {
                                        Text("Email")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.textSecondary.opacity(0.5))
                                    }
                                
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.border)
                            }
                            
                            VStack(alignment: .leading, spacing: 5) {
                                TextField("", text: $password)
                                    .font(.system(size: 20))
                                    .foregroundStyle(.textPrimary)
                                    .placeholder(when: password.isEmpty) {
                                        Text("Password")
                                            .font(.system(size: 20))
                                            .foregroundStyle(.textSecondary.opacity(0.5))
                                    }
                                Rectangle()
                                    .frame(height: 1)
                                    .foregroundStyle(.border)
                                
                            }
                            Text(errorMessage)
                                .foregroundStyle(Color.red.opacity(0.5))
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Button {
                        
                        guard !email.replacingOccurrences(of: " ", with: "").isEmpty && !password.replacingOccurrences(of: " ", with: "").isEmpty else {
                            errorMessage = "Please fill all the fields"
                            return
                        }
                        
                        Task {
                            do {
                                let userResponse = try await service.login(email: email, password: password)
                                let user = User(id: userResponse.user_id!, email: email, username: userResponse.username!, fullname: userResponse.fullname!, avatar: userResponse.avatar!)
                                authvm.login(user: user)
                            } catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    } label: {
                        ZStack(alignment: .center) {
                            Rectangle()
                                .fill(.blueprimary)
                                .frame(height: 50)
                                .cornerRadius(10)
                                .padding(20)
                            
                            Text("Sign in")
                                .font(.system(size: 20)).bold()
                                .foregroundStyle(.backgroundPrimary)
                        }
                    }
                    
                }
                
            }
            
            
//            VStack(alignment: .leading) {
//                VStack {
//                    TextField("Email", text: $email)
//                        .textFieldStyle(.roundedBorder)
//                    TextField("Password", text: $password)
//                        .textFieldStyle(.roundedBorder)
//                    Button("Login") {
//                        Task {
//                            do {
//                                let userResponse = try await service.login(email: email, password: password)
//                                let user = User(id: userResponse.user_id!, email: email, username: userResponse.username!, fullname: userResponse.fullname!, avatar: userResponse.avatar!)
//                                authvm.login(user: user)
//                            }
//                        }
//                    }
//                }
//            }
        }
    }
}

#Preview {
    LoginView()
}
