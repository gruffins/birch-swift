//
//  SourceTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class SourceTests: QuickSpec {
    override func spec() {
        var source: Source!
        var storage: Storage!
        var eventBus: EventBus!

        beforeEach {
            eventBus = EventBus()
            storage = Storage()
            source = Source(storage: storage, eventBus: eventBus)
        }

        describe("uuid") {
            it("has a value") {
                expect(source.uuid).notTo(beEmpty())
            }
        }

        describe("packageName") {
            it("gets the package name") {
                expect(source.packageName).to(equal("com.apple.dt.xctest.tool"))
            }
        }

        describe("appVersion") {
            it("gets the app version") {
                expect(source.appVersion).notTo(beEmpty())
            }
        }

        describe("appBuildNumber") {
            it("gets the app build number") {
                expect(source.appBuildNumber).notTo(beEmpty())
            }
        }

        describe("brand") {
            it("gets the brand") {
                expect(source.brand).to(equal("Apple"))
            }
        }

        describe("manufacturer") {
            it("gets the manufacturer") {
                expect(source.manufacturer).to(equal("Apple"))
            }
        }

        describe("model") {
            it("gets the model") {
                expect(source.model).notTo(beEmpty())
            }
        }

        describe("osVersion") {
            it("gets the os version") {
                expect(source.osVersion).notTo(beEmpty())
            }
        }

        describe("toJson()") {
            it("serializes all attributes") {
                let dict = source.toJson()
                expect(dict["uuid"]).to(equal(source.uuid))
                expect(dict["package_name"]).to(equal(source.packageName))
                expect(dict["app_version"]).to(equal(source.appVersion))
                expect(dict["app_build_number"]).to(equal(source.appBuildNumber))
                expect(dict["brand"]).to(equal(source.brand))
                expect(dict["manufacturer"]).to(equal(source.manufacturer))
                expect(dict["model"]).to(equal(source.model))
                expect(dict["os"]).to(equal(source.os))
                expect(dict["os_version"]).to(equal(source.osVersion))
            }

            it("serializes custom properties") {
                source.customProperties = ["key": "value"]
                let dict = source.toJson()
                expect(dict["custom_property__key"]).to(equal("value"))
            }
        }
    }
}
