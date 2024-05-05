//
//  ProfileView.swift
//  Esports Application
//
//  Created by Osian Smith on 22/12/2023.
//


import FirebaseFirestore
import SwiftUI
import Firebase

struct ProfileView: View {
    var user: User? // Change to optional user
    var isCurrentUserProfile: Bool // Property to determine if it's the current user's profile
    var deleteAccount: () -> Void
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isDropDownOpen = false // State to track dropdown open/close
    @State private var organisationName: String = ""
    @State private var showTeamCreatedAlert = false // State to control the alert
    @State private var showAccountDeletedAlert = false
    @State private var isEditMode = false // State to track edit mode
   
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    Section {
                        // Content area
                        VStack(alignment: .leading, spacing: 4) {
                            // User information
                            if let user = user {
                                HStack(alignment: .top) {
                                    // Initials area
                                    Text(user.initials)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                        .frame(width: 72, height: 72)
                                        .background(Color(.systemGray3))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack{
                                            // Name area
                                            Text(user.fullname)
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .padding(.top, 1)
                                            
                                            Spacer()
                                            
                                            NavigationLink(destination: chatLog()) {
                                                Image(systemName: "envelope")
                                                    .foregroundColor(.white)
                                                    .padding(5)
                                                    .background(Color.blue)
                                                    .cornerRadius(8)
                                            }
                                            .frame(width: 8, height: 8) // Set a fixed size for the button
                                        }
                                        // Email Area
                                        Text(user.email)
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                        
                                        // Achievments Area
                                        Text("Gaming Achievments:")
                                            .font(.footnote)
                                            .foregroundColor(.gray)
                                    }
                                }
                                
                                .padding(.leading, 8) // padding between the initials and the content
                            } else {
                                Text("No user found")
                            }
                        }
                        
                        HStack(alignment: .top) {
                            Spacer()
                            HStack {
                                Text("Team Name: \(organisationName)")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            Spacer()
                        }
                        
                        if isEditMode { //in edit mode
                            HStack(alignment: .top){
                                TextField("Enter Team Name", text: $organisationName)
                                    .padding()
                                    .background(Color(.systemGray).opacity(0.4))
                                    .cornerRadius(8)
                                    .padding(.horizontal)
                                    .autocapitalization(.none)
                            }
                        }
                    }
                    
                    
                    Section(header: Text("Current Games Supported:")
                        .font(.headline) // Larger font size
                        .foregroundColor(.white) // Text color
                    ) {
                        NavigationLink(destination: UserStatsView()) {
                            HStack {
                                Image("BAR_logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 30, height: 30) // Adjust the size as needed
                                    .padding(.trailing, 10)
                                
                                Text("Beyond All Reason")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    Section(header: Text("App News Feed:")
                        .font(.headline) // Larger font size
                        .foregroundColor(.white) // Text color
                    ) {
                        Text("Beyond All reason game stats have been added to 'osTas'")
                            .foregroundColor(.white)
                    }
                    
                    Section(header: Text("Future Games Supported:")
                        .font(.headline) // Larger font size
                        .foregroundColor(.white) // Text color
                    ) {
                        Text("Valorant")
                            .foregroundColor(.gray)
                        Text("League Of Legends")
                            .foregroundColor(.gray)
                        Text("Call Of Duty")
                            .foregroundColor(.gray)
                    }
                }
                
                if isEditMode{
                    Button(action: {
                        // Save the organization name
                        viewModel.saveOrganisationName(organisationName: organisationName){
                            showTeamCreatedAlert = true
                        }
                    }) {
                        Text("Save Team Name")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                
                if isCurrentUserProfile {
                    // Dropdown Menu
                    HStack {
                        Spacer()
                        Button(action: {
                            isDropDownOpen.toggle()
                        }) {
                            HStack {
                                Button(action: {
                                    isEditMode.toggle() // Toggle edit mode
                                }) {
                                    Text(isEditMode ? "Done" : "Edit Profile")
                                        .font(.subheadline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue)
                                        .cornerRadius(8)
                                }
                                .padding()
                                .foregroundColor(.blue)
                                
                                Spacer()
                                
                                Text("Settings")
                                    .font(.subheadline)
                                    .foregroundColor(.white)
                                
                                Image(systemName: isDropDownOpen ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                                    .font(.title)
                            }
                        }
                        .padding()
                        .foregroundColor(.blue)
                    }
                }
                
                
                // Drop down bar
                if isDropDownOpen {
                    DropDownBar(isOpen: $isDropDownOpen) {
                        viewModel.signOut()
                    }
                    // Button to delete account
                    Button(action: {
                        // Show delete account alert
                        showAccountDeletedAlert = true
                    }) {
                        Text("Delete Account")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .padding(.trailing)
                }
                
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
            .onAppear {
                // Fetch organisation name from the database
                viewModel.fetchOrganisationName { result in
                    switch result {
                    case .success(let name):
                        DispatchQueue.main.async {
                            organisationName = name
                        }
                    case .failure(let error):
                        print("Error fetching team name: \(error)")
                    }
                }
            }
            .alert(isPresented: $showTeamCreatedAlert) {
                Alert(title: Text("Team Created"), message: Text("The team has been created successfully."), dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $showAccountDeletedAlert) {
                        // Configure the delete account alert
                        Alert(
                            title: Text("Are you sure?"),
                            message: Text("This action cannot be undone."),
                            primaryButton: .destructive(Text("Delete"), action: {
                                // Call delete account function
                                deleteAccount()
                            }),
                            secondaryButton: .cancel()
                        )
                    }
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with a sample user
        let user = User(id: "", fullname: "", email: "", organisationName: "")
        let viewModel = AuthViewModel() // Create an instance of AuthViewModel
        return ProfileView(user: user, isCurrentUserProfile: true, deleteAccount: viewModel.deleteAccount)
            .environmentObject(viewModel) // Provide the environment object
    }
}



