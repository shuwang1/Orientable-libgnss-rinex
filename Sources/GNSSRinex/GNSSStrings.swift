//
//  GNSSStrings.swift
//  GNSSRinex
//

public struct GNSSStrings {
    
    private static let obscodes: [String] = [
        "", "1C", "1P", "1W", "1Y", "1M", "1N", "1S", "1L", "1E", /*  0- 9 */
        "1A", "1B", "1X", "1Z", "2C", "2D", "2S", "2L", "2X", "2P", /* 10-19 */
        "2W", "2Y", "2M", "2N", "5I", "5Q", "5X", "7I", "7Q", "7X", /* 20-29 */
        "6A", "6B", "6C", "6X", "6Z", "6S", "6L", "8L", "8Q", "8X", /* 30-39 */
        "2I", "2Q", "6I", "6Q", "3I", "3Q", "3X", "1I", "1Q", ""    /* 40-49 */
    ]

    private static let obsfreqs: [UInt8] = [ /* 1:L1,2:L2,3:L5,4:L6,5:L7,6:L8,7:L3 */
        0, 1, 1, 1, 1, 1, 1, 1, 1, 1, /*  0- 9 */
        1, 1, 1, 1, 2, 2, 2, 2, 2, 2, /* 10-19 */
        2, 2, 2, 2, 3, 3, 3, 5, 5, 5, /* 20-29 */
        4, 4, 4, 4, 4, 4, 4, 6, 6, 6, /* 30-39 */
        2, 2, 4, 4, 3, 3, 3, 1, 1, 0  /* 40-49 */
    ]
    
    // Using 0 as CODE_NONE and 48 as MAXCODE
    public static let codeNone: UInt8 = 0
    public static let maxCode: UInt8 = 48

    /// Convert obs code type string to obs code
    /// - Parameters:
    ///   - obs: obs code string ("1C","1P","1Y",...)
    /// - Returns: Tuple of (obs code, frequency)
    public static func obs2code(_ obs: String) -> (code: UInt8, freq: Int) {
        for i in 1...Int(maxCode) {
            if obscodes[i] == obs {
                return (UInt8(i), Int(obsfreqs[i]))
            }
        }
        return (codeNone, 0)
    }

    /// Convert obs code to obs code string
    /// - Parameters:
    ///   - code: obs code
    /// - Returns: Tuple of (obs code string, frequency)
    public static func code2obs(_ code: UInt8) -> (obs: String, freq: Int) {
        if code <= codeNone || code > maxCode {
            return ("", 0)
        }
        let i = Int(code)
        return (obscodes[i], Int(obsfreqs[i]))
    }
}
