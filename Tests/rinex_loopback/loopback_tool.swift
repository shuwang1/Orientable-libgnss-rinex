import Foundation
import GNSSRinex

func main() {
    let args = CommandLine.arguments
    if args.count < 3 {
        print("Usage: \(args[0]) <input_rinex_nav> <output_rinex_nav>")
        exit(1)
    }
    
    let infile = args[1]
    let outfile = args[2]
    
    var nav = Nav()
    var optStruct = Rnxopt()
    var obs: [Obsd] = []
    var sta = Sta()
    
    print("Parsing: \(infile)")
    
    let stat = RinexParse.readRnx(file: infile, rcv: 0, opt: "", obs: &obs, nav: &nav, sta: &sta)
    if !stat {
        print("Failed to parse RINEX file: \(infile)")
        exit(1)
    }
    
    print("Parsed \(nav.eph.count) ephemeris.")
    
    do {
        let content = try String(contentsOfFile: infile, encoding: .ascii)
        if let firstLine = content.components(separatedBy: .newlines).first {
            let parts = firstLine.split(separator: " ", omittingEmptySubsequences: true)
            if let first = parts.first, let ver = Double(String(first)) {
                optStruct.rnxver = ver
            }
        }
    } catch {
        print("Failed to read input file for version")
        exit(1)
    }
    
    if optStruct.rnxver == 0 { optStruct.rnxver = 2.11 }
    
    optStruct.navsys = GNSSSystem([.gps, .glo, .gal, .qzs, .cmp, .sbs]).rawValue
    optStruct.outiono = 1
    optStruct.outtime = 1
    optStruct.outleaps = 1
    optStruct.prog = "LOOPBACK_TEST"
    
    print("Setting output RINEX version: \(String(format: "%.2f", optStruct.rnxver))")
    
    var outContent = ""
    outContent += RinexGenerate.outRnxNavH(opt: optStruct, nav: nav)
    
    for eph in nav.eph {
        outContent += RinexGenerate.outRnxNavB(opt: optStruct, eph: eph)
    }
    
    do {
        try outContent.write(toFile: outfile, atomically: true, encoding: .ascii)
        print("Regenerated: \(outfile)")
    } catch {
        print("Failed to write to output file")
        exit(1)
    }
}

main()
