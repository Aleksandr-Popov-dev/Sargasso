//
//  SargassoApp.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI

@main
struct SargassoApp: App {
    @StateObject var authViewModel = AuthViewModel.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authViewModel)
        }
    }
}
