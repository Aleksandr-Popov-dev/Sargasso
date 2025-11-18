//
//  SideMenuView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI
import SDWebImageSwiftUI

struct SideMenuView: View {
    @Binding var isShowing: Bool
    
    @EnvironmentObject var authvm: AuthViewModel
    
    var body: some View {
        if let user = authvm.currentUser {
            ZStack {
                if isShowing {
                    Rectangle()
                        .opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            isShowing.toggle()
                        }
                    HStack {
                        VStack(alignment: .leading, spacing: 30) {
                            
                            HStack(alignment: .center, spacing: 16) {
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
                                        .font(.system(size: 28)).bold()
                                        .foregroundStyle(.textPrimary)
                                    Text(user.username)
                                        .font(.system(size: 18)).bold()
                                        .foregroundStyle(.textPrimary)
                                }
                            }
                            .padding(.bottom, 50)
                            
//                            Spacer()
                            
                            Group {
                                NavigationLink {
                                    ProfileView()
                                } label: {
                                    HStack {
                                        Image(systemName: "person")
                                        Text("Profile")
                                    }
                                    .font(.system(size: 20))
                                    .foregroundStyle(.textPrimary)
                                }
                                
                                NavigationLink {
                                    FindUserView()
                                } label: {
                                    HStack {
                                        Image(systemName: "person.badge.plus")
                                        Text("Find user")
                                    }
                                    .font(.system(size: 20))
                                    .foregroundStyle(.textPrimary)
                                }
                                
//                                NavigationLink {
//                                    //
//                                } label: {
//                                    HStack {
//                                        Image(systemName: "person")
//                                        Text("All contacts")
//                                    }
//                                    .font(.system(size: 20))
//                                    .foregroundStyle(.white)
//                                }
//                                
//                                NavigationLink {
//                                    //
//                                } label: {
//                                    HStack {
//                                        Image(systemName: "person")
//                                        Text("New group")
//                                    }
//                                    .font(.system(size: 20))
//                                    .foregroundStyle(.white)
//                                }
//                                
//                                NavigationLink {
//                                    //
//                                } label: {
//                                    HStack {
//                                        Image(systemName: "person")
//                                        Text("New channel")
//                                    }
//                                    .font(.system(size: 20))
//                                    .foregroundStyle(.white)
//                                }
//                                
//                                NavigationLink {
//                                    //
//                                } label: {
//                                    HStack {
//                                        Image(systemName: "person")
//                                        Text("Settings")
//                                    }
//                                    .font(.system(size: 20))
//                                    .foregroundStyle(.white)
//                                }
                            }
                            .padding(.horizontal, 20)
                            
                            Spacer()
                        }
                        .padding()
                        .frame(width: 300, alignment: .leading)
                        .background(Color.backgroundPrimary)
                        
                        Spacer()
                    }
                    .transition(.move(edge: .leading))
                }
            }
            .animation(.easeInOut, value: isShowing)
        }
    }
}
