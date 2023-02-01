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

    public var debug: Bool = false

    public var optOut: Bool = false

    public var uuid: String? { engine?.source.uuid }

    public var identifier: String? {
        get {
            engine?.source.identifier
        }
        set {
            engine?.source.identifier = newValue
        }
    }

    public var customProperties: [String: String] {
        get {
            engine?.source.customProperties ?? [:]
        }
        set {
            engine?.source.customProperties = newValue
        }
    }

    public var console: Bool = false

    public var remote: Bool = true

    public var level: Level?

    public var synchronous: Bool = false

    public init(directory: String) {
        self.directory = directory
    }

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
            let logger = Logger(agent: self, encryption: encryption)
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

    public func syncConfiguration() {
        engine?.syncConfiguration()
    }

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
}
