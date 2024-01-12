//
//  Engine.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

protocol EngineProtocol {
    var source: Source { get }
    var storage: Storage { get }
    var currentLevel: Level { get }

    func start()
    @discardableResult func log(level: Level, message: @escaping () -> String) -> Bool
    @discardableResult func flush() -> Bool
    @discardableResult func updateSource(source: Source) -> Bool
    @discardableResult func syncConfiguration() -> Bool
}

class Engine: EngineProtocol {
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
    private let agent: Agent
    private let logger: Logger
    private let network: Network
    private let eventBus: EventBus
    private let scrubbers: [Scrubber]
    private var isStarted = false
    private var flushPeriod: Int {
        didSet {
            DispatchQueue.main.async {
                self.timers[.flush]?.invalidate()
                self.timers[.flush] = Timer.scheduledTimer(
                    withTimeInterval: TimeInterval(self.flushPeriod),
                    repeats: true
                ) { [weak self] _ in self?.flush() }
            }
        }
    }

    let source: Source
    let storage: Storage
    
    var currentLevel: Level {
        logger.currentLevel
    }

    var timers: [TimerType: Timer] = [:]

    init(
        agent: Agent,
        source: Source,
        logger: Logger,
        storage: Storage,
        network: Network,
        eventBus: EventBus,
        scrubbers: [Scrubber]
    ) {
        self.agent = agent
        self.source = source
        self.logger = logger
        self.storage = storage
        self.network = network
        self.eventBus = eventBus
        self.flushPeriod = storage.flushPeriod
        self.scrubbers = scrubbers

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

            queue.asyncAfter(deadline: .now() + 5.0) { [weak self] in
                self?.trimFiles()
            }

            queue.asyncAfter(deadline: .now() + 10.0) { [weak self] in
                self?.syncConfiguration()
            }

            queue.asyncAfter(deadline: .now() + 15.0) { [weak self] in
                self?.flush()
            }

            updateSource(source: source)
        }
    }

    @discardableResult func log(level: Level, message: @escaping () -> String) -> Bool {
        guard !agent.optOut else { return false }

        let timestamp = Utils.dateFormatter.string(from: Date())
        let scrubbed = {
            self.scrubbers.reduce(message()) { acc, scrubber in
                scrubber.scrub(input: acc)
            }
        }

        logger.log(
            level: level,
            block: {
                Utils.dictionaryToJson(input: [
                    "timestamp": timestamp,
                    "level": level.rawValue,
                    "source": self.source.toJson(),
                    "message": scrubbed()
                ]) ?? ""
            },
            original: scrubbed)
        return true
    }

    @discardableResult func flush() -> Bool {
        guard !agent.optOut else { return false }

        queue.async {
            self.logger.rollFile()
            self.logger.nonCurrentFiles
                .sorted(by: { l, r in l.path > r.path})
                .forEach { url in
                    if Utils.fileSize(url: url) == 0 {
                        self.agent.debugStatement { "[Birch] Empty file \(url.lastPathComponent)." }
                        Utils.deleteFile(url: url)
                    } else {
                        Utils.safeIgnore {
                            try self.network.uploadLogs(url: url) { success in
                                if success {
                                    self.agent.debugStatement { "[Birch] Removing file \(url.lastPathComponent)." }
                                    Utils.deleteFile(url: url)
                                }
                            }
                        }
                    }
                }
        }
        return true
    }

    @discardableResult func updateSource(source: Source) -> Bool {
        guard !agent.optOut else { return false }

        queue.async {
            self.network.syncSource(source: source)
        }
        return true
    }

    @discardableResult func syncConfiguration() -> Bool {
        guard !agent.optOut else { return false }

        queue.async {
            self.network.getConfiguration(source: self.source) { json in
                if let rawValue = json["log_level"] as? Int, let level = Level(rawValue: rawValue) {
                    self.storage.logLevel = level

                    self.agent.debugStatement { "[Birch] Remote log level set to \(level)." }
                }

                if let period = json["flush_period_seconds"] as? Int {
                    self.storage.flushPeriod = period
                    self.flushPeriod = period

                    self.agent.debugStatement { "[Birch] Remote flush period set to \(period)." }
                }
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
