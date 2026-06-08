//
//  RinexParse.swift
//  GNSSRinex
//

import Foundation

public struct RinexParse {
    
    private class LineReader {
        private let lines: [String]
        private var currentIndex = 0
        
        init?(file: String) {
            guard let content = try? String(contentsOfFile: file, encoding: .ascii) else { return nil }
            self.lines = content.replacingOccurrences(of: "\r\n", with: "\n").components(separatedBy: "\n")
        }
        
        init(lines: [String]) {
            self.lines = lines
        }
        
        func nextLine() -> String? {
            if currentIndex < lines.count {
                var line = lines[currentIndex]
                currentIndex += 1
                if line.count < 1024 {
                    line += String(repeating: " ", count: 1024 - line.count)
                }
                return line
            }
            return nil
        }
    }
    
    private static func adjweek(t: GTime, t0: GTime) -> GTime {
        let tt = t.diff(to: t0)
        if tt < -302400.0 { return t.add(sec: 604800.0) }
        if tt > 302400.0 { return t.add(sec: -604800.0) }
        return t
    }
    
    private static func uraindex(value: Double) -> Int {
        let ura_eph: [Double] = [
            2.4, 3.4, 4.85, 6.85, 9.65, 13.65, 24.0, 48.0, 96.0, 192.0, 384.0, 768.0, 1536.0,
            3072.0, 6144.0, 0.0
        ]
        for i in 0..<15 {
            if ura_eph[i] >= value { return i }
        }
        return 15
    }

    private static func decode_eph(ver: Double, sat: Int, toc: GTime, data: [Double], eph: inout Eph) -> Bool {
        let (sys, _) = GNSSCommon.satSys(sat)
        if sys != .gps && sys != .gal && sys != .qzs && sys != .cmp {
            return false
        }
        eph = Eph()
        eph.sat = sat
        eph.toc = toc
        
        eph.f0 = data[0]; eph.f1 = data[1]; eph.f2 = data[2]
        eph.iode = Int(data[3]); eph.crs = data[4]; eph.deln = data[5]; eph.M0 = data[6]
        eph.cuc = data[7]; eph.e = data[8]; eph.cus = data[9]; eph.A = pow(data[10], 2)
        eph.toes = data[11]; eph.cic = data[12]; eph.OMG0 = data[13]; eph.cis = data[14]
        eph.i0 = data[15]; eph.crc = data[16]; eph.omg = data[17]; eph.OMGd = data[18]
        eph.idot = data[19]; eph.code = Int(data[20]); eph.week = Int(data[21]); eph.flag = Int(data[22])
        eph.sva = uraindex(value: data[23])
        eph.svh = Int(data[24])
        eph.tgd[0] = data[25]
        
        if sys == .gps || sys == .qzs {
            eph.iodc = Int(data[26])
            eph.ttr = GTime.gpst2time(week: eph.week, sec: data[27])
            eph.fit = data[28] > 0.0 ? data[28] : (eph.sva > 0 ? 4.0 : 0.0)
        } else if sys == .gal {
            eph.tgd[1] = data[26]
            eph.ttr = GTime.gpst2time(week: eph.week, sec: data[27])
            eph.fit = data[28] > 0.0 ? data[28] : 0.0
        }
        
        var toeWeek = eph.week
        var toes = eph.toes
        if toes >= 604800.0 { toeWeek += 1; toes -= 604800.0 }
        else if toes < 0.0 { toeWeek -= 1; toes += 604800.0 }
        eph.toe = GTime.gpst2time(week: toeWeek, sec: toes)
        eph.toe = adjweek(t: eph.toe, t0: toc)
        eph.ttr = adjweek(t: eph.ttr, t0: toc)
        
        return true
    }
    
    private static func convcode(ver: Double, sys: GNSSSystem, str: String, type: inout String) {
        type = "   "
        let strTrim = str.trimmingCharacters(in: .whitespaces)
        if strTrim.count < 2 { return }
        
        let s0 = String(strTrim.first!)
        let s1 = String(strTrim.dropFirst().first!)
        
        if strTrim == "P1" {
            if sys == .gps { type = "C1W" }
            else if sys == .glo { type = "C1P" }
        } else if strTrim == "P2" {
            if sys == .gps { type = "C2W" }
            else if sys == .glo { type = "C2P" }
        } else if strTrim == "C1" {
            if ver >= 2.12 { } // reject C1 for 2.12
            else if sys == .gps { type = "C1C" }
            else if sys == .glo { type = "C1C" }
            else if sys == .gal { type = "C1X" }
            else if sys == .qzs { type = "C1C" }
            else if sys == .sbs { type = "C1C" }
        } else if strTrim == "C2" {
            if sys == .gps {
                if ver >= 2.12 { type = "C2W" }
                else { type = "C2X" }
            } else if sys == .glo { type = "C2C" }
            else if sys == .qzs { type = "C2X" }
            else if sys == .cmp { type = "C1X" }
        } else if ver >= 2.12 && s1 == "A" {
            if sys == .gps || sys == .glo || sys == .qzs || sys == .sbs {
                type = s0 + "1C"
            }
        } else if ver >= 2.12 && s1 == "B" {
            if sys == .gps || sys == .qzs {
                type = s0 + "1X"
            }
        } else if ver >= 2.12 && s1 == "C" {
            if sys == .gps || sys == .qzs {
                type = s0 + "2X"
            }
        } else if ver >= 2.12 && s1 == "D" {
            if sys == .glo {
                type = s0 + "2C"
            }
        } else if ver >= 2.12 && s1 == "1" {
            if sys == .gps { type = s0 + "1W" }
            else if sys == .glo { type = s0 + "1P" }
            else if sys == .gal { type = s0 + "1X" }
            else if sys == .cmp { type = s0 + "1X" }
        } else if ver < 2.12 && s1 == "1" {
            if sys == .gps || sys == .glo || sys == .qzs || sys == .sbs {
                type = s0 + "1C"
            } else if sys == .gal {
                type = s0 + "1X"
            }
        } else if s1 == "2" {
            if sys == .gps { type = s0 + "2W" }
            else if sys == .glo { type = s0 + "2P" }
            else if sys == .qzs { type = s0 + "2X" }
            else if sys == .cmp { type = s0 + "1X" }
        } else if s1 == "5" {
            if sys == .gps || sys == .gal || sys == .qzs || sys == .sbs {
                type = s0 + "5X"
            }
        } else if s1 == "6" {
            if sys == .gal || sys == .qzs || sys == .cmp {
                type = s0 + "6X"
            }
        } else if s1 == "7" {
            if sys == .gal || sys == .cmp {
                type = s0 + "7X"
            }
        } else if s1 == "8" {
            if sys == .gal {
                type = s0 + "8X"
            }
        }
    }
    
    private static func decode_obsh(reader: LineReader, buff: String, ver: Double, tsys: inout GNSSTimeSystem, tobs: inout [[String]], nav: inout Nav, sta: inout Sta) {
        let defcodes = [
            "CWX   ", "CC    ", "X XXXX", "CXXX  ", "C X   ", "X  XX "
        ]
        
        let label = RinexCommon.setStr(buff.dropFirst(60), length: 20)
        var pBuff = buff
        
        if label.hasPrefix("MARKER NAME") {
            sta.name = RinexCommon.setStr(pBuff, length: 60)
        } else if label.hasPrefix("MARKER NUMBER") {
            sta.marker = RinexCommon.setStr(pBuff, length: 20)
        } else if label.hasPrefix("MARKER TYPE") {
            // ver.3
        } else if label.hasPrefix("OBSERVER / AGENCY") {
            // ...
        } else if label.hasPrefix("REC # / TYPE / VERS") {
            sta.recsno = RinexCommon.setStr(pBuff, length: 20)
            sta.rectype = RinexCommon.setStr(pBuff.dropFirst(20), length: 20)
            sta.recver = RinexCommon.setStr(pBuff.dropFirst(40), length: 20)
        } else if label.hasPrefix("ANT # / TYPE") {
            sta.antsno = RinexCommon.setStr(pBuff, length: 20)
            sta.antdes = RinexCommon.setStr(pBuff.dropFirst(20), length: 20)
        } else if label.hasPrefix("APPROX POSITION XYZ") {
            for i in 0..<3 {
                sta.pos[i] = GNSSCommon.str2num(pBuff, i: i * 14, n: 14)
            }
        } else if label.hasPrefix("ANTENNA: DELTA H/E/N") {
            let h = GNSSCommon.str2num(pBuff, i: 0, n: 14)
            let e = GNSSCommon.str2num(pBuff, i: 14, n: 14)
            let nVal = GNSSCommon.str2num(pBuff, i: 28, n: 14)
            sta.del[0] = e
            sta.del[1] = nVal
            sta.del[2] = h
        } else if label.hasPrefix("SYS / # / OBS TYPES") {
            let sysChar = pBuff.first!
            guard let i = RinexCommon.syscodes.firstIndex(of: sysChar) else { return }
            let sysIdx = RinexCommon.syscodes.distance(from: RinexCommon.syscodes.startIndex, to: i)
            
            let n = Int(GNSSCommon.str2num(pBuff, i: 3, n: 3))
            var nt = 0
            var k = 7
            for _ in 0..<n {
                if k > 58 {
                    if let nextLine = reader.nextLine() {
                        pBuff = nextLine
                        k = 7
                    } else {
                        break
                    }
                }
                if nt < GNSSConstants.maxObsType - 1 {
                    tobs[sysIdx][nt] = RinexCommon.setStr(pBuff.dropFirst(k), length: 3)
                    nt += 1
                }
                k += 4
            }
            if sysIdx == 5 {
                for j in 0..<nt {
                    if tobs[sysIdx][j].count >= 2 {
                        let idx = tobs[sysIdx][j].index(tobs[sysIdx][j].startIndex, offsetBy: 1)
                        if tobs[sysIdx][j][idx] == "2" {
                            var arr = Array(tobs[sysIdx][j])
                            arr[1] = "1"
                            tobs[sysIdx][j] = String(arr)
                        }
                    }
                }
            }
            for j in 0..<nt {
                if tobs[sysIdx][j].count == 3 { continue }
                if tobs[sysIdx][j].count >= 2 {
                    let idx1 = tobs[sysIdx][j].index(tobs[sysIdx][j].startIndex, offsetBy: 1)
                    let frqChar = tobs[sysIdx][j][idx1]
                    if let p = RinexCommon.frqcodes.firstIndex(of: frqChar) {
                        let frqIdx = RinexCommon.frqcodes.distance(from: RinexCommon.frqcodes.startIndex, to: p)
                        let defChar = Array(defcodes[sysIdx])[frqIdx]
                        var arr = Array(tobs[sysIdx][j])
                        if arr.count < 3 { arr.append(" ") }
                        arr[2] = defChar
                        tobs[sysIdx][j] = String(arr)
                    }
                }
            }
        } else if label.hasPrefix("# / TYPES OF OBSERV") {
            let n = Int(GNSSCommon.str2num(pBuff, i: 0, n: 6))
            var nt = 0
            var j = 10
            for _ in 0..<n {
                if j > 58 {
                    if let nextLine = reader.nextLine() {
                        pBuff = nextLine
                        j = 10
                    } else {
                        break
                    }
                }
                if nt >= GNSSConstants.maxObsType - 1 { continue }
                if ver <= 2.99 {
                    let str = RinexCommon.setStr(pBuff.dropFirst(j), length: 2)
                    convcode(ver: ver, sys: .gps, str: str, type: &tobs[0][nt])
                    convcode(ver: ver, sys: .glo, str: str, type: &tobs[1][nt])
                    convcode(ver: ver, sys: .gal, str: str, type: &tobs[2][nt])
                    convcode(ver: ver, sys: .qzs, str: str, type: &tobs[3][nt])
                    convcode(ver: ver, sys: .sbs, str: str, type: &tobs[4][nt])
                    convcode(ver: ver, sys: .cmp, str: str, type: &tobs[5][nt])
                }
                nt += 1
                j += 6
            }
        } else if label.hasPrefix("TIME OF FIRST OBS") {
            let sysStr = RinexCommon.setStr(pBuff.dropFirst(48), length: 3)
            if sysStr == "GPS" { tsys = .gps }
            else if sysStr == "GLO" { tsys = .utc }
            else if sysStr == "GAL" { tsys = .gal }
            else if sysStr == "QZS" { tsys = .qzs }
            else if sysStr == "BDT" { tsys = .cmp }
        } else if label.hasPrefix("GLONASS SLOT / FRQ #") {
            var p = 4
            for _ in 0..<8 {
                if p + 8 > pBuff.count { break }
                let sub = String(pBuff.dropFirst(p).prefix(8))
                let parts = sub.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
                if parts.count >= 2, parts[0].hasPrefix("R") {
                    let prnStr = parts[0].dropFirst()
                    if let prn = Int(prnStr), let fcn = Int(parts[1]) {
                        if prn >= 1 && prn <= GNSSConstants.maxPrnGLO {
                            nav.glo_fcn[prn - 1] = UInt8(fcn + 8)
                        }
                    }
                }
                p += 8
            }
        } else if label.hasPrefix("GLONASS COD/PHS/BIS") {
            var p = 0
            for _ in 0..<4 {
                if p + 13 > pBuff.count { break }
                let sub = String(pBuff.dropFirst(p).prefix(13))
                let val = GNSSCommon.str2num(sub, i: 5, n: 8)
                if sub.hasPrefix(" C1C") { nav.glo_cpbias[0] = val }
                else if sub.hasPrefix(" C1P") { nav.glo_cpbias[1] = val }
                else if sub.hasPrefix(" C2C") { nav.glo_cpbias[2] = val }
                else if sub.hasPrefix(" C2P") { nav.glo_cpbias[3] = val }
                p += 13
            }
        } else if label.hasPrefix("LEAP SECONDS") {
            nav.leaps = Int(GNSSCommon.str2num(pBuff, i: 0, n: 6))
        }
    }
    
    private static func decode_navh(buff: String, nav: inout Nav) {
        let label = RinexCommon.setStr(buff.dropFirst(60), length: 20)
        if label.hasPrefix("ION ALPHA") {
            for i in 0..<4 { nav.ion_gps[i] = GNSSCommon.str2num(buff, i: 2 + i * 12, n: 12) }
        } else if label.hasPrefix("ION BETA") {
            for i in 0..<4 { nav.ion_gps[i + 4] = GNSSCommon.str2num(buff, i: 2 + i * 12, n: 12) }
        } else if label.hasPrefix("DELTA-UTC: A0,A1,T,W") {
            for i in 0..<2 { nav.utc_gps[i] = GNSSCommon.str2num(buff, i: 3 + i * 19, n: 19) }
            for i in 2..<4 { nav.utc_gps[i] = GNSSCommon.str2num(buff, i: 41 + (i - 2) * 9, n: 9) } // i=2->41, i=3->50
        } else if label.hasPrefix("IONOSPHERIC CORR") {
            if buff.hasPrefix("GPSA") {
                for i in 0..<4 { nav.ion_gps[i] = GNSSCommon.str2num(buff, i: 5 + i * 12, n: 12) }
            } else if buff.hasPrefix("GPSB") {
                for i in 0..<4 { nav.ion_gps[i + 4] = GNSSCommon.str2num(buff, i: 5 + i * 12, n: 12) }
            } else if buff.hasPrefix("GAL") {
                for i in 0..<4 { nav.ion_gal[i] = GNSSCommon.str2num(buff, i: 5 + i * 12, n: 12) }
            } else if buff.hasPrefix("QZSA") {
                for i in 0..<4 { nav.ion_qzs[i] = GNSSCommon.str2num(buff, i: 5 + i * 12, n: 12) }
            } else if buff.hasPrefix("QZSB") {
                for i in 0..<4 { nav.ion_qzs[i + 4] = GNSSCommon.str2num(buff, i: 5 + i * 12, n: 12) }
            } else if buff.hasPrefix("BDSA") {
                for i in 0..<4 { nav.ion_cmp[i] = GNSSCommon.str2num(buff, i: 5 + i * 12, n: 12) }
            } else if buff.hasPrefix("BDSB") {
                for i in 0..<4 { nav.ion_cmp[i + 4] = GNSSCommon.str2num(buff, i: 5 + i * 12, n: 12) }
            }
        } else if label.hasPrefix("TIME SYSTEM CORR") {
            if buff.hasPrefix("GPUT") {
                nav.utc_gps[0] = GNSSCommon.str2num(buff, i: 5, n: 17)
                nav.utc_gps[1] = GNSSCommon.str2num(buff, i: 22, n: 16)
                nav.utc_gps[2] = GNSSCommon.str2num(buff, i: 38, n: 7)
                nav.utc_gps[3] = GNSSCommon.str2num(buff, i: 45, n: 5)
            } else if buff.hasPrefix("GLUT") {
                nav.utc_glo[0] = GNSSCommon.str2num(buff, i: 5, n: 17)
                nav.utc_glo[1] = GNSSCommon.str2num(buff, i: 22, n: 16)
            } else if buff.hasPrefix("GAUT") {
                nav.utc_gal[0] = GNSSCommon.str2num(buff, i: 5, n: 17)
                nav.utc_gal[1] = GNSSCommon.str2num(buff, i: 22, n: 16)
                nav.utc_gal[2] = GNSSCommon.str2num(buff, i: 38, n: 7)
                nav.utc_gal[3] = GNSSCommon.str2num(buff, i: 45, n: 5)
            } else if buff.hasPrefix("QZUT") {
                nav.utc_qzs[0] = GNSSCommon.str2num(buff, i: 5, n: 17)
                nav.utc_qzs[1] = GNSSCommon.str2num(buff, i: 22, n: 16)
                nav.utc_qzs[2] = GNSSCommon.str2num(buff, i: 38, n: 7)
                nav.utc_qzs[3] = GNSSCommon.str2num(buff, i: 45, n: 5)
            } else if buff.hasPrefix("BDUT") || buff.hasPrefix("SBUT") {
                nav.utc_cmp[0] = GNSSCommon.str2num(buff, i: 5, n: 17)
                nav.utc_cmp[1] = GNSSCommon.str2num(buff, i: 22, n: 16)
                nav.utc_cmp[2] = GNSSCommon.str2num(buff, i: 38, n: 7)
                nav.utc_cmp[3] = GNSSCommon.str2num(buff, i: 45, n: 5)
            }
        } else if label.hasPrefix("LEAP SECONDS") {
            nav.leaps = Int(GNSSCommon.str2num(buff, i: 0, n: 6))
        }
    }
    
    private static func decode_gnavh(buff: String, nav: inout Nav) {
        let label = RinexCommon.setStr(buff.dropFirst(60), length: 20)
        if label.hasPrefix("LEAP SECONDS") {
            nav.leaps = Int(GNSSCommon.str2num(buff, i: 0, n: 6))
        }
    }
    
    private static func readrnxh(reader: LineReader, ver: inout Double, type: inout Character, sys: inout GNSSSystem, tsys: inout GNSSTimeSystem, tobs: inout [[String]], nav: inout Nav, sta: inout Sta) -> Bool {
        ver = 2.10
        type = " "
        sys = .gps
        tsys = .gps
        
        var i = 0
        var block = 0
        
        while let buff = reader.nextLine() {
            if buff.count <= 60 { continue }
            let label = RinexCommon.setStr(buff.dropFirst(60), length: 20)
            
            if label.hasPrefix("RINEX VERSION / TYPE") {
                ver = GNSSCommon.str2num(buff, i: 0, n: 9)
                type = buff[buff.index(buff.startIndex, offsetBy: 20)]
                let sysChar = buff[buff.index(buff.startIndex, offsetBy: 40)]
                switch sysChar {
                case " ", "G": sys = .gps; tsys = .gps
                case "R": sys = .glo; tsys = .utc
                case "E": sys = .gal; tsys = .gal
                case "S": sys = .sbs; tsys = .gps
                case "J": sys = .qzs; tsys = .qzs
                case "C": sys = .cmp; tsys = .cmp
                case "M": sys = .none; tsys = .gps
                default: break
                }
                continue
            } else if label.hasPrefix("PGM / RUN BY / DATE") {
                continue
            } else if label.hasPrefix("COMMENT") {
                if buff.contains("WIDELANE SATELLITE FRACTIONAL BIASES") || buff.contains("WIDELANE SATELLITE FRACTIONNAL BIASES") {
                    block = 1
                } else if block == 1 {
                    if buff.hasPrefix("WL") {
                        let satId = RinexCommon.setStr(buff.dropFirst(3), length: 4)
                        let sat = GNSSCommon.satId2No(satId)
                        if sat != 0 {
                            nav.wlbias[sat - 1] = GNSSCommon.str2num(buff, i: 40, n: 15)
                        }
                    } else {
                        let satId = RinexCommon.setStr(buff.dropFirst(1), length: 4)
                        let sat = GNSSCommon.satId2No(satId)
                        if sat != 0 {
                            nav.wlbias[sat - 1] = GNSSCommon.str2num(buff, i: 6, n: 15)
                        }
                    }
                }
                continue
            }
            
            switch type {
            case "O": decode_obsh(reader: reader, buff: buff, ver: ver, tsys: &tsys, tobs: &tobs, nav: &nav, sta: &sta)
            case "N", "J", "L": decode_navh(buff: buff, nav: &nav)
            case "G": decode_gnavh(buff: buff, nav: &nav)
            case "H": decode_gnavh(buff: buff, nav: &nav) // mapped to gnavh logically in C
            default: break
            }
            
            if label.hasPrefix("END OF HEADER") { return true }
            
            i += 1
            if i >= 1024 && type == " " { break }
        }
        return false
    }
    
    private static func set_sysmask(opt: String) -> GNSSSystem {
        guard let range = opt.range(of: "-SYS=") else { return .all }
        var mask: GNSSSystem = .none
        let substr = opt[range.upperBound...]
        for c in substr {
            if c == " " { break }
            switch c {
            case "G": mask.insert(.gps)
            case "R": mask.insert(.glo)
            case "E": mask.insert(.gal)
            case "J": mask.insert(.qzs)
            case "C": mask.insert(.cmp)
            case "S": mask.insert(.sbs)
            default: break
            }
        }
        return mask
    }
    
    private static func set_index(ver: Double, sys: GNSSSystem, opt: String, tobs: [String], ind: inout SigInd) {
        var n = 0
        for i in 0..<tobs.count {
            if tobs[i].isEmpty { break }
            let obsCodeStr = String(tobs[i].dropFirst())
            let (code, frq) = GNSSStrings.obs2code(obsCodeStr)
            ind.code[i] = code
            ind.frq[i] = frq
            
            if let p = RinexCommon.obscodes.firstIndex(of: tobs[i].first!) {
                ind.type[i] = UInt8(RinexCommon.obscodes.distance(from: RinexCommon.obscodes.startIndex, to: p))
            } else {
                ind.type[i] = 0
            }
            
            ind.pri[i] = UInt8(GNSSCommon.getCodePri(sys: sys, code: ind.code[i], opt: opt))
            ind.pos[i] = -1
            
            if sys == .cmp {
                if ind.frq[i] == 5 { ind.frq[i] = 2 }
                else if ind.frq[i] == 4 { ind.frq[i] = 3 }
            }
            n += 1
        }
        
        // Phase shift logic is omitted for brevity as it requires regex parsing.
        
        for i in 0..<GNSSConstants.nFreq {
            var k = -1
            for j in 0..<n {
                if ind.frq[j] == i + 1 && ind.pri[j] > 0 && (k < 0 || ind.pri[j] > ind.pri[k]) {
                    k = j
                }
            }
            if k < 0 { continue }
            for j in 0..<n {
                if ind.code[j] == ind.code[k] { ind.pos[j] = i }
            }
        }
        
        for i in 0..<GNSSConstants.nExObs {
            var j = 0
            while j < n {
                if ind.code[j] > 0 && ind.pri[j] > 0 && ind.pos[j] < 0 { break }
                j += 1
            }
            if j >= n { break }
            for k in 0..<n {
                if ind.code[k] == ind.code[j] { ind.pos[k] = GNSSConstants.nFreq + i }
            }
        }
        ind.n = n
    }
    
    private static func decode_obsepoch(reader: LineReader, buff: String, ver: Double, time: inout GTime, flag: inout Int, sats: inout [Int]) -> Int {
        var pBuff = buff
        if ver <= 2.99 {
            let n = Int(GNSSCommon.str2num(pBuff, i: 29, n: 3))
            if n <= 0 { return 0 }
            flag = Int(GNSSCommon.str2num(pBuff, i: 28, n: 1))
            if flag >= 3 && flag <= 5 { return n }
            
            if let t = GTime.str2time(s: pBuff, i: 0, n: 26) {
                time = t
            } else { return 0 }
            
            var j = 32
            for i in 0..<n {
                if j >= 68 {
                    if let nextLine = reader.nextLine() {
                        pBuff = nextLine
                        j = 32
                    } else { break }
                }
                if i < GNSSConstants.maxObs {
                    let satid = RinexCommon.setStr(pBuff.dropFirst(j), length: 3)
                    sats[i] = GNSSCommon.satId2No(satid)
                }
                j += 3
            }
            return n
        } else {
            let n = Int(GNSSCommon.str2num(pBuff, i: 32, n: 3))
            if n <= 0 { return 0 }
            flag = Int(GNSSCommon.str2num(pBuff, i: 31, n: 1))
            if flag >= 3 && flag <= 5 { return n }
            
            if !pBuff.hasPrefix(">") { return 0 }
            if let t = GTime.str2time(s: pBuff, i: 1, n: 28) {
                time = t
            } else { return 0 }
            return n
        }
    }
    
    private static func decode_obsdata(reader: LineReader, buff: String, ver: Double, mask: GNSSSystem, index: [SigInd], obs: inout Obsd) -> Bool {
        var pBuff = buff
        if ver > 2.99 {
            let satid = RinexCommon.setStr(pBuff, length: 3)
            obs.sat = UInt8(GNSSCommon.satId2No(satid))
        }
        if obs.sat == 0 { return false }
        
        let (sys, _) = GNSSCommon.satSys(Int(obs.sat))
        if !mask.contains(sys) { return false }
        
        var ind: SigInd
        switch sys {
        case .glo: ind = index[1]
        case .gal: ind = index[2]
        case .qzs: ind = index[3]
        case .sbs: ind = index[4]
        case .cmp: ind = index[5]
        default: ind = index[0]
        }
        
        var val = [Double](repeating: 0.0, count: GNSSConstants.maxObsType)
        var lli = [UInt8](repeating: 0, count: GNSSConstants.maxObsType)
        
        var j = ver <= 2.99 ? 0 : 3
        for i in 0..<ind.n {
            if ver <= 2.99 && j >= 80 {
                if let nextLine = reader.nextLine() {
                    pBuff = nextLine
                    j = 0
                } else { break }
            }
            val[i] = GNSSCommon.str2num(pBuff, i: j, n: 14) + ind.shift[i]
            lli[i] = UInt8(Int(GNSSCommon.str2num(pBuff, i: j + 14, n: 1)) & 3)
            j += 16
        }
        
        for i in 0..<(GNSSConstants.nFreq + GNSSConstants.nExObs) {
            obs.P[i] = 0.0; obs.L[i] = 0.0; obs.D[i] = 0.0
            obs.snr[i] = 0; obs.lli[i] = 0; obs.code[i] = 0
        }
        
        var p = [Int](repeating: 0, count: GNSSConstants.maxObsType)
        var k = [Int](repeating: 0, count: 16)
        var l = [Int](repeating: 0, count: 16)
        var n = 0, m = 0
        
        for i in 0..<ind.n {
            p[i] = ver <= 2.11 ? ind.frq[i] - 1 : ind.pos[i]
            if ind.type[i] == 0 && p[i] == 0 { k[n] = i; n += 1 }
            if ind.type[i] == 0 && p[i] == 1 { l[m] = i; m += 1 }
        }
        
        if ver <= 2.11 {
            if n >= 2 {
                if val[k[0]] == 0.0 && val[k[1]] == 0.0 { p[k[0]] = -1; p[k[1]] = -1 }
                else if val[k[0]] != 0.0 && val[k[1]] == 0.0 { p[k[0]] = 0; p[k[1]] = -1 }
                else if val[k[0]] == 0.0 && val[k[1]] != 0.0 { p[k[0]] = -1; p[k[1]] = 0 }
                else if ind.pri[k[1]] > ind.pri[k[0]] { p[k[1]] = 0; p[k[0]] = GNSSConstants.nExObs < 1 ? -1 : GNSSConstants.nFreq }
                else { p[k[0]] = 0; p[k[1]] = GNSSConstants.nExObs < 1 ? -1 : GNSSConstants.nFreq }
            }
            if m >= 2 {
                if val[l[0]] == 0.0 && val[l[1]] == 0.0 { p[l[0]] = -1; p[l[1]] = -1 }
                else if val[l[0]] != 0.0 && val[l[1]] == 0.0 { p[l[0]] = 1; p[l[1]] = -1 }
                else if val[l[0]] == 0.0 && val[l[1]] != 0.0 { p[l[0]] = -1; p[l[1]] = 1 }
                else if ind.pri[l[1]] > ind.pri[l[0]] { p[l[1]] = 1; p[l[0]] = GNSSConstants.nExObs < 2 ? -1 : GNSSConstants.nFreq + 1 }
                else { p[l[0]] = 1; p[l[1]] = GNSSConstants.nExObs < 2 ? -1 : GNSSConstants.nFreq + 1 }
            }
        }
        
        for i in 0..<ind.n {
            if p[i] < 0 || val[i] == 0.0 { continue }
            switch ind.type[i] {
            case 0: obs.P[p[i]] = val[i]; obs.code[p[i]] = ind.code[i]
            case 1: obs.L[p[i]] = val[i]; obs.lli[p[i]] = lli[i]
            case 2: obs.D[p[i]] = Float(val[i])
            case 3: obs.snr[p[i]] = UInt8(val[i] * 4.0 + 0.5)
            default: break
            }
        }
        return true
    }
    
    public static func readRnx(file: String, rcv: Int, opt: String, obs: inout [Obsd], nav: inout Nav, sta: inout Sta) -> Bool {
        guard let reader = LineReader(file: file) else { return false }
        
        var ver = 0.0
        var type: Character = " "
        var sys: GNSSSystem = .gps
        var tsys: GNSSTimeSystem = .gps
        var tobs = [[String]](repeating: [String](repeating: "", count: GNSSConstants.maxObsType), count: 6)
        
        if !readrnxh(reader: reader, ver: &ver, type: &type, sys: &sys, tsys: &tsys, tobs: &tobs, nav: &nav, sta: &sta) {
            return false
        }
        
        if type == "O" {
            let mask = set_sysmask(opt: opt)
            var index = [SigInd](repeating: SigInd(), count: 6)
            set_index(ver: ver, sys: .gps, opt: opt, tobs: tobs[0], ind: &index[0])
            set_index(ver: ver, sys: .glo, opt: opt, tobs: tobs[1], ind: &index[1])
            set_index(ver: ver, sys: .gal, opt: opt, tobs: tobs[2], ind: &index[2])
            set_index(ver: ver, sys: .qzs, opt: opt, tobs: tobs[3], ind: &index[3])
            set_index(ver: ver, sys: .sbs, opt: opt, tobs: tobs[4], ind: &index[4])
            set_index(ver: ver, sys: .cmp, opt: opt, tobs: tobs[5], ind: &index[5])
            
            var time = GTime()
            var flag = 0
            var sats = [Int](repeating: 0, count: GNSSConstants.maxObs)
            var nsat = 0
            var i = 0
            var epochData = [Obsd]()
            
            while let buff = reader.nextLine() {
                if i == 0 {
                    nsat = decode_obsepoch(reader: reader, buff: buff, ver: ver, time: &time, flag: &flag, sats: &sats)
                    if nsat <= 0 { continue }
                } else if flag <= 2 || flag == 6 {
                    var data = Obsd()
                    data.time = time
                    data.sat = UInt8(sats[i - 1])
                    if decode_obsdata(reader: reader, buff: buff, ver: ver, mask: mask, index: index, obs: &data) {
                        data.rcv = UInt8(rcv)
                        epochData.append(data)
                    }
                }
                i += 1
                if i > nsat {
                    obs.append(contentsOf: epochData)
                    epochData.removeAll()
                    i = 0
                }
            }
            return true
        } else {
            // Nav processing
            var i = 0
            var sat = 0
            var sp = 3
            var toc = GTime()
            var data = [Double](repeating: 0.0, count: 64)
            
            while let buff = reader.nextLine() {
                if buff.trimmingCharacters(in: .whitespaces).isEmpty { continue }
                if i == 0 {
                    if ver >= 3.0 || sys == .gal || sys == .qzs {
                        let id = String(buff.prefix(3))
                        sat = GNSSCommon.satId2No(id)
                        sp = 4
                        if ver >= 3.0 {
                            let (s, _) = GNSSCommon.satSys(sat)
                            sys = s
                        }
                    } else {
                        let prn = Int(GNSSCommon.str2num(buff, i: 0, n: 2))
                        if sys == .sbs { sat = GNSSCommon.satNo(sys: .sbs, prn: prn + 100) }
                        else if sys == .glo { sat = GNSSCommon.satNo(sys: .glo, prn: prn) }
                        else if prn >= 93 && prn <= 97 { sat = GNSSCommon.satNo(sys: .qzs, prn: prn + 100) }
                        else { sat = GNSSCommon.satNo(sys: .gps, prn: prn) }
                    }
                    if let t = GTime.str2time(s: buff, i: sp, n: 19) {
                        toc = t
                    } else {
                        // try to resync
                        continue
                    }
                    for j in 0..<3 {
                        data[i] = GNSSCommon.str2num(buff, i: sp + 19 + j * 19, n: 19); i += 1
                    }
                } else {
                    for j in 0..<4 {
                        data[i] = GNSSCommon.str2num(buff, i: sp + j * 19, n: 19); i += 1
                    }
                    if sys == .glo && i >= 15 {
                        i = 0
                    } else if sys == .sbs && i >= 15 {
                        i = 0
                    } else if i >= 31 {
                        var eph = Eph()
                        if decode_eph(ver: ver, sat: sat, toc: toc, data: data, eph: &eph) {
                            nav.eph.append(eph)
                        }
                        i = 0
                    }
                }
            }
            return true
        }
    }
}
