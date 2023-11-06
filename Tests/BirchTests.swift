//
//  BirchTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/29/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class BirchTests: QuickSpec {
    private class TestAgent: Agent {
        var initializeCalled = false
        var syncConfigurationCalled = false
        var flushCalled = false
        var tStringCalled = false
        var dStringCalled = false
        var iStringCalled = false
        var wStringCalled = false
        var eStringCalled = false
        var tBlockCalled = false
        var dBlockCalled = false
        var iBlockCalled = false
        var wBlockCalled = false
        var eBlockCalled = false

        override var uuid: String? { "uuid" }

        var _identifier: String?
        override var identifier: String? {
            get {
                _identifier
            }
            set {
                _identifier = newValue
            }
        }

        var _customProperties: [String: String] = [:]
        override var customProperties: [String : String] {
            get {
                _customProperties
            }
            set {
                _customProperties = newValue
            }
        }

        var _optOut: Bool = false
        override var optOut: Bool {
            get {
                _optOut
            }
            set {
                _optOut = newValue
            }
        }

        var _level: Level?
        override var level: Level? {
            get {
                _level
            }
            set {
                _level = newValue
            }
        }

        override func initialize(
            _ apiKey: String,
            publicKey: String? = nil,
            options: Options = Options()
        ) {
            initializeCalled = true
        }

        override func syncConfiguration() {
            syncConfigurationCalled = true
        }

        override func flush() {
            flushCalled = true
        }

        override func t(_ message: String) {
            tStringCalled = true
        }

        override func d(_ message: String) {
            dStringCalled = true
        }

        override func i(_ message: String) {
            iStringCalled = true
        }

        override func w(_ message: String) {
            wStringCalled = true
        }

        override func e(_ message: String) {
            eStringCalled = true
        }

        override func t(_ block: @escaping () -> String) {
            tBlockCalled = true
        }

        override func d(_ block: @escaping () -> String) {
            dBlockCalled = true
        }

        override func i(_ block: @escaping () -> String) {
            iBlockCalled = true
        }

        override func w(_ block: @escaping () -> String) {
            wBlockCalled = true
        }

        override func e(_ block: @escaping () -> String) {
            eBlockCalled = true
        }
    }

    override class func spec() {
        var agent: TestAgent!

        beforeEach {
            agent = TestAgent(directory: "test")
            Birch.agent = agent
        }

        afterEach {
            Birch.agent = Agent(directory: "birch")
        }

        describe("debug()") {
            describe("get") {
                it("calls the agent") {
                    expect(Birch.debug).to(equal(agent.debug))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.debug = true
                    expect(agent.debug).to(beTrue())
                }
            }
        }

        describe("optOut()") {
            describe("get") {
                it("calls the agent") {
                    expect(Birch.optOut).to(equal(agent.optOut))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.optOut = true
                    expect(agent.optOut).to(beTrue())
                }
            }
        }

        describe("uuid()") {
            it("returns the agent value") {
                expect(Birch.uuid).to(equal(agent.uuid))
            }
        }

        describe("identifier()") {
            describe("get") {
                it("calls the agent") {
                    agent.identifier = "identifier"
                    expect(Birch.identifier).to(equal(agent.identifier))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.identifier = "test"
                    expect(agent.identifier).to(equal("test"))
                }
            }
        }

        describe("customProperties()") {
            describe("get") {
                it("calls the agent") {
                    agent.customProperties = ["key": "value"]
                    expect(Birch.customProperties["key"]).to(equal("value"))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.customProperties = ["key": "value"]
                    expect(agent.customProperties["key"]).to(equal("value"))
                }
            }
        }

        describe("console()") {
            describe("get") {
                it("calls the agent") {
                    expect(Birch.console).to(equal(agent.console))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.console = true
                    expect(agent.console).to(beTrue())
                }
            }
        }

        describe("remote") {
            describe("get") {
                it("calls the agent") {
                    expect(Birch.remote).to(equal(agent.remote))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.remote = true
                    expect(agent.remote).to(beTrue())
                }
            }
        }

        describe("level()") {
            describe("get") {
                it("calls the agent") {
                    agent.level = .debug
                    expect(Birch.level).to(equal(agent.level))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.level = .trace
                    expect(agent.level).to(equal(.trace))
                }
            }
        }

        describe("synchronous()") {
            describe("get") {
                it("calls the agent") {
                    expect(Birch.synchronous).to(equal(agent.synchronous))
                }
            }

            describe("set") {
                it("calls the agent") {
                    Birch.synchronous = true
                    expect(agent.synchronous).to(beTrue())
                }
            }
        }

        describe("initialize()") {
            it("calls the agent") {
                Birch.initialize("api_key")
                expect(agent.initializeCalled).to(beTrue())
            }
        }

        describe("syncConfiguration()") {
            it("calls the agent") {
                Birch.syncConfiguration()
                expect(agent.syncConfigurationCalled).to(beTrue())
            }
        }

        describe("flush()") {
            it("calls the agent") {
                Birch.flush()
                expect(agent.flushCalled).to(beTrue())
            }
        }

        describe("t(String)") {
            it("calls the agent") {
                Birch.t("message")
                expect(agent.tStringCalled).to(beTrue())
            }
        }

        describe("t(block)") {
            it("calls the agent") {
                Birch.t { "message" }
                expect(agent.tBlockCalled).to(beTrue())
            }
        }

        describe("d(String)") {
            it("calls the agent") {
                Birch.d("message")
                expect(agent.dStringCalled).to(beTrue())
            }
        }

        describe("d(block)") {
            it("calls the agent") {
                Birch.d { "message" }
                expect(agent.dBlockCalled).to(beTrue())
            }
        }

        describe("i(String)") {
            it("calls the agent") {
                Birch.i("message")
                expect(agent.iStringCalled).to(beTrue())
            }
        }

        describe("i(block)") {
            it("calls the agent") {
                Birch.i { "message" }
                expect(agent.iBlockCalled).to(beTrue())
            }
        }

        describe("w(String)") {
            it("calls the agent") {
                Birch.w("message")
                expect(agent.wStringCalled).to(beTrue())
            }
        }

        describe("w(block)") {
            it("calls the agent") {
                Birch.w { "message" }
                expect(agent.wBlockCalled).to(beTrue())
            }
        }

        describe("e(String)") {
            it("calls the agent") {
                Birch.e("message")
                expect(agent.eStringCalled).to(beTrue())
            }
        }

        describe("e(block)") {
            it("calls the agent") {
                Birch.e { "message" }
                expect(agent.eBlockCalled).to(beTrue())
            }
        }
    }
}
