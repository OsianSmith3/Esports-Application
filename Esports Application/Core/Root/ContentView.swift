//
//  ContentView.swift
//  Esports Application
//
//  Created by Osian Smith on 18/12/2023.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if let user = viewModel.currentUser { // Assuming currentUser holds the user data
                ProfileView(user: user)
            } else {
                LoginView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
