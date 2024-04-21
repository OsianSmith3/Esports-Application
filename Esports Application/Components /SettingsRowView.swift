//
//  SettingsRowView.swift
//  Esports Application
//
//  Created by Osian Smith on 22/12/2023.
//

import SwiftUI

struct SettingsRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white)
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsRowView_Previews: PreviewProvider{
    static var previews: some View {
        SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
    }
}
