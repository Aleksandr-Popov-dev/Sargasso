//
//  RegisterView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI

struct RegisterView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var username: String = ""
    @State private var fullname: String = ""
    
    @State private var errorMessage: String = ""
    
    let service = AuthService()
    @EnvironmentObject var authvm: AuthViewModel
    
    var body: some View {
        NavigationStack {
            
            ZStack {
                Color.backgroundPrimary.ignoresSafeArea()
                
                
                VStack(alignment: .leading) {
                    
                    Text("Welcome!")
                        .font(.system(size: 34))
                        .foregroundStyle(.textSecondary)
                        .padding(.horizontal)
                        .padding(.top, 20)
                    Text("Sargasso")
                        .font(.system(size: 42))
                        .foregroundStyle(.textPrimary)
                        .padding(.horizontal)
                        
                    
                    Spacer()
                    
                    VStack(alignment: .center) {
                        
                        Text("Register")
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
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    TextField("", text: $username)
                                        .font(.system(size: 20))
                                        .foregroundStyle(.textPrimary)
                                        .placeholder(when: username.isEmpty) {
                                            Text("Username")
                                                .font(.system(size: 20))
                                                .foregroundStyle(.textSecondary.opacity(0.5))
                                        }
                                    Rectangle()
                                        .frame(height: 1)
                                        .foregroundStyle(.border)
                                    
                                }
                                
                                VStack(alignment: .leading, spacing: 5) {
                                    TextField("", text: $fullname)
                                        .font(.system(size: 20))
                                        .foregroundStyle(.textPrimary)
                                        .placeholder(when: fullname.isEmpty) {
                                            Text("Fullname")
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
                            
                            guard !email.replacingOccurrences(of: " ", with: "").isEmpty && !password.replacingOccurrences(of: " ", with: "").isEmpty && !username.replacingOccurrences(of: " ", with: "").isEmpty && !fullname.replacingOccurrences(of: " ", with: "").isEmpty else {
                                errorMessage = "Please fill all the fields"
                                return
                            }
                            
                            Task {
                                do {
                                    let uid = try await service.register(email: email, password: password, username: username, fullname: fullname, avatar: "")
                                    let user = User(id: uid, email: email, username: username, fullname: fullname, avatar: "")
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
                                
                                Text("Create account")
                                    .font(.system(size: 20)).bold()
                                    .foregroundStyle(.backgroundPrimary)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Spacer()
                        NavigationLink {
                            LoginView()
                        } label: {
                            
                            Text("Already have an account?")
                                .font(.system(size: 20))
                                .foregroundStyle(.textSecondary)
                                .padding(10)
                        }
                        Spacer()
                    }
                }
            }
            
        }
//            VStack(alignment: .leading) {
//                TextField("Email", text: $email)
//                    .textFieldStyle(.roundedBorder)
//                TextField("Password", text: $password)
//                    .textFieldStyle(.roundedBorder)
//                TextField("Username", text: $username)
//                    .textFieldStyle(.roundedBorder)
//                TextField("Fullname", text: $fullname)
//                    .textFieldStyle(.roundedBorder)
//                Button("Create account") {
//                    Task {
//                        do {
//                            let uid = try await service.register(email: email, password: password, username: username, fullname: fullname, avatar: "")
//                            let user = User(id: uid, email: email, username: username, fullname: fullname, avatar: "")
//                            authvm.login(user: user)
//                        }
//                    }
//                }
//            }
//            .padding()
//            
//            Spacer()
//            
//            NavigationLink {
//                LoginView()
//            } label: {
//                Text("Already have an account?")
//            }
//        }
    }
}

#Preview {
    RegisterView()
}
