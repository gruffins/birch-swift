//
//  NetworkTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class NetworkTests: QuickSpec {
    override class func spec() {
        var agent: Agent!
        var http: TestHTTP!
        var network: Network!

        beforeEach {
            agent = Agent(directory: "birch")
            http = TestHTTP()
            network = Network(
                agent: agent,
                host: "localhost",
                apiKey: "key",
                http: http
            )
            agent.debug = true
        }

        describe("uploadLogs()") {
            var file: URL!

            beforeEach {
                file = FileManager.default.temporaryDirectory.appendingPathComponent("file")
                Utils.createFile(url: file)
            }

            it("doesnt call callback on unauthorized") {
                http.testSession.statusCode = 401
                try network.uploadLogs(url: file) { _ in
                    fail("should not have been called")
                }
            }

            it("calls the callback on any other response") {
                http.testSession.statusCode = 201
                waitUntil { done in
                    Utils.safeIgnore {
                        try network.uploadLogs(url: file) { success in
                            expect(success).to(beTrue())
                            done()
                        }
                    }
                }
            }
        }

        describe("syncSource()") {
            var source: Source!

            beforeEach {
                source = Source(
                    storage: Storage(directory: "birch", defaultLevel: .error),
                    eventBus: EventBus()
                )
            }

            it("doesnt call callback on unauthorized") {
                http.testSession.statusCode = 401
                network.syncSource(source: source) {
                    fail("should not have been called")
                }
            }

            it("calls the callback on any other response") {
                http.testSession.statusCode = 500
                waitUntil { done in
                    network.syncSource(source: source) {
                        expect(true).to(beTrue())
                        done()
                    }
                }
            }
        }

        describe("getConfiguration()") {
            var source: Source!

            beforeEach {
                source = Source(
                    storage: Storage(directory: "birch", defaultLevel: .error),
                    eventBus: EventBus()
                )
            }

            it("doesnt call callback on unauthorized") {
                http.testSession.statusCode = 401
                network.getConfiguration(source: source) { dict in
                    fail("should not have been called")
                }
            }

            it("calls the callback on any other response") {
                http.testSession.statusCode = 200
                http.testSession.responseBody = Utils.dictionaryToJson(
                    input: [
                        "source_configuration": [
                            "log_level": Level.info.rawValue,
                            "flush_period_seconds": 10
                        ]
                    ]
                )!

                waitUntil { done in
                    network.getConfiguration(source: source) { dict in
                        expect(dict).notTo(beNil())
                        done()
                    }
                }
            }
        }
    }
}
