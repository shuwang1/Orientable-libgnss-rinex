//
//  RinexTypes.swift
//  GNSSRinex
//

public struct Rnxctr {
    public var time: GTime = GTime()
    public var ver: Double = 0.0
    public var type: Character = " "
    public var sys: Int = 0
    public var tsys: Int = 0
    public var tobs: [[String]] = [[String]](repeating: [String](repeating: "", count: GNSSConstants.maxObsType), count: 6)
    public var obs: [Obsd] = []
    public var nav: Nav = Nav()
    public var sta: Sta = Sta()
    public var ephsat: Int = 0
    public var opt: String = ""
    public init() {}
}

public struct Rnxopt {
    public var ts: GTime = GTime()
    public var te: GTime = GTime()
    public var tint: Double = 0.0
    public var tunit: Double = 0.0
    public var rnxver: Double = 0.0
    public var navsys: Int = 0
    public var obstype: Int = 0
    public var freqtype: Int = 0
    public var mask: [String] = [String](repeating: "", count: 6)
    public var staid: String = ""
    public var prog: String = ""
    public var runby: String = ""
    public var marker: String = ""
    public var markerno: String = ""
    public var markertype: String = ""
    public var name: [String] = ["", ""]
    public var rec: [String] = ["", "", ""]
    public var ant: [String] = ["", "", ""]
    public var apppos: [Double] = [0.0, 0.0, 0.0]
    public var antdel: [Double] = [0.0, 0.0, 0.0]
    public var comment: [String] = [String](repeating: "", count: GNSSConstants.maxComment)
    public var rcvopt: String = ""
    public var exsats: [UInt8] = [UInt8](repeating: 0, count: GNSSConstants.maxSat)
    public var scanobs: Int = 0
    public var outiono: Int = 0
    public var outtime: Int = 0
    public var outleaps: Int = 0
    public var autopos: Int = 0
    public var tstart: GTime = GTime()
    public var tend: GTime = GTime()
    public var trtcm: GTime = GTime()
    public var tobs: [[String]] = [[String]](repeating: [String](repeating: "", count: GNSSConstants.maxObsType), count: 6)
    public var nobs: [Int] = [Int](repeating: 0, count: 6)
    public init() {}
}

public struct SigInd {
    public var n: Int = 0
    public var frq: [Int] = [Int](repeating: 0, count: GNSSConstants.maxObsType)
    public var pos: [Int] = [Int](repeating: -1, count: GNSSConstants.maxObsType)
    public var pri: [UInt8] = [UInt8](repeating: 0, count: GNSSConstants.maxObsType)
    public var type: [UInt8] = [UInt8](repeating: 0, count: GNSSConstants.maxObsType)
    public var code: [UInt8] = [UInt8](repeating: 0, count: GNSSConstants.maxObsType)
    public var shift: [Double] = [Double](repeating: 0.0, count: GNSSConstants.maxObsType)
    public init() {}
}
