//
//  BottomBar.swift
//  Esports Application
//
//  Created by Osian Smith on 01/02/2024.
//

import SwiftUI

struct CustomBarButton: View {
    let systemName: String
    let destination: AnyView
    
    var body: some View {
        NavigationLink(destination: destination) {
            Image(systemName: systemName)
                .font(.title)
                .padding(.horizontal, 40)
                .padding(.vertical, 10)
                .foregroundColor(.white)
                .background(Color.black)
                .cornerRadius(8)
        }
        // Grey line separator
        .overlay(
            Rectangle()
                .frame(width: 1, height: 30)
                .foregroundColor(.gray),
            alignment: .trailing
        )
        .navigationBarBackButtonHidden(true)
    }
}
