//
//  GTime.swift
//  GNSSRinex
//

import Foundation

public struct GTime: Equatable, Comparable, Sendable {
    public var time: Int // time_t equivalent (Unix timestamp)
    public var sec: Double
    
    public init(time: Int = 0, sec: Double = 0.0) {
        self.time = time
        self.sec = sec
    }
    
    public init(epoch ep: [Double]) {
        if ep.count < 6 {
            self.time = 0
            self.sec = 0.0
            return
        }
        let doy = [1, 32, 60, 91, 121, 152, 182, 213, 244, 274, 305, 335]
        let year = Int(ep[0])
        let mon = Int(ep[1])
        let day = Int(ep[2])
        
        if year < 1970 || year > 2099 || mon < 1 || mon > 12 {
            self.time = 0
            self.sec = 0.0
            return
        }
        
        let isLeap = (year % 4 == 0 && mon >= 3) ? 1 : 0
        let days = (year - 1970) * 365 + (year - 1969) / 4 + doy[mon - 1] + day - 2 + isLeap
        let secInt = Int(floor(ep[5]))
        
        self.time = days * 86400 + Int(ep[3]) * 3600 + Int(ep[4]) * 60 + secInt
        self.sec = ep[5] - Double(secInt)
    }
    
    public static func < (lhs: GTime, rhs: GTime) -> Bool {
        if lhs.time != rhs.time {
            return lhs.time < rhs.time
        }
        return lhs.sec < rhs.sec
    }
    
    public func add(sec: Double) -> GTime {
        var t = self
        t.sec += sec
        let tt = floor(t.sec)
        t.time += Int(tt)
        t.sec -= tt
        return t
    }
    
    public func diff(to t2: GTime) -> Double {
        return Double(self.time - t2.time) + self.sec - t2.sec
    }
    
    public func toEpoch() -> [Double] {
        let mday = [
            31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
            31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
            31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31,
            31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
        ]
        var ep = [Double](repeating: 0.0, count: 6)
        let days = Int(self.time / 86400)
        let secInt = Int(self.time - days * 86400)
        
        var day = days % 1461
        var mon = 0
        while mon < 48 {
            if day >= mday[mon] {
                day -= mday[mon]
                mon += 1
            } else {
                break
            }
        }
        
        ep[0] = Double(1970 + days / 1461 * 4 + mon / 12)
        ep[1] = Double(mon % 12 + 1)
        ep[2] = Double(day + 1)
        ep[3] = Double(secInt / 3600)
        ep[4] = Double((secInt % 3600) / 60)
        ep[5] = Double(secInt % 60) + self.sec
        return ep
    }
    
    public static func str2time(s: String, i: Int, n: Int) -> GTime? {
        if i < 0 || n <= 0 || i + n > s.count { return nil }
        
        let start = s.index(s.startIndex, offsetBy: i)
        let end = s.index(start, offsetBy: n)
        let substr = String(s[start..<end])
        
        let parts = substr.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        if parts.count < 6 { return nil }
        
        var ep = [Double](repeating: 0.0, count: 6)
        for j in 0..<6 {
            if let val = Double(parts[j]) {
                ep[j] = val
            } else {
                return nil
            }
        }
        if ep[0] < 100.0 {
            ep[0] += ep[0] < 80.0 ? 2000.0 : 1900.0
        }
        return GTime(epoch: ep)
    }
    
    public func time2str(n: Int) -> String {
        var t = self
        var nVar = n
        if nVar < 0 { nVar = 0 }
        else if nVar > 12 { nVar = 12 }
        
        if 1.0 - t.sec < 0.5 / pow(10.0, Double(nVar)) {
            t.time += 1
            t.sec = 0.0
        }
        
        let ep = t.toEpoch()
        let fmt = String(format: "%%04.0f/%%02.0f/%%02.0f %%02.0f:%%02.0f:%%0%d.%df", nVar <= 0 ? 2 : nVar + 3, nVar <= 0 ? 0 : nVar)
        return String(format: fmt, ep[0], ep[1], ep[2], ep[3], ep[4], ep[5])
    }
    
    nonisolated(unsafe) public static var timeoffset: Double = 0.0
    
    public static func timeget() -> GTime {
        let interval = Date().timeIntervalSince1970
        let sec = Int(floor(interval))
        let frac = interval - Double(sec)
        
        var t = GTime()
        t.time = sec
        t.sec = frac
        return t.add(sec: timeoffset)
    }
    
    // MARK: - GNSS Time Systems
    
    private static let gpst0: [Double] = [1980, 1, 6, 0, 0, 0]
    private static let bdt0: [Double] = [2006, 1, 1, 0, 0, 0]
    private static let leaps: [[Double]] = [
        [2017, 1, 1, 0, 0, 0, -18],
        [2015, 7, 1, 0, 0, 0, -17],
        [2012, 7, 1, 0, 0, 0, -16],
        [2009, 1, 1, 0, 0, 0, -15],
        [2006, 1, 1, 0, 0, 0, -14],
        [1999, 1, 1, 0, 0, 0, -13],
        [1997, 7, 1, 0, 0, 0, -12],
        [1996, 1, 1, 0, 0, 0, -11],
        [1994, 7, 1, 0, 0, 0, -10],
        [1993, 7, 1, 0, 0, 0, -9],
        [1992, 7, 1, 0, 0, 0, -8],
        [1991, 1, 1, 0, 0, 0, -7],
        [1990, 1, 1, 0, 0, 0, -6],
        [1988, 1, 1, 0, 0, 0, -5],
        [1985, 7, 1, 0, 0, 0, -4],
        [1983, 7, 1, 0, 0, 0, -3],
        [1982, 7, 1, 0, 0, 0, -2],
        [1981, 7, 1, 0, 0, 0, -1]
    ]
    
    public static let t_gpst0 = GTime(epoch: gpst0)
    public static let t_bdt0 = GTime(epoch: bdt0)
    public static let leapsCache: [(time: GTime, offset: Double)] = leaps.map { (GTime(epoch: $0), $0[6]) }
    
    public func time2gpst() -> (tow: Double, week: Int) {
        let sec = Double(self.time - GTime.t_gpst0.time)
        let w = Int(sec / (86400.0 * 7.0))
        let tow = sec - Double(w) * 86400.0 * 7.0 + self.sec
        return (tow, w)
    }
    
    public static func gpst2time(week: Int, sec: Double) -> GTime {
        var t = GTime.t_gpst0
        var s = sec
        if s < -1E9 || s > 1E9 { s = 0.0 }
        let secInt = Int(s)
        t.time += 86400 * 7 * week + secInt
        t.sec = s - Double(secInt)
        return t
    }
    
    public static func adjgpsweek(week: Int) -> Int {
        let utcNow = GTime.timeget()
        let (_, w) = utcNow.utc2gpst().time2gpst()
        var adjW = w
        if adjW < 1560 { adjW = 1560 } // use 2009/12/1 if time is earlier than 2009/12/1
        return week + (adjW - week + 512) / 1024 * 1024
    }
    
    public func time2bdt() -> (tow: Double, week: Int) {
        let sec = Double(self.time - GTime.t_bdt0.time)
        let w = Int(sec / (86400.0 * 7.0))
        let tow = sec - Double(w) * 86400.0 * 7.0 + self.sec
        return (tow, w)
    }
    
    public static func bdt2time(week: Int, sec: Double) -> GTime {
        var t = GTime.t_bdt0
        var s = sec
        if s < -1E9 || s > 1E9 { s = 0.0 }
        let secInt = Int(s)
        t.time += 86400 * 7 * week + secInt
        t.sec = s - Double(secInt)
        return t
    }
    
    public func gpst2utc() -> GTime {
        for (leapTime, offset) in GTime.leapsCache {
            let tu = self.add(sec: offset)
            if tu.diff(to: leapTime) >= 0.0 {
                return tu
            }
        }
        return self
    }
    
    public func utc2gpst() -> GTime {
        for (leapTime, offset) in GTime.leapsCache {
            if self.diff(to: leapTime) >= 0.0 {
                return self.add(sec: -offset)
            }
        }
        return self
    }
    
    public func gpst2bdt() -> GTime {
        return self.add(sec: -14.0)
    }
    
    public func bdt2gpst() -> GTime {
        return self.add(sec: 14.0)
    }
    
    public func screent(ts: GTime, te: GTime, tint: Double) -> Bool {
        let dttol = 0.005
        let (tow, _) = self.time2gpst()
        
        let cond1 = (tint <= 0.0 || (tow + dttol).truncatingRemainder(dividingBy: tint) <= dttol * 2.0)
        let cond2 = (ts.time == 0 || self.diff(to: ts) >= -dttol)
        let cond3 = (te.time == 0 || self.diff(to: te) < dttol)
        
        return cond1 && cond2 && cond3
    }
}
