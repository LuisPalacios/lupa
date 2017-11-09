//
//  LPString.swift
//  lupa
//
//  Created by Luis Palacios on 27/9/15.
//  Copyright © 2015 Luis Palacios. All rights reserved.
//

import Foundation

extension String {
    
    public func replace (_ oldString: String, _ newString: String) -> String {
        return self.replacingOccurrences(of: oldString, with: newString)
    }
    
//    /** Replace the first `limit` occurrences of oldString with newString. */
//    public func replace (oldString: String, _ newString: String, limit: Int) -> String {
//        let ranges = self.findAll(oldString) |> take(limit)
//        return ranges.count == 0
//            ? self
//            : self.stringByReplacingOccurrencesOfString(oldString, withString: newString,
//                range: ranges.first!.startIndex ..< ranges.last!.endIndex)
//    }
    
    public func split (_ sep: String) -> [String] {
        return self.components(separatedBy: sep)
    }
    
    public func trim () -> String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    
//    public func countOccurrencesOf (substring: String) -> Int {
//        return (self.findAll(substring) |> toArray).count
//    }
    
//    /** A lazy sequence of the ranges of `findstring` in this string. */
//    public func findAll (_ findstring: String) -> AnySequence<Range<String.Index>> {
//        var rangeofremainder: Range = self.characters.indices
//        return AnySequence (AnyIterator {
//            if let foundrange = self.range(of: findstring, range:rangeofremainder) {
//                rangeofremainder = foundrange.upperBound..<self.endIndex
//                return foundrange
//            } else {
//                return nil
//            }
//            })
//    }
    
    /**
    Split the string at the first occurrence of separator, and return a 3-tuple containing the part
    before the separator, the separator itself, and the part after the separator. If the separator is
    not found, return a 3-tuple containing the string itself, followed by two empty strings.
    */
    public func partition (_ separator: String) -> (String, String, String) {
        if let separatorRange = self.range(of: separator) {
            if !separatorRange.isEmpty {
                let firstpart = self[self.startIndex ..< separatorRange.lowerBound]
                let secondpart = self[separatorRange.upperBound ..< self.endIndex]
                
                return (String(firstpart), separator, String(secondpart))
            }
        }
        return (self,"","")
    }

    // Returns true if string is either empty or has only spaces
    func isEmptyOrWhitespace() -> Bool {
        
        if(self.isEmpty) {
            return true
        }
        
        return (self.trimmingCharacters(in: CharacterSet.whitespaces) == "")
    }
    

    
}
