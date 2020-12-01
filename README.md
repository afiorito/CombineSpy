# ![icon](combinespy.png) Combine Spy

A collection of utilities that make testing Combine publishers easier.

## Installation

Add Injector to your project using Swift Package Manager. In your Xcode project, select `File` > `Swift Packages` > `Add Package Dependency` and enter the repository URL.

## Usage

- [Elements](#elements)
- [Next](#next)

### Elements

The `elements()` method returns all input after waiting for the spied publisher to complete. If no completion is received before the timeout, the test fails.

```swift
// success - no failure
func testArrayPublisherCompletesWithSuccess() {
    let spy = [1, 2, 3].publisher.spy()
    XCTAssertEqual(spy.elements(), [1, 2, 3])
}

```

### Next

The `next()` method returns the next input received by the spied publisher. If no input is received before the timeout, the test fails.

```swift
// success - no failure
func testArrayOfTwoElementsPublishesInOrder() {
    let spy = [1, 2].publisher.spy()
    XCTAssertEqual(spy.next(), 1)
    XCTAssertEqual(spy.next(), 2)
}
```

## License

Combine Spy is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
