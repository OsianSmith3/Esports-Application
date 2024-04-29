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
    let isFirstOrSecond: Bool // Indicates if it's the first or second button
    
    var body: some View {
        Group {
            NavigationLink(destination: destination) {
                Image(systemName: systemName)
                    .font(.title)
                    .padding(.horizontal, 40)
                    .padding(.vertical, 10)
                    .foregroundColor(.white)
                    .background(Color.black)
                    .cornerRadius(8)
            }
            Spacer()
            // Apply grey line separator conditionally for the first two buttons
            if isFirstOrSecond {
                Rectangle()
                    .frame(width: 1, height: 30)
                    .foregroundColor(.gray)
                    .padding(.trailing, 10) // Adjust the padding if needed
            }
        }
        .navigationBarBackButtonHidden(true)
    }
}
