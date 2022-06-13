// ==============================================================================
// Character.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-19.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// Character extension
// ==============================================================================

// ==============================================================================
// Extension containing methods to test if a character is a member of a
// character set.
extension Character {
    /// True for any space character, and the control characters \t, \n, \r, \f,
    /// \v.
    var isSpace: Bool {
        switch self {
        case " ", "\t", "\n", "\r", "\r\n": return true

        case "\u{000B}", "\u{000C}": return true // Form Feed, vertical tab

        default: return false
        }
    }

    /// True for any Unicode space character, and the control characters \t, \n,
    /// \r, \f, \v.
    var isUnicodeSpace: Bool {
        switch self {
        case " ", "\t", "\n", "\r", "\r\n": return true

        // Form Feed, vertical tab, next line (nel)
        case "\u{000C}", "\u{000B}", "\u{0085}": return true

        // No-break space, ogham space mark, mongolian vowel
        case "\u{00A0}", "\u{1680}", "\u{180E}": return true

        // En quad, em quad, en space, em space, three-per-em space, four-per-em
        // space, six-per-em space, figure space, ponctuation space, thin space,
        // hair space, zero width space, zero width non-joiner, zero width
        // joiner.
        case "\u{2000}", "\u{2001}", "\u{2002}", "\u{2003}", "\u{2004}",
             "\u{2005}", "\u{2006}", "\u{2007}", "\u{2008}", "\u{2009}",
             "\u{200A}", "\u{200B}", "\u{200C}", "\u{200D}":

            return true

        // Line separator, paragraph separator.
        case "\u{2028}", "\u{2029}": return true

        // Narrow no-break space, medium mathematical space, word joiner,
        // ideographic space, zero width no-break space.
        case "\u{202F}", "\u{205F}", "\u{2060}", "\u{3000}", "\u{FEFF}":

            return true

        default: return false
        }
    }

    /// `true` if `self` normalized contains a single code unit that is in the
    /// categories of Uppercase and Titlecase Letters.
    var isUppercase: Bool {
        isMember(of: CharacterSet.uppercaseLetters)
    }

    /// `true` if `self` normalized contains a single code unit that is in the
    /// category of Lowercase Letters.
    var isLowercase: Bool {
        isMember(of: CharacterSet.lowercaseLetters)
    }

    /// `true` if `self` normalized contains a single code unit that is in the
    /// categories of Letters and Marks.
    var isAlpha: Bool {
        isMember(of: CharacterSet.letters)
    }

    /// `true` if `self` normalized contains a single code unit that is in th
    /// categories of Letters, Marks, and Numbers.
    var isAlphaNumeric: Bool {
        isMember(of: CharacterSet.alphanumerics)
    }

    /// `true` if `self` normalized contains a single code unit that is in the
    /// category of Symbols. These characters include, for example, the dollar
    /// sign ($) and the plus (+) sign.
    var isSymbol: Bool {
        isMember(of: CharacterSet.symbols)
    }

    /// `true` if `self` normalized contains a single code unit that is in the
    /// category of Decimal Numbers.
    var isDigit: Bool {
        isMember(of: CharacterSet.decimalDigits)
    }

    /// `true` if `self` is an ASCII decimal digit, i.e. between "0" and "9".
    var isDecimalDigit: Bool {
        "0123456789".contains(self)
    }

    /// `true` if `self` is an ASCII hexadecimal digit, i.e. "0"..."9",
    /// "a"..."f", "A"..."F".
    var isHexadecimalDigit: Bool {
        "01234567890abcdefABCDEF".contains(self)
    }

    /// `true` if `self` is an ASCII octal digit, i.e. between '0' and '7'.
    var isOctalDigit: Bool {
        "01234567".contains(self)
    }

    /// Return `true` if `self` normalized contains a single code unit that is a
    /// member of the supplied character set.
    ///
    /// - parameter set: The `NSCharacterSet` used to test for membership.
    /// - returns: `true` if `self` normalized contains a single code unit that
    ///   is a member of the supplied character set.
    func isMember(of set: CharacterSet) -> Bool {
        let normalized = String(self).precomposedStringWithCanonicalMapping
        let unicodes = normalized.unicodeScalars

        guard unicodes.count == 1 else { return false }

        return set.contains(unicodes.first!)
    }
}

// ==============================================================================
// Extension containing methods related to the conversion of a character.
extension Character {
    /// The first `UnicodeScalar` of `self`.
    var unicodeScalar: UnicodeScalar {
        let unicodes = String(self).unicodeScalars
        return unicodes[unicodes.startIndex]
    }

    /// Lowercase `self`.
    var lowercase: Character {
        let str = String(self).lowercased()
        return str[str.startIndex]
    }

    /// Uppercase `self`.
    var uppercase: Character {
        let str = String(self).uppercased()
        return str[str.startIndex]
    }
}
