//
//  TestHTTP.swift
//  Birch-Unit-Tests
//
//  Created by Ryan Fung on 11/22/22.
//

import Foundation

@testable import Birch

class TestHTTP: HTTP {
    let testSession: TestSession

    init() {
        testSession = TestSession()
        super.init(session: testSession)
    }
}
