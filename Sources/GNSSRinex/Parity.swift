//
//  Parity.swift
//  GNSSRinex
//

public struct Parity {
    
    private static let hamming: [UInt32] = [
        0xBB1F3480, 0x5D8F9A40, 0xAEC7CD00, 0x5763E680, 0x6BB1F340, 0x8B7A89C0
    ]
    
    /// Check parity and decode navigation data word
    /// - Parameters:
    ///   - word: Navigation data word (2+30bit)
    ///   - data: Buffer to store decoded navigation data without parity (8bit x 3)
    /// - Returns: True if parity is ok, false if parity error
    public static func decodeWord(_ word: UInt32, data: inout [UInt8]) -> Bool {
        var wWord = word
        var parity: UInt32 = 0
        
        if (wWord & 0x40000000) != 0 {
            wWord ^= 0x3FFFFFC0
        }
        
        for i in 0..<6 {
            parity <<= 1
            var w = (wWord & hamming[i]) >> 6
            while w != 0 {
                parity ^= w & 1
                w >>= 1
            }
        }
        
        if parity != (wWord & 0x3F) {
            return false
        }
        
        if data.count < 3 {
            data = [0, 0, 0]
        }
        
        for i in 0..<3 {
            data[i] = UInt8(truncatingIfNeeded: wWord >> (22 - i * 8))
        }
        
        return true
    }
}
