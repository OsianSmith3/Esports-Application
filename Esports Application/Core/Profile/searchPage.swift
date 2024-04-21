//
//  searchPage.swift
//  Esports Application
//
//  Created by Osian Smith on 01/02/2024.
//

import SwiftUI
import Firebase

struct searchPage: View {
    @State private var searchText = ""
    @State private var searchResults: [User] = []
    @State private var isProfileViewPresented = false
    @State private var selectedUserProfile: User? = nil
    @State private var organisationName = ""
    @State private var showAlert = false // Add state for showing alert

    var body: some View {
        NavigationView {
            VStack {
                // TextField for searching users
                TextField("Search", text: $searchText)
                    .padding()
                    .background(Color(.systemGray).opacity(0.4))
                    .cornerRadius(8)
                
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
                
                // TextField for organization name
                TextField("Organisation Name", text: $organisationName)
                    .padding()
                    .background(Color(.systemGray).opacity(0.4))
                    .cornerRadius(8)
                    .padding(.horizontal)
                
                // Button to save organization name to Firebase
                Button(action: {
                    saveOrganisationName()
                }) {
                    Text("Create Organization")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(8)
                }
                .padding()
                
                Spacer()
                
                // Bottom Bar with adjusted spacing for icons and grey line separator
                HStack {
                    Spacer()
                    // Usage of CustomBarButton
                    CustomBarButton(systemName: "house", destination: AnyView(ContentView()))
                    CustomBarButton(systemName: "magnifyingglass", destination: AnyView(searchPage()))
                    CustomBarButton(systemName: "message", destination: AnyView(chatLog()))
                    Spacer()
                }
                .background(Color.black)
            }
            .background(Color.black)
            .foregroundColor(.white)
            .preferredColorScheme(.dark)
            .navigationBarTitle("Search for Players")
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Organization Created"), message: Text("The organization has been created successfully."), dismissButton: .default(Text("OK")))
            }
        }
        .sheet(isPresented: $isProfileViewPresented) {
            if let user = selectedUserProfile {
                ProfileView(user: user, organisationName: organisationName)
            }
        }
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
                    return User(id: document.documentID, fullname: name, email: data["email"] as? String ?? "")
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
    
    func saveOrganisationName() {
        let db = Firestore.firestore()
        let organisationsRef = db.collection("organisations")
        organisationsRef.addDocument(data: ["name": organisationName]) { error in
            if let error = error {
                print("Error adding organization: \(error)")
            } else {
                print("Organization added successfully!")

                // Update the user's document with the organization's name
                if let currentUser = Auth.auth().currentUser {
                    let usersRef = db.collection("users").document(currentUser.uid)
                    usersRef.updateData(["organisationName": organisationName]) { error in
                        if let error = error {
                            print("Error updating user document: \(error)")
                        } else {
                            print("User document updated with organization name")
                            showAlert = true // Show alert when organization is successfully created
                        }
                    }
                }
            }
        }
    }
}
