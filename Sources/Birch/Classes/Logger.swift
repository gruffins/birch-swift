//
//  Logger.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

class Logger {
    struct Constants {
        static let MAX_FILE_SIZE_BYTES = 1024 * 512
    }

    enum Level: Int {
        case trace = 0, debug, info, warn, error, none
    }

    private let queue = DispatchQueue(label: "Birch-Logger")
    private var fileHandle: FileHandle?

    let encryption: Encryption?
    let directory: URL
    let current: URL

    var level: Level = .error

    var nonCurrentFiles: [URL] {
        do {
            let items = try FileManager.default.contentsOfDirectory(at: directory, includingPropertiesForKeys: [])
            return items.filter { $0.lastPathComponent != "current" }
        } catch {
            return []
        }
    }

    init(encryption: Encryption?) {
        self.encryption = encryption

        directory = FileManager.default.temporaryDirectory.appendingPathComponent("birch")
        current = directory.appendingPathComponent("current")

        Utils.safeIgnore {
            try Utils.mkdirs(url: directory)
        }
    }

    func log(level: Level, block: @escaping () -> String, original: @escaping () -> String) {
        if Utils.diskAvailable() && (level.rawValue >= self.level.rawValue || Birch.debug) {
            queue.async {
                Utils.safeIgnore {
                    self.ensureCurrentFileExists()

                    if self.fileHandle == nil {
                        self.fileHandle = try FileHandle(forWritingTo: self.current)
                    }

                    if #available(iOS 13.4, *) {
                        try self.fileHandle?.seekToEnd()
                    } else {
                        self.fileHandle?.seekToEndOfFile()
                    }

                    var message: String

                    if let encryption = self.encryption {
                        message = Utils.dictionaryToJson(input: [
                            "em": encryption.encrypt(input: block()),
                            "ek": encryption.encryptedKey
                        ]) ?? "{}"
                    } else {
                        message = block()
                    }

                    if let data = "\(message),\n".data(using: .utf8) {
                        self.fileHandle?.write(data)
                    }

                    if Birch.debug {
                        let timestamp = Utils.dateFormatter.string(from: Date())

                        switch level {
                        case .trace:
                            print("\(timestamp) TRACE \(original())")
                        case .debug:
                            print("\(timestamp) DEBUG \(original())")
                        case .info:
                            print("\(timestamp) INFO \(original())")
                        case .warn:
                            print("\(timestamp) WARN \(original())")
                        case .error:
                            print("\(timestamp) ERROR \(original())")
                        case .none:
                            break
                        }
                    }

                    if try self.needsRollFile() {
                        self.rollFile(queueSync: false)
                    }
                }
            }
        }
    }

    func rollFile(queueSync: Bool = true) {
        let block = {
            Utils.safeIgnore {
                self.ensureCurrentFileExists()

                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let rollTo = self.directory.appendingPathComponent("\(timestamp)")

                if Birch.debug {
                    Birch.d { "[Birch] Rolled file to \(rollTo.lastPathComponent)." }
                }

                if #available(iOS 13.0, *) {
                    try self.fileHandle?.close()
                } else {
                    self.fileHandle?.closeFile()
                }
                self.fileHandle = nil

                try Utils.moveFile(from: self.current, to: rollTo)

                self.fileHandle = try FileHandle(forWritingTo: self.current)
            }
        }

        if queueSync {
            queue.sync { block() }
        } else {
            block()
        }
    }
}

private extension Logger {
    func needsRollFile() throws -> Bool {
        return Utils.fileSize(url: current) > Constants.MAX_FILE_SIZE_BYTES
    }

    func ensureCurrentFileExists() {
        if !Utils.fileExists(url: current) {
            Utils.createFile(url: current)
        }
    }
}
