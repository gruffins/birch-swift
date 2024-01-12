//
//  Agent.swift
//  Pods
//
//  Created by Ryan Fung on 1/31/23.
//

import Foundation

public class Agent {
    var engine: EngineProtocol?

    let directory: String

    /// Sets the logger in debug mode.
    public var debug: Bool = false

    /// Sets the logger to opt out. This disables log collection and device synchronization.
    public var optOut: Bool {
        get {
            engine?.storage.optOut ?? false
        }
        set {
            engine?.storage.optOut = newValue
        }
    }

    /// The assigned UUID this source has been given. The UUID remains stable for the install, it does
    /// not persist across installs.
    public var uuid: String? { engine?.source.uuid }

    /// An identifer such as a `user_id` that can be used on the Birch dashboard to locate the device.
    public var identifier: String? {
        get {
            engine?.source.identifier
        }
        set {
            engine?.source.identifier = newValue
        }
    }

    /// Additional properties of the source that should be appended to each log.
    public var customProperties: [String: String] {
        get {
            engine?.source.customProperties ?? [:]
        }
        set {
            engine?.source.customProperties = newValue
        }
    }

    /// Set whether logging to console should be enabled. Defaults to TRUE. Consider changing to FALSE in production.
    public var console: Bool = true

    /// Set whether remote logging is enabled. Defaults to TRUE. This should be TRUE in a production build so your logs are delivered to Birch.
    public var remote: Bool = true

    /// Override the level set by the server. Defaults to NULL. This should be NULL in a production build so you can remotely adjust the log level.
    public var level: Level?
    
    /// Returns the current level used by the logger. This takes into account your override as well as the server configuration.
    public var currentLevel: Level? {
        engine?.currentLevel
    }

    /// Whether to log synchronously or asynchronously. Defaults to FALSE. This should be FALSE in a production build.
    public var synchronous: Bool = false

    /**
        Creates a new logger in the given directory. All Birch agents must have a unique directory.
     */
    public init(directory: String) {
        self.directory = directory
    }

    /**
     Initializes the logger  with the given parameters.
     - Parameters:
        - apiKey: Your api key.
        - publicKey: Your base64 encoded RSA public key.
        - options: Additional options to configure.
     */
    public func initialize(
        _ apiKey: String,
        publicKey: String? = nil,
        options: Options = Options()
    ) {
        if engine == nil {
            var encryption: Encryption?

            if let publicKey, let enc = Encryption.create(publicKey: publicKey) {
                encryption = enc
            }

            let eventBus = EventBus()
            let storage = Storage(directory: directory, defaultLevel: options.defaultLevel)
            let source = Source(storage: storage, eventBus: eventBus)
            let logger = Logger(storage: storage, agent: self, encryption: encryption)
            let network = Network(agent: self, host: options.host, apiKey: apiKey)

            engine = Engine(
                agent: self,
                source: source,
                logger: logger,
                storage: storage,
                network: network,
                eventBus: eventBus,
                scrubbers: options.scrubbers
            )
            engine?.start()
        } else {
            w { "[Birch] Ignored duplicate initialize() call." }
        }
    }

    /// Force the agent to synchronize its configuration.
    public func syncConfiguration() {
        engine?.syncConfiguration()
    }

    /// Flushes logs to the server.
    public func flush() {
        engine?.flush()
    }

    public func t(_ message: String) {
        t { message }
    }

    public func t(_ block: @escaping () -> String) {
        engine?.log(level: .trace, message: block)
    }

    public func d(_ message: String) {
        d { message }
    }

    public func d(_ block: @escaping () -> String) {
        engine?.log(level: .debug, message: block)
    }

    public func i(_ message: String) {
        i { message }
    }

    public func i(_ block: @escaping () -> String) {
        engine?.log(level: .info, message: block)
    }

    public func w(_ message: String) {
        w { message }
    }

    public func w(_ block: @escaping () -> String) {
        engine?.log(level: .warn, message: block)
    }

    public func e(_ message: String) {
        e { message }
    }

    public func e(_ block: @escaping () -> String) {
        engine?.log(level: .error, message: block)
    }

    func debugStatement(_ block: @escaping () -> String) {
        if debug {
            d(block)
        }
    }
}
