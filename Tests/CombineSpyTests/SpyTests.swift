import Combine
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

    func testLast() {
        let subject = PassthroughSubject<Int, Never>()
        let instantCompletionSpy = subject.prepend([1, 2, 3]).spy()

        XCTAssertEqual(instantCompletionSpy.last(), 3)

        subject.send(4)
        XCTAssertEqual(instantCompletionSpy.last(), 4)

        let delayedCompletionSpy = [1, 2].publisher
            .delay(for: .milliseconds(10), scheduler: DispatchQueue.main).spy()

        XCTAssertEqual(delayedCompletionSpy.last(), 2)
    }

    func testNext() {
        let subject = PassthroughSubject<Int, Never>()
        let instantCompletionSpy = subject.prepend([1, 2, 3]).spy()

        XCTAssertEqual(instantCompletionSpy.next(), 1)
        XCTAssertEqual(instantCompletionSpy.next(), 2)
        XCTAssertEqual(instantCompletionSpy.next(), 3)

        assertFailure {
            XCTAssertEqual(instantCompletionSpy.next(timeout: 1), nil)
        }

        subject.send(4)
        XCTAssertEqual(instantCompletionSpy.next(), 4)

        let delayedCompletionSpy = [1, 2].publisher
            .delay(for: .milliseconds(10), scheduler: DispatchQueue.main).spy()

        XCTAssertEqual(delayedCompletionSpy.next(), 1)
        XCTAssertEqual(delayedCompletionSpy.next(), 2)

        assertFailure {
            XCTAssertEqual(delayedCompletionSpy.next(timeout: 1), nil)
        }
    }
}
