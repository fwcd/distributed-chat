//
//  AutoPersisting.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import Foundation
import Logging

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()
fileprivate let log = Logger(label: "AutoPersisting")

@propertyWrapper
struct AutoPersisting<T> where T: Codable {
    private let url: URL
    public var wrappedValue: T {
        didSet {
            save()
        }
    }
    
    public init(wrappedValue: T, path: [String]) {
        url = path.reduce(try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) {
            $0.appendingPathComponent($1)
        }
        
        log.debug("Creating directory for auto-persisted value")
        try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        
        do {
            self.wrappedValue = try decoder.decode(T.self, from: Data(contentsOf: url))
        } catch {
            log.debug("Could not read file: \(error)")
            self.wrappedValue = wrappedValue
            save()
            
        }
    }
    
    private func save() {
        do {
            try encoder.encode(wrappedValue).write(to: url)
        } catch {
            log.error("Could not write to file")
        }
    }
}
