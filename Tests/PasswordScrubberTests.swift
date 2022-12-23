//
//  PasswordScrubberTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/26/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class PasswordScrubberTests: QuickSpec {
    override func spec() {
        var scrubber: PasswordScrubber!

        beforeEach {
            scrubber = PasswordScrubber()
        }

        it("scrubs passwords") {
            let input = "password=@BcopBT4nSDRuDL!"
            expect(scrubber.scrub(input: input)).to(equal("password=[FILTERED]"))
        }

        it("scrubs case insensitive") {
            let input = "PASSWORD=@BcopBT4nSDRuDL!"
            expect(scrubber.scrub(input: input)).to(equal("PASSWORD=[FILTERED]"))
        }

        it("scrubs for urls params") {
            let input = "https://birch.ryanfung.com/auth?username=test123&password=password123"
            expect(scrubber.scrub(input: input)).to(equal("https://birch.ryanfung.com/auth?username=test123&password=[FILTERED]"))
        }

        it("scrubs json") {
            let input = Utils.dictionaryToJson(input: ["password": "password123"])!
            expect(scrubber.scrub(input: input)).to(equal("{\"password\":\"[FILTERED]\"}"))
        }

        it("scrubs json with spacing") {
            let input = "{\"password\": \"password123\"}"
            expect(scrubber.scrub(input: input)).to(equal("{\"password\": \"[FILTERED]\"}"))
        }
    }
}
