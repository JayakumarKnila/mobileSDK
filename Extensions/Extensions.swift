//
//  Extensions.swift
//  POS
//
//  Created by Gal Blank on 12/7/15.
//  Copyright © 2015 1stPayGateway. All rights reserved.
//

import Foundation


extension String {
    
    subscript (i: Int) -> Character {
        return self[self.startIndex.advancedBy(i)]
    }
    
    subscript (i: Int) -> String {
        return String(self[i] as Character)
    }
    
    subscript (r: Range<Int>) -> String {
        return substringWithRange(Range(start: startIndex.advancedBy(r.startIndex), end: startIndex.advancedBy(r.endIndex)))
    }
    
    func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
        let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
        let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
        if let from = String.Index(from16, within: self),
            let to = String.Index(to16, within: self) {
                return from ..< to
        }
        return nil
    }
    
    func urlEncodedString() -> String? {
        let customAllowedSet =  NSCharacterSet.URLQueryAllowedCharacterSet()
        let escapedString = self.stringByAddingPercentEncodingWithAllowedCharacters(customAllowedSet)
        return escapedString
    }

    
    func validateEmail(email:String) -> Bool{
        let emailRegex:String = String("[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}")
        let emailTest: NSPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailTest.evaluateWithObject(email)
    }
    
}

extension Dictionary {
    mutating func merge<K, V>(dict: [K: V]){
        for (k, v) in dict {
            self.updateValue(v as! Value, forKey: k as! Key)
        }
    }
}

//extension DbLocalError: CustomStringConvertible {
//    var description: String {
//        switch self {
//        case ErrorNone: return "NoError"
//        case ErrorOnInsert: return "Error on INSERT"
//        case ErrorOnUpdate: return "Error on UPDATE"
//        case ErrorOnDelete: return "Error on DELETE"
//        case ErrorUnKnown: return "Unknown Error"
//        default: return "Hello"
//        }
//    }
//}

