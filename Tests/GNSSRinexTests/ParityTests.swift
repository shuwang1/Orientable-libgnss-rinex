import XCTest
@testable import GNSSRinex

final class ParityTests: XCTestCase {
    
    func test_decodeWord_should_CheckParity() {
        var data: [UInt8] = [0, 0, 0]
        
        // A word of all 0s has 0 parity bits if previous D29, D30 are 0.
        var status = Parity.decodeWord(0x00000000, data: &data)
        
        XCTAssertTrue(status)
        XCTAssertEqual(data[0], 0x00)
        XCTAssertEqual(data[1], 0x00)
        XCTAssertEqual(data[2], 0x00)
        
        // Intentional parity error
        status = Parity.decodeWord(0x00000001, data: &data)
        XCTAssertFalse(status)
    }
}
