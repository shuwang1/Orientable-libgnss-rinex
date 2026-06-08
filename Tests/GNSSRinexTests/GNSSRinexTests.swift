import XCTest
@testable import GNSSRinex

final class GNSSRinexTests: XCTestCase {
    
    // MARK: - Bits.swift Tests
    
    func test_getBitU_should_ExtractUnsignedBits() {
        let buff: [UInt8] = [0b10101010, 0b11001100, 0b11110000]
        
        // pos=0, len=8 -> 0b10101010 (170)
        XCTAssertEqual(Bits.getBitU(buff, pos: 0, len: 8), 170)
        
        // pos=4, len=4 -> 0b1010 (10)
        XCTAssertEqual(Bits.getBitU(buff, pos: 4, len: 4), 10)
        
        // pos=4, len=8 -> 0b10101100 (172)
        XCTAssertEqual(Bits.getBitU(buff, pos: 4, len: 8), 172)
    }
    
    func test_getBitS_should_ExtractSignedBits() {
        let buff: [UInt8] = [0b10101010, 0b11001100, 0b11110000]
        
        // pos=0, len=4 -> 1010 -> sign extended -> -6
        XCTAssertEqual(Bits.getBitS(buff, pos: 0, len: 4), -6)
        
        // pos=8, len=2 -> 11 -> sign extended -> -1
        XCTAssertEqual(Bits.getBitS(buff, pos: 8, len: 2), -1)
        
        // pos=4, len=4 -> 1010 -> sign extended -> -6
        XCTAssertEqual(Bits.getBitS(buff, pos: 4, len: 4), -6)
    }
    
    func test_setBitU_should_SetUnsignedBits() {
        var buff: [UInt8] = [0, 0, 0]
        
        // set 8 bits at pos 0
        Bits.setBitU(&buff, pos: 0, len: 8, data: 0xAA)
        XCTAssertEqual(buff[0], 0xAA)
        
        // set 4 bits at pos 8
        Bits.setBitU(&buff, pos: 8, len: 4, data: 0x0C)
        XCTAssertEqual(buff[1], 0xC0)
        
        // set cross-byte
        var buff2: [UInt8] = [0, 0, 0]
        Bits.setBitU(&buff2, pos: 4, len: 8, data: 0xAB) // 1010 1011
        // Expect: buff2[0] = 00001010 (0x0A), buff2[1] = 10110000 (0xB0)
        XCTAssertEqual(buff2[0], 0x0A)
        XCTAssertEqual(buff2[1], 0xB0)
    }
    
    func test_setBitS_should_SetSignedBits() {
        var buff: [UInt8] = [0, 0, 0]
        
        Bits.setBitS(&buff, pos: 0, len: 8, data: -2) // -2 is 0xFE
        XCTAssertEqual(buff[0], 0xFE)
        
        var buff2: [UInt8] = [0, 0, 0]
        Bits.setBitS(&buff2, pos: 4, len: 4, data: -1) // -1 is 0xF in 4 bits
        XCTAssertEqual(buff2[0], 0x0F)
    }
    
    // MARK: - CRC.swift Tests
    
    func test_crc24q_should_CalculateCorrectCrc() {
        let data: [UInt8] = [0xD3, 0x00, 0x04, 0x03, 0xE9, 0x00]
        let crc = CRC.crc24q(data)
        XCTAssertNotEqual(crc, 0)
    }
    
    func test_crc32_should_CalculateCorrectCrc() {
        let data: [UInt8] = [0xAA, 0x44, 0x12, 0x1C]
        let crc = CRC.crc32(data)
        XCTAssertNotEqual(crc, 0)
    }
}
