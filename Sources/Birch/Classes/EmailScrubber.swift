//
//  EmailScrubber.swift
//  Birch
//
//  Created by Ryan Fung on 11/26/22.
//

import Foundation

public class EmailScrubber: Scrubber {
    struct Constants {
        // Borrowed from https://developer.android.com/reference/android/util/Patterns#EMAIL_ADDRESS
        static let REGEX = "[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{1,256}\\@[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}(\\.[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25})"
        static let REPLACEMENT = "[FILTERED]"
    }

    public init() {}

    public func scrub(input: String) -> String {
        return input.replacingOccurrences(
            of: Constants.REGEX,
            with: Constants.REPLACEMENT,
            options: [.regularExpression, .caseInsensitive]
        )
    }
}
