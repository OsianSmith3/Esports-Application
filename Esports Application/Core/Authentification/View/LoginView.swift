//
//  LoginView.swift
//  Esports Application
//
//  Created by Osian Smith on 21/12/2023.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            //image
            Image("ostas_logo")
                .resizable()
                .scaledToFill()
                .frame(width:300, height: 100)
                .padding(.vertical, 32)
            
            
            //from fields
            VStack(spacing: 24) {
                ZStack(alignment: .trailing){
                    InputView(text: $email,
                              title: "Email Address",
                              placeholder: "name@example.com")
                    .autocapitalization(.none)
                    
                    if !email.isEmpty {
                        if email.contains("@") {
                            Image(systemName: "checkmark.circle.fill")
                                .imageScale(.medium)
                                .fontWeight(.bold)
                                .foregroundColor(Color(.systemGreen))
                        }else {
                            VStack{
                                Image(systemName: "xmark.circle.fill")
                                    .imageScale(.medium)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemRed))
                                Text("Must include '@' ")
                                    .font(.system(size: 10))
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password",
                          isSecureField: true)
            }
            .padding(.horizontal)
            .padding(.top, 12)
            
            //sign in button
            
            Button {
                Task {
                    try await viewModel.signIn(withEmail: email, password: password)
                }
            } label: {
                HStack{
                    Text("SIGN IN")
                        .fontWeight(.semibold)
                    Image(systemName: "arrow.right")
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 48)
            }
            .background(Color(.systemBlue))
            .disabled(!formIsValid)
            .opacity(formIsValid ? 1.0 : 0.5)
            .cornerRadius(10)
            .padding(.top, 24)
            
            Spacer()
            
            //sign up button
            
            NavigationLink{
                RegistrationView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                HStack(spacing: 5){
                    Text("Don't have an account?")
                    Text("Sign Up")
                        .fontWeight(.bold)
                }
                .font(.system(size: 14))
            }
        }
    }
}

//MARK: - AuthenticationFormProtocol

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
    }
}

struct LoginView_Preview: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
    
