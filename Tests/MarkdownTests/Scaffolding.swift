/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2024 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

#if SWIFT_MARKDOWN_SWIFT_TESTING_INTEGRATION
import Testing
import XCTest

final class AllTests: XCTestCase {
    func testAll() async {
        await XCTestScaffold.runAllTests(hostedBy: self)
    }
}
#endif
