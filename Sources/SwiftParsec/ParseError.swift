// ==============================================================================
// Error.swift
// SwiftParsec
//
// Created by David Dufresne on 2015-09-04.
// Copyright © 2015 David Dufresne. All rights reserved.
//
// Parse errors.
// ==============================================================================

// ==============================================================================
/// Message represents parse error messages. The fine distinction between
/// different kinds of parse errors allows the system to generate quite good
/// error messages for the user. It also allows error messages that are
/// formatted in different languages. Each kind of message is generated by
/// different combinators.
///
/// The `Comparable` protocol is implemented based on the index of a message.
public enum Message: Comparable {
    /// A `SystemUnexpected` message is automatically generated by the
    /// `satisfy` combinator. The argument is the unexpected input.
    case systemUnexpected(String)

    /// An `Unexpected` message is generated by the `unexpected` combinator.
    /// The argument describes the unexpected item.
    case unexpected(String)

    /// An `Expect` message is generated by the `<?>` combinator. The argument
    /// describes the expected item.
    case expected(String)

    /// A `Generic` message is generated by the `fail` combinator. The argument
    /// is some general parser message.
    case generic(String)

    /// The index of the message type.
    var index: Int {
        switch self {
        case .systemUnexpected: return 0

        case .unexpected: return 1

        case .expected: return 2

        case .generic: return 3
        }
    }

    /// The message string.
    var messageString: String {
        switch self {
        case .systemUnexpected(let str): return str

        case .unexpected(let str): return str

        case .expected(let str): return str

        case .generic(let str): return str
        }
    }
}

// ==============================================================================
// Operator implementations for the `Message` type.

/// Equality based on the index.
public func == (leftMsg: Message, rightMsg: Message) -> Bool {
    leftMsg.index == rightMsg.index
}

/// Comparison based on the index.
public func < (leftMsg: Message, rightMsg: Message) -> Bool {
    leftMsg.index < rightMsg.index
}

// ==============================================================================
/// `ParseError` represents parse errors. It provides the source position
/// (`SourcePosition`) of the error and an array of error messages (`Message`).
/// A `ParseError` can be returned by the function `parse`.
public struct ParseError: Error, CustomStringConvertible {
    /// Return an unknown parse error.
    ///
    /// - parameter position: The current position.
    /// - returns: An unknown parse error.
    static func unknownParseError(_ position: SourcePosition) -> ParseError {
        ParseError(position: position, messages: [])
    }

    /// Return a system unexpected parse error.
    ///
    /// - parameters:
    ///   - position: The current position.
    ///   - message: The message string.
    /// - returns: An unexpected parse error.
    static func unexpectedParseError(
        _ position: SourcePosition,
        message: String
    ) -> ParseError {
        ParseError(
            position: position,
            messages: [.systemUnexpected(message)]
        )
    }

    /// Source position of the error.
    public var position: SourcePosition

    /// Sorted array of error messages.
    public var messages: [Message] {
        get { _messages.sorted() }

        set { _messages = newValue }
    }

    // Backing store for `messages`.
    private var _messages = [Message]()

    /// A textual representation of `self`.
    public var description: String {
        String(describing: position) + ":\n" + messagesDescription
    }

    /// Indicates if `self` is an unknown parse error.
    var isUnknown: Bool { messages.isEmpty }

    private var messagesDescription: String {
        guard !messages.isEmpty else {
            return LocalizedString("unknown parse error")
        }

        let (sysUnexpected, msgs1) =
            messages.part { $0 == .systemUnexpected("") }
        let (unexpected, msgs2) = msgs1.part { $0 == .unexpected("") }
        let (expected, generic) = msgs2.part { $0 == .expected("") }

        // System unexpected messages.
        let sysUnexpectedDesc: String

        let unexpectedMsg = LocalizedString("unexpected")

        if !unexpected.isEmpty || sysUnexpected.isEmpty {
            sysUnexpectedDesc = ""
        } else {
            let firstMsg = sysUnexpected.first!.messageString

            if firstMsg.isEmpty {
                sysUnexpectedDesc = LocalizedString("unexpected end of input")
            } else {
                sysUnexpectedDesc = unexpectedMsg + " " + firstMsg
            }
        }

        // Unexpected messages.
        let unexpectedDesc =
            formatMessages(unexpected, havingType: unexpectedMsg)

        // Expected messages.
        let expectingMsg = LocalizedString("expecting")
        let expectedDesc = formatMessages(expected, havingType: expectingMsg)

        // Generic messages.
        let genericDesc = formatMessages(generic, havingType: "")

        let descriptions = [
            sysUnexpectedDesc, unexpectedDesc, expectedDesc, genericDesc
        ]

        return descriptions.removingDuplicatesAndEmpties().joined(
            separator: "\n"
        )
    }

    /// Initializes from a source position and an array of messages.
    init(position: SourcePosition, messages: [Message]) {
        self.position = position
        self.messages = messages
    }

    /// Insert a message error in `messages`. All messages equal to the inserted
    /// messages are removed and the new message is inserted at the beginning of
    /// `messages`.
    ///
    /// - parameter message: The new message to insert in `messages`.
    mutating func insertMessage(_ message: Message) {
        messages = messages.filter({ $0 != message }).prepending(message)
    }

    /// Insert the labels as `.Expected` message errors in `messages`.
    ///
    /// - parameter labels: The labels to insert.
    mutating func insertLabelsAsExpected(_ labels: [String]) {
        guard !labels.isEmpty else {
            insertMessage(.expected(""))
            return
        }

        insertMessage(.expected(labels[0]))

        for label in labels.suffix(from: 1) {
            messages.append(.expected(label))
        }
    }

    /// Merge this `ParseError` with another `ParseError`.
    ///
    /// - parameter other: `ParseError` to merge with `self`.
    mutating func merge(_ other: ParseError) {
        let otherIsEmpty = other.messages.isEmpty

        // Prefer meaningful error.
        if messages.isEmpty && !otherIsEmpty {
            self = other
        } else if !otherIsEmpty {
            // Select the longest match
            if position == other.position {
                messages += other.messages
            } else if position < other.position {
                self = other
            }
        }
    }

    private func formatMessages(
        _ messages: [Message],
        havingType messageType: String
    ) -> String {
        let msgs = messages.map({
            $0.messageString
        }).removingDuplicatesAndEmpties()

        guard !msgs.isEmpty else { return "" }

        let msgType = messageType.isEmpty ? "" : messageType + " "

        if msgs.count == 1 {
            return msgType + msgs.first!
        }

        let commaSep = msgs.dropLast().joined(separator: ", ")

        let orStr = LocalizedString("or")

        return msgType + commaSep + " " + orStr + " " + msgs.last!
    }
}

// ==============================================================================
// Extension to add ad-hoc methods on the `Sequence` type.
extension Sequence where Iterator.Element == String {
    /// Return an array with duplicate and empty strings removed.
    func removingDuplicatesAndEmpties() -> [Self.Iterator.Element] {
        self.removingDuplicates().filter { !$0.isEmpty }
    }
}
