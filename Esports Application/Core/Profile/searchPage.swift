//
//  searchPage.swift
//  Esports Application
//
//  Created by Osian Smith on 01/02/2024.
//

import SwiftUI
import Firebase
import SplineRuntime

struct searchPage: View {
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isProfileViewPresented = false
    @State private var selectedUserProfile: User? = nil
    @State private var showAlert = false // Add state for showing alert

    var body: some View {
        NavigationView {
            VStack {
                Text("Find Players from across the Globe")
                    .font(.headline)
                    .padding()
                Spacer()
                
                VStack{
                    //Here lies the globe::
                    Onboard3DView()
                        .ignoresSafeArea()
                    
                }

                // TextField for searching users
                TextField("Enter Username...", text: $searchText)
                    .padding()
                    .background(Color(.systemGray).opacity(0.4))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                
                // List of search results
                ScrollViewReader { proxy in
                    List(searchResults) { user in
                        Button(action: {
                            // Assign the selected user profile
                            selectedUserProfile = user
                            isProfileViewPresented = true // Show the profile view
                        }) {
                            Text(user.fullname)
                        }
                        .id(user.id) // Ensure each row has a unique identifier
                    }
                    .frame(maxHeight: 200) // Limit the height of the list
                    .padding(.horizontal)
                }
                .onAppear {
                    // Start a timer to trigger the search function every second
                    let _ = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
                        searchUsers(query: searchText)
                    }
                }
                
                Spacer()
            
                
                // Bottom Bar with adjusted spacing for icons and grey line separator
                HStack {
                    Spacer()
                    // Usage of CustomBarButton
                    CustomBarButton(systemName: "house", destination: AnyView(ContentView()), isFirstOrSecond: true)
                    CustomBarButton(systemName: "magnifyingglass", destination: AnyView(searchPage()), isFirstOrSecond: true)
                    CustomBarButton(systemName: "message", destination: AnyView(chatLog()), isFirstOrSecond: false)
                    Spacer()
                }
                .background(Color.black)
            }
            .background(Color.black)
            .foregroundColor(.white)
            .preferredColorScheme(.dark)
        }
        .sheet(isPresented: $isProfileViewPresented) {
            if let user = selectedUserProfile {
                ProfileView(user: user, isCurrentUserProfile: false)
            }
        }
        .navigationBarBackButtonHidden(true)
    }
    
    func searchUsers(query: String) {
        let db = Firestore.firestore()
        let usersRef = db.collection("users")
        usersRef
            .whereField("fullname", isGreaterThanOrEqualTo: query)
            .whereField("fullname", isLessThan: query + "z")
            .getDocuments { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching documents: \(error!)")
                    return
                }
                let users = documents.compactMap { document -> User? in
                    let data = document.data()
                    guard let name = data["fullname"] as? String else {
                        return nil
                    }
                    return User(id: document.documentID, fullname: name, email: data["email"] as? String ?? "", organisationName: "")
                }
                DispatchQueue.main.async {
                    if query.isEmpty {
                        searchResults = [] // Clear search results if query is empty
                    } else {
                        searchResults = users.filter { $0.fullname.lowercased().contains(query.lowercased()) }
                    }
                }
            }
    }
}

struct Onboard3DView: View {
    var body: some View {
        // fetching from cloud
        let url = URL(string: "https://build.spline.design/TXeFwdUMc3aUx6H3KlDa/scene.splineswift")!

        // // fetching from local
        // let url = Bundle.main.url(forResource: "scene", withExtension: "splineswift")!

        try? SplineView(sceneFileURL: url).ignoresSafeArea(.all)
    }
}
