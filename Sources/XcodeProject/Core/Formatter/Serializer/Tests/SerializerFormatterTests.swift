//
//  SerializerFormatterTests.swift
//  XcodeProjectTests
//
//  Created by Yudai Hirose on 2019/07/22.
//

import XCTest
@testable import XcodeProject

class SerializerFormatterTests: XCTestCase {
    
    func make() -> FieldListFormatterImpl {
        return makeFieldFormatter()
    }
    
    func testEscape() {
        XCTContext.runActivity(named: "A", block: { _ in
            do {
                let formatter = make()
                let input = "\"# Type a script or drag a script file from your workspace to insert its path.\necho \"Script\"\n\""
                let expected = "\"\\\"# Type a script or drag a script file from your workspace to insert its path.\\necho \\\"Script\\\"\\n\\\"\""
                let got = try formatter.escape(with: input)

                XCTAssertEqual(got, expected)
            } catch {
                XCTFail(error.localizedDescription)
            }
        })
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
