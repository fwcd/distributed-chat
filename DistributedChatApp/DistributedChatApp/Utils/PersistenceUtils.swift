//
//  PersistenceUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import Foundation
import Combine
import Logging

fileprivate let encoder = makeJSONEncoder()
fileprivate let decoder = makeJSONDecoder()
fileprivate let log = Logger(label: "DistributedChatApp.PersistenceUtils")

private var subscriptions = [String: AnyCancellable]()

func persistenceFileURL(path: String) -> URL {
    let url = path
        .split(separator: "/")
        .reduce(try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)) {
            $0.appendingPathComponent(String($1))
        }
    
    log.debug("Creating directory for auto-persisted value")
    try! FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
    
    return url
}

extension Published where Value: Codable {
    init(wrappedValue: Value, persistingTo path: String) {
        let url = persistenceFileURL(path: path)
        let save = { (value: Value) in
            do {
                try encoder.encode(value).write(to: url)
            } catch {
                log.error("Could not write to file")
            }
        }
        
        do {
            self.init(initialValue: try decoder.decode(Value.self, from: Data.smartContents(of: url)))
        } catch {
            log.debug("Could not read file: \(error)")
            self.init(initialValue: wrappedValue)
        }
        
        subscriptions[path] = projectedValue.sink(receiveValue: save)
    }
}

extension Data {
    /// Reads a potentially security-scoped or distributedchat-schemed resource.
    static func smartContents(of url: URL) throws -> Data {
        do {
            return try Data(contentsOf: url.smartResolved)
        } catch {
            log.debug("Could not read \(url) directly, trying security-scoped access...")
            
            guard url.startAccessingSecurityScopedResource() else { throw PersistenceError.couldNotReadSecurityScoped }
            defer { url.stopAccessingSecurityScopedResource() }
            
            var error: NSError? = nil
            var caughtError: Error? = nil
            var data: Data? = nil
            
            NSFileCoordinator().coordinate(readingItemAt: url, error: &error) { url2 in
                do {
                    data = try Data(contentsOf: url)
                } catch {
                    caughtError = error
                }
            }
            
            if let error = error {
                throw error
            } else if let caughtError = caughtError {
                throw caughtError
            }
            
            guard let unwrappedData = data else { throw PersistenceError.couldNotReadData }
            return unwrappedData
        }
    }
    
    /// Writes a potentially distributedchat-schemed resources.
    func smartWrite(to url: URL) throws {
        try write(to: url.smartResolved)
    }
}
