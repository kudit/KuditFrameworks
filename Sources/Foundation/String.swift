//
//  String.swift
//  KuditFrameworks
//
//  Created by Ben Ku on 1/8/16.
//  Copyright © 2016 Kudit. All rights reserved.
//

@_exported import Foundation

/// TODO: Make note of how to convert a string to markdown?

// for NSDocumentTypeDocumentAttribute
//#if canImport(UIKit)
//import UIKit
//#elseif canImport(AppKit)
//import AppKit
//#endif
public extension Int64 {
    /// Formats this value as a number of bytes (or kB/MB/GB/etc) using the ByteCountFormatter() to get a nice clean string.
    var byteString: String {
        ByteCountFormatter().string(fromByteCount: self)
    }
}
public extension UInt64 {
    /// Formats this value as a number of bytes (or kB/MB/GB/etc) using the ByteCountFormatter() to get a nice clean string.
    var byteString: String {
        Int64(self).byteString
    }
}

public extension LosslessStringConvertible {
    /// Initialize from a possibly empty string and a default value if the string is nil or if the conversion fails
    init(string: String?, defaultValue: Self) {
        guard let string else {
            self = defaultValue
            return
        }
        guard let converted = Self(string) else {
            self = defaultValue
            return
        }
        self = converted
    }
}

extension CharacterSet: Testable {
    public static let tests = [
        Test("character strings", testCharacterStrings),
    ]
}
public extension CharacterSet {
    /// Returns the character set as an array of strings. (ONLY ASCII Characters!)
    var characterStrings: [String] {
        let unichars = Array(0..<128).map { UnicodeScalar($0)! }
        let filtered = unichars.filter(contains)
        return filtered.map { String($0) }
    }
    internal static let testCharacterStrings: TestClosure = {
        let array = "hello".characterStrings
        return (array == ["h","e","l","l","o"], String(describing:array))
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

// MARK: - HTML
public typealias HTML = String
public extension HTML {
    /// Cleans the HTML content to ensure this isn't just a snippet of HTML and includes the proper headers, etc.
    var cleaned: HTML {
        var cleaned = self
        if !cleaned.contains("<body>") {
            cleaned = """
<body>
\(cleaned)
</body>
"""
        }        
        if !cleaned.contains("<html>") {
            cleaned = """
<html>
\(cleaned)
</html>
"""
        }  
        return cleaned
    }
    /// Generate an NSAttributedString from the HTML content enclosed
    var attributedString: NSAttributedString {
        let cleaned = self.cleaned
        let data = Data(cleaned.utf8)
        if let attributedString = try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
            return attributedString
        }
        return NSAttributedString(string: cleaned)
    }
}

extension String: Testable {}
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
    /// Return whether this value should evalute to true whether it's a positive integer, "true", "t", "yes", "y", or "on" regardless of capitalization.
    var asBool: Bool {
        let lower = self.lowercased()
        let int = Int(self) ?? 0
        if int > 0 || lower == "true" || lower == "yes" || lower == "y" || lower == "t" || lower == "on" {
            return true
        }
        return false
    }
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
    /// Returns a URL if the String can be converted to URL.  `nil` otherwise.
    var asURL: URL? {
        // make sure data matches detector so "world.json" isn't seen as a valid URL.  must be fully qualified.
        guard isURL else {
            return nil
        }
        return URL(string: self)
    }

    /// Get last "path" component of a string (basically everything from the last `/` to the end)
    var lastPathComponent: String {
        let parts = self.components(separatedBy: "/")
        let last = parts.last ?? self
        return last
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
    /// Returns a new string made by removing from both ends of the `String` instances of the given string.
    // Fixed to use Substrings so we don't have to do length or indexing.
    func trimming(_ trimString: String) -> String {
        guard trimString.count > 0 else { // if we try to trim an empty string, infinite loop will happen below so just return.
            return self
        }
        var returnString = Substring(self)
        while returnString.hasPrefix(trimString) {
            //returnString = returnString.substring(from: returnString.characters.index(returnString.startIndex, offsetBy: trimString.length))
            let index = returnString.index(returnString.startIndex, offsetBy: trimString.count)
            returnString = returnString.suffix(from: index)
        }
        while returnString.hasSuffix(trimString) {
            let index = returnString.index(returnString.endIndex, offsetBy: -(trimString.count + 1)) // NOTE: Needs the +1 since the endIndex is one AFTER the position and we're using the "through:" syntax which includes the last index.
//            print("Trimming suffix \(trimString) from \(returnString) offset: \(-trimString.count)")
            returnString = returnString.prefix(through: index) // since through, need to be -1 to not be inclusive
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
    
    internal static let testTriming: TestClosure = {
        let long = "ExampleWorld/world.json"
        let trim = "world.json"
        let trimmed = long.trimming(trim)
        // assert
        return (trimmed == "ExampleWorld/", "Trimmed: \(trimmed)")
    }
    internal static let testTrimingEmpty: TestClosure = {
        let long = "ExampleWorld/world.json"
        let trim = ""
        let trimmed = long.trimming(trim)
        // assert
        return (trimmed == long, "Trimmed should match long: \(trimmed)")
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
    /// version of string with first letter of each sentence capitalized
    var sentenceCapitalized: String {
        let sentences = self.components(separatedBy: ".")
        var fixed = [String]()
        for sentence in sentences {
            var words = sentence.components(separatedBy: " ")
            for index in words.indices {
                // check for spaces or blank words
                if words[index].trimmed != "" {
                    words[index] = words[index].capitalized
                    break // only do first word
                }
            }
            fixed.append(words.joined(separator: " "))
        }
        return fixed.joined(separator: ".")
    }
    internal static let testSentenceCapitalized: TestClosure = {
        let capitalized = "hello world. goodbye world.".sentenceCapitalized
        return (capitalized == "Hello world. Goodbye world.", String(describing:capitalized))
    }

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
    internal static let testSubstring: TestClosure = {
        let extraction = TEST_STRING.substring(with: NSRange(7...12))
        return (extraction == "string" , String(describing:extraction))
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
    internal static let TEST_STRING = "A long string with some <em>intérressant</em> properties!"
    internal static let testExtractTags: TestClosure = {
        let extraction = TEST_STRING.extract(from: "<em>", to: "</em>") // should never fail
        return (extraction == "intérressant" , String(describing:extraction))
    }
    internal static let testExtractNilStart: TestClosure = {
        let extraction = TEST_STRING.extract(from: nil, to: "string")
        return (extraction == "A long " , String(describing:extraction))
    }
    internal static let testExtractNilEnd: TestClosure = {
        let extraction = TEST_STRING.extract(from: "</em>", to: nil)
        return (extraction == " properties!" , String(describing:extraction))
    }
    internal static let testExtractMissingStart: TestClosure = {
        let extraction = TEST_STRING.extract(from: "<strong>", to: "</em>")
        return (extraction == nil , String(describing:extraction))
    }
    internal static let testExtractMissingEnd: TestClosure = {
        let extraction = TEST_STRING.extract(from: "<em>", to: "</strong>")
        return (extraction == nil , String(describing:extraction))
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
    
    @MainActor
    static let tests = [
        Test("sentence capitalized", testSentenceCapitalized),
        Test("substring", testSubstring),
        Test("trimming", testTriming),
        Test("trimming empty", testTrimingEmpty),
        Test("extract tags", testExtractTags),
        Test("extract nil start", testExtractNilStart),
        Test("extract nil end", testExtractNilEnd),
        Test("extract missing start", testExtractMissingStart),
        Test("extract missing end", testExtractMissingEnd),
        Test("Line Reversal", testTextReversal)
    ]
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

// TODO: See where we can use @autoclosure in Kudit Frameworks to delay execution (particularly in test frameworks!)
public extension Optional where Wrapped == any Numeric {
    /// Support displaying string as an alternative in nil coalescing for inline \(optionalNum ?? "String description of nil")
    static func ?? (optional: Wrapped?, defaultValue: @autoclosure () -> String) -> String {
        if let optional {
            return String(describing: optional)
        } else {
            return defaultValue()
        }
    }
}

#if canImport(SwiftUI)
import SwiftUI
struct String_Previews: PreviewProvider {
    static var previews: some View {
        TestsListView(tests: String.tests)
    }
}
#endif

let testTextReversal: TestClosure = {
    let text = """
v1.0.8 8/10/2022 Manually created initializers for SwiftUI views to prevent internal protection errors.
v1.0.9 8/10/2022 Fixed tests to run in Xcode.  Added watchOS and tvOS support.
v1.0.10 8/11/2022 Removed a bunch of KuditConnect and non-critical code since those should be completely re-thought and added in a modern way and there is too much legacy code.
v1.0.11 8/11/2022 Removed unnecessary KuditFrameworks import from Image.swift.
v1.0.12 8/12/2022 changed String.contains() to String.containsAny() to be more clear.  Modified KuError to include public initializer and automatic Debug print.
v1.0.13 8/12/2022 Added File and Date and URL comparable code.  Need to migrate NSDate to Date.  
v1.0.14 8/24/2022 Added RingedText, ShareSheet, and Graphics code from old Swift Frameworks.
v1.0.15 8/25/2022 Checked added frameworks to make sure everything is marked public so usable by ouside code.
v1.0.16 8/25/2022 Made let properties on ShareSheet struct public vars hopefully to silence private init warning. 
v1.0.17 8/26/2022 Added public init to ShareSheet.  Added Coding framework. 
v1.0.18 8/26/2022 Added String.sentenceCapitalization.
v1.0.19 8/29/2022 Re-worked testing framework to be more robust and to allow code coverage tests in Xcode.
v1.0.20 8/30/2022 Removed shuffle and random since built-in as part of native Array functions.
v1.0.21 8/31/2022 Moved folders for KuditFrameworks into Sources folder since we already know this is for KuditFrameworks and removes unnecessary nesting.
v1.0.22 8/31/2022 Rearranged test order and shorted sleep test.
v1.0.23 9/8/2022 Added KuditLogo to framework from Tracker (not perfected yet).  Added preview to KuditFrameworksApp.  Fixed UIActivity missing from Mac (non-catalyst) build.
v1.0.24 9/8/2022 Removed conditions from ShareSheet as it prevents access on iOS for some reason.
v1.0.25 9/8/2022 Tweaked KuditLogo with some previews that have examples of how it might be used.
v1.0.26 9/14/2022 Added additional documentation to KuditFrameworks Threading.  Renamed KuError to CustomError.  Added ++ operator.  Added Date.pretty formatter. Added Image(data:Data) import extensions.  Added padding(size:) extension.  Added Color: Codable extensions.  Added Int.ordinal function.  Included deprecated message for KuError.  Added PlusPlus test.  Fixed Playgrounds test with #if canImport(PreviewProvider) to #if canImport(SwiftUI).  Fixed/Added App Icon.
v1.0.27 9/14/2022 Fixed permissions on methods.  Fixed package versioning and synced package.txt files.
v1.0.28 9/14/2022 Added signing capabilities for macOS network connections and added note about future dependency on DeviceKit project (replace any usage in KuditHardware since DeviceKit will be more likely updated regularly.)
v1.0.29 9/14/2022 Fixed problem with Readme comments continually reverting.  Added @available modifiers to code.  Restored mistakenly uploaded Package file.  Moved some TODOs around.
v1.0.30 9/14/2022 Fixed issue where last two updates were the wrong major version number!
v1.0.31 9/14/2022 Updated KuColor protocol to apply to SwiftUI Color.  Removed old UIImage code that could cause crashes.  Added .frame(size:) method.  Fixed issue with RGBA parsing and HSV calculations.  Re-worked SwiftUI color conformance to KuColor protocols to simplify.  Added some test methods.  Reversed order of versioning to make easier to find changes.
"""
    var lines = text.components(separatedBy: "\n")
    lines.reverse()
    let reversed = lines.joined(separator: "\n")
    print(reversed)
    let expected = """
v1.0.31 9/14/2022 Updated KuColor protocol to apply to SwiftUI Color.  Removed old UIImage code that could cause crashes.  Added .frame(size:) method.  Fixed issue with RGBA parsing and HSV calculations.  Re-worked SwiftUI color conformance to KuColor protocols to simplify.  Added some test methods.  Reversed order of versioning to make easier to find changes.
v1.0.30 9/14/2022 Fixed issue where last two updates were the wrong major version number!
v1.0.29 9/14/2022 Fixed problem with Readme comments continually reverting.  Added @available modifiers to code.  Restored mistakenly uploaded Package file.  Moved some TODOs around.
v1.0.28 9/14/2022 Added signing capabilities for macOS network connections and added note about future dependency on DeviceKit project (replace any usage in KuditHardware since DeviceKit will be more likely updated regularly.)
v1.0.27 9/14/2022 Fixed permissions on methods.  Fixed package versioning and synced package.txt files.
v1.0.26 9/14/2022 Added additional documentation to KuditFrameworks Threading.  Renamed KuError to CustomError.  Added ++ operator.  Added Date.pretty formatter. Added Image(data:Data) import extensions.  Added padding(size:) extension.  Added Color: Codable extensions.  Added Int.ordinal function.  Included deprecated message for KuError.  Added PlusPlus test.  Fixed Playgrounds test with #if canImport(PreviewProvider) to #if canImport(SwiftUI).  Fixed/Added App Icon.
v1.0.25 9/8/2022 Tweaked KuditLogo with some previews that have examples of how it might be used.
v1.0.24 9/8/2022 Removed conditions from ShareSheet as it prevents access on iOS for some reason.
v1.0.23 9/8/2022 Added KuditLogo to framework from Tracker (not perfected yet).  Added preview to KuditFrameworksApp.  Fixed UIActivity missing from Mac (non-catalyst) build.
v1.0.22 8/31/2022 Rearranged test order and shorted sleep test.
v1.0.21 8/31/2022 Moved folders for KuditFrameworks into Sources folder since we already know this is for KuditFrameworks and removes unnecessary nesting.
v1.0.20 8/30/2022 Removed shuffle and random since built-in as part of native Array functions.
v1.0.19 8/29/2022 Re-worked testing framework to be more robust and to allow code coverage tests in Xcode.
v1.0.18 8/26/2022 Added String.sentenceCapitalization.
v1.0.17 8/26/2022 Added public init to ShareSheet.  Added Coding framework. 
v1.0.16 8/25/2022 Made let properties on ShareSheet struct public vars hopefully to silence private init warning. 
v1.0.15 8/25/2022 Checked added frameworks to make sure everything is marked public so usable by ouside code.
v1.0.14 8/24/2022 Added RingedText, ShareSheet, and Graphics code from old Swift Frameworks.
v1.0.13 8/12/2022 Added File and Date and URL comparable code.  Need to migrate NSDate to Date.  
v1.0.12 8/12/2022 changed String.contains() to String.containsAny() to be more clear.  Modified KuError to include public initializer and automatic Debug print.
v1.0.11 8/11/2022 Removed unnecessary KuditFrameworks import from Image.swift.
v1.0.10 8/11/2022 Removed a bunch of KuditConnect and non-critical code since those should be completely re-thought and added in a modern way and there is too much legacy code.
v1.0.9 8/10/2022 Fixed tests to run in Xcode.  Added watchOS and tvOS support.
v1.0.8 8/10/2022 Manually created initializers for SwiftUI views to prevent internal protection errors.
"""
    return (expected == reversed, reversed)
}

extension Character {
    /// A simple emoji is one scalar and presented to the user as an Emoji
    var isSimpleEmoji: Bool {
        guard let firstScalar = unicodeScalars.first else { return false }
        return firstScalar.properties.isEmoji && firstScalar.value > 0x238C
    }
    
    /// Checks if the scalars will be merged into an emoji
    var isCombinedIntoEmoji: Bool { unicodeScalars.count > 1 && unicodeScalars.first?.properties.isEmoji ?? false }
    
    var isEmoji: Bool { isSimpleEmoji || isCombinedIntoEmoji }
}

extension String {
    var containsEmoji: Bool { contains { $0.isEmoji } }
}
