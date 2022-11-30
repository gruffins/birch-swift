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
    private class TestEngine: EngineProtocol {
        let source: Source = Source(storage: Storage(), eventBus: EventBus())

        var startCalled = false
        var logCalled = false
        var flushCalled = false
        var updateSourceCalled = false
        var syncConfigurationCalled = false


        func start() {
            startCalled = true
        }

        func log(level: Logger.Level, message: @escaping () -> String) -> Bool {
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

    override func spec() {
        var engine: TestEngine!

        beforeEach {
            engine = TestEngine()
            Birch.engine = engine
        }

        afterEach {
            Birch.engine = nil
            Birch.host = nil
            Birch.debug = false
        }

        describe("debug()") {
            context("is true") {
                it("sets flush period to 30") {
                    Birch.debug = true
                    expect(Birch.flushPeriod).to(equal(30))
                }

                it("calls engine.syncConfiguration()") {
                    Birch.debug = true
                    expect(engine.syncConfigurationCalled).to(beTrue())
                }
            }

            context("is false") {
                it("sets flush period to nil") {
                    Birch.debug = false
                    expect(Birch.flushPeriod).to(beNil())
                }

                it("calls engine.syncConfiguration()") {
                    Birch.debug = false
                    expect(engine.syncConfigurationCalled).to(beTrue())
                }
            }
        }

        describe("optOut()") {
            it("gets and sets") {
                Birch.optOut = true
                expect(Birch.optOut).to(beTrue())
            }
        }

        describe("host()") {
            context("set to nil") {
                it("sets Network.Constants.HOST to be default host") {
                    Birch.host = nil
                    expect(Network.Constants.HOST).to(equal(Network.Constants.DEFAULT_HOST))
                }
            }

            context("set to empty") {
                it("sets Network.Constants.HOST to be default host") {
                    Birch.host = ""
                    expect(Network.Constants.HOST).to(equal(Network.Constants.DEFAULT_HOST))
                }
            }

            context("set to value") {
                it("sets Network.Constants.HOST to be the value") {
                    Birch.host = "localhost"
                    expect(Network.Constants.HOST).to(equal("localhost"))
                }
            }

            it("returns the host") {
                expect(Birch.host).to(equal(Network.Constants.HOST))
            }
        }

        describe("uuid()") {
            it("returns the source uuid") {
                expect(Birch.uuid).to(equal(engine.source.uuid))
            }
        }

        describe("identifier()") {
            it("gets from the source") {
                engine.source.identifier = "test"
                expect(Birch.identifier).to(equal("test"))
            }

            it("sets the source") {
                Birch.identifier = "test"
                expect(engine.source.identifier).to(equal("test"))
            }
        }

        describe("customProperties") {
            describe("get()") {
                context("nil custom properties") {
                    it("returns empty dict") {
                        engine.source.customProperties = nil
                        expect(Birch.customProperties).to(beEmpty())
                    }
                }

                context("existing custom properties") {
                    it("returns source dict") {
                        engine.source.customProperties = ["key": "value"]
                        expect(Birch.customProperties["key"]).to(equal("value"))
                    }
                }
            }

            describe("set()") {
                it("sets the source") {
                    Birch.customProperties = ["key": "value"]
                    expect(engine.source.customProperties!["key"]).to(equal("value"))
                }
            }
        }

        describe("flush()") {
            it("calls engine") {
                Birch.flush()
                expect(engine.flushCalled).to(beTrue())
            }
        }

        describe("t(String)") {
            it("calls engine") {
                Birch.t("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("t(Block)") {
            it("calls the engine") {
                Birch.t { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("d(String)") {
            it("calls engine") {
                Birch.d("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("d(Block)") {
            it("calls the engine") {
                Birch.d { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("i(String)") {
            it("calls engine") {
                Birch.i("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("i(Block)") {
            it("calls the engine") {
                Birch.i { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("w(String)") {
            it("calls engine") {
                Birch.w("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("w(Block)") {
            it("calls the engine") {
                Birch.w { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("e(String)") {
            it("calls engine") {
                Birch.e("message")
                expect(engine.logCalled).to(beTrue())
            }
        }

        describe("e(Block)") {
            it("calls the engine") {
                Birch.e { "message" }
                expect(engine.logCalled).to(beTrue())
            }
        }
    }
}
