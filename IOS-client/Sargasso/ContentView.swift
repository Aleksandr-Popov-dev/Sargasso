//
//  ContentView.swift
//  Sargasso
//
//  Created by Popov Alexsandr on 12.11.2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.userSession == false {
                RegisterView()
            } else {
                HomeView()
            }
        }
    }
}

