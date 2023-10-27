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

    func test_executeNonexistentExecutable() {
        let executor = ShellExecutor(executablePath: "/nonexistent")

        do {
            try executor.execute(ShellCommand(commandPath: "random", arguments: ""))
        } catch {
            XCTAssertEqual(error as! ExecutionError, ExecutionError.executableNotFound)
            return
        }

        XCTFail("Expected `Execution.executableNotFound` error")
    }

    func test_executeNonexistentCommand() {
        let executor = ShellExecutor(executablePath: "/bin/zsh")

        do {
            try executor.execute(ShellCommand(commandPath: "nonexistent", arguments: ""))
        } catch {
            XCTAssertEqual(error as! ExecutionError, ExecutionError.commandNotFound)
            return
        }

        XCTFail("Expected `Execution.commandNotFound` error")
    }

}
#endif
