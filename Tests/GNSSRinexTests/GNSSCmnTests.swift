import XCTest
@testable import GNSSRinex

final class GNSSCmnTests: XCTestCase {
    
    func test_satNo_should_ConvertSysPrnToSatno() {
        // GPS
        XCTAssertEqual(GNSSCommon.satNo(sys: .gps, prn: 1), 1)
        XCTAssertEqual(GNSSCommon.satNo(sys: .gps, prn: 32), 32)
        XCTAssertEqual(GNSSCommon.satNo(sys: .gps, prn: 33), 0) // Out of bounds
        
        // GLO
        XCTAssertEqual(GNSSCommon.satNo(sys: .glo, prn: 1), 33)
        XCTAssertEqual(GNSSCommon.satNo(sys: .glo, prn: 24), 32 + 24)
        
        // Invalid
        XCTAssertEqual(GNSSCommon.satNo(sys: .none, prn: 1), 0)
        XCTAssertEqual(GNSSCommon.satNo(sys: .gps, prn: -1), 0)
    }
    
    func test_satsys_should_ConvertSatnoToSysPrn() {
        var sys: GNSSSystem
        var prn: Int
        
        // GPS
        (sys, prn) = GNSSCommon.satSys(1)
        XCTAssertEqual(sys, .gps)
        XCTAssertEqual(prn, 1)
        
        (sys, prn) = GNSSCommon.satSys(32)
        XCTAssertEqual(sys, .gps)
        XCTAssertEqual(prn, 32)
        
        // GLO
        (sys, prn) = GNSSCommon.satSys(33)
        XCTAssertEqual(sys, .glo)
        XCTAssertEqual(prn, 1)
        
        // Invalid
        (sys, prn) = GNSSCommon.satSys(0)
        XCTAssertEqual(sys, .none)
        XCTAssertEqual(prn, 0)
    }
    
    func test_satId2no_should_ParseSatIdString() {
        XCTAssertEqual(GNSSCommon.satId2No("G01"), 1)
        XCTAssertEqual(GNSSCommon.satId2No("G32"), 32)
        XCTAssertEqual(GNSSCommon.satId2No("R01"), 33)
        
        // Also parses bare numbers as GPS
        XCTAssertEqual(GNSSCommon.satId2No("1"), 1)
        
        // Invalid format
        XCTAssertEqual(GNSSCommon.satId2No("X01"), 0)
    }
}
