//
//  JGSourceBaseTests.swift
//  JGSourceBaseTests
//
//  Created by Mei JiGao on 2026/6/15.
//

import Testing
@testable import JGSourceBase

struct JGSourceBaseTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        
        JGSLogger.enableDebug = true
        JGSLogger.enableLog(mode: .func)
    }

}
