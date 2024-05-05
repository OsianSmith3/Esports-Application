//
//  AuthViewModel.swift
//  Esports Application
//
//  Created by Osian Smith on 23/12/2023.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

protocol AuthenticationFormProtocol {
    var formIsValid: Bool { get }
}

@MainActor
class AuthViewModel: ObservableObject {
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init() {
        self.userSession = Auth.auth().currentUser
        
        Task {
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        } catch {
            print("DEBUG: Failed to log in with error \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String, organisationName: String) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email, organisationName: organisationName)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            await fetchUser()
        } catch {
            print("DEBUG: Failed to create user with error \(error.localizedDescription))")
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()  // signs out user on backend
            self.userSession = nil    // wipes out user session and takes us back to the login screen
            self.currentUser = nil   // wipes out current user data model
        } catch {
            print("DEBUG: Failed to sign out with error \(error.localizedDescription)")
        }
    }
    
    func saveOrganisationName(organisationName: String, completion: @escaping () -> Void) {
        let db = Firestore.firestore()
        // Update the user's document with the organization's name
        if let currentUser = Auth.auth().currentUser {
            let usersRef = db.collection("users").document(currentUser.uid)
            usersRef.updateData(["organisationName": organisationName]) { error in
                if let error = error {
                    print("Error updating user document: \(error)")
                } else {
                    print("User document updated with organization name")
                    // Toggle showAlert state when the organization name is successfully saved
                    completion()
                }
            }
        }
    }
    
    func fetchOrganisationName(completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(FetchError.currentUserNotFound))
            return
        }
        
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(currentUser.uid)
        
        userRef.getDocument { document, error in
            if let document = document, document.exists {
                if let organisationName = document.data()?["organisationName"] as? String {
                    completion(.success(organisationName))
                } else {
                    completion(.failure(FetchError.noOrganisationName))
                }
            } else {
                completion(.failure(error ?? FetchError.unknown))
            }
        }
    }


    enum FetchError: Error {
        case noOrganisationName
        case currentUserNotFound
        case unknown
    }
    
    // Updated deleteAccount function to directly delete the user account
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else {
            print("No user is currently signed in.")
            return
        }
        
        // Delete user document from Firestore
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(user.uid)
        userDocRef.delete { error in
            if let error = error {
                print("Error deleting user document: \(error.localizedDescription)")
                return
            }
            
            // Delete user authentication account
            user.delete { error in
                if let error = error {
                    print("Error deleting user account: \(error.localizedDescription)")
                    return
                }
                
                // Clear local user session and data
                self.userSession = nil
                self.currentUser = nil
                
                print("User account and data deleted successfully.")
            }
        }
    }

     
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        do {
            let userSnapshot = try await Firestore.firestore().collection("users").document(uid).getDocument()
            let userData = try userSnapshot.data(as: User.self)
            self.currentUser = userData
        } catch {
            print("Error fetching user data: \(error.localizedDescription)")
        }
    }
}

