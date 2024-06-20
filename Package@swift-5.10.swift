// swift-tools-version:5.10
/*
 This source file is part of the Swift.org open source project

 Copyright (c) 2021-2024 Apple Inc. and the Swift project authors
 Licensed under Apache License v2.0 with Runtime Library Exception

 See https://swift.org/LICENSE.txt for license information
 See https://swift.org/CONTRIBUTORS.txt for Swift project authors
*/

import PackageDescription

func envEnable(_ key: String, default defaultValue: Bool = false) -> Bool {
    guard let value = Context.environment[key] else {
        return defaultValue
    }
    if value == "1" {
        return true
    } else if value == "0" {
        return false
    } else {
        return defaultValue
    }
}

let isSwiftCI = Context.environment["SWIFTCI_USE_LOCAL_DEPS"] != nil

let cmarkPackageName = isSwiftCI ? "cmark" : "swift-cmark"

let markdownTarget = Target.target(
    name: "Markdown",
    dependencies: [
        "CAtomic",
        .product(name: "cmark-gfm", package: cmarkPackageName),
        .product(name: "cmark-gfm-extensions", package: cmarkPackageName),
    ],
    exclude: [
        "CMakeLists.txt"
    ]
)
let markdownTestTarget = Target.testTarget(
    name: "MarkdownTests",
    dependencies: ["Markdown"],
    resources: [.process("Visitors/Everything.md")]
)

let package = Package(
    name: "swift-markdown",
    products: [
        .library(
            name: "Markdown",
            targets: ["Markdown"]),
    ],
    targets: [
        .target(name: "CAtomic"),
        markdownTarget,
        markdownTestTarget,
    ]
)

// If the `SWIFTCI_USE_LOCAL_DEPS` environment variable is set,
// we're building in the Swift.org CI system alongside other projects in the Swift toolchain and
// we can depend on local versions of our dependencies instead of fetching them remotely.
if !isSwiftCI {
    // Building standalone, so fetch all dependencies remotely.
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-cmark.git", branch: "gfm"),
    ]
    
    // SwiftPM command plugins are only supported by Swift version 5.6 and later.
    #if swift(>=5.6)
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ]
    #endif
} else {
    // Building in the Swift.org CI system, so rely on local versions of dependencies.
    package.dependencies += [
        .package(path: "../cmark"),
    ]
}

// Enable swift-testing by default on CI environment
let enableSwiftTesting = envEnable("SWIFT_MARKDOWN_SWIFT_TESTING_INTEGRATION", default: true)

if enableSwiftTesting {
    package.dependencies += [
        .package(url: "https://github.com/apple/swift-testing.git", exact: "0.6.0"),
    ]
    markdownTestTarget.dependencies.append(
        .product(name: "Testing", package: "swift-testing")
    )
    var swiftSettings = markdownTestTarget.swiftSettings ?? []
    swiftSettings.append(.define("SWIFT_MARKDOWN_SWIFT_TESTING_INTEGRATION"))
    markdownTestTarget.swiftSettings = swiftSettings
}
