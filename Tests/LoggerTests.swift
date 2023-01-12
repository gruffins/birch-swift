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
            logger = Logger(encryption: nil)
        }

        afterEach {
            Utils.safeIgnore {
                try FileManager.default.contentsOfDirectory(
                    at: logger.directory,
                    includingPropertiesForKeys: []
                ).forEach { Utils.deleteFile(url: $0) }
            }

            Birch.debug = false
            Birch.console = false
            Birch.remote = true
            Birch.level = nil
            Birch.synchronous = false
        }

        describe("nonCurrentFiles()") {
            it("returns all non current files") {
                let other = logger.directory.appendingPathComponent("\(Int(Date().timeIntervalSince1970))")
                Utils.createFile(url: logger.current)
                Utils.createFile(url: other)
                expect(logger.nonCurrentFiles).to(containElementSatisfying { $0.lastPathComponent == other.lastPathComponent })
                expect(logger.nonCurrentFiles).notTo(containElementSatisfying { $0.lastPathComponent == logger.current.lastPathComponent })
            }
        }

        describe("log()") {
            beforeEach {
                Birch.synchronous = true
            }

            it("logs if local level overridden") {
                Birch.level = .trace
                logger.level = .none
                logger.log(level: .trace, block: { "message" }, original: { "message" })
                expect(Utils.fileExists(url: logger.current)).to(beTrue())
            }

            it("skips logs lower than the current level") {
                logger.level = .none
                logger.log(level: .trace, block: { "message" }, original: { "message "})
                expect(Utils.fileExists(url: logger.current)).to(beFalse())
            }

            it("doesnt skip logs higher than the current level") {
                logger.level = .trace
                logger.log(level: .trace, block: { "message" }, original: { "message" })
                expect(Utils.fileExists(url: logger.current)).to(beTrue())
            }

            describe("with console") {
                it("logs") {
                    Birch.level = .trace
                    Birch.console = true
                    
                    var calls: [Level: Bool] = [
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

                    expect(calls[.trace]).to(beTrue())
                    expect(calls[.debug]).to(beTrue())
                    expect(calls[.info]).to(beTrue())
                    expect(calls[.warn]).to(beTrue())
                    expect(calls[.error]).to(beTrue())
                }
            }

            context("with encryption") {
                beforeEach {
                    logger = Logger(
                        encryption: Encryption.create(
                            publicKey: EncryptionTests.Constants.PUBLIC_KEY
                        )
                    )
                }

                it("encrypts the logs") {
                    Utils.deleteFile(url: logger.current)
                    logger.level = .trace
                    logger.log(level: .trace, block: { "message" }, original: { "message" })
                    expect(Utils.fileExists(url: logger.current)).to(beTrue())
                    waitUntil(timeout: .seconds(5)) { done in
                        if let contents = try? String(contentsOf: logger.current, encoding: .utf8), !contents.isEmpty {
                            expect(contents).notTo(contain("message"))
                            done()
                        }
                    }
                }
            }

            context("without encryption") {
                it("writes in plain text") {
                    logger.level = .trace
                    logger.log(level: .trace, block: { "message" }, original: { "message" })
                    expect(Utils.fileExists(url: logger.current)).toEventually(beTrue())
                    let contents = try String(contentsOf: logger.current, encoding: .utf8)
                    expect(contents).notTo(contain("em"))
                    expect(contents).notTo(contain("ek"))
                }
            }

            context("with remote disabled") {
                it("doesnt write to disk") {
                    Birch.remote = false
                    logger.level = .trace
                    logger.log(level: .trace, block: { "message" }, original: { "message" })
                    expect(Utils.fileExists(url: logger.current)).to(beTrue())
                    let contents = try String(contentsOf: logger.current, encoding: .utf8)
                    expect(contents).to(beEmpty())
                }
            }

            context("synchronously") {
                it("logs") {
                    Birch.synchronous = true
                    logger.level = .trace
                    logger.log(level: .trace, block: { "message" }, original: { "message" })
                    expect(Utils.fileExists(url: logger.current)).to(beTrue())
                }
            }
        }

        describe("rollFile()") {
            it("moves the current file to another file") {
                Utils.createFile(url: logger.current)
                logger.rollFile()
                expect(logger.nonCurrentFiles).notTo(beEmpty())
            }
        }
    }
}
