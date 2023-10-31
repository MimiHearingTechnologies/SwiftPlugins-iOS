//
//  ShellExecutorTests.swift
//  
//
//  Created by Kosta Nedeljkovic on 27/10/2023.
//

import XCTest
@testable import Execution

#if os(macOS)
final class ShellExecutorTests: XCTestCase {

    func test_execute_throwsErrorWithInvalidExecutablePath() {
        let executor = ShellExecutor(executablePath: "/invalidPath")

        do {
            try executor.execute(ShellCommand(commandPath: "random", arguments: ""))
            XCTFail("Expected `Execution.executableNotFound` error")
        } catch {
            XCTAssertEqual(error as! ExecutionError, ExecutionError.executableNotFound)
        }
    }

    func test_execute_throwsErrorWithInvalidCommandPath() {
        let executor = ShellExecutor(executablePath: "/bin/zsh")

        do {
            try executor.execute(ShellCommand(commandPath: "nonexistent", arguments: ""))
            XCTFail("Expected `Execution.commandNotFound` error")
        } catch {
            XCTAssertEqual(error as! ExecutionError, ExecutionError.commandNotFound)
        }
    }
}
#endif
