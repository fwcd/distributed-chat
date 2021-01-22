//
//  ContentView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/17/21.
//

import SwiftUI
import DistributedChat

struct ContentView: View {
    private let controller = ChatController(transport: CoreBluetoothTransport())
    
    var body: some View {
        Text("Hello!")
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
