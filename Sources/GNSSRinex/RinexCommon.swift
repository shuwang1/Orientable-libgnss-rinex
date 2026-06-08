//
//  RinexCommon.swift
//  GNSSRinex
//

import Foundation

internal struct RinexCommon {
    
    static let syscodes = "GREJSC"
    static let obscodes = "CLDS"
    static let frqcodes = "125678"
    
    static let ura_eph: [Double] = [
        2.4, 3.4, 4.85, 6.85, 9.65, 13.65, 24.0, 48.0, 96.0, 192.0, 384.0, 768.0, 1536.0,
        3072.0, 6144.0, 0.0
    ]
    
    /// Equivalent to setstr: get a substring of length n and trim trailing spaces.
    static func setStr<S: StringProtocol>(_ src: S, length: Int) -> String {
        let prefix = String(src.prefix(length))
        var res = prefix
        while res.hasSuffix(" ") {
            res.removeLast()
        }
        return res
    }
    
    /// Adjust time considering week handover
    static func adjDay(t: GTime, t0: GTime) -> GTime {
        let tt = t.diff(to: t0)
        if tt < -43200.0 { return t.add(sec: 86400.0) }
        if tt > 43200.0 { return t.add(sec: -86400.0) }
        return t
    }
    
    /// Time string for ver.3 (yyyymmdd hhmmss UTC)
    static func timeStrRnx() -> String {
        var time = GTime.timeget()
        time.sec = 0.0
        let ep = time.toEpoch()
        return String(format: "%04.0f%02.0f%02.0f %02.0f%02.0f%02.0f UTC", ep[0], ep[1], ep[2], ep[3], ep[4], ep[5])
    }
    
    /// Satellite to satellite code
    static func sat2Code(_ sat: Int) -> String {
        let (sys, prn) = GNSSCommon.satSys(sat)
        switch sys {
        case .gps: return String(format: "G%02d", prn - GNSSConstants.minPrnGPS + 1)
        case .glo: return String(format: "R%02d", prn - GNSSConstants.minPrnGLO + 1)
        case .gal: return String(format: "E%02d", prn - GNSSConstants.minPrnGAL + 1)
        case .sbs: return String(format: "S%02d", prn - 100)
        case .qzs: return String(format: "J%02d", prn - GNSSConstants.minPrnQZS + 1)
        case .cmp: return String(format: "C%02d", prn - GNSSConstants.minPrnCMP + 1)
        default: return ""
        }
    }
    
    /// URA index to URA value (m)
    static func uraValue(_ sva: Int) -> Double {
        if sva >= 0 && sva < 15 {
            return ura_eph[sva]
        }
        return 32767.0
    }
    
    /// URA value (m) to URA index
    static func uraIndex(_ value: Double) -> Int {
        for i in 0..<15 {
            if ura_eph[i] >= value {
                return i
            }
        }
        return 15
    }
}
