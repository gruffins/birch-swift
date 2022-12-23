//
//  PasswordScrubber.swift
//  Birch
//
//  Created by Ryan Fung on 11/26/22.
//

import Foundation

public class PasswordScrubber: Scrubber {
    struct Constants {
        static let KVP_REGEX = "(password)=[^&#]*"
        static let JSON_REGEX = "(\"password\":\\s?)\".*\""
    }

    public init() {}

    public func scrub(input: String) -> String {
        return input.replacingOccurrences(
            of: Constants.KVP_REGEX,
            with: "$1=[FILTERED]",
            options: [.regularExpression, .caseInsensitive]
        ).replacingOccurrences(
            of: Constants.JSON_REGEX,
            with: "$1\"[FILTERED]\"",
            options: [.regularExpression, .caseInsensitive]
        )
    }
}
