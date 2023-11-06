//
//  EmailScrubberTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/26/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class EmailScrubberTests: QuickSpec {
    override class func spec() {
        var scrubber: EmailScrubber!

        beforeEach {
            scrubber = EmailScrubber()
        }

        it("scrubs emails") {
            let input = "abcd@domain.com"
            expect(scrubber.scrub(input: input)).to(equal("[FILTERED]"))
        }

        it("scrubs emails from urls") {
            let input = "https://birch.ryanfung.com/user?email=valid+email@domain.com"
            expect(scrubber.scrub(input: input)).to(equal("https://birch.ryanfung.com/user?email=[FILTERED]"))
        }

        it("scrubs from json") {
            let input = "{\"email\": \"abcd@domain.com\"}"
            expect(scrubber.scrub(input: input)).to(equal("{\"email\": \"[FILTERED]\"}"))
        }

        it("scrubs multiple emails") {
            let input = "abcd@domain.com asdf@domain.com"
            expect(scrubber.scrub(input: input)).to(equal("[FILTERED] [FILTERED]"))
        }
    }
}
