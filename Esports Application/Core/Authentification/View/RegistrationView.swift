//
//  RegistrationView.swift
//  Esports Application
//
//  Created by Osian Smith on 21/12/2023.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var viewModel: AuthViewModel
    
    
    var body: some View {
        VStack{
            //image
            Image("ostas_logo")
                .resizable()
                .scaledToFill()
                .frame(width:300, height: 100)
                .padding(.vertical, 32)
            
            //from fields
            //Email
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
                    
                
                //Name
                    InputView(text: $fullname,
                              title: "Username",
                              placeholder: "Enter your username")
                    
                    //Password
                    InputView(text: $password,
                              title: "Password",
                              placeholder: "Enter your password",
                              isSecureField: true)
                    
                    ZStack(alignment: .trailing){
                        //Confirm Password
                        InputView(text: $confirmPassword,
                                  title: "Confirm Password",
                                  placeholder: "Confrim your password",
                                  isSecureField: true)
                        
                        if !password.isEmpty && !confirmPassword.isEmpty {
                            if password == confirmPassword && password.count > 5{
                                Image(systemName: "checkmark.circle.fill")
                                    .imageScale(.large)
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(.systemGreen))
                            } else {
                                VStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color(.systemRed))
                                    if password.count < 5 {
                                        Text("5 or more characters needed")
                                            .font(.system(size: 10))
                                            .foregroundColor(.red)
                                    }
                                    if confirmPassword != password {
                                        Text("Passwords do not match")
                                            .font(.system(size: 10))
                                            .foregroundColor(.red)
                                    }
                                }
                            }
                        }
                    }
                }
                
                .padding(.horizontal)
                .padding(.top, 12)
            
                Button {
                    Task {
                        try await viewModel.createUser(withEmail: email, 
                                                       password: password,
                                                       fullname: fullname,
                                                       organisationName: "")
                }
            } label: {
                HStack{
                    Text("SIGN UP")
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
            
            Button {
                dismiss()
            } label: {
                HStack(spacing: 5){
                    Text("Already have an account?")
                    Text("Sign in")
                        .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                }
                .font(.system(size: 14))
            }
        }
    }
}

//MARK: - AuthenticationFormProtocol

extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        return !email.isEmpty
        && email.contains("@")
        && !password.isEmpty
        && password.count > 5
        && confirmPassword == password
        && !fullname.isEmpty
    }
}

struct RegistrationView_Preview: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
