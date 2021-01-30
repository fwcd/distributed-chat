//
//  PersistenceError.swift
//  DistributedChatApp
//
//  Created by Fredrik on 1/30/21.
//

enum PersistenceError: Error {
    case couldNotReadSecurityScoped
    case couldNotReadData
    case invalidDistributedChatURL(String)
}
