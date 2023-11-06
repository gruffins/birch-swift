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
    override class func spec() {
        var agent: Agent!
        var source: Source!
        var logger: Logger!
        var storage: Storage!
        var network: Network!
        var eventBus: EventBus!
        var engine: Engine!
        var http: TestHTTP!

        beforeEach {
            agent = Agent(directory: "birch")
            storage = Storage(directory: "birch", defaultLevel: .error)
            logger = Logger(agent: agent, encryption: nil)
            eventBus = EventBus()
            source = Source(storage: storage, eventBus: eventBus)
            http = TestHTTP()
            network = Network(
                agent: agent,
                host: "localhost",
                apiKey: "key",
                http: http
            )
            engine = Engine(
                agent: agent,
                source: source,
                logger: logger,
                storage: storage,
                network: network,
                eventBus: eventBus,
                scrubbers: [
                    PasswordScrubber(),
                    EmailScrubber()
                ]
            )
            agent.engine = engine
            agent.debug = true
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
            context("opted in") {
                beforeEach {
                    agent.optOut = false
                }

                it("logs the message") {
                    logger.level = .trace
                    engine.log(level: .trace, message: { "message" })
                    expect(Utils.fileExists(url: logger.current)).toEventually(beTrue())
                }

                it("scrubs messages") {
                    logger.level = .trace
                    engine.log(level: .trace, message: { "https://birch.ryanfung.com/?email=abcd+test@domain.com&password=password123" })
                    expect(String(data: FileManager.default.contents(atPath: logger.current.path)!, encoding: .utf8)).toEventually(contain("email=[FILTERED]&password=[FILTERED]"))
                }

                it("returns true") {
                    logger.level = .trace
                    let result = engine.log(level: .trace, message: { "message" })
                    expect(result).to(beTrue())

                }
            }

            context("opted out") {
                beforeEach {
                    agent.optOut = true
                }

                it("returns false") {
                    logger.level = .trace
                    let result = engine.log(level: .trace, message: { "message" })
                    expect(result).to(beFalse())
                }
            }
        }

        describe("flush()") {
            var file: URL!

            beforeEach {
                file = logger.directory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
            }

            context("opted in") {
                beforeEach {
                    agent.optOut = false
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

                it("returns true") {
                    expect(engine.flush()).to(beTrue())
                }
            }

            context("opted out") {
                beforeEach {
                    agent.optOut = true
                }

                it("returns false") {
                    expect(engine.flush()).to(beFalse())
                }
            }
        }

        describe("updateSource()") {
            context("opted in") {
                beforeEach {
                    agent.optOut = false
                }

                it("returns true") {
                    expect(engine.updateSource(source: source)).to(beTrue())
                }
            }

            context("opted out") {
                beforeEach {
                    agent.optOut = true
                }

                it("doesnt update the source") {
                    expect(engine.updateSource(source: source)).to(beFalse())
                }
            }
        }

        describe("syncConfiguration()") {
            beforeEach {
                http.testSession.responseBody = Utils.dictionaryToJson(
                    input: [
                        "source_configuration": [
                            "log_level": Level.info.rawValue,
                            "flush_period_seconds": 10
                        ]
                    ]
                )!
            }

            context("opted in") {
                beforeEach {
                    agent.optOut = false
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

                it("returns true") {
                    expect(engine.syncConfiguration()).to(beTrue())
                }
            }

            context("opted out") {
                beforeEach {
                    agent.optOut = true
                }

                it("returns false") {
                    expect(engine.syncConfiguration()).to(beFalse())
                }
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
