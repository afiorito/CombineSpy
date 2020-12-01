import CombineSpy
import XCTest

final class AssertFailureTestCaseTests: AssertFailureTestCase {
    func testEmptyTest() {}

    func testExpectedAnyFailure() {
        assertFailure {
            XCTFail("foo")
        }
        assertFailure {
            XCTFail("foo")
            XCTFail("bar")
        }
    }

    func testMissingAnyFailure() {
        assertFailure("failed - No fail occured") {
            assertFailure {}
        }
    }

    func testExpectedFailure() {
        assertFailure("failed - foo") {
            XCTFail("foo")
        }
    }

    func testExpectedFailureMatchesOnPrefix() {
        assertFailure("failed - foo") {
            XCTFail("foobarbaz")
        }
    }

    func testOrderOfExpectedFailureIsIgnored() {
        assertFailure("failed - foo", "failed - bar") {
            XCTFail("foo")
            XCTFail("bar")
        }
        assertFailure("failed - bar", "failed - foo") {
            XCTFail("foo")
            XCTFail("bar")
        }
    }

    func testExpectedFailureCanBeRepeated() {
        assertFailure("failed - foo", "failed - foo", "failed - bar") {
            XCTFail("foo")
            XCTFail("bar")
            XCTFail("foo")
        }
    }

    func testExactNumberOfRepetitionIsRequired() {
        assertFailure("failed - \"failed - foo\" did not occur") {
            assertFailure("failed - foo", "failed - foo") {
                XCTFail("foo")
            }
        }
        assertFailure("failed - foo") {
            assertFailure("failed - foo", "failed - foo") {
                XCTFail("foo")
                XCTFail("foo")
                XCTFail("foo")
            }
        }
    }

    func testUnexpectedFailure() {
        assertFailure("failed - \"failed - foo\" did not occur") {
            assertFailure("failed - foo") {}
        }
    }

    func testMissedFailure() {
        assertFailure("failed - bar") {
            assertFailure("failed - foo") {
                XCTFail("foo")
                XCTFail("bar")
            }
        }
    }
}
