//
//  Esports_ApplicationApp.swift
//  Esports Application
//
//  Created by Osian Smith on 18/12/2023.
//


import SwiftUI
import Firebase

@main
struct Esports_ApplicationApp: App {
    @StateObject var viewModel = AuthViewModel()
    
    init () {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}
