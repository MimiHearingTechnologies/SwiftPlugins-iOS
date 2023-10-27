//
//  ShellExecutorTests.swift
//  
//
//  Created by Kosta Nedeljkovic on 27/10/2023.
//

import XCTest

final class ShellExecutorTests: XCTestCase {

    func test_executeNonexistentExecutable() {
        let executor = ShellExecutor(executablePath: "/nonexistent")

        do {
            try executor.execute("random command")
        } catch {
            XCTAssertEqual(error as! ExecutionError, ExecutionError.executableNotFound)
            return
        }

        XCTFail("Expected `Execution.executableNotFound` error")
    }

}
