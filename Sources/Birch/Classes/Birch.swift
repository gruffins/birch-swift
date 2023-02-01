//
//  Birch.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

public class Birch {
    static var agent: Agent = Agent(directory: "birch")

    static public var debug: Bool {
        get {
            agent.debug
        }
        set {
            agent.debug = newValue
        }
    }

    static public var optOut: Bool {
        get {
            agent.optOut
        }
        set {
            agent.optOut = newValue
        }
    }

    static public var uuid: String? { agent.uuid }

    static public var identifier: String? {
        get {
            agent.identifier
        }
        set {
            agent.identifier = newValue
        }
    }

    static public var customProperties: [String: String] {
        get {
            agent.customProperties
        }
        set {
            agent.customProperties = newValue
        }
    }

    static public var console: Bool {
        get {
            agent.console
        }
        set {
            agent.console = newValue
        }
    }

    static public var remote: Bool {
        get {
            agent.remote
        }
        set {
            agent.remote = newValue
        }
    }

    static public var level: Level? {
        get {
            agent.level
        }
        set {
            agent.level = newValue
        }
    }

    static public var synchronous: Bool {
        get {
            agent.synchronous
        }
        set {
            agent.synchronous = newValue
        }
    }

    static public func initialize(
        _ apiKey: String,
        publicKey: String? = nil,
        options: Options = Options()
    ) {
        agent.initialize(apiKey, publicKey: publicKey, options: options)
    }

    static public func syncConfiguration() {
        agent.syncConfiguration()
    }

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
