//
//  RinexGenerate.swift
//  GNSSRinex
//

import Foundation

public struct RinexGenerate {
    
    private static let ura_eph: [Double] = [
        2.4, 3.4, 4.85, 6.85, 9.65, 13.65, 24.0, 48.0, 96.0, 192.0, 384.0, 768.0, 1536.0,
        3072.0, 6144.0, 0.0
    ]
    
    private static func outnavf(value: Double) -> String {
        let e = abs(value) < 1E-99 ? 0.0 : floor(log10(abs(value)) + 1.0)
        let sign = value < 0.0 ? "-" : " "
        let mantissa = abs(value) / pow(10.0, e - 12.0)
        return String(format: "%@0.%012.0fD%+03.0f", sign, mantissa, e)
    }
    
    private static func uraValue(sva: Int) -> Double {
        if sva >= 0 && sva < 15 {
            return ura_eph[sva]
        }
        return 32767.0
    }
    
    public static func outRnxObsH(opt: Rnxopt, nav: Nav) -> String {
        var str = ""
        let date = RinexCommon.timeStrRnx()
        var sysStr = ""
        
        let pad11 = { (s: String) in s.padding(toLength: 11, withPad: " ", startingAt: 0) }
        let pad18 = { (s: String) in s.padding(toLength: 18, withPad: " ", startingAt: 0) }
        let pad20 = { (s: String) in s.padding(toLength: 20, withPad: " ", startingAt: 0) }
        let pad40 = { (s: String) in s.padding(toLength: 40, withPad: " ", startingAt: 0) }
        let pad60 = { (s: String) in s.padding(toLength: 60, withPad: " ", startingAt: 0) }
        
        if opt.rnxver <= 2.99 {
            sysStr = opt.navsys == GNSSSystem.gps.rawValue ? "G (GPS)" : "M (MIXED)"
        } else {
            if opt.navsys == GNSSSystem.gps.rawValue { sysStr = "G: GPS" }
            else if opt.navsys == GNSSSystem.glo.rawValue { sysStr = "R: GLONASS" }
            else if opt.navsys == GNSSSystem.gal.rawValue { sysStr = "E: Galileo" }
            else if opt.navsys == GNSSSystem.qzs.rawValue { sysStr = "J: QZSS" }
            else if opt.navsys == GNSSSystem.cmp.rawValue { sysStr = "C: BeiDou" }
            else if opt.navsys == GNSSSystem.sbs.rawValue { sysStr = "S: SBAS Payload" }
            else { sysStr = "M: Mixed" }
        }
        
        str += String(format: "%9.2f", opt.rnxver) + pad11("") + pad20("OBSERVATION DATA") + pad20(sysStr) + pad20("RINEX VERSION / TYPE") + "\n"
        str += pad20(opt.prog) + pad20(opt.runby) + pad20(date) + pad20("PGM / RUN BY / DATE") + "\n"
        
        for i in 0..<GNSSConstants.maxComment {
            if opt.comment[i].isEmpty { continue }
            str += pad60(opt.comment[i]) + pad20("COMMENT") + "\n"
        }
        
        str += pad60(opt.marker) + pad20("MARKER NAME") + "\n"
        str += pad20(opt.markerno) + pad40("") + pad20("MARKER NUMBER") + "\n"
        
        if opt.rnxver > 2.99 {
            str += pad20(opt.markertype) + pad40("") + pad20("MARKER TYPE") + "\n"
        }
        str += pad20(opt.name[0]) + pad40(opt.name[1]) + pad20("OBSERVER / AGENCY") + "\n"
        str += pad20(opt.rec[0]) + pad20(opt.rec[1]) + pad20(opt.rec[2]) + pad20("REC # / TYPE / VERS") + "\n"
        str += pad20(opt.ant[0]) + pad20(opt.ant[1]) + pad20(opt.ant[2]) + pad20("ANT # / TYPE") + "\n"
        
        var pos = [0.0, 0.0, 0.0]
        var del = [0.0, 0.0, 0.0]
        for i in 0..<3 { if abs(opt.apppos[i]) < 1E8 { pos[i] = opt.apppos[i] } }
        for i in 0..<3 { if abs(opt.antdel[i]) < 1E8 { del[i] = opt.antdel[i] } }
        
        str += String(format: "%14.4f%14.4f%14.4f", pos[0], pos[1], pos[2]) + pad18("") + pad20("APPROX POSITION XYZ") + "\n"
        str += String(format: "%14.4f%14.4f%14.4f", del[0], del[1], del[2]) + pad18("") + pad20("ANTENNA: DELTA H/E/N") + "\n"
        
        str += pad60("") + pad20("END OF HEADER") + "\n"
        return str
    }
    
    public static func outRnxNavH(opt: Rnxopt, nav: Nav) -> String {
        var str = ""
        let date = RinexCommon.timeStrRnx()
        
        let pad20 = { (s: String) in s.padding(toLength: 20, withPad: " ", startingAt: 0) }
        let pad60 = { (s: String) in s.padding(toLength: 60, withPad: " ", startingAt: 0) }
        
        if opt.rnxver <= 2.99 {
            str += String(format: "%9.2f           ", opt.rnxver) + pad20("N: GPS NAV DATA") + pad20("") + pad20("RINEX VERSION / TYPE") + "\n"
        } else {
            var sysStr = ""
            if opt.navsys == GNSSSystem.gps.rawValue { sysStr = "G: GPS" }
            else if opt.navsys == GNSSSystem.glo.rawValue { sysStr = "R: GLONASS" }
            else if opt.navsys == GNSSSystem.gal.rawValue { sysStr = "E: Galileo" }
            else if opt.navsys == GNSSSystem.qzs.rawValue { sysStr = "J: QZSS" }
            else if opt.navsys == GNSSSystem.cmp.rawValue { sysStr = "C: BeiDou" }
            else if opt.navsys == GNSSSystem.sbs.rawValue { sysStr = "S: SBAS Payload" }
            else { sysStr = "M: Mixed" }
            
            str += String(format: "%9.2f           ", opt.rnxver) + pad20("N: GNSS NAV DATA") + pad20(sysStr) + pad20("RINEX VERSION / TYPE") + "\n"
        }
        
        str += pad20(opt.prog) + pad20(opt.runby) + pad20(date) + pad20("PGM / RUN BY / DATE") + "\n"
        
        for i in 0..<GNSSConstants.maxComment {
            if opt.comment[i].isEmpty { continue }
            str += pad60(opt.comment[i]) + pad20("COMMENT") + "\n"
        }
        str += pad60("") + pad20("END OF HEADER") + "\n"
        return str
    }
    
    public static func outRnxNavB(opt: Rnxopt, eph: Eph) -> String {
        var str = ""
        let (sys, prn) = GNSSCommon.satSys(eph.sat)
        if (sys.rawValue & opt.navsys) == 0 { return "" }
        
        var ep: [Double]
        if sys != .cmp {
            ep = eph.toc.toEpoch()
        } else {
            ep = eph.toc.gpst2bdt().toEpoch()
        }
        
        let code = RinexCommon.sat2Code(eph.sat)
        var sep = ""
        
        if opt.rnxver > 2.99 || sys == .gal || sys == .cmp {
            str += String(format: "%-3s %04.0f %2.0f %2.0f %2.0f %2.0f %2.0f", code, ep[0], ep[1], ep[2], ep[3], ep[4], ep[5])
            sep = "    "
        } else if sys == .qzs {
            str += String(format: "%-3s %02d %2.0f %2.0f %2.0f %2.0f %4.1f", code, Int(ep[0]) % 100, ep[1], ep[2], ep[3], ep[4], ep[5])
            sep = "    "
        } else {
            str += String(format: "%2d %02d %2.0f %2.0f %2.0f %2.0f %4.1f", prn, Int(ep[0]) % 100, ep[1], ep[2], ep[3], ep[4], ep[5])
            sep = "   "
        }
        
        str += outnavf(value: eph.f0)
        str += outnavf(value: eph.f1)
        str += outnavf(value: eph.f2)
        str += "\n\(sep)"
        
        str += outnavf(value: Double(eph.iode))
        str += outnavf(value: eph.crs)
        str += outnavf(value: eph.deln)
        str += outnavf(value: eph.M0)
        str += "\n\(sep)"
        
        str += outnavf(value: eph.cuc)
        str += outnavf(value: eph.e)
        str += outnavf(value: eph.cus)
        str += outnavf(value: sqrt(eph.A))
        str += "\n\(sep)"
        
        str += outnavf(value: eph.toes)
        str += outnavf(value: eph.cic)
        str += outnavf(value: eph.OMG0)
        str += outnavf(value: eph.cis)
        str += "\n\(sep)"
        
        str += outnavf(value: eph.i0)
        str += outnavf(value: eph.crc)
        str += outnavf(value: eph.omg)
        str += outnavf(value: eph.OMGd)
        str += "\n\(sep)"
        
        str += outnavf(value: eph.idot)
        str += outnavf(value: Double(eph.code))
        str += outnavf(value: Double(eph.week))
        str += outnavf(value: Double(eph.flag))
        str += "\n\(sep)"
        
        str += outnavf(value: uraValue(sva: eph.sva))
        str += outnavf(value: Double(eph.svh))
        str += outnavf(value: eph.tgd[0])
        
        if sys == .gal || sys == .cmp {
            str += outnavf(value: eph.tgd[1])
        } else {
            str += outnavf(value: Double(eph.iodc))
        }
        str += "\n\(sep)"
        
        var ttr: Double
        var week: Int
        if sys != .cmp {
            (ttr, week) = eph.ttr.time2gpst()
        } else {
            (ttr, week) = eph.ttr.gpst2bdt().time2bdt()
        }
        str += outnavf(value: ttr + Double(week - eph.week) * 604800.0)
        
        if sys == .gps || sys == .qzs {
            str += outnavf(value: eph.fit)
            str += outnavf(value: 0.0)
            str += outnavf(value: 0.0)
        } else if sys == .cmp {
            str += outnavf(value: Double(eph.iodc))
            str += outnavf(value: 0.0)
            str += outnavf(value: 0.0)
        } else {
            str += outnavf(value: 0.0)
            str += outnavf(value: 0.0)
            str += outnavf(value: 0.0)
        }
        str += "\n"
        return str
    }
}
