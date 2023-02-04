//
//  Storage.swift
//  Birch
//
//  Created by Ryan Fung on 11/20/22.
//

import Foundation

class Storage {
    let defaults: UserDefaults?
    let defaultLevel: Level

    init(directory: String, defaultLevel: Level) {
        self.defaults = UserDefaults(suiteName: "com.gruffins.\(directory)")
        self.defaultLevel = defaultLevel
    }

    var uuid: String? {
        get {
            return defaults?.string(forKey: "uuid")
        }
        set {
            defaults?.set(newValue, forKey: "uuid")
        }
    }

    var identifier: String? {
        get {
            return defaults?.string(forKey: "identifier")
        }
        set {
            defaults?.set(newValue, forKey: "identifier")
        }
    }

    var customProperties: [String: String]? {
        get {
            return defaults?.object(forKey: "custom_properties") as? [String: String]
        }
        set {
            defaults?.set(newValue, forKey: "custom_properties")
        }
    }

    var logLevel: Level {
        get {
            if let level = defaults?.integer(forKey: "log_level") {
                return Level(rawValue: level) ?? defaultLevel
            }
            return defaultLevel
        }
        set {
            defaults?.set(newValue.rawValue, forKey: "log_level")
        }
    }

    var flushPeriod: Int {
        get {
            return defaults?.integer(forKey: "flush_period") ?? Engine.Constants.FLUSH_PERIOD_SECONDS
        }
        set {
            defaults?.set(newValue, forKey: "flush_period")
        }
    }
}
