// ==============================================================================
// Parsec.swift
// SwiftParsec
//
// Created by David Dufresne on 2016-05-02.
// Copyright © 2016 David Dufresne. All rights reserved.
//
// Parsec protocol and related operator definitions.
// ==============================================================================

/// A `Stream` instance is responsible for maintaining the position of the
/// parser's stream.
public protocol Stream: Collection, ExpressibleByArrayLiteral
where ArrayLiteralElement == Element {}

extension String: Stream {
    /// Create an instance containing `elements`.
    public init(arrayLiteral elements: String.Iterator.Element...) {
        self.init(elements)
    }
}

// ==============================================================================
/// Types conforming to the `EmptyInitializable` protocol provide an empty
/// intializer.
public protocol EmptyInitializable {
    init()
}

// ==============================================================================
// Extensions implementing the `Stream` protocol for various collections.

extension Array: Stream, EmptyInitializable {}

extension ContiguousArray: Stream, EmptyInitializable {}

extension ArraySlice: Stream, EmptyInitializable {}

extension Dictionary: EmptyInitializable {}

extension Set: EmptyInitializable {}
