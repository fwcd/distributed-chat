//
//  ProfileView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import SwiftUI

struct ProfileView: View {
    @Binding var name: String
    
    // TODO: Add isEditable and reuse these views for other
    //       chat user's profile views
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 40) {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 80, height: 80, alignment: .center)
                TextField("Your nickname", text: $name)
                    .font(.title2)
                    .multilineTextAlignment(.center)
            }
            .padding(20)
            .navigationBarTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    @State static var name: String = ""
    static var previews: some View {
        ProfileView(name: $name)
    }
}
