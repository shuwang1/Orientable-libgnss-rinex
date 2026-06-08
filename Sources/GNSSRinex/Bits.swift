//
//  Bits.swift
//  GNSSRinex
//

public struct Bits {
    
    /// Extract unsigned bits from byte data
    /// - Parameters:
    ///   - buff: The byte array
    ///   - pos: Starting bit position
    ///   - len: Number of bits to extract (1-32)
    /// - Returns: The extracted bits as UInt32
    public static func getBitU(_ buff: [UInt8], pos: Int, len: Int) -> UInt32 {
        var bits: UInt32 = 0
        var i = pos / 8
        var bitOffset = pos % 8
        var bitsLeft = len
        
        if len <= 0 || len > 32 || (pos + len) > buff.count * 8 { return 0 }
        
        while bitsLeft > 0 {
            var take = 8 - bitOffset
            if take > bitsLeft { take = bitsLeft }
            
            bits = (bits << take) | UInt32((buff[i] >> (8 - bitOffset - take)) & UInt8((1 << take) - 1))
            bitsLeft -= take
            bitOffset = 0
            i += 1
        }
        
        return bits
    }
    
    /// Extract signed bits from byte data
    /// - Parameters:
    ///   - buff: The byte array
    ///   - pos: Starting bit position
    ///   - len: Number of bits to extract (1-32)
    /// - Returns: The extracted bits as Int32 with sign extension
    public static func getBitS(_ buff: [UInt8], pos: Int, len: Int) -> Int32 {
        let bits = getBitU(buff, pos: pos, len: len)
        if len <= 0 || len >= 32 || (bits & (1 << (len - 1))) == 0 {
            return Int32(bits)
        }
        return Int32(bitPattern: bits | (~0 << len))
    }
    
    /// Set unsigned bits into byte data
    /// - Parameters:
    ///   - buff: The byte array (mutated in place)
    ///   - pos: Starting bit position
    ///   - len: Number of bits to set (1-32)
    ///   - data: The value to set
    public static func setBitU(_ buff: inout [UInt8], pos: Int, len: Int, data: UInt32) {
        var i = pos / 8
        var bitOffset = pos % 8
        var bitsLeft = len
        
        if len <= 0 || len > 32 || (pos + len) > buff.count * 8 { return }
        
        while bitsLeft > 0 {
            var take = 8 - bitOffset
            if take > bitsLeft { take = bitsLeft }
            
            let shift = 8 - bitOffset - take
            let mask = UInt8(((1 << take) - 1) << shift)
            
            let dataChunk = UInt8((data >> (bitsLeft - take)) & UInt32((1 << take) - 1))
            
            buff[i] = (buff[i] & ~mask) | (dataChunk << shift)
            
            bitsLeft -= take
            bitOffset = 0
            i += 1
        }
    }
    
    /// Set signed bits into byte data
    /// - Parameters:
    ///   - buff: The byte array (mutated in place)
    ///   - pos: Starting bit position
    ///   - len: Number of bits to set (1-32)
    ///   - data: The value to set
    public static func setBitS(_ buff: inout [UInt8], pos: Int, len: Int, data: Int32) {
        var d = data
        if d < 0 {
            d |= 1 << (len - 1)
        } else {
            d &= ~(1 << (len - 1))
        }
        setBitU(&buff, pos: pos, len: len, data: UInt32(bitPattern: d))
    }
}
