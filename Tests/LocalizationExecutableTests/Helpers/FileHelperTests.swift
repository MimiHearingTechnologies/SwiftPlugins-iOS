//
//  FileHelperTests.swift
//  
//
//  Created by Salar on 10/30/23.
//

import XCTest
@testable import LocalizationExecutable

final class FileHelperTests: XCTestCase {

    // MARK: Properties
    
    private let fileManager = FileManager.default
    private var tempPath: String {
        return fileManager.temporaryDirectory.path
    }
    private let fileName = "test"
    private var fullPath: String {
        tempPath + "/\(fileName)"
    }
    
    // MARK: Lifecycle
    
    override func setUp() {
        super.setUp()
        clearPathDirectory()
    }
    
    override func tearDown() {
        super.tearDown()
       clearPathDirectory()
    }
    
    // MARK: Tests
    
    func test_writeToFile_createsFile() {
        let sut = FileHelper()
        sut.writeToFile(string: "test", path: fullPath, encoding: .utf8)
        if fileManager.fileExists(atPath: fullPath) {
            XCTAssertTrue(true)
        } else {
            XCTFail("File does not exist")
        }
    }
    
    func test_filePaths_returnsEmptyArrayIfFileDoesntExist() throws {
        let sut = FileHelper()

        let paths = sut.filePaths(in: tempPath, forFile: fileName)
        XCTAssertTrue(paths.isEmpty)

    }
    
    func test_filePaths_returnsArrayOfFileURL() throws {
        let sut = FileHelper()
        try "test".write(toFile: fullPath, atomically: true, encoding: .utf8)
        
        let paths = sut.filePaths(in: tempPath, forFile: fileName)
        XCTAssertFalse(paths.isEmpty)
    }
    
    func test_readFile_returnsNilIfFileDoesntExist() {
        let sut = FileHelper()
        
        let data = sut.readFile(path: fullPath)
        XCTAssertNil(data)
    }
    
    func test_readFile_returnsContentOfFile() throws {
        let sut = FileHelper()
        let content = "File content"
        try content.write(toFile: fullPath, atomically: true, encoding: .utf8)
        
        let data = sut.readFile(path: fullPath)
        XCTAssertEqual(data, content)
    }

    // MARK: - Helpers
    private func clearPathDirectory() {
        do {
            if fileManager.fileExists(atPath: fullPath) {
                try fileManager.removeItem(atPath: fullPath)
                XCTAssertFalse(fileManager.fileExists(atPath: fullPath))
            }
        } catch {
            XCTFail("Error while deleting temporary file: \(error)")
        }
    }
}
