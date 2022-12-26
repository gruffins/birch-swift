//
//  EncryptionTests.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 12/15/22.
//

import Foundation
import Quick
import Nimble

@testable import Birch

class EncryptionTests: QuickSpec {
    struct Constants {
        static let PUBLIC_KEY = "LS0tLS1CRUdJTiBQVUJMSUMgS0VZLS0tLS0KTUlJQklqQU5CZ2txaGtpRzl3MEJBUUVGQUFPQ0FROEFNSUlCQ2dLQ0FRRUE2aEVvZlV0VmY3dHhZMVZDNUhNSwpSVVpYRk1FNWN1V3lCTlJKZU1RRmlPK1NnWGlodGNESmx3VzhGeGJaQUlUTWF1azhzay9VTndTZlRXcWcxOXVqCkNrdklkaVVqaWdjSmQyQWZJd0pIWlRJUWRkUjh3dnhzSnNTYTJyVnl4ZUxNZ0VWNExXZGx5Q0l4VUJBWURlSy8KUWZScGJlT21xdmVBMGNDNlVGc2R4R1F0NEJiWVp2YjMycVlEU1c1OExMMXRiQThpN002dE5wZXpaY1JtOVhIWAo1c1dDNDc2RmRGRjhQVWU5a0RRSFpEc3cxK0dWM0RGeW9JWmE1WklSWmFuYkhxY2plRTlLWXgxclNHa1VkT3dhCncwb1piODZQUzlJT2E3cjNHNGxpaDZMdkRLRlAwamxvVHVqTFdUMzhBRzg3TzcrYTFXdHZjS2ZOUUt2OHU0S24KZXdJREFRQUIKLS0tLS1FTkQgUFVCTElDIEtFWS0tLS0tCg=="
    }

    override func spec() {
        var encryption: Encryption!

        beforeEach {
            encryption = Encryption.create(publicKey: Constants.PUBLIC_KEY)
        }

        describe("encryptedKey()") {
            it("returns an encrypted symmetric key") {
                expect(encryption.encryptedKey).notTo(beNil())
            }
        }

        describe("encrypt()") {
            it("returns an encrypted version") {
                let input = "test"
                expect(encryption.encrypt(input: input)).notTo(equal("test"))
            }

            it("can reuse encryption") {
                let input = "test"
                let output = encryption.encrypt(input: input)
                expect(encryption.encrypt(input: input)).notTo(equal(output))
            }
        }
    }
}
