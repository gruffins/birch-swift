//
//  Birch.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

public class Birch {
    static var agent: Agent = Agent(directory: "birch")

    /// Sets the logger in debug mode..
    static public var debug: Bool {
        get {
            agent.debug
        }
        set {
            agent.debug = newValue
        }
    }

    /// Sets the logger to opt out. This disables log collection and device synchronization.
    static public var optOut: Bool {
        get {
            agent.optOut
        }
        set {
            agent.optOut = newValue
        }
    }

    /// The assigned UUID this source has been given. The UUID remains stable for the install, it does
    /// not persist across installs.
    static public var uuid: String? { agent.uuid }

    /// An identifer such as a `user_id` that can be used on the Birch dashboard to locate the device.
    static public var identifier: String? {
        get {
            agent.identifier
        }
        set {
            agent.identifier = newValue
        }
    }

    /// Additional properties of the source that should be appended to each log.
    static public var customProperties: [String: String] {
        get {
            agent.customProperties
        }
        set {
            agent.customProperties = newValue
        }
    }

    /// Set whether logging to console should be enabled. Defaults to FALSE. This should be FALSE in a production build since you cannot read console remotely anyways.
    static public var console: Bool {
        get {
            agent.console
        }
        set {
            agent.console = newValue
        }
    }

    /// Set whether remote logging is enabled. Defaults to TRUE. This should be TRUE in a production build so your logs are delivered to Birch.
    static public var remote: Bool {
        get {
            agent.remote
        }
        set {
            agent.remote = newValue
        }
    }

    /// Override the level set by the server. Defaults to NULL. This should be NULL in a production build so you can remotely adjust the log level.
    static public var level: Level? {
        get {
            agent.level
        }
        set {
            agent.level = newValue
        }
    }

    /// Whether to log synchronously or asynchronously. Defaults to FALSE. This should be FALSE in a production build.
    static public var synchronous: Bool {
        get {
            agent.synchronous
        }
        set {
            agent.synchronous = newValue
        }
    }

    /**
     Initializes the logger  with the given parameters.
     - Parameters:
        - apiKey: Your api key.
        - publicKey: Your base64 encoded RSA public key.
        - options: Additional options to configure.
     */
    static public func initialize(
        _ apiKey: String,
        publicKey: String? = nil,
        options: Options = Options()
    ) {
        agent.initialize(apiKey, publicKey: publicKey, options: options)
    }

    /// Force the agent to synchronize its configuration.
    static public func syncConfiguration() {
        agent.syncConfiguration()
    }

    /// Flushes logs to the server.
    static public func flush() {
        agent.flush()
    }

    static public func t(_ message: String) {
        agent.t(message)
    }

    static public func t(_ block: @escaping () -> String) {
        agent.t(block)
    }

    static public func d(_ message: String) {
        agent.d(message)
    }

    static public func d(_ block: @escaping () -> String) {
        agent.d(block)
    }

    static public func i(_ message: String) {
        agent.i(message)
    }

    static public func i(_ block: @escaping () -> String) {
        agent.i(block)
    }

    static public func w(_ message: String) {
        agent.w(message)
    }

    static public func w(_ block: @escaping () -> String) {
        agent.w(block)
    }

    static public func e(_ message: String) {
        agent.e(message)
    }

    static public func e(_ block: @escaping () -> String) {
        agent.e(block)
    }

    private init() {}

}
