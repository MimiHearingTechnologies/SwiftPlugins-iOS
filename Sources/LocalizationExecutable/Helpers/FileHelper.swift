//
//  FileHelper.swift
//
//
//  Created by Salar on 10/30/23.
//

import Foundation

class FileHelper {

    typealias FileURL = (relative: String, absolute: String)
    private let logger = Logger()

    func filePaths(in directory: String, forFile name: String) -> [FileURL] {

        let manager = FileManager.default
        var files = [FileURL]()
        manager.enumerator(atPath: directory)?.forEach {
            guard
                let string = $0 as? String,
                let url = URL(string: string),
                url.lastPathComponent == name
            else { return }

            files.append((url.absoluteString, directory + "/" + url.absoluteString))
        }

        return files
    }

    func readFile(path: String) -> String? {
        try? String(contentsOfFile: path)
    }

    func writeToFile(string: String, path: String, encoding: String.Encoding) {

        do {
            try string.write(
                toFile: path,
                atomically: true,
                encoding: encoding
            )
        } catch {
            if (error as NSError).code == 4 { // directory does not exist
                do {
                    let url = URL(fileURLWithPath: path).deletingLastPathComponent()
                    try FileManager.default.createDirectory(
                        atPath: url.absoluteString.replacingOccurrences(of: "file://", with: ""),
                        withIntermediateDirectories: true,
                        attributes: nil
                    )
                    writeToFile(string: string, path: path, encoding: encoding)
                } catch {
                    logger.log("\(error)")
                    logger.log("Could not write to file: \(path)\n\(string)")
                }
            } else {
                logger.log("Could not write to file: \(path)\n\(string)")
            }
        }
    }
}
