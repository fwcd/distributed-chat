//
//  PersistenceUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import Foundation
import Combine
import Logging

fileprivate let encoder = JSONEncoder()
fileprivate let decoder = JSONDecoder()
fileprivate let log = Logger(label: "PersistenceUtils")

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
            self.init(initialValue: try decoder.decode(Value.self, from: Data(contentsOf: url)))
        } catch {
            log.debug("Could not read file: \(error)")
            self.init(initialValue: wrappedValue)
            save(wrappedValue)
        }
        
        subscriptions[path] = projectedValue.sink(receiveValue: save)
    }
}
