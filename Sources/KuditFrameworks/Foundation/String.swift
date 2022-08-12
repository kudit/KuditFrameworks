//
//  String.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 1/8/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

import Foundation

// for NSDocumentTypeDocumentAttribute
//#if canImport(UIKit)
//import UIKit
//#elseif canImport(AppKit)
//import AppKit
//#endif

public extension CharacterSet {
    /// Returns the character set as an array of strings. (ONLY ASCII Characters!)
    var characterStrings: [String] {
        let unichars = Array(0..<128).map { UnicodeScalar($0)! }
        let filtered = unichars.filter(contains)
        return filtered.map { String($0) }
    }

    /// Returns a character set containing all numeric digits.
    static var numerics: CharacterSet {
        let validCharacterString = "0123456789"
        return CharacterSet(charactersIn: validCharacterString)
    }
    /// Returns a character set containing the characters allowed in an URL's parameter subcomponent.
    static var urlParameterAllowed: CharacterSet {
        var validCharacterString = CharacterSet.alphanumerics.characterStrings.joined()
        validCharacterString += "-_.!~*()" // alphanumeric plus some additional valid characters
        return CharacterSet(charactersIn: validCharacterString)
    }
}

public extension String {
    static var INVALID_ENCODING = "INVALID_ENCODING"
    
    // MARK: - UUID Generation
    static func uuid() -> String {
        return UUID().uuidString
    }

    // MARK: - Introspection
    /*
    /// number of characters in the `String`
    @available(*, deprecated, message: "use String.count instead") // TODO: see where used and adapt.
    var length: Int {
        return self.count
    }
     */
    /// `true` iff `self` contains characters.
    ///
    /// Equivalent to `!self.isEmpty`
    var hasContent: Bool {
        return !self.isEmpty
    }
    /// Returns `true` iff the `String` contains one of the `strings` by case-sensitive, non-literal search.
    func containsAny(_ strings: [String]) -> Bool {
        for string in strings {
            if self.contains(string) {
                return true
            }
        }
        return false
    }
    /// Returns the number of times a string is included in the `String`.  Does not count overlaps.
    func occurrences(of substring: String) -> Int {
        let components = self.components(separatedBy: substring)
        return components.count - 1
    }
    /// `true` if there is only an integer number or double in the `String` and there isn't other letters or spaces.
    var isNumeric: Bool {
        if let _ = Double(self) {
            return true
//            if let intVersion = Int(foo) {
//                print("Int: \(intVersion)")
//            } else {
//                print("Double: \(doubleVersion)")
//            }
        }
        // print("NaN")
        return false
    }
    /// Helper for various data detector matches.
    /// Returns `true` iff the `String` matches the data detector type for the complete string.
    func matchesDataDetector(type: NSTextCheckingResult.CheckingType, scheme: String? = nil) -> Bool {
        let dataDetector = try? NSDataDetector(types: type.rawValue)
        guard let firstMatch = dataDetector?.firstMatch(in: self, options: NSRegularExpression.MatchingOptions.reportCompletion, range: NSRange(location: 0, length: count)) else {
            return false
        }
        return firstMatch.range.location != NSNotFound
            // make sure the entire string is an email, not just contains an email
            && firstMatch.range.location == 0
            && firstMatch.range.length == count
            // make sure the link type matches if link scheme
            && (type != .link || scheme == nil || firstMatch.url?.scheme == scheme)
    }
    /// `true` iff the `String` is an email address in the proper form.
    var isEmail: Bool {
        return matchesDataDetector(type: .link, scheme: "mailto")
    }
    /// `true` iff the `String` is a phone number in the proper form.
    var isPhoneNumber: Bool {
        return matchesDataDetector(type: .phoneNumber)
    }
    /// `true` iff the `String` is a phone number in the proper form.
    var isURL: Bool {
        return matchesDataDetector(type: .link)
    }
    /// `true` iff the `String` is an address in the proper form.
    var isAddress: Bool {
        return matchesDataDetector(type: .address)
    }

    /// `true` if the byte length of the `String` is larger than 100k (the exact threashold may change)
    var isLarge: Bool {
        let bytes = self.lengthOfBytes(using: String.Encoding.utf8)
        return bytes / 1024 > 100 // larger than 100k worth of text (that's still a LOT of lines)
    }
    /// `true` if the `String` appears to be a year after 1760 and before 3000 (use for reasonablly assuming text could be a year value)
    var isPostIndustrialYear: Bool {
        guard let year = Int(self) else {
            return false
        }
        guard self.isNumeric else {
            return false
        }
        return year > 1760 && year < 3000
    }
    /// an array of the characters of the `String` as strings
    // Objective-C was [string characters] which returned character strings.
    // Swift strings have a .characters method which returns an array of characters.
    // Matches the syntax for CharacterSet added above.
    var characterStrings: [String] {
        var characters = [String]()
        for character in self {
            characters += [String(character)]
        }
        return characters
        //return Array(self.characters).map { String($0) }
    }

    // MARK: - Trimming
    /// Returns a new string made by removing whitespace from both ends of the `String`.
    var trimmed: String {
        return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
    /// Removes whitespace from both ends of the `String`.
    mutating func trim() {
        self = self.trimmed
    }
    /// Returns a new string made by removing from both ends of the `String` instances of the given string.
    func trimming(_ trimString: String) -> String {
        var returnString = self[self.startIndex...self.endIndex]
        while returnString.hasPrefix(trimString) {
            //returnString = returnString.substring(from: returnString.characters.index(returnString.startIndex, offsetBy: trimString.length))
            let index = returnString.index(returnString.startIndex, offsetBy: trimString.count)
            returnString = returnString.suffix(from: index)
        }
        while returnString.hasSuffix(trimString) {
            let index = returnString.index(returnString.endIndex, offsetBy: -trimString.count)
            returnString = returnString.prefix(through: index)
            //returnString = returnString.substring(to: returnString.characters.index(returnString.endIndex, offsetBy: -trimString.length))
        }
        return String(returnString)
    }
    /// Removes the given string from both ends of the `String`.
    mutating func trim(_ trimString: String) {
        self = self.trimming(trimString)
    }
    /// Returns a new string made by removing from both ends of the `String` instances of any of the given strings.
    func trimming(_ trimStrings: [String]) -> String {
        var returnString = self
        for string in trimStrings {
            returnString = returnString.trimming(string)
        }
        return returnString
    }
    /// Removes the given strings from both ends of the `String`.
    mutating func trim(_ trimStrings: [String]) {
        self = self.trimming(trimStrings)
    }
    /// Returns a new string made by removing from both ends of the `String` characters contained in a given string.
    func trimmingCharacters(in string: String) -> String {
        let badSet = CharacterSet(charactersIn: string)
        return self.trimmingCharacters(in: badSet)
    }
    
    // MARK: - Replacements
    func replacingCharacters(in range: NSRange, with string: String) -> String {
        return (self as NSString).replacingCharacters(in: range, with: string)
    }

    /// Returns a new string in which all occurrences of any target
    /// strings in a specified range of the `String` are replaced by
    /// another given string.
    func replacingOccurrences(
        of targets: [String],
        with replacement: String,
        options: CompareOptions = [],
        range searchRange: Range<Index>? = nil
    ) -> String {
        var returnString = self // copy
        for search in targets {
            returnString = returnString.replacingOccurrences(of: search, with: replacement, options: options, range: searchRange)
        }
        return returnString
    }
    /// Returns a new string in which all characters in a target
    /// string in a specified range of the `String` are replaced by
    /// another given string.
    func replacingCharacters(
        in findCharacters: String,
        with replacement: String,
        options: CompareOptions = [],
        range searchRange: Range<Index>? = nil
        ) -> String {
        let characters = findCharacters.characterStrings
        return self.replacingOccurrences(of: characters, with: replacement, options: options, range: searchRange)
    }
    /// Returns a new string in which all characters in a target
    /// string in a specified range of the `String` are replaced by
    /// another given string.
    func replacingCharacters(
        in characterSet: CharacterSet,
        with replacement: String,
        options: CompareOptions = [],
        range searchRange: Range<Index>? = nil
        ) -> String {
        return self.components(separatedBy: characterSet).joined(separator: replacement)
    }
    
    // MARK: - Condensing
    /// Returns a trimmed string with all double spaces collapsed to single spaces and multiple line breaks collapsed to a single line break.  Removes non-breaking spaces.  Designed for making text compact.  (Note: for compatibility with KuditFrameworks.php, not used currently in any swift code).
    var whitespaceCollapsed: String {
        // replace non-breaking space with normal space (seems to not be included in whitespaces)
        var returnString = self.replacingOccurrences(of: " ", with: " ");
        // replace whitespace characters with spaces
        returnString = returnString.replacingOccurrences(of: CharacterSet.whitespaces.characterStrings, with: " ")
        // replace newline characters with new lines
        returnString = returnString.replacingOccurrences(of: CharacterSet.newlines.characterStrings, with: "\n")
        // collapse runs of spaces
        while returnString.contains("  ") {
            returnString = returnString.replacingOccurrences(of: "  ", with: " ")
        }
        // collapse runs of line breaks with a single line break
        while returnString.contains("\n\n") {
            returnString = returnString.replacingOccurrences(of: "\n\n", with: "\n")
        }
        return returnString.trimmed
    }
    // - (NSString *)
    //     stringByRemovingCharactersInString:(NSString *)target
    /// Returns a string with characters in the `characters` string removed.
    func removing(
        characters: String,
        options: CompareOptions = [],
        range searchRange: Range<Index>? = nil
    ) -> String {
        return self.replacingOccurrences(of: characters.characterStrings, with: "", options: options, range: searchRange)
    }
    // - (NSString *)
    //     stringByRemovingCharactersNotInString:(NSString *)target
    /// Returns a string containing only the characters found in the `characters` string.
    func preserving(
        characters: String,
        options: CompareOptions = [],
        range searchRange: Range<Index>? = nil
        ) -> String {
        let whitelistCharacterSet = CharacterSet(charactersIn: characters)
        let badCharacterSet = whitelistCharacterSet.inverted
        return self.components(separatedBy: badCharacterSet).joined(separator: "")
    }
    /// string with all duplicate characters removed
    var duplicateCharactersRemoved: String {
        return self.characterStrings.unique.joined(separator: "")
    }

    // MARK: - Transformed
    /// normalized version of string for comparisons and database lookups.  If normalization fails or results in an empty string, original string is returned.
    var normalized: String? {
        // expand ligatures and other joined characters and flatten to simple ascii (æ => ae, etc.) by converting to ascii data and back
        guard let data = self.data(using: String.Encoding.ascii, allowLossyConversion: true) else {
            print("WARNING: Unable to convert string to ASCII Data: \(self)")
            return self
        }
        guard let processed = String(data: data, encoding: String.Encoding.ascii) else {
            print("WARNING: Unable to decode ASCII Data normalizing stirng: \(self)")
            return self
        }
        var normalized = processed
        
        //    // remove non alpha-numeric characters
        normalized = normalized.replacingOccurrences(of: "?", with: "") // educated quotes and the like will be destroyed by above data conversion
        // replace diatrics and accented characters with normal equivalents
        // (probably unnecessary due to the ascii encoding above)
        normalized = normalized.decomposedStringWithCanonicalMapping
        // strip appostrophes
        normalized = normalized.replacingCharacters(in: "'", with: "")
        // replace non-alpha-numeric characters with spaces
        normalized = normalized.replacingCharacters(in: CharacterSet.alphanumerics.inverted, with: " ")
        // lowercase string
        normalized = normalized.lowercased()
        
        // remove multiple spaces and line breaks and tabs and trim
        normalized = normalized.whitespaceCollapsed
        
        // may return an empty string if no alphanumeric characters!  In this case, use the raw string as the "normalized" form (for Deckmaster card "____"
        if normalized == "" {
            return self
        } else {
            return normalized
        }
    }
    /// Returns the `String` reversed.
    var reversed: String {
        return self.characterStrings.reversed().joined(separator: "")
    }
    /// Returns the `String` repeated the specified number of times.
    func repeated(_ times: Int) -> String {
        return String(repeating: self, count: times)
    }

    /// An array of string of all the vowels in the english language (not counting Y).
    static var vowels: [String] {
        return ["a", "e", "i", "o", "u"]
    }
    
    /// An array of all the consonants in the english language (not counting Y).
    static var consonants: [String] {
        return ["b", "c", "d", "f", "g", "h", "j", "k", "l", "m", "n", "p", "q", "r", "s", "t", "v", "w", "x", "z"]
    }
    
    /// The name game string
    var banana : String {
        guard self.count > 1 else {
            return "\"\(self)\" is too short to play the name game :("
        }
        let secondIndex = self.index(startIndex, offsetBy: 1)
        let first = self[..<secondIndex].uppercased()
        //let first = substring(to:secondIndex).uppercased()
        var shortName = self
        if String.consonants.contains(first.lowercased()) {
            shortName = String(self[secondIndex...])
            //shortName = substring(from: secondIndex)
        }
        var string = "\(self), \(self), bo-"
        if "B" != first {
            string += "b"
        }
        string += "\(shortName)\nBanana-fana fo-"
        if "F" != first {
            string += "f"
        }
        string += "\(shortName)\nFee-fy-mo-"
        if "M" != first {
            string += "m"
        }
        string += "\(shortName)\n\(self)!"
        return string
    }

    // MARK: - Encoded
    /// URL encoded (% encoded) string or the `String` "`COULD_NOT_ENCODE`" if the `String` is not valid Unicode.
    var urlEncoded: String {
        // http://stackoverflow.com/a/33558934/897883
        guard let encoded = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlParameterAllowed) else {
            return String.INVALID_ENCODING
        }
        return encoded
    }
    /// String with non-file-safe characters replaced with an underscore (`_`).
    var fileSafe: String {
        return self.replacingCharacters(in: "/=\\?%*|'\"<>:", with:"_")
    }
    /// get the basename of the file without the extension (returns entire string if no extension)
    @available(*, deprecated, message: "use fileBasename method on NSURL") // TODO: see where used and adapt.
    var fileBasename: String {
        var parts = self.components(separatedBy: ".")
        guard parts.count > 1 else {
            return self
        }
        _ = parts.popLast() // strip off extension
        return parts.joined(separator: ".")
    }
    /// get the extension of the file
    @available(*, deprecated, message: "use pathExtension method on NSString") // TODO: see where used and adapt.
    var fileExtension: String {
        return self.replacingOccurrences(of: "\(self.fileBasename).", with: "")
    }

    // MARK: - HTML Tools
    /// String with XML style tags removed.
    var tagsStripped: String {
        var cleaned = self
        while let range = cleaned.range(of: "<[^>]+>", options: .regularExpression) {
            cleaned = cleaned.replacingCharacters(in: range, with: "")
        }
        return cleaned
    }
    var utf8data: Data? {
        return self.data(using: String.Encoding.utf8)
    }
#if canImport(NSAttributedString)
/// Attributed string if content contains HTML markup.  Can also be used to decode entities and strip tags.
    var attributedStringFromHTML: NSAttributedString? {
        guard let encodedData = self.utf8data else {
            print("WARNING: Unable to decode string data: \(self)")
            return nil
        }
        let attributedOptions : [String: AnyObject] = [
            NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType as AnyObject,
            NSCharacterEncodingDocumentAttribute: String.Encoding.utf8 as AnyObject
        ]
        do {
            return try NSAttributedString(data: encodedData, options: attributedOptions, documentAttributes: nil)
        } catch {
            print("WARNING: Problem getting encoded string: \(error)")
            return nil
        }
    }
#endif
    
    // MARK: - Parsing
    /// Fix to avoid casting String to NSString
    func substring(with range: NSRange) -> String { // TODO: figure out how to replace this...
        return (self as NSString).substring(with: range)
    }
    
    /// Parses out a substring from the first occurrence of `start` to the next occurrence of `end`.
    /// If `start` or `end` are `nil`, will parse from the beginning of the `String` or to the end of the `String`.
    /// If the `String` doesn't contain the start or end (whichever is provided), this will return nil.
    /// - Parameter from: start the extraction after the first occurrence of this string or from the beginning of the `String` if this is `nil`
    /// - Parameter to: end the extraction at the first occurrence of this string after `from` or at the end of the `String` if this is `nil`
    ///  - Return: the extracted string or nil if either start or end are not found
    // TODO: rename extracting?
    func extract(from start: String?, to end: String?) -> String? {
        // copy this string for use
        var substr = self
        if let start = start {
            guard self.contains(start) else {
                return nil
            }
            // get everything after the start tag
            var parts = substr.components(separatedBy: start)
            parts.removeFirst()
            substr = parts.joined(separator: start) // probably only 1 item, but just in case...
        }
        if let end = end {
            guard self.contains(end) else {
                return nil
            }
            // get everything before the end tag
            let parts = substr.components(separatedBy: end)
            substr = parts[0]
        }
        return substr
    }
    /// Deletes a section of text from the first occurrence of `start` to the next occurrence of `end` (inclusive).
    /// - Warning: string must contain `start` and `end` in order to work as expected.
    
    @available(*, deprecated, message: "There may be better ways to do this not in the standard library") // TODO: see where used and adapt.  If keep, change to deleting(from: to:) no throws (just don't do anything)
    func stringByDeleting(from start: String, to end: String) throws -> String {
        let scanner = Scanner(string: self)
        scanner.charactersToBeSkipped = nil // don't skip any whitespace!
        var beginning: NSString? = ""
        scanner.scanUpTo(start, into: &beginning)
        guard beginning != nil else {
            return self
        }
        scanner.scanUpTo(end, into: nil)
        scanner.scanString(end, into: nil)
        let tail = scanner.string.substring(from: self.index(self.startIndex, offsetBy: scanner.scanLocation))
        return "\(beginning!)" + tail
    }

    // MARK: - JSON Tools
    /// Return an object extracted from the JSON data in this string or nil if this is not a valid JSON string.
    var JSONObject: Any? {
        guard let data = self.utf8data else {
            print("WARNING: Unable to convert string to data: \(self)")
            return nil
        }
        do {
            return try JSONSerialization.jsonObject(with: data, options: [])
        } catch {
            // don't warn because this could be expected behavior print("WARNING: Unable to create JSON object: \(self)")
            return nil
        }
    }
    
    /// Tests for automated testing
    static var tests: [Test] {
        let testString = "A very long string with some <em>intérressant</em> properties!"
        return [
            Test("extractData()") {
                let extraction = testString.extract(from: "<em>", to: "</em>") // should never fail
                return (extraction == "intérressant" , String(describing:extraction))
            },
            Test("extractData() nil case start") {
                let extraction = testString.extract(from: "<strong>", to: "</em>")
                return (extraction == nil , String(describing:extraction))
            },
            Test("extractData() nil case end") {
                let extraction = testString.extract(from: "<em>", to: "</strong>")
                return (extraction == nil , String(describing:extraction))
            },
        ]
    }
}


public extension NSSecureCoding {
    /// helper for converting objects to JSON strings.
    
    fileprivate func JSONString(_ compact: Bool) -> String? {
        guard JSONSerialization.isValidJSONObject(self) else {
            print("WARNING: Invalid JSON object: \(self)")
            return nil
        }
        do {
            // Pass [] if you don't care about the readability of the generated string
            let jsonData = try JSONSerialization.data(withJSONObject: self, options: (compact ? [] : JSONSerialization.WritingOptions.prettyPrinted))
            return String(data: jsonData, encoding: String.Encoding.utf8)
        } catch {
            // may be intentional print("WARNING: Unable to write JSON: \(self)")
            return nil
        }
    }
    /// Convert a valid Object to string representation in compact form.
    var asJSON: String? {
        return self.JSONString(true)
    }
    /// Convert a valid Object to string representation in compact form.
    var asPrettyJSON: String? {
        return self.JSONString(false)
    }
}
