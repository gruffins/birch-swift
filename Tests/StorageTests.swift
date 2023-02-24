//
//  StorageTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class StorageTests: QuickSpec {
    override func spec() {
        var storage: Storage!

        beforeEach {
            storage = Storage(directory: "birch", defaultLevel: .error)
        }

        afterEach {
            storage.defaults?.removeSuite(named: "com.gruffins.birch")
        }

        describe("uuid") {
            it("gets and sets") {
                let uuid = UUID().uuidString
                storage.uuid = uuid
                expect(storage.uuid).to(equal(uuid))
            }
        }

        describe("identifier") {
            it("gets and sets") {
                let identifier = "identifier"
                storage.identifier = identifier
                expect(storage.identifier).to(equal(identifier))
            }
        }

        describe("customProperties") {
            it("gets and sets") {
                let properties = ["key": "value"]
                storage.customProperties = properties
                expect(storage.customProperties?["key"]).to(equal("value"))
            }
        }

        describe("logLevel") {
            it("gets and sets") {
                let logLevel = Level.warn
                storage.logLevel = logLevel
                expect(storage.logLevel).to(equal(logLevel))
            }
        }

        describe("flushPeriod") {
            it("gets and sets") {
                let flushPeriod = 30
                storage.flushPeriod = flushPeriod
                expect(storage.flushPeriod).to(equal(flushPeriod))
            }
        }

        describe("optOut") {
            it("gets and sets") {
                storage.optOut = true
                expect(storage.optOut).to(beTrue())
            }
        }
    }
}
