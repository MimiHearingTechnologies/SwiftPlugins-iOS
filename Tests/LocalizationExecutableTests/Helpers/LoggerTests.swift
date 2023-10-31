//
//  LoggerTests.swift
//  
//
//  Created by Salar on 10/31/23.
//

import XCTest
@testable import LocalizationExecutable

final class LoggerTests: XCTestCase {

    func test_generateReport_returnsEmptyOnEmptyReportLog() {
        let sut = Logger()
        sut.log("test")
        let result = sut.generateReport()
        XCTAssertTrue(result.isEmpty)
    }
    
    func test_generateReport_returnsReportLogs() {
        let sut = Logger()
        sut.log("test", type: .report)
        sut.log("test1", type: .debug)
        sut.log("test2", type: .report)
        
        let result = sut.generateReport()
        
        XCTAssertEqual(result, "test\ntest2")
    }
}
