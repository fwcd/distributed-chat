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
            Form {
                Section(header: Text("Presentation")) {
                    EnumPicker(selection: $settings.presentation.messageHistoryStyle, label: Text("Message History Style"))
                    Toggle(isOn: $settings.presentation.showChannelPreviews) {
                        Text("Show Channel Previews")
                    }
                }
                Section(header: Text("Bluetooth")) {
                    Toggle(isOn: $settings.bluetooth.advertisingEnabled) {
                        Text("Advertise to nearby devices")
                    }
                    Toggle(isOn: $settings.bluetooth.scanningEnabled) {
                        Text("Scan for nearby devices")
                    }
                    Toggle(isOn: $settings.bluetooth.monitorSignalStrength) {
                        Text("Monitor signal strengths")
                    }
                    if settings.bluetooth.monitorSignalStrength {
                        HStack {
                            Text("Monitoring interval in seconds")
                            Spacer()
                            TextField("sec", text: Binding(
                                get: { String(format: "%.02f", settings.bluetooth.monitorSignalStrengthInterval) },
                                set: {
                                    if let value = NumberFormatter().number(from: $0) {
                                        settings.bluetooth.monitorSignalStrengthInterval = value.doubleValue
                                    }
                                }
                            ))
                                .multilineTextAlignment(.trailing)
                                .fixedSize()
                                .keyboardType(.numberPad)
                        }
                    }
                }
            }
            .onReceive(settings.$bluetooth) { _ in
                print("Updated")
            }
            .navigationTitle("Settings")
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
