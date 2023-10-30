//
//  Logger.swift
//
//
//  Created by Salar on 10/30/23.
//

import Foundation

class Logger {
    private var reportLog: [String] = []
    
    enum LogType {
        case report
        case debug
    }

    func log(_ message: String, type: LogType = .debug) {
        print(message)
        if type == .report {
            reportLog.append(message)
        }
    }

    func generateReport() -> String {
        return reportLog.joined(separator: "\n")
    }
}
