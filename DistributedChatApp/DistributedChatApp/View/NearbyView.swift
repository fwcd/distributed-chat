//
//  NearbyView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/23/21.
//

import SwiftUI

struct NearbyView: View {
    @EnvironmentObject private var nearby: Nearby
    
    var body: some View {
        NavigationView {
            List(nearby.nearbyNodes, id: \.self) { node in
                Text(node)
            }
            .navigationTitle("Nearby")
        }
    }
}

struct NearbyView_Previews: PreviewProvider {
    @StateObject static var nearby = Nearby()
    static var previews: some View {
        NearbyView()
            .environmentObject(nearby)
    }
}