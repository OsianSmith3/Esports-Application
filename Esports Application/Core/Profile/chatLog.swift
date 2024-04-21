//
//  chatLog.swift
//  Esports Application
//
//  Created by Osian Smith on 01/02/2024.
//

import SwiftUI

struct chatLog: View {
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                VStack {
                    // Custom nav bar
                    TopBar
                    messagesView
                }
                .background(Color.black)
                .foregroundColor(.white)
                .preferredColorScheme(.dark)

                // CustomBarButton and NewMessageButton
                HStack {
                    Spacer()
                    // Usage of CustomBarButton
                    CustomBarButton(systemName: "house", destination: AnyView(ContentView()))
                    CustomBarButton(systemName: "magnifyingglass", destination: AnyView(searchPage()))
                    CustomBarButton(systemName: "message", destination: AnyView(chatLog()))
                    Spacer()
                }
                .background(Color.black)
                .navigationBarBackButtonHidden(true)
                
                // newMessageButton
                newMessageButton
                    .padding(.bottom, 75)
                    .navigationBarBackButtonHidden(true)
            }
        }
    }
    
    private var TopBar: some View {
        HStack(spacing: 16) {
            Image(systemName: "person.fill")
                .font(.system(size: 34, weight: .heavy))
            
            VStack(alignment: .leading, spacing: 4) {
                Text("USERNAME")
                    .font(.system(size: 24, weight: .bold))
                
                HStack {
                    Circle()
                        .foregroundColor(.green)
                        .frame(width: 14, height: 14)
                    Text("Online")
                        .font(.system(size: 12))
                        .foregroundColor(Color(.systemGray))
                }
            }
            Spacer()
        }
    }
        
    private var messagesView: some View {
        ScrollView {
            ForEach(0..<10, id: \.self) { num in
                VStack {
                    HStack(spacing: 16) {
                        Image(systemName: "person.fill")
                            .font(.system(size: 32))
                            .padding(8)
                            .overlay(RoundedRectangle(cornerRadius: 44)
                                .stroke(Color(.label), lineWidth: 1)
                            )
                        
                        VStack(alignment: .leading) {
                            Text("Username")
                                .font(.system(size: 16, weight: .bold))
                            Text("Message sent to user")
                                .font(.system(size: 14))
                                .foregroundColor(Color(.systemGray))
                        }
                        Spacer()
                        Text("22d")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    Divider()
                        .padding(.vertical, 8)
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 50)
        }
    }
    
    private var newMessageButton: some View {
        Button {
            //action when the button is tapped
        } label: {
            HStack {
                Spacer()
                Text("+ New Message")
                    .font(.system(size: 16, weight: .bold))
                Spacer()
            }
            .foregroundColor(.white)
            .padding(.vertical)
            .background(Color.blue)
            .cornerRadius(32)
            .padding(.horizontal)
            .shadow(radius: 15)
        }
    }
}

struct chatLogView_Previews: PreviewProvider {
    static var previews: some View {
        chatLog()
            .preferredColorScheme(.dark)
        
        chatLog()
    }
}
