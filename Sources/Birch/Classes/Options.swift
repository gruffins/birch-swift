//
//  Options.swift
//  Pods
//
//  Created by Ryan Fung on 1/31/23.
//

import Foundation

public class Options {
    var scrubbers: [Scrubber] = [EmailScrubber(), PasswordScrubber()]
    var host: String = "birch.ryanfung.com"
    var defaultLevel: Level = .trace

    public init() {}
}
