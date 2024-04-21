//
//  ProfileView.swift
//  Esports Application
//
//  Created by Osian Smith on 22/12/2023.
//


import FirebaseFirestore
import SwiftUI


struct ProfileView: View {
    var user: User? // Change to optional user
    let organisationName: String
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isDropDownOpen = false // State to track dropdown open/close
    
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
                                    
                                    // Name area
                                    Text(user.fullname)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                        .padding(.top, 1)
                                    
                                    // Email Area
                                    Text(user.email)
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8) // Add padding between the initials and the content
                            } else {
                                Text("No user found")
                            }
                            HStack {
                                Text("Organization Name: \(organisationName)")
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
                        Text("Beyond All reason game stats have been added to osTas Esports Application.")
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
                
            
                // Dropdown Menu
                HStack {
                    Spacer()
                    Button(action: {
                        isDropDownOpen.toggle()
                    }) {
                        Text("Settings")
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Image(systemName: isDropDownOpen ? "chevron.down.circle.fill" : "chevron.up.circle.fill")
                            .font(.title)
                    }
                    .padding()
                    .foregroundColor(.blue)
                }
                
                // Drop down bar
                if isDropDownOpen {
                    DropDownBar(isOpen: $isDropDownOpen) {
                        viewModel.signOut()
                    }
                }
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
            .onAppear {
            }
        }
    }
}

    
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        // Preview with a sample user
        let user = User(id: "", fullname: "", email: "")
        let organisationName = ""
        return ProfileView(user: user, organisationName: organisationName)
    }
}
