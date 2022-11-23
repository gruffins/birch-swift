//
//  EngineTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class EngineTests: QuickSpec {
    override func spec() {
        var source: Source!
        var logger: Logger!
        var storage: Storage!
        var network: Network!
        var eventBus: EventBus!
        var engine: Engine!
        var http: TestHTTP!

        beforeEach {
            storage = Storage()
            logger = Logger()
            eventBus = EventBus()
            source = Source(storage: storage, eventBus: eventBus)
            http = TestHTTP()
            network = Network(apiKey: "key", configuration: Network.Configuration(), http: http)
            engine = Engine(
                source: source,
                logger: logger,
                storage: storage,
                network: network,
                eventBus: eventBus
            )
        }

        describe("start()") {
            it("starts the trim timer") {
                engine.start()
                expect(engine.timers[.trim]).toEventuallyNot(beNil())
            }

            it("starts the sync timer") {
                engine.start()
                expect(engine.timers[.sync]).toEventuallyNot(beNil())
            }

            it("starts the flush timer") {
                engine.start()
                expect(engine.timers[.flush]).toEventuallyNot(beNil())
            }
        }

        describe("log()") {
            it("logs the message") {
                logger.level = .trace
                engine.log(level: .trace, message: { "message" })
                expect(Utils.fileExists(url: logger.current)).toEventually(beTrue())
            }
        }

        describe("flush()") {
            var file: URL!

            beforeEach {
                file = logger.directory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
            }
            it("deletes empty files") {
                Utils.createFile(url: file)
                engine.flush()
                expect(Utils.fileExists(url: file)).toEventually(beFalse())
            }

            it("deletes files on success") {
                Utils.createFile(url: file)
                Utils.safeIgnore {
                    try "a".write(to: file, atomically: true, encoding: .utf8)
                }
                http.testSession.statusCode = 201
                engine.flush()
                expect(Utils.fileExists(url: file)).toEventually(beFalse())
            }

            it("keeps files on failure") {
                Utils.createFile(url: file)
                Utils.safeIgnore {
                    try "a".write(to: file, atomically: true, encoding: .utf8)
                }
                http.testSession.statusCode = 500
                engine.flush()
                expect(Utils.fileExists(url: file)).toEventually(beTrue())
            }
        }

        describe("updateSource()") {
            it("updates the source") {
                engine.updateSource(source: source)
            }
        }

        describe("syncConfiguration()") {
            beforeEach {
                http.testSession.responseBody = Utils.dictionaryToJson(
                    input: [
                        "log_level": Logger.Level.info.rawValue,
                        "flush_period_seconds": 10
                    ]
                )!
            }

            it("updates storage") {
                engine.syncConfiguration()
                expect(storage.logLevel).toEventually(equal(.info))
                expect(storage.flushPeriod).toEventually(equal(10))
            }

            it("updates the logger") {
                engine.syncConfiguration()
                expect(logger.level).toEventually(equal(.info))
            }

            it("updates the flush timer") {
                engine.syncConfiguration()
                expect(engine.timers[.flush]).toEventuallyNot(beNil())
            }
        }

        describe("trimFiles()") {
            it("removes files older than max age") {
                let file = logger.directory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
                Utils.createFile(url: file)

                let now = Date().addingTimeInterval(Double(Engine.Constants.MAX_FILE_AGE_SECONDS + 1))

                engine.trimFiles(now: now)

                expect(Utils.fileExists(url: file)).toEventually(beFalse())
            }

            it("keeps files less than max age") {
                let file = logger.directory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
                Utils.createFile(url: file)

                engine.trimFiles()

                expect(Utils.fileExists(url: file)).toEventually(beTrue())
            }
        }
    }
}
