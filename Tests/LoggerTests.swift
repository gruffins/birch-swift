//
//  LoggerTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class LoggerTests: QuickSpec {
    override func spec() {
        var logger: Logger!

        beforeEach {
            logger = Logger()
        }

        afterEach {
            Utils.safeIgnore {
                try FileManager.default.contentsOfDirectory(
                    at: logger.directory,
                    includingPropertiesForKeys: []
                ).forEach { Utils.deleteFile(url: $0) }
            }

            Birch.debug = false
        }

        describe("nonCurrentFiles()") {
            it("returns all non current files") {
                let other = logger.directory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
                Utils.createFile(url: logger.current)
                Utils.createFile(url: other)
                expect(logger.nonCurrentFiles).to(contain(other))
                expect(logger.nonCurrentFiles).notTo(contain(logger.current))
            }
        }

        describe("log()") {
            it("logs any level with debug") {
                Birch.debug = true
                logger.level = .none
                logger.log(level: .trace, block: { "message" }, original: { "message" })
                expect(Utils.fileExists(url: logger.current)).toEventually(beTrue())
            }

            it("skips logs lower than the current level") {
                logger.level = .none
                logger.log(level: .trace, block: { "message" }, original: { "message "})
                expect(Utils.fileExists(url: logger.current)).toEventually(beFalse())
            }

            it("doesnt skip logs higher than the current level") {
                logger.level = .trace
                logger.log(level: .trace, block: { "message" }, original: { "message" })
                expect(Utils.fileExists(url: logger.current)).toEventually(beTrue())
            }

            describe("with debug") {
                it("logs all levels") {
                    Birch.debug = true
                    
                    var calls: [Logger.Level: Bool] = [
                        .trace: false,
                        .debug: false,
                        .info: false,
                        .warn: false,
                        .error: false
                    ]

                    let block = { "" }

                    logger.log(level: .trace, block: block) {
                        calls[.trace] = true
                        return ""
                    }
                    logger.log(level: .debug, block: block) {
                        calls[.debug] = true
                        return ""
                    }
                    logger.log(level: .info, block: block) {
                        calls[.info] = true
                        return ""
                    }
                    logger.log(level: .warn, block: block) {
                        calls[.warn] = true
                        return ""
                    }
                    logger.log(level: .error, block: block) {
                        calls[.error] = true
                        return ""
                    }
                    logger.log(level: .none, block: block, original: block)

                    expect(calls[.trace]).toEventually(beTrue())
                    expect(calls[.debug]).toEventually(beTrue())
                    expect(calls[.info]).toEventually(beTrue())
                    expect(calls[.warn]).toEventually(beTrue())
                    expect(calls[.error]).toEventually(beTrue())
                }
            }
        }

        describe("rollFile()") {
            it("moves the current file to another file") {
                Utils.createFile(url: logger.current)
                logger.rollFile()
                expect(logger.nonCurrentFiles).toEventuallyNot(beEmpty())
            }
        }
    }
}
