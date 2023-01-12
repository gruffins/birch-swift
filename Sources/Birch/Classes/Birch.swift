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

    /// Sets the logger in debug mode. This will log Birch operations and flush logs every 30 seconds.
    /// This should be FALSE in production builds otherwise you will not be able to modify settings remotely.
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

    /// Sets the logger to opt out. This disables log collection and device synchronization.
    public static var optOut: Bool = false

    /// Override the default host that should be used. This should be called prior to initializing the logger.
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

    /// The assigned UUID this source has been given. The UUID remains stable for the install, it does
    /// not persist across installs.
    public static var uuid: String? {
        return engine?.source.uuid
    }

    /// An identifer such as a `user_id` that can be used on the Birch dashboard to locate the device.
    public static var identifier: String? {
        get {
            return engine?.source.identifier
        }
        set {
            engine?.source.identifier = newValue
        }
    }

    /// Additional properties of the source that should be appended to each log.
    public static var customProperties: [String: String] {
        get {
            return engine?.source.customProperties ?? [:]
        }
        set {
            engine?.source.customProperties = newValue
        }
    }

    /// Set whether logging to console should be enabled. Defaults to FALSE. This should be FALSE in a production build since you cannot read logcat remotely anyways.
    public static var console: Bool = false

    /// Set whether remote logging is enabled. Defaults to TRUE. This should be TRUE in a production build so your logs are delivered to Birch.
    public static var remote: Bool = true

    /// Override the level set by the server. Defaults to NULL. This should be NULL in a production build so you can remotely adjust the log level.
    public static var level: Level? = nil

    /// Whether to log synchronously or asynchronously. Defaults to FALSE. This should be FALSE in a production build.
    public static var synchronous: Bool = false

    /**
     Initializes the logger  with the given parameters.

     - Parameters:
        - apiKey: Your api key.
        - publicKey: Your base64 encoded RSA public key.
        - scrubbers: An array of scrubbers to be used to sanitize logs.
     */
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

            if let publicKey, let enc = Encryption.create(publicKey: publicKey) {
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

    /// Flushes logs to the server.
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
