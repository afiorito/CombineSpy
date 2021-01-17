import Combine
import Foundation
import XCTest

/// A Combine subscriber which records input of a publisher.
///
/// You create a spy with the `spy()` method:
///
///     let spy = [1, 2, 3].publisher.spy()
///
public class Spy<Input, Failure: Error>: Subscriber {
    public typealias Input = Input
    public typealias Failure = Failure

    fileprivate init() {}

    /// Returns all input received by the spy after waiting for the spied publisher to complete.
    ///
    /// If no completion is received before the timeout, the test fails.
    ///
    /// For example:
    ///
    ///     // success - no failure
    ///     func testArrayPublisherCompletesWithSuccess() {
    ///         let spy = [1, 2, 3].publisher.spy()
    ///         XCTAssertEqual(spy.elements(), [1, 2, 3])
    ///     }
    ///
    /// - Parameters:
    ///     - timeout: The amount of seconds within which the spied publisher must finish.
    ///
    /// - Returns: The input received by the spy after waiting for completion.
    public func elements(timeout: TimeInterval = 5) -> [Input] {
        wait(for: .completion, timeout: timeout, description: "Waiting for elements timed out.")
        return sync { capturedElements }
    }

    /// Returns the next input received by the spy.
    ///
    /// If no input is received before the timeout, the test fails.
    ///
    /// For example:
    ///
    ///     // success - no failure
    ///     func testArrayOfTwoElementsPublishesInOrder() {
    ///         let spy = [1, 2].publisher.spy()
    ///         XCTAssertEqual(spy.next(), 1)
    ///         XCTAssertEqual(spy.next(), 2)
    ///      }
    ///
    /// - Parameters:
    ///     - timeout: The amount of seconds within which the spied publisher must send input.
    ///
    /// - Returns: The  next input received by the spy.
    public func next(timeout: TimeInterval = 5) -> Input? {
        let completed = wait(for: .input(1), timeout: timeout, description: "Waiting for next element timed out.")
        return completed ? sync {
            let index = nextIndex
            self.nextIndex += 1
            return index < capturedElements.count ? capturedElements[index] : nil
        } : nil
    }

    public func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    public func receive(_ input: Input) -> Subscribers.Demand {
        sync {
            self.capturedElements.append(input)
            switch expectationEvent {
                case let .input(count):
                    if capturedElements.count >= nextIndex + count {
                        self.expectation?.fulfill()
                        self.expectation = nil
                    }
                default:
                    break
            }
        }
        return .unlimited
    }

    public func receive(completion: Subscribers.Completion<Failure>) {
        sync {
            self.completion = completion

            switch expectationEvent {
                case .completion:
                    self.expectation?.fulfill()
                    self.expectation = nil
                default:
                    break
            }
        }
    }

    @discardableResult
    private func wait(for event: ExpectationEvent, timeout: TimeInterval, description: String) -> Bool {
        let expectation = XCTestExpectation()
        let waiter = XCTWaiter()
        let isCompleted: Bool = sync {
            self.expectationEvent = event
            self.expectation = expectation
            self.waiter = waiter

            switch event {
                case .completion:
                    if completion != nil {
                        return true
                    }
                case .input:
                    if capturedElements.count > nextIndex {
                        return true
                    }
                default:
                    break
            }

            return false
        }

        if !isCompleted && waiter.wait(for: [expectation], timeout: timeout) != .completed {
            XCTFail(description)
            return false
        }

        return true
    }

    private func sync<T>(_ block: () throws -> T) rethrows -> T {
        lock.lock()
        defer { lock.unlock() }
        return try block()
    }

    private enum ExpectationEvent {
        case completion
        case input(Int)
        case none
    }

    private var capturedElements = [Input]()
    private var completion: Subscribers.Completion<Failure>?
    private var nextIndex = 0
    private var expectationEvent: ExpectationEvent = .none

    private var expectation: XCTestExpectation?
    private var waiter: XCTWaiter?
    private let lock = NSLock()
}

// MARK: - Publisher Extension for Spy

extension Publisher {
    /// Attaches a spy subscriber to a publisher to capture input.
    ///
    /// - Returns: A cancellable instance which you use when you end assignment of the received values.
    ///   Deallocation of the result will tear down the subscription stream.
    public func spy() -> Spy<Output, Failure> {
        let spy = Spy<Output, Failure>()
        subscribe(spy)
        return spy
    }
}
