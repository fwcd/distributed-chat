//
//  EnvironmentUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/5/21.
//

import Foundation

func isRunningInSwiftUIPreview() -> Bool {
    #if DEBUG
    return ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    #else
    return false
    #endif
}
