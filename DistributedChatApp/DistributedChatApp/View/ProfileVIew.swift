//
//  ProfileView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var profile: Profile
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 40) {
                EnumPicker(selection: $profile.presence.status, label: ZStack(alignment: .bottomTrailing) {
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 80, height: 80, alignment: .center)
                        .foregroundColor(.primary)
                    Circle()
                        .frame(width: 20, height: 20, alignment: .center)
                        .foregroundColor(profile.presence.status.color)
                })
                    .pickerStyle(MenuPickerStyle())
                
                VStack {
                    TextField("Your nickname", text: $profile.presence.user.name)
                        .font(.title2)
                        .multilineTextAlignment(.center)
                    TextField("Your custom status", text: $profile.presence.info)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(20)
            .navigationTitle("Profile")
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    @StateObject static var profile = Profile()
    static var previews: some View {
        ProfileView()
            .environmentObject(profile)
    }
}
