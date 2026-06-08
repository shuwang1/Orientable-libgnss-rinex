//
//  GNSSData.swift
//  GNSSRinex
//

public struct Obsd {
    public var time: GTime
    public var sat: UInt8
    public var rcv: UInt8
    public var snr: [UInt8]
    public var lli: [UInt8]
    public var code: [UInt8]
    public var L: [Double]
    public var P: [Double]
    public var D: [Float]

    public init() {
        self.time = GTime()
        self.sat = 0
        self.rcv = 0
        let count = GNSSConstants.nFreq + GNSSConstants.nExObs
        self.snr = [UInt8](repeating: 0, count: count)
        self.lli = [UInt8](repeating: 0, count: count)
        self.code = [UInt8](repeating: 0, count: count)
        self.L = [Double](repeating: 0.0, count: count)
        self.P = [Double](repeating: 0.0, count: count)
        self.D = [Float](repeating: 0.0, count: count)
    }
}

public struct ERPData {
    public var mjd: Double = 0.0
    public var xp: Double = 0.0
    public var yp: Double = 0.0
    public var xpr: Double = 0.0
    public var ypr: Double = 0.0
    public var ut1_utc: Double = 0.0
    public var lod: Double = 0.0
    public init() {}
}

public struct Alm {
    public var sat: Int = 0
    public var svh: Int = 0
    public var svconf: Int = 0
    public var week: Int = 0
    public var toa: GTime = GTime()
    public var A: Double = 0.0
    public var e: Double = 0.0
    public var i0: Double = 0.0
    public var OMG0: Double = 0.0
    public var omg: Double = 0.0
    public var M0: Double = 0.0
    public var OMGd: Double = 0.0
    public var toas: Double = 0.0
    public var f0: Double = 0.0
    public var f1: Double = 0.0
    public init() {}
}

public struct Tec {
    public var time: GTime = GTime()
    public var ndata: [Int] = [0, 0, 0]
    public var rb: Double = 0.0
    public var lats: [Double] = [0.0, 0.0, 0.0]
    public var lons: [Double] = [0.0, 0.0, 0.0]
    public var hgts: [Double] = [0.0, 0.0, 0.0]
    public var data: [Double] = []
    public var rms: [Float] = []
    public init() {}
}

public struct Stecd {
    public var time: GTime = GTime()
    public var sat: UInt8 = 0
    public var slip: UInt8 = 0
    public var iono: Float = 0.0
    public var rate: Float = 0.0
    public var rms: Float = 0.0
    public init() {}
}

public struct Stec {
    public var pos: [Double] = [0.0, 0.0]
    public var index: [Int] = [Int](repeating: 0, count: GNSSConstants.maxSat)
    public var data: [Stecd] = []
    public init() {}
}

public struct Pcv {
    public var sat: Int = 0
    public var type: String = ""
    public var code: String = ""
    public var ts: GTime = GTime()
    public var te: GTime = GTime()
    public var off: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: 3), count: GNSSConstants.nFreq)
    public var var_: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: 19), count: GNSSConstants.nFreq)
    public init() {}
}

public struct Sbsfcorr {
    public var t0: GTime = GTime()
    public var prc: Double = 0.0
    public var rrc: Double = 0.0
    public var dt: Double = 0.0
    public var iodf: Int = 0
    public var udre: Int16 = 0
    public var ai: Int16 = 0
    public init() {}
}

public struct Sbslcorr {
    public var t0: GTime = GTime()
    public var iode: Int = 0
    public var dpos: [Double] = [0.0, 0.0, 0.0]
    public var dvel: [Double] = [0.0, 0.0, 0.0]
    public var daf0: Double = 0.0
    public var daf1: Double = 0.0
    public init() {}
}

public struct Sbssatp {
    public var sat: Int = 0
    public var fcorr: Sbsfcorr = Sbsfcorr()
    public var lcorr: Sbslcorr = Sbslcorr()
    public init() {}
}

public struct Sbssat {
    public var iodp: Int = 0
    public var nsat: Int = 0
    public var tlat: Int = 0
    public var sat: [Sbssatp] = [Sbssatp](repeating: Sbssatp(), count: GNSSConstants.maxSat)
    public init() {}
}

public struct Sbsigp {
    public var t0: GTime = GTime()
    public var lat: Int16 = 0
    public var lon: Int16 = 0
    public var give: Int16 = 0
    public var delay: Float = 0.0
    public init() {}
}

public struct Sbsigpband {
    public var x: Int16 = 0
    public var y: [Int16] = []
    public var bits: UInt8 = 0
    public var bite: UInt8 = 0
    public init() {}
}

public struct Sbsion {
    public var iodi: Int = 0
    public var igp: [Sbsigp] = [Sbsigp](repeating: Sbsigp(), count: GNSSConstants.maxNIgp)
    public init() {}
}

public struct Dgps {
    public var t0: GTime = GTime()
    public var prc: Double = 0.0
    public var rrc: Double = 0.0
    public var iod: Int = 0
    public var udre: Double = 0.0
    public init() {}
}

public struct Ssr {
    public var t0: [GTime] = [GTime](repeating: GTime(), count: 5)
    public var udi: [Double] = [Double](repeating: 0.0, count: 5)
    public var iod: [Int] = [Int](repeating: 0, count: 5)
    public var iode: Int = 0
    public var iodcrc: Int = 0
    public var ura: Int = 0
    public var refd: Int = 0
    public var deph: [Double] = [0.0, 0.0, 0.0]
    public var ddeph: [Double] = [0.0, 0.0, 0.0]
    public var dclk: [Double] = [0.0, 0.0, 0.0]
    public var hrclk: Double = 0.0
    public var cbias: [Float] = [Float](repeating: 0.0, count: Int(GNSSStrings.maxCode))
    public var update: UInt8 = 0
    public init() {}
}

public struct Eph {
    public var sat: Int = 0
    public var iode: Int = 0
    public var iodc: Int = 0
    public var sva: Int = 0
    public var svh: Int = 0
    public var week: Int = 0
    public var code: Int = 0
    public var flag: Int = 0
    public var toe: GTime = GTime()
    public var toc: GTime = GTime()
    public var ttr: GTime = GTime()
    public var A: Double = 0.0
    public var e: Double = 0.0
    public var i0: Double = 0.0
    public var OMG0: Double = 0.0
    public var omg: Double = 0.0
    public var M0: Double = 0.0
    public var deln: Double = 0.0
    public var OMGd: Double = 0.0
    public var idot: Double = 0.0
    public var crc: Double = 0.0
    public var crs: Double = 0.0
    public var cuc: Double = 0.0
    public var cus: Double = 0.0
    public var cic: Double = 0.0
    public var cis: Double = 0.0
    public var toes: Double = 0.0
    public var fit: Double = 0.0
    public var f0: Double = 0.0
    public var f1: Double = 0.0
    public var f2: Double = 0.0
    public var tgd: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var Adot: Double = 0.0
    public var ndot: Double = 0.0
    public init() {}
}

public struct Geph {
    public var sat: Int = 0
    public var iode: Int = 0
    public var frq: Int = 0
    public var svh: Int = 0
    public var sva: Int = 0
    public var age: Int = 0
    public var toe: GTime = GTime()
    public var tof: GTime = GTime()
    public var pos: [Double] = [0.0, 0.0, 0.0]
    public var vel: [Double] = [0.0, 0.0, 0.0]
    public var acc: [Double] = [0.0, 0.0, 0.0]
    public var taun: Double = 0.0
    public var gamn: Double = 0.0
    public var dtaun: Double = 0.0
    public init() {}
}

public struct Peph {
    public var time: GTime = GTime()
    public var index: Int = 0
    public var pos: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: 4), count: GNSSConstants.maxSat)
    public var std: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: 4), count: GNSSConstants.maxSat)
    public var vel: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: 4), count: GNSSConstants.maxSat)
    public var vst: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: 4), count: GNSSConstants.maxSat)
    public var cov: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: 3), count: GNSSConstants.maxSat)
    public var vco: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: 3), count: GNSSConstants.maxSat)
    public init() {}
}

public struct Seph {
    public var sat: Int = 0
    public var t0: GTime = GTime()
    public var tof: GTime = GTime()
    public var sva: Int = 0
    public var svh: Int = 0
    public var pos: [Double] = [0.0, 0.0, 0.0]
    public var vel: [Double] = [0.0, 0.0, 0.0]
    public var acc: [Double] = [0.0, 0.0, 0.0]
    public var af0: Double = 0.0
    public var af1: Double = 0.0
    public init() {}
}

public struct Pclk {
    public var time: GTime = GTime()
    public var index: Int = 0
    public var clk: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: 1), count: GNSSConstants.maxSat)
    public var std: [[Float]] = [[Float]](repeating: [Float](repeating: 0.0, count: 1), count: GNSSConstants.maxSat)
    public init() {}
}

public struct Lexeph {
    public var toe: GTime = GTime()
    public var tof: GTime = GTime()
    public var sat: Int = 0
    public var health: UInt8 = 0
    public var ura: UInt8 = 0
    public var pos: [Double] = [0.0, 0.0, 0.0]
    public var vel: [Double] = [0.0, 0.0, 0.0]
    public var acc: [Double] = [0.0, 0.0, 0.0]
    public var jerk: [Double] = [0.0, 0.0, 0.0]
    public var af0: Double = 0.0
    public var af1: Double = 0.0
    public var tgd: Double = 0.0
    public var isc: [Double] = [Double](repeating: 0.0, count: 8)
    public init() {}
}

public struct Lexion {
    public var t0: GTime = GTime()
    public var tspan: Double = 0.0
    public var pos0: [Double] = [0.0, 0.0]
    public var coef: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: 2), count: 3)
    public init() {}
}

public struct Nav {
    public var eph: [Eph] = []
    public var geph: [Geph] = []
    public var seph: [Seph] = []
    public var peph: [Peph] = []
    public var pclk: [Pclk] = []
    public var alm: [Alm] = []
    public var tec: [Tec] = []
    public var stec: [Stec] = []
    public var erp: [ERPData] = []
    public var utc_gps: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var utc_glo: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var utc_gal: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var utc_qzs: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var utc_cmp: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var utc_sbs: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var ion_gps: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    public var ion_gal: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var ion_qzs: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    public var ion_cmp: [Double] = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
    public var leaps: Int = 0
    public var lam: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: GNSSConstants.nFreq), count: GNSSConstants.maxSat)
    public var cbias: [[Double]] = [[Double]](repeating: [Double](repeating: 0.0, count: 3), count: GNSSConstants.maxSat)
    public var wlbias: [Double] = [Double](repeating: 0.0, count: GNSSConstants.maxSat)
    public var glo_cpbias: [Double] = [0.0, 0.0, 0.0, 0.0]
    public var glo_fcn: [UInt8] = [UInt8](repeating: 0, count: GNSSConstants.maxPrnGLO + 1)
    public var pcvs: [Pcv] = [Pcv](repeating: Pcv(), count: GNSSConstants.maxSat)
    public var sbssat: Sbssat = Sbssat()
    public var sbsion: [Sbsion] = [Sbsion](repeating: Sbsion(), count: GNSSConstants.maxBand + 1)
    public var dgps: [Dgps] = [Dgps](repeating: Dgps(), count: GNSSConstants.maxSat)
    public var ssr: [Ssr] = [Ssr](repeating: Ssr(), count: GNSSConstants.maxSat)
    public var lexeph: [Lexeph] = [Lexeph](repeating: Lexeph(), count: GNSSConstants.maxSat)
    public var lexion: Lexion = Lexion()
    
    public init() {}
}

public struct Sta {
    public var name: String = ""
    public var marker: String = ""
    public var antdes: String = ""
    public var antsno: String = ""
    public var rectype: String = ""
    public var recver: String = ""
    public var recsno: String = ""
    public var antsetup: Int = 0
    public var itrf: Int = 0
    public var deltype: Int = 0
    public var pos: [Double] = [0.0, 0.0, 0.0]
    public var del: [Double] = [0.0, 0.0, 0.0]
    public var hgt: Double = 0.0
    public init() {}
}
