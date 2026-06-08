//
//  GNSSCommon.swift
//  GNSSRinex
//
import Foundation

public struct GNSSCommon {
    
    /// Convert satellite system + prn/slot number to satellite number
    public static func satNo(sys: GNSSSystem, prn: Int) -> Int {
        if prn <= 0 { return 0 }
        
        if sys == .gps {
            if prn < GNSSConstants.minPrnGPS || prn > GNSSConstants.maxPrnGPS { return 0 }
            return prn - GNSSConstants.minPrnGPS + 1
        } else if sys == .glo {
            if prn < GNSSConstants.minPrnGLO || prn > GNSSConstants.maxPrnGLO { return 0 }
            return GNSSConstants.nSatGPS + prn - GNSSConstants.minPrnGLO + 1
        } else if sys == .gal {
            if prn < GNSSConstants.minPrnGAL || prn > GNSSConstants.maxPrnGAL { return 0 }
            return GNSSConstants.nSatGPS + GNSSConstants.nSatGLO + prn - GNSSConstants.minPrnGAL + 1
        } else if sys == .qzs {
            if prn < GNSSConstants.minPrnQZS || prn > GNSSConstants.maxPrnQZS { return 0 }
            return GNSSConstants.nSatGPS + GNSSConstants.nSatGLO + GNSSConstants.nSatGAL + prn - GNSSConstants.minPrnQZS + 1
        } else if sys == .cmp {
            if prn < GNSSConstants.minPrnCMP || prn > GNSSConstants.maxPrnCMP { return 0 }
            return GNSSConstants.nSatGPS + GNSSConstants.nSatGLO + GNSSConstants.nSatGAL + GNSSConstants.nSatQZS + prn - GNSSConstants.minPrnCMP + 1
        } else if sys == .leo {
            if prn < GNSSConstants.minPrnLEO || prn > GNSSConstants.maxPrnLEO { return 0 }
            return GNSSConstants.nSatGPS + GNSSConstants.nSatGLO + GNSSConstants.nSatGAL + GNSSConstants.nSatQZS + GNSSConstants.nSatCMP + prn - GNSSConstants.minPrnLEO + 1
        } else if sys == .sbs {
            if prn < GNSSConstants.minPrnSBS || prn > GNSSConstants.maxPrnSBS { return 0 }
            return GNSSConstants.nSatGPS + GNSSConstants.nSatGLO + GNSSConstants.nSatGAL + GNSSConstants.nSatQZS + GNSSConstants.nSatCMP + GNSSConstants.nSatLEO + prn - GNSSConstants.minPrnSBS + 1
        }
        
        return 0
    }
    
    /// Satellite number to satellite system
    public static func satSys(_ satInput: Int) -> (sys: GNSSSystem, prn: Int) {
        var sys: GNSSSystem = .none
        var sat = satInput
        var prn = 0
        
        if sat <= 0 || sat > GNSSConstants.maxSat {
            sat = 0
        } else if sat <= GNSSConstants.nSatGPS {
            sys = .gps
            sat += GNSSConstants.minPrnGPS - 1
        } else {
            sat -= GNSSConstants.nSatGPS
            if sat <= GNSSConstants.nSatGLO {
                sys = .glo
                sat += GNSSConstants.minPrnGLO - 1
            } else {
                sat -= GNSSConstants.nSatGLO
                if sat <= GNSSConstants.nSatGAL {
                    sys = .gal
                    sat += GNSSConstants.minPrnGAL - 1
                } else {
                    sat -= GNSSConstants.nSatGAL
                    if sat <= GNSSConstants.nSatQZS {
                        sys = .qzs
                        sat += GNSSConstants.minPrnQZS - 1
                    } else {
                        sat -= GNSSConstants.nSatQZS
                        if sat <= GNSSConstants.nSatCMP {
                            sys = .cmp
                            sat += GNSSConstants.minPrnCMP - 1
                        } else {
                            sat -= GNSSConstants.nSatCMP
                            if sat <= GNSSConstants.nSatLEO {
                                sys = .leo
                                sat += GNSSConstants.minPrnLEO - 1
                            } else {
                                sat -= GNSSConstants.nSatLEO
                                if sat <= GNSSConstants.nSatSBS {
                                    sys = .sbs
                                    sat += GNSSConstants.minPrnSBS - 1
                                } else {
                                    sat = 0
                                }
                            }
                        }
                    }
                }
            }
        }
        
        prn = sat
        return (sys, prn)
    }

    /// Convert substring in string to number
    public static func str2num(_ s: String, i: Int, n: Int) -> Double {
        if i < 0 || n <= 0 || i + n > s.count { return 0.0 }
        
        let start = s.index(s.startIndex, offsetBy: i)
        let end = s.index(start, offsetBy: n)
        var substr = String(s[start..<end])
        
        // Fortran style double support (D/d to E)
        substr = substr.replacingOccurrences(of: "D", with: "E")
        substr = substr.replacingOccurrences(of: "d", with: "E")
        
        // Remove whitespaces to correctly parse with Double initializer
        substr = substr.trimmingCharacters(in: .whitespaces)
        
        if let val = Double(substr) {
            return val
        }
        return 0.0
    }

    /// Convert satellite id to satellite number
    public static func satId2No(_ id: String) -> Int {
        var sys: GNSSSystem = .none
        
        // Trim
        let idTrimmed = id.trimmingCharacters(in: .whitespaces)
        if idTrimmed.isEmpty { return 0 }
        
        if let prn = Int(idTrimmed) {
            if GNSSConstants.minPrnGPS <= prn && prn <= GNSSConstants.maxPrnGPS {
                sys = .gps
            } else if GNSSConstants.minPrnSBS <= prn && prn <= GNSSConstants.maxPrnSBS {
                sys = .sbs
            } else if GNSSConstants.minPrnQZS <= prn && prn <= GNSSConstants.maxPrnQZS {
                sys = .qzs
            } else {
                return 0
            }
            return satNo(sys: sys, prn: prn)
        }
        
        let code = idTrimmed.first!
        let prnStr = idTrimmed.dropFirst()
        guard let prnParsed = Int(prnStr) else { return 0 }
        
        var prn = prnParsed
        
        switch code {
        case "G":
            sys = .gps
            prn += GNSSConstants.minPrnGPS - 1
        case "R":
            sys = .glo
            prn += GNSSConstants.minPrnGLO - 1
        case "E":
            sys = .gal
            prn += GNSSConstants.minPrnGAL - 1
        case "J":
            sys = .qzs
            prn += GNSSConstants.minPrnQZS - 1
        case "C":
            sys = .cmp
            prn += GNSSConstants.minPrnCMP - 1
        case "L":
            sys = .leo
            prn += GNSSConstants.minPrnLEO - 1
        case "S":
            sys = .sbs
            prn += 100
        default:
            return 0
        }
        
        return satNo(sys: sys, prn: prn)
    }

    /// Get satellite carrier wave lengths
    public static func satWaveLen(sat: Int, frq: Int, nav: Nav) -> Double {
        let freq_glo = [GNSSConstants.freq1_glo, GNSSConstants.freq2_glo, GNSSConstants.freq3_glo]
        let dfrq_glo = [GNSSConstants.dfrq1_glo, GNSSConstants.dfrq2_glo, 0.0]
        
        let (sys, _) = satSys(sat)
        
        if sys == .glo {
            if frq >= 0 && frq <= 2 {
                for eph in nav.geph {
                    if eph.sat != sat { continue }
                    return GNSSConstants.cLight / (freq_glo[frq] + dfrq_glo[frq] * Double(eph.frq))
                }
            }
        } else if sys == .cmp {
            if frq == 0 { return GNSSConstants.cLight / GNSSConstants.freq1_cmp } /* B1 */
            else if frq == 1 { return GNSSConstants.cLight / GNSSConstants.freq2_cmp } /* B3 */
            else if frq == 2 { return GNSSConstants.cLight / GNSSConstants.freq3_cmp } /* B2 */
        } else {
            if frq == 0 { return GNSSConstants.cLight / GNSSConstants.freq1 } /* L1/E1 */
            else if frq == 1 { return GNSSConstants.cLight / GNSSConstants.freq2 } /* L2 */
            else if frq == 2 { return GNSSConstants.cLight / GNSSConstants.freq5 } /* L5/E5a */
            else if frq == 3 { return GNSSConstants.cLight / GNSSConstants.freq6 } /* L6/LEX */
            else if frq == 4 { return GNSSConstants.cLight / GNSSConstants.freq7 } /* E5b */
            else if frq == 5 { return GNSSConstants.cLight / GNSSConstants.freq8 } /* E5a+b */
        }
        return 0.0
    }
    
    private static let codePris: [[String]] = [
        /* L1,G1E1a   L2,G2,B1     L5,G3,E5a L6,LEX,B3 E5a,B2    E5a+b */
        ["CPYWMNSL", "PYWCMNDSLX", "IQX", "", "", ""], /* GPS */
        ["PC", "PC", "IQX", "", "", ""], /* GLO */
        ["CABXZ", "", "IQX", "ABCXZ", "IQX", "IQX"], /* GAL */
        ["CSLXZ", "SLX", "IQX", "SLX", "", ""], /* QZS */
        ["C", "", "IQX", "", "", ""], /* SBS */
        ["IQX", "IQX", "IQX", "IQX", "IQX", ""]  /* BDS */
    ]
    
    /// Get code priority for multiple codes in a frequency
    public static func getCodePri(sys: GNSSSystem, code: UInt8, opt: String?) -> Int {
        var i = 0
        var optStr = ""
        
        switch sys {
        case .gps: i = 0; optStr = "-GL%2s"
        case .glo: i = 1; optStr = "-RL%2s"
        case .gal: i = 2; optStr = "-EL%2s"
        case .qzs: i = 3; optStr = "-JL%2s"
        case .sbs: i = 4; optStr = "-SL%2s"
        case .cmp: i = 5; optStr = "-CL%2s"
        default: return 0
        }
        
        let obsInfo = GNSSStrings.code2obs(code)
        let obs = obsInfo.obs
        if obs.isEmpty { return 0 }
        let j = obsInfo.freq
        if j < 1 || j > 6 { return 0 }
        
        if let opt = opt {
            let optParts = opt.components(separatedBy: "-")
            for part in optParts {
                if part.isEmpty { continue }
                // Re-creating the sscanf behavior, "-GL%2s" -> we split by "-" so "GL1C"
                let prefix = String(optStr.dropFirst().prefix(2)) // e.g. "GL"
                if part.hasPrefix(prefix) {
                    let extracted = part.dropFirst(2)
                    if extracted.count >= 2 && extracted.first == obs.first {
                        let extractedSecond = extracted[extracted.index(extracted.startIndex, offsetBy: 1)]
                        let obsSecond = obs[obs.index(obs.startIndex, offsetBy: 1)]
                        return extractedSecond == obsSecond ? 15 : 0
                    }
                }
            }
        }
        
        let pStr = codePris[i][j - 1]
        let obsSecond = obs[obs.index(obs.startIndex, offsetBy: 1)]
        if let range = pStr.range(of: String(obsSecond)) {
            let dist = pStr.distance(from: pStr.startIndex, to: range.lowerBound)
            return 14 - dist
        }
        return 0
    }
}
