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
        NavigationStack {
            Form {
                Section(header: Text("Presentation")) {
                    EnumPicker(selection: $settings.presentation.messageHistoryStyle, label: Text("Message History Style"))
                        .pickerStyle(SegmentedPickerStyle())
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
                                get: { String(settings.bluetooth.monitorSignalStrengthInterval) },
                                set: {
                                    if let value = Int($0) {
                                        settings.bluetooth.monitorSignalStrengthInterval = value
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
            .navigationTitle("Settings")
        }
    }
}

#Preview {
    let settings = Settings()
    
    return SettingsView()
        .environmentObject(settings)
}
