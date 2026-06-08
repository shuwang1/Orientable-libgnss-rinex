//
//  GNSSConstants.swift
//  GNSSRinex
//

public struct GNSSConstants {
    public static let cLight: Double = 299792458.0
    public static let sc2rad: Double = 3.1415926535898
    public static let au: Double = 149597870691.0

    public static let maxFreq = 7
    
    public static let freq1: Double = 1.57542E9
    public static let freq2: Double = 1.22760E9
    public static let freq5: Double = 1.17645E9
    public static let freq6: Double = 1.27875E9
    public static let freq7: Double = 1.20714E9
    public static let freq8: Double = 1.191795E9
    
    public static let freq1_glo: Double = 1.60200E9
    public static let dfrq1_glo: Double = 0.56250E6
    public static let freq2_glo: Double = 1.24600E9
    public static let dfrq2_glo: Double = 0.43750E6
    public static let freq3_glo: Double = 1.202025E9
    
    public static let freq1_cmp: Double = 1.561098E9
    public static let freq2_cmp: Double = 1.20714E9
    public static let freq3_cmp: Double = 1.26852E9

    public static let nFreq = 3
    public static let nExObs = 0
    public static let maxObs = 64
    public static let maxRcv = 64
    public static let maxObsType = 64
    public static let maxExFile = 1024
    public static let maxBand = 10
    public static let maxNIgp = 201
    public static let maxComment = 10
    public static let maxAnt = 64
    
    public static let minPrnGPS = 1
    public static let maxPrnGPS = 32
    public static let nSatGPS = (maxPrnGPS - minPrnGPS + 1)
    
    public static let minPrnGLO = 1
    public static let maxPrnGLO = 24
    public static let nSatGLO = (maxPrnGLO - minPrnGLO + 1)
    public static let nSysGLO = 1
    
    public static let minPrnGAL = 1
    public static let maxPrnGAL = 30
    public static let nSatGAL = (maxPrnGAL - minPrnGAL + 1)
    public static let nSysGAL = 1
    
    public static let minPrnQZS = 193
    public static let maxPrnQZS = 199
    public static let minPrnQZS_S = 183
    public static let maxPrnQZS_S = 189
    public static let nSatQZS = (maxPrnQZS - minPrnQZS + 1)
    public static let nSysQZS = 1
    
    public static let minPrnCMP = 1
    public static let maxPrnCMP = 35
    public static let nSatCMP = (maxPrnCMP - minPrnCMP + 1)
    public static let nSysCMP = 1
    
    public static let minPrnLEO = 1
    public static let maxPrnLEO = 10
    public static let nSatLEO = (maxPrnLEO - minPrnLEO + 1)
    public static let nSysLEO = 1
    
    public static let minPrnSBS = 120
    public static let maxPrnSBS = 142
    public static let nSatSBS = (maxPrnSBS - minPrnSBS + 1)
    
    public static let maxSat = (nSatGPS + nSatGLO + nSatGAL + nSatQZS + nSatCMP + nSatSBS + nSatLEO)
}

public struct GNSSSystem: OptionSet, Equatable, Sendable {
    public let rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    public static let none = GNSSSystem([])
    public static let gps  = GNSSSystem(rawValue: 0x01)
    public static let sbs  = GNSSSystem(rawValue: 0x02)
    public static let glo  = GNSSSystem(rawValue: 0x04)
    public static let gal  = GNSSSystem(rawValue: 0x08)
    public static let qzs  = GNSSSystem(rawValue: 0x10)
    public static let cmp  = GNSSSystem(rawValue: 0x20)
    public static let leo  = GNSSSystem(rawValue: 0x80)
    public static let all  = GNSSSystem(rawValue: 0xFF)
}

public enum GNSSTimeSystem: Int {
    case gps = 0
    case utc = 1
    case gal = 3
    case qzs = 4
    case cmp = 5
}
