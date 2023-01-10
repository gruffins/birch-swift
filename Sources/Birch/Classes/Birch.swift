//
//  Birch.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

public class Birch {
    static var engine: EngineProtocol?
    static var flushPeriod: Int?

    public static var debug: Bool = false {
        didSet {
            if debug {
                flushPeriod = 30
            } else {
                flushPeriod = nil
            }
            engine?.syncConfiguration()
        }
    }

    public static var optOut: Bool = false

    public static var host: String? {
        get {
            return Network.Constants.HOST
        }
        set {
            if let host = newValue {
                if host.isEmpty {
                    Network.Constants.HOST = Network.Constants.DEFAULT_HOST
                } else {
                    Network.Constants.HOST = host
                }
            } else {
                Network.Constants.HOST = Network.Constants.DEFAULT_HOST
            }
        }
    }

    public static var uuid: String? {
        return engine?.source.uuid
    }

    public static var identifier: String? {
        get {
            return engine?.source.identifier
        }
        set {
            engine?.source.identifier = newValue
        }
    }

    public static var customProperties: [String: String] {
        get {
            return engine?.source.customProperties ?? [:]
        }
        set {
            engine?.source.customProperties = newValue
        }
    }

    public static var console: Bool = false
    public static var remote: Bool = true

    public static func initialize(
        _ apiKey: String,
        publicKey: String? = nil,
        scrubbers: [Scrubber] = [
            PasswordScrubber(),
            EmailScrubber()
        ]
    ) {
        if engine == nil {
            var encryption: Encryption?

            if let publicKey = publicKey, let enc = Encryption.create(publicKey: publicKey) {
                encryption = enc
            }

            let eventBus = EventBus()
            let storage = Storage()
            let source = Source(storage: storage, eventBus: eventBus)
            let logger = Logger(encryption: encryption)
            let network = Network(apiKey: apiKey)

            engine = Engine(
                source: source,
                logger: logger,
                storage: storage,
                network: network,
                eventBus: eventBus,
                scrubbers: scrubbers
            )
            engine?.start()
        }
    }

    public static func flush() {
        engine?.flush()
    }

    public static func t(_ message: String) {
        t { message }
    }

    public static func t(_ block: @escaping () -> String) {
        engine?.log(level: .trace, message: block)
    }

    public static func d(_ message: String) {
        d { message }
    }

    public static func d(_ block: @escaping () -> String) {
        engine?.log(level: .debug, message: block)
    }

    public static func i(_ message: String) {
        i { message }
    }

    public static func i(_ block: @escaping () -> String) {
        engine?.log(level: .info, message: block)
    }

    public static func w(_ message: String) {
        w { message }
    }

    public static func w(_ block: @escaping () -> String) {
        engine?.log(level: .warn, message: block)
    }

    public static func e(_ message: String) {
        e { message }
    }

    public static func e(_ block: @escaping () -> String) {
        engine?.log(level: .error, message: block)
    }

    private init() {}

}
