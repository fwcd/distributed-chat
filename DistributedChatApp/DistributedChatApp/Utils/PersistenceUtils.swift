//
//  PersistenceUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/24/21.
//

import DistributedChat
import Dispatch
import Foundation
import Combine
import Logging

private let encoder = makeJSONEncoder()
private let decoder = makeJSONDecoder()
private let log = Logger(label: "DistributedChatApp.PersistenceUtils")
private var queue = DispatchQueue(label: "DistributedChatApp.PersistenceUtils")

private var subscriptions = [String: AnyCancellable]()
private var persistenceDisablers = 0

func withoutPersistence(_ action: @escaping () -> Void) {
    queue.async {
        persistenceDisablers += 1
        action()
        persistenceDisablers = max(0, persistenceDisablers - 1)
    }
}

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
        if persistenceDisablers <= 0 {
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
        } else {
            // If persistence is disabled (e.g. in testing/preview contexts),
            // just initialize the propery as usual.
            self.init(initialValue: wrappedValue)
        }
    }
}
