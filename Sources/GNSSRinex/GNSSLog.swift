//
//  GNSSLog.swift
//  GNSSRinex
//

import Foundation

public enum GNSSLogLevel: Int, Comparable {
    case none = 0
    case error = 1
    case warn = 2
    case info = 3
    case debug = 4
    case trace = 5
    
    public static func < (lhs: GNSSLogLevel, rhs: GNSSLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
}

public struct GNSSLog {
    
    /// Global log level filter
    nonisolated(unsafe) public static var level: GNSSLogLevel = .trace
    
    /// Optional custom handler
    nonisolated(unsafe) public static var handler: ((GNSSLogLevel, String, Int, String) -> Void)?
    
    private static let tags = ["---", "ERR", "WRN", "INF", "DBG", "TRC"]
    
    /// Main trace function
    public static func trace(_ lvl: GNSSLogLevel, file: String = #file, line: Int = #line, _ message: @autoclosure () -> String) {
        if lvl > level || lvl < .error { return }
        
        let msg = message()
        if let handler = handler {
            handler(lvl, file, line, msg)
        } else {
            let tag = tags[lvl.rawValue]
            let filename = (file as NSString).lastPathComponent
            print("[\(tag)] \(filename):\(line): \(msg)")
        }
    }
    
    /// Dump a matrix to log
    public static func traceMat(_ lvl: GNSSLogLevel, A: [Double], n: Int, m: Int, p: Int, q: Int, file: String = #file, line: Int = #line) {
        if lvl > level || lvl < .error { return }
        
        var output = ""
        for i in 0..<n {
            for j in 0..<m {
                let value = A[i + j * n]
                // Basic formatting replacing %*.*f
                let formatString = String(format: " %\(p).\(q)f", value)
                output += formatString
            }
            output += "\n"
        }
        
        if let handler = handler {
            handler(lvl, file, line, output)
        } else {
            print(output, terminator: "")
        }
    }
    
    /// Dump raw bytes
    public static func traceB(_ lvl: GNSSLogLevel, p: [UInt8], file: String = #file, line: Int = #line) {
        if lvl > level || lvl < .error { return }
        
        var output = ""
        for i in 0..<p.count {
            output += String(format: "%02X%@", p[i], (i % 8 == 7) ? " " : "")
        }
        output += "\n"
        
        if let handler = handler {
            handler(lvl, file, line, output)
        } else {
            print(output, terminator: "")
        }
    }
}
