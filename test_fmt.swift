import Foundation
let str1 = "TEST1"
let str2 = "TEST2"
let s1 = str1.padding(toLength: 20, withPad: " ", startingAt: 0) + str2.padding(toLength: 20, withPad: " ", startingAt: 0)
print("[\(s1)]")
