//
//  DropDownBar.swift
//  Esports Application
//
//  Created by Osian Smith on 10/04/2024.
//

import SwiftUI

struct DropDownBar: View {
    @Binding var isOpen: Bool
    var signOutAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Section("Account") {
                Button(action: {
                    signOutAction()
                }) {
                    HStack {
                        Text("Sign Out")
                            .foregroundColor(.blue)
                            .font(.subheadline)
                        Spacer()
                        
                        Image(systemName: "gearshape.fill") // Add gear image
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Version area in dropdown
            Section("General") {
                HStack {
                    Text("Version")
                        .font(.subheadline)
                    Spacer()
                    
                    Text("1.0.0")
                        .font(.subheadline)
                        .foregroundColor(.white) // Set text color to white
                }
            }
        }
        .padding()
        .foregroundColor(.white) // Set the foreground color to white for the text
    }
}
