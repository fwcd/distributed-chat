//
//  DataUtils.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/2/21.
//

import DistributedChat
import Foundation
import Logging

fileprivate let log = Logger(label: "DistributedChatApp.DataUtils")

enum ChatAttachmentExtractionError: Error {
    case cannotExtractEncryptedData
}

extension ChatAttachment {
    func extractedData() throws -> Data {
        var extracted: Data
        switch content {
        case .url(let url):
            extracted = try Data.smartContents(of: url)
        case .encrypted(_):
            throw ChatAttachmentExtractionError.cannotExtractEncryptedData
        case .data(let data):
            extracted = data
        }
        if let compression = compression {
            extracted = try extracted.decompressed(with: compression)
        }
        return extracted
    }
}

extension ChatAttachment.Compression {
    var algorithm: NSData.CompressionAlgorithm {
        switch self {
        case .lz4:
            return .lz4
        case .lzma:
            return .lzma
        case .lzfse:
            return .lzfse
        case .zlib:
            return .zlib
        }
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
    
    /// Compresses the data with the given algorithm.
    func compressed(with compression: ChatAttachment.Compression) throws -> Data {
        try (self as NSData).compressed(using: compression.algorithm) as Data
    }
    
    /// Decompresses the data with the given algorithm.
    func decompressed(with compression: ChatAttachment.Compression) throws -> Data {
        try (self as NSData).decompressed(using: compression.algorithm) as Data
    }
}
