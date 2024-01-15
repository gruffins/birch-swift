//
//  Options.swift
//  Pods
//
//  Created by Ryan Fung on 1/31/23.
//

import Foundation

public class Options {
    public var scrubbers: [Scrubber] = [EmailScrubber(), PasswordScrubber()]
    public var host: String = "birch.ryanfung.com"
    public var defaultLevel: Level = .trace

    public init() {}
}
