//
//  PasswordScrubber.swift
//  Birch
//
//  Created by Ryan Fung on 11/26/22.
//

import Foundation

public class PasswordScrubber: Scrubber {
    struct Constants {
        static let REGEX = "(password)=[^&#]*"
    }

    public init() {}

    public func scrub(input: String) -> String {
        return input.replacingOccurrences(
            of: Constants.REGEX,
            with: "$1=[FILTERED]",
            options: [.regularExpression, .caseInsensitive]
        )
    }
}
