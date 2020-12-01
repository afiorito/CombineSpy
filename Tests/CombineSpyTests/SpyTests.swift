import Combine
import CombineExpectations
@testable import CombineSpy
import XCTest

final class CombineSpyTests: AssertFailureTestCase {
    func testSpySubscribes() {
        var subscribed = false
        let publisher = Empty<Void, Never>().handleEvents(receiveSubscription: { _ in subscribed = true })
        _ = publisher.spy()
        XCTAssertTrue(subscribed)
    }

    func testElements() {
        let instantCompletionSpy = [1, 2, 3].publisher.spy()
        XCTAssertEqual(instantCompletionSpy.elements(), [1, 2, 3])

        let delayedCompletionSpy = [1, 2, 3].publisher
            .delay(for: .milliseconds(10), scheduler: DispatchQueue.main).spy()
        XCTAssertEqual(delayedCompletionSpy.elements(), [1, 2, 3])
    }

    func testNext() {
        let instantCompletionSpy = [1, 2, 3].publisher.spy()

        XCTAssertEqual(instantCompletionSpy.next(), 1)
        XCTAssertEqual(instantCompletionSpy.next(), 2)
        XCTAssertEqual(instantCompletionSpy.next(), 3)

        assertFailure {
            XCTAssertEqual(instantCompletionSpy.next(timeout: 1), nil)
        }

        let delayedCompletionSpy = [1, 2].publisher
                    .delay(for: .milliseconds(10), scheduler: DispatchQueue.main).spy()

        XCTAssertEqual(delayedCompletionSpy.next(), 1)
        XCTAssertEqual(delayedCompletionSpy.next(), 2)

        assertFailure {
            XCTAssertEqual(delayedCompletionSpy.next(timeout: 1), nil)
        }
    }
}
