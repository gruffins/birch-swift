//
//  Engine.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation
import UIKit

class Engine {
    struct Constants {
        static let SYNC_PERIOD_SECONDS = 60 * 15
        static let FLUSH_PERIOD_SECONDS = 60 * 30
        static let TRIM_PERIOD_SECONDS = 60 * 60 * 24
        static let MAX_FILE_AGE_SECONDS = 60 * 60 * 24 * 3
    }

    enum TimerType {
        case trim, sync, flush
    }

    private let queue = DispatchQueue(label: "Birch-Engine")

    private let logger: Logger
    private let storage: Storage
    private let network: Network
    private let eventBus: EventBus
    private var isStarted = false
    private var flushPeriod: Int {
        didSet {
            let period = Double(Birch.flushPeriod ?? flushPeriod)

            DispatchQueue.main.async {
                self.timers[.flush]?.invalidate()
                self.timers[.flush] = Timer.scheduledTimer(
                    withTimeInterval: period,
                    repeats: true
                ) { [weak self] _ in self?.flush() }
            }
        }
    }

    let source: Source

    var timers: [TimerType: Timer] = [:]

    init(
        source: Source,
        logger: Logger,
        storage: Storage,
        network: Network,
        eventBus: EventBus
    ) {
        self.source = source
        self.logger = logger
        self.storage = storage
        self.network = network
        self.eventBus = eventBus
        self.flushPeriod = storage.flushPeriod

        eventBus.subscribe(listener: self)
    }

    deinit {
        timers.values.forEach { $0.invalidate() }
    }

    func start() {
        if !isStarted {
            isStarted = true

            DispatchQueue.main.async {
                self.timers[.trim] = Timer.scheduledTimer(
                    withTimeInterval: Double(Constants.TRIM_PERIOD_SECONDS),
                    repeats: true
                ) { [weak self] _ in self?.trimFiles() }

                self.timers[.sync] = Timer.scheduledTimer(
                    withTimeInterval: Double(Constants.SYNC_PERIOD_SECONDS),
                    repeats: true
                ) { [weak self] _ in self?.syncConfiguration() }

                self.timers[.flush] = Timer.scheduledTimer(
                    withTimeInterval: Double(Constants.FLUSH_PERIOD_SECONDS),
                    repeats: true
                ) { [weak self] _ in self?.flush() }
            }

            updateSource(source: source)
        }
    }

    @discardableResult func log(level: Logger.Level, message: @escaping () -> String) -> Bool {
        guard !Birch.optOut else { return false }

        let timestamp = Utils.dateFormatter.string(from: Date())

        logger.log(
            level: level,
            block: {
                Utils.dictionaryToJson(input: [
                    "timestamp": timestamp,
                    "level": level.rawValue,
                    "source": self.source.toJson(),
                    "message": message()
                ]) ?? ""
            },
            original: message)
        return true
    }

    @discardableResult func flush() -> Bool {
        guard !Birch.optOut else { return false }

        queue.async {
            self.logger.rollFile()
            self.logger.nonCurrentFiles
                .sorted(by: { l, r in l.path > r.path})
                .forEach { url in
                    if Utils.fileSize(url: url) == 0 {
                        Utils.deleteFile(url: url)
                    } else {
                        self.network.uploadLogs(url: url) { success in
                            if success {
                                if Birch.debug {
                                    Birch.d { "[Birch] Removing file \(url.lastPathComponent)" }
                                }

                                Utils.deleteFile(url: url)
                            }
                        }
                    }
                }
        }
        return true
    }

    @discardableResult func updateSource(source: Source) -> Bool {
        guard !Birch.optOut else { return false }

        queue.async {
            self.network.syncSource(source: source)
        }
        return true
    }

    @discardableResult func syncConfiguration() -> Bool {
        guard !Birch.optOut else { return false }

        queue.async {
            self.network.getConfiguration(source: self.source) { json in
                let level = Logger.Level(rawValue: (json["log_level"] as? Int) ?? Logger.Level.error.rawValue)
                let period = (json["flush_period_seconds"] as? Int) ?? Constants.FLUSH_PERIOD_SECONDS

                self.storage.logLevel = level ?? Logger.Level.error
                self.logger.level = level ?? Logger.Level.error
                self.storage.flushPeriod = period

                self.flushPeriod = period
            }
        }
        return true
    }

    func trimFiles(now: Date = Date()) {
        queue.async {
            let timestamp = now.timeIntervalSince1970 - Double(Constants.MAX_FILE_AGE_SECONDS)

            self.logger.nonCurrentFiles
                .filter { Double($0.lastPathComponent) ?? 0 < timestamp }
                .forEach { Utils.deleteFile(url: $0) }
        }
    }
}

extension Engine: EventBusListener {
    func onEvent(event: EventBus.Event) {
        switch event {
        case .sourceUpdate(let source):
            updateSource(source: source)
        }
    }
}

extension Engine: Hashable, Equatable {
    static func == (lhs: Engine, rhs: Engine) -> Bool {
        return ObjectIdentifier(lhs) == ObjectIdentifier(rhs)
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(self))
    }
}
