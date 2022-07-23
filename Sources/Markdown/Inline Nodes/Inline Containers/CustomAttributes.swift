/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

/// A set of one or more custom attributes.
public struct CustomAttributes: InlineMarkup, InlineContainer {
    public var _data: _MarkupData

    init(_ raw: RawMarkup) throws {
        guard case .customAttributes = raw.data else {
            throw RawMarkup.Error.concreteConversionError(from: raw, to: CustomAttributes.self)
        }
        let absoluteRaw = AbsoluteRawMarkup(markup: raw, metadata: MarkupMetadata(id: .newRoot(), indexInParent: 0))
        self.init(_MarkupData(absoluteRaw))
    }

    init(_ data: _MarkupData) {
        self._data = data
    }
}

// MARK: - Public API

public extension CustomAttributes {
    /// Create a set of custom attributes applied to zero or more child inline elements.
    init<Children: Sequence>(attributes: String, _ children: Children) where Children.Element == RecurringInlineMarkup {
        try! self.init(.customAttributes(attributes: attributes, parsedRange: nil, children.map { $0.raw.markup }))
    }

    /// Create a set of custom attributes applied to zero or more child inline elements.
    init(attributes: String, _ children: RecurringInlineMarkup...) {
        self.init(attributes: attributes, children)
    }
    
    /// The specified attributes in JSON5 format.
    var attributes: String {
        get {
            guard case let .customAttributes(attributes) = _data.raw.markup.data else {
                fatalError("\(self) markup wrapped unexpected \(_data.raw)")
            }
            return attributes
        }
        set {
            _data = _data.replacingSelf(.customAttributes(attributes: newValue, parsedRange: nil, _data.raw.markup.copyChildren()))
        }
    }
    
    // MARK: Visitation

    func accept<V: MarkupVisitor>(_ visitor: inout V) -> V.Result {
        return visitor.visitCustomAttributes(self)
    }
}
