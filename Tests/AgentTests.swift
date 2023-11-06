//
//  AgentTests.swift
//  Pods
//
//  Created by Ryan Fung on 1/31/23.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class AgentTests: QuickSpec {
    private class TestEngine: EngineProtocol {
        let source: Source
        let storage: Storage

        var startCalled = false
        var logCalled = false
        var flushCalled = false
        var updateSourceCalled = false
        var syncConfigurationCalled = false

        init() {
            storage = Storage(directory: "birch", defaultLevel: .error)
            source = Source(storage: storage, eventBus: EventBus())
        }

        func start() {
            startCalled = true
        }

        func log(level: Level, message: @escaping () -> String) -> Bool {
            _ = message()
            logCalled = true
            return true
        }

        func flush() -> Bool {
            flushCalled = true
            return true
        }

        func updateSource(source: Source) -> Bool {
            updateSourceCalled = true
            return true
        }

        func syncConfiguration() -> Bool {
            syncConfigurationCalled = true
            return true
        }
    }

    override class func spec() {
        var agent: Agent!
        var engine: TestEngine!

        beforeEach {
            agent = Agent(directory: "birch")
            engine = TestEngine()
            agent.engine = engine
        }

        describe("identifier()") {
            it("gets") {
                engine.source.identifier = "user_id"
                expect(agent.identifier).to(equal("user_id"))
            }

            it("sets") {
                agent.identifier = "user_id"
                expect(engine.source.identifier).to(equal("user_id"))
            }
        }

        describe("optOut()") {
            it("gets") {
                engine.storage.optOut = true
                expect(agent.optOut).to(beTrue())
            }

            it("sets") {
                agent.optOut = true
                expect(engine.storage.optOut).to(beTrue())
            }
        }

        describe("customProperties()") {
            it("gets") {
                engine.source.customProperties = ["key": "value"]
                expect(agent.customProperties["key"]).to(equal("value"))
            }

            it("sets") {
                agent.customProperties = ["key": "value"]
                expect(engine.source.customProperties?["key"]).to(equal("value"))
            }
        }

        describe("initialize()") {
            it("called twice doesnt crash") {
                agent.initialize("api_key")
                agent.initialize("api_key")
            }
        }

        describe("syncConfiguration()") {
            it("calls the engine") {
                agent.syncConfiguration()
                expect(engine.syncConfigurationCalled).to(beTrue())
            }
        }

        describe("flush()") {
            it("calls the engine") {
                agent.flush()
                expect(engine.flushCalled).to(beTrue())
            }
        }

        describe("t(String)") {
            it("calls the engine") {
                agent.t("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("t(block)") {
            it("calls the engine") {
                agent.t { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("d(String)") {
            it("calls the engine") {
                agent.d("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("d(block)") {
            it("calls the engine") {
                agent.d { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("i(String)") {
            it("calls the engine") {
                agent.i("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("i(block)") {
            it("calls the engine") {
                agent.i { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("w(String)") {
            it("calls the engine") {
                agent.w("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("w(block)") {
            it("calls the engine") {
                agent.w { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("e(String)") {
            it("calls the engine") {
                agent.e("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("e(block)") {
            it("calls the engine") {
                agent.e { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }
    }
}
