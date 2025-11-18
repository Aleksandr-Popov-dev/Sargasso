//
//  ProfileView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 17.11.2025.
//

import SwiftUI
import PhotosUI
import SDWebImageSwiftUI

struct ProfileView: View {
    @State private var avatarItem: PhotosPickerItem?
    @State private var avatarImage: Image?
    @State private var selectedImageData: Data?
    
    
    let service = UserService()
    @EnvironmentObject var authvm: AuthViewModel
    var body: some View {
        if let user = authvm.currentUser {
            NavigationStack {
                ZStack {
                    
                    Color.surface.ignoresSafeArea(edges: .all)
                    
                    VStack {
                        header(user: user)
                        
                        mainInf(user: user)
                        Spacer()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            authvm.logout()
                        } label: {
                            Image(systemName: "rectangle.portrait.and.arrow.forward")
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func header(user: User) -> some View {
        VStack(alignment: .leading, spacing: -175) {
            Rectangle()
                .fill(.border)
                .frame(height: 200)
                .ignoresSafeArea()
            
            ZStack(alignment: .bottomTrailing) {
                if !user.avatar.isEmpty {
                    WebImage(url: URL(string: "http:/localhost:8000/static/images/\(user.avatar)"))
                        .resizable()
                        .scaledToFit()
                        .aspectRatio(contentMode: .fill)
                        .clipShape(Circle())
                        .padding(.leading, 20)
                        .frame(width: 120, height: 120)
                } else {
                    ZStack(alignment: .center) {
                        Circle()
                            .fill(.backgroundPrimary)
                            .frame(width: 120, height: 120)
                        Image(systemName: "person")
                            .font(.system(size: 50)).bold()
                            .foregroundStyle(.textPrimary)
                    }
                    .padding(.leading, 20)
                }
                    
                
                PhotosPicker(selection: $avatarItem, matching: .images) {
                    Image(systemName: "pencil.circle")
                        .font(.system(size: 24))
                        .foregroundStyle(.textPrimary)
                        .padding(.leading, 20)
                }
                .onChange(of: avatarItem) { oldValue, newItem in
                    Task {
                        guard let newItem = newItem else { return }
                        
                        do {
                            guard let imageData = try? await newItem.loadTransferable(type: Data.self) else {
                                return
                            }
                            
                            let res = try await service.uploadAvatar(
                                user_id: user.id!,
                                selectedImageData: imageData
                            )
                            
                            authvm.updateAvatar(url: res)
                            
                        } catch {
                            print("error in loading avatar: \(error.localizedDescription)")
                        }
                        
                        await MainActor.run {
                            avatarItem = nil
                            selectedImageData = nil
                            avatarImage = nil
                        }
                    }
                }
                
                .padding(.leading, -50)
            }
            .padding(.bottom, 50)
        }
    }
    
    @ViewBuilder
    func mainInf(user: User) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 20) {
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Fullname")
                        .foregroundStyle(.border)
                        .padding(.vertical, -10)
                    Text(user.fullname)
                        .font(.system(size: 28))
                        .foregroundStyle(.textPrimary)
                    
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.border)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Username")
                        .foregroundStyle(.border)
                        .padding(.vertical, -10)
                    Text("@\(user.username)")
                        .font(.system(size: 28))
                        .foregroundStyle(.textPrimary)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.border)
                }
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Email")
                        .foregroundStyle(.border)
                        .padding(.vertical, -10)
                    Text(user.email)
                        .font(.system(size: 28))
                        .foregroundStyle(.textPrimary)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundStyle(.border)
                }
                
            }
            .padding(.leading, 20)
        }
    }
}

#Preview {
    ProfileView()
}
