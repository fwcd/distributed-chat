//
//  SettingsView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        NavigationView {
            Text("TODO")
                .navigationBarTitle("Settings")
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    @StateObject static var settings = Settings()
    static var previews: some View {
        SettingsView()
            .environmentObject(settings)
    }
}
