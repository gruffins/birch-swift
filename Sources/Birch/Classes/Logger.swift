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

    private let queue = DispatchQueue(label: "Birch-Logger")
    private var fileHandle: FileHandle?
    private let agent: Agent

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

    init(
        agent: Agent,
        encryption: Encryption?
    ) {
        self.agent = agent
        self.encryption = encryption

        directory = FileManager.default.temporaryDirectory.appendingPathComponent(agent.directory)
        current = directory.appendingPathComponent("current")

        Utils.safeIgnore {
            try Utils.mkdirs(url: directory)
        }
    }

    func log(level: Level, block: @escaping () -> String, original: @escaping () -> String) {
        let currentLevel = agent.level ?? self.level
        if Utils.diskAvailable() && level.rawValue >= currentLevel.rawValue {
            let job = {
                Utils.safeIgnore {
                    self.ensureCurrentFileExists()

                    if self.fileHandle == nil {
                        self.fileHandle = try FileHandle(forWritingTo: self.current)
                    }

                    if #available(iOS 13.4, macOS 10.15.4, watchOS 6.2, tvOS 13.14, *) {
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

                    if self.agent.remote, let data = "\(message),\n".data(using: .utf8) {
                        self.fileHandle?.write(data)

                        if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
                            try self.fileHandle?.synchronize()
                        } else {
                            self.fileHandle?.synchronizeFile()
                        }
                    }

                    if self.agent.console {
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

            if agent.synchronous {
                queue.sync(execute: job)
            } else {
                queue.async(execute: job)
            }
        } else if agent.debug && agent.console {
            let timestamp = Utils.dateFormatter.string(from: Date())
            print("\(timestamp) DEBUG Dropped log. level=\(level) currentLevel=\(currentLevel)")
        }
    }

    func rollFile(queueSync: Bool = true) {
        let block = {
            Utils.safeIgnore {
                self.ensureCurrentFileExists()

                let timestamp = Int(Date().timeIntervalSince1970 * 1000)
                let rollTo = self.directory.appendingPathComponent("\(timestamp)")

                if #available(iOS 13.0, macOS 10.15, watchOS 6.0, tvOS 13.0, *) {
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
