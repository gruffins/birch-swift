//
//  Utils.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation
import UIKit

class Utils {

    static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZ"
        return formatter
    }()

    static func safeIgnore(_ block: () throws -> Void) {
        do {
            try block()
        } catch {
            // no-op
        }
    }

    private init() {}
}

// Device Helpers

extension Utils {
    static func getDeviceModel() -> String? {
        if let sim = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] {
            return sim
        }
        var sysinfo = utsname()
        uname(&sysinfo)
        return String(bytes: Data(bytes: &sysinfo.machine, count: Int(_SYS_NAMELEN)), encoding: .ascii)?.trimmingCharacters(in: .controlCharacters)
    }
}

// JSON Helpers

extension Utils {
    static func dictionaryToJson(input: [String: Any]) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: input, options: []) {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    static func jsonToDictionary(input: String) -> [String: Any]? {
        if let data = input.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        {
            return json
        }
        return nil
    }
}

// File Helpers

extension Utils {
    static func fileSize(url: URL) -> Int {
        let manager = FileManager.default
        if let attrs = try? manager.attributesOfItem(atPath: url.path), let byteSize = attrs[.size] as? Int {
            return byteSize
        }
        return 0
    }

    static func deleteFile(url: URL) {
        Utils.safeIgnore {
            try FileManager.default.removeItem(at: url)
        }
    }

    static func fileExists(url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }

    static func createFile(url: URL) {
        FileManager.default.createFile(atPath: url.path, contents: nil)
    }

    static func moveFile(from: URL, to: URL) throws {
        try FileManager.default.moveItem(at: from, to: to)
    }

    static func mkdirs(url: URL) throws {
        if !fileExists(url: url) {
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }

    static func diskAvailable() -> Bool {
        var available = false

        safeIgnore {
            let manager = FileManager.default
            let url = manager.temporaryDirectory

            if #available(iOS 11.0, *) {
                let resourceValues = try url.resourceValues(forKeys: [.volumeAvailableCapacityForOpportunisticUsageKey])

                if let capacity = resourceValues.volumeAvailableCapacityForOpportunisticUsage {
                    available = capacity > 0
                }
            } else {
                let attributes = try? manager.attributesOfFileSystem(forPath: url.path)

                if let capacity = attributes?[.systemFreeSize] as? Int {
                    available = capacity > 0
                }
            }
        }

        return available
    }
}

// Encryption

extension Utils {
    static func parsePublicKey(pem: String) -> SecKey? {
        if let data = Data(
            base64Encoded: pem
                .replacingOccurrences(of: "-----BEGIN PUBLIC KEY-----", with: "")
                .replacingOccurrences(of: "-----END PUBLIC KEY-----", with: "")
                .replacingOccurrences(of: "\n", with: ""),
            options: .ignoreUnknownCharacters
        ) {
            let attrs: [String: Any] = [
                String(kSecAttrKeyType): kSecAttrKeyTypeRSA,
                String(kSecAttrKeyClass): kSecAttrKeyClassPublic,
                String(kSecAttrKeySizeInBits): data.count * 8
            ]

            return SecKeyCreateWithData(data as CFData, attrs as CFDictionary, nil)
        }

        return nil
    }
}
