import XCTest

/// An XTestCase subclass that can test for failures.
open class AssertFailureTestCase: XCTestCase {
    override open func setUpWithError() throws {
        isCapturing = false
        captures.removeAll()
    }

    override public func record(_ issue: XCTIssue) {
        if isCapturing {
            return captures.append(Capture(issue: issue))
        }

        super.record(issue)
    }

    /// Tests for the occurence of a failure in the given block.
    ///
    /// For example:
    ///
    ///     func testAssertFailure() {
    ///         assertFailure("failed - error") {
    ///             XCTFail("error")
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///     - prefixes: The prefixes for the failure descriptions.
    ///     - file: The source code file where the failture occured.
    ///     - line: The line number of the source code file where the failure occured.
    ///     - block: The block to test for failure occurences.
    ///
    ///     func testAssertFailure() {
    ///
    public func assertFailure(
        _ prefixes: String...,
        file: StaticString = #file,
        line: UInt = #line,
        _ block: () throws -> Void
    ) rethrows {
        let captures = try capture(block)

        let context =
            XCTSourceCodeContext(location: XCTSourceCodeLocation(filePath: String(describing: file),
                                                                 lineNumber: Int(line)))
        if prefixes.isEmpty {
            if captures.isEmpty {
                record(XCTIssue(
                    type: .assertionFailure,
                    compactDescription: "failed - No fail occured",
                    detailedDescription: nil,
                    sourceCodeContext: context,
                    associatedError: nil,
                    attachments: []
                ))
            }
        } else {
            let expectedCaptures = prefixes.map {
                Capture(issue: XCTIssue(
                    type: .assertionFailure,
                    compactDescription: $0,
                    detailedDescription: nil,
                    sourceCodeContext: context,
                    associatedError: nil,
                    attachments: []
                ))
            }

            assertIssuesMatch(captures, expectedCaptures)
        }
    }

    private func assertIssuesMatch(_ captures: [Capture], _ expectedCaptures: [Capture]) {
        let diff = expectedCaptures.difference(from: captures).inferringMoves()

        for change in diff.reversed() {
            switch change {
                case let .insert(offset: _, element: capture, associatedWith: nil):
                    record(capture.issue { "failed - \"\($0)\" did not occur" })
                case let .remove(offset: _, element: capture, associatedWith: nil):
                    record(capture.issue)
                default:
                    break
            }
        }
    }

    private func capture(_ block: () throws -> Void) rethrows -> [Capture] {
        let prevIsCapturing = isCapturing
        let prevCaptures = captures
        defer {
            isCapturing = prevIsCapturing
            captures = prevCaptures
        }
        isCapturing = true
        captures.removeAll()
        try block()
        return captures
    }

    private var captures = [Capture]()
    private var isCapturing = false
}

// MARK: - Test Case Capture

extension AssertFailureTestCase {
    private struct Capture: Hashable {
        let issue: XCTIssue

        func issue(_ compactDescription: (String) -> String) -> XCTIssue {
            XCTIssue(
                type: issue.type,
                compactDescription: compactDescription(issue.compactDescription),
                detailedDescription: issue.detailedDescription,
                sourceCodeContext: issue.sourceCodeContext,
                associatedError: issue.associatedError,
                attachments: issue.attachments
            )
        }

        func hash(into hasher: inout Hasher) {
            hasher.combine(0)
        }

        var description: String {
            issue.compactDescription
        }

        static func == (lhs: Capture, rhs: Capture) -> Bool {
            lhs.description.hasPrefix(rhs.description) || rhs.description.hasPrefix(lhs.description)
        }
    }
}
