//
//  HTTPTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class HTTPTests: QuickSpec {
    override func spec() {
        var session: TestSession!
        var http: HTTP!
        var url: URL!

        beforeEach {
            url = URL(string: "http://localhost/")!
            session = TestSession()
            http = HTTP(session: session)
        }

        describe("get()") {
            it("calls the callback") {
                waitUntil { done in
                    http.get(url: url, headers: [:]) { response in
                        expect(response.success).to(beTrue())
                        done()
                    }
                }

            }
        }

        describe("postString()") {
            it("calls the callback") {
                waitUntil { done in
                    http.post(url: url, body: "") { response in
                        expect(response.success).to(beTrue())
                        done()
                    }
                }
            }
        }

        describe("postData()") {
            it("calls the callback") {
                waitUntil { done in
                    Utils.safeIgnore {
                        try http.post(url: url, file: Data()) { response in
                            expect(response.success).to(beTrue())
                            done()
                        }
                    }
                }
            }
        }

        describe("Response") {
            describe("unauthorized") {
                it("returns true if 401") {
                    expect(HTTP.Response(statusCode: 401, body: "").unauthorized).to(beTrue())
                }

                it("returns false if not 401") {
                    expect(HTTP.Response(statusCode: 200, body: "").unauthorized).to(beFalse())
                }
            }

            describe("success") {
                it("returns true if within success range") {
                    expect(HTTP.Response(statusCode: 201, body: "").success).to(beTrue())
                }

                it("returns false outside of success range") {
                    expect(HTTP.Response(statusCode: 500, body: "").success).to(beFalse())
                }
            }

            describe("failure") {
                it("returns true if within failure range") {
                    expect(HTTP.Response(statusCode: 400, body: "").failure).to(beTrue())
                }

                it("returns false if outside failure range") {
                    expect(HTTP.Response(statusCode: 200, body: "").failure).to(beFalse())
                }
            }
        }
    }
}
