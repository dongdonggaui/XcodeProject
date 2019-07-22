//
//  TestHelper.swift
//  XcodeProjectTests
//
//  Created by Yudai Hirose on 2019/07/10.
//

import Foundation
import XCTest
@testable import XcodeProject

func xcodeProjectUrl() -> URL {
    guard
        let testPath = ProcessInfo().environment["PBXProjectPath"],
        let url = URL(string: "file://" + testPath)
        else {
            XCTFail("Should set environment PBXProjectPath.")
            fatalError()
    }
    
    return url
}

func makeContextAndXcodeProject() -> (Context, XcodeProject) {
    do {
        let parser = try PBXProjectParser(xcodeprojectUrl: xcodeProjectUrl())
        let project = XcodeProject(
            parser: parser,
            hashIDGenerator: PBXObjectHashIDGenerator()
        )
        return (parser.context(), project)
    } catch {
        XCTFail(error.localizedDescription)
        fatalError()
    }
}

func makeXcodeProject() -> XcodeProject {
    let (_, proejct) = makeContextAndXcodeProject()
    return proejct
}
extension Context {
    var grouped: [String: [PBX.Object]] {
        return self.dictionary
            .values
            .toArray()
            .groupBy { $0.isa.rawValue }
    }
}
