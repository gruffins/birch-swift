import Foundation
import XCTest

public class AsyncExample: ExampleBase {
    weak internal var group: AsyncExampleGroup?

    private let internalDescription: String
    private let closure: () async throws -> Void

    internal init(description: String, callsite: Callsite, flags: FilterFlags, closure: @escaping () async throws -> Void) {
        self.internalDescription = description
        self.closure = closure
        super.init(callsite: callsite, flags: flags)
    }

    public override var description: String {
        return internalDescription
    }

    /**
        The example name. A name is a concatenation of the name of
        the example group the example belongs to, followed by the
        description of the example itself.

        The example name is used to generate a test method selector
        to be displayed in Xcode's test navigator.
    */
    public override var name: String {
        guard let groupName = group?.name else { return description }
        return "\(groupName), \(description)"
    }

    public func run() async {
        let asyncWorld = AsyncWorld.sharedWorld
        let world = World.sharedWorld

        if world.numberOfExamplesRun == 0 {
            await MainActor.run {
                world.suiteHooks.executeBefores()
            }
        }

        let exampleMetadata = AsyncExampleMetadata(group: group!, example: self, exampleIndex: asyncWorld.numberOfAsyncExamplesRun)
        asyncWorld.currentExampleMetadata = exampleMetadata
        defer {
            asyncWorld.currentExampleMetadata = nil
        }

        group!.phase = .beforesExecuting

        let runExample: () async -> Void = { [closure, name, callsite] in
            self.group!.phase = .beforesFinished

            do {
                try await closure()
            } catch {
                if let stopTestError = error as? StopTest {
                    self.reportStoppedTest(stopTestError)
                } else if let testSkippedError = error as? XCTSkip {
                    self.reportSkippedTest(testSkippedError, name: name, callsite: callsite)
                } else {
                    self.reportFailedTest(error, name: name, callsite: callsite)
                }
            }

            self.group!.phase = .aftersExecuting
        }

        var cancelTests = false

        let handleThrowingClosure: (@escaping () async throws -> Void) -> () async -> Void = { [name, callsite] (closure: @escaping () async throws -> Void) in
            {
                if cancelTests { return }
                do {
                    try await closure()
                } catch {
                    self.reportFailedTest(error, name: name, callsite: callsite)
                    cancelTests = true
                }
            }
        }

        let allJustBeforeEachStatements = group!.justBeforeEachStatements + asyncWorld.exampleHooks.justBeforeEachStatements
        let justBeforeEachExample = allJustBeforeEachStatements.reduce(runExample as () async throws -> Void) { closure, wrapper in
            return { try await wrapper(exampleMetadata, handleThrowingClosure(closure)) }
        }

        let allWrappers = group!.wrappers + asyncWorld.exampleHooks.wrappers
        let wrappedExample = allWrappers.reduce(justBeforeEachExample) { closure, wrapper in
            return { try await wrapper(exampleMetadata, handleThrowingClosure(closure)) }
        }
        do {
            try await wrappedExample()
        } catch {
            self.reportFailedTest(error, name: name, callsite: callsite)
        }


        group!.phase = .aftersFinished

        asyncWorld.numberOfAsyncExamplesRun += 1

        if !asyncWorld.isRunningAdditionalSuites && world.numberOfExamplesRun >= world.cachedIncludedExampleCount {
            await MainActor.run {
                world.suiteHooks.executeAfters()
            }
        }
    }

    /**
        Evaluates the filter flags set on this example and on the example groups
        this example belongs to. Flags set on the example are trumped by flags on
        the example group it belongs to. Flags on inner example groups are trumped
        by flags on outer example groups.
    */
    internal override var filterFlags: FilterFlags {
        var aggregateFlags = flags
        for (key, value) in group!.filterFlags {
            aggregateFlags[key] = value
        }
        return aggregateFlags
    }

    #if canImport(Darwin)
    static internal let recordSkipSelector = NSSelectorFromString("recordSkipWithDescription:sourceCodeContext:")
    #endif

    internal func reportSkippedTest(_ testSkippedError: XCTSkip, name: String, callsite: Callsite) {
        #if !canImport(Darwin)
            return // This functionality is only supported by Apple's proprietary XCTest, not by swift-corelibs-xctest
        #else // `NSSelectorFromString` requires the Objective-C runtime, which is not available on Linux.

            let messageSuffix = """
                \n
                If nobody else has done so yet, please submit an issue to https://github.com/Quick/Quick/issues

                For now, we'll just benignly ignore skipped tests.
            """

            guard let testRun = AsyncSpec.current?.testRun else {
                print("""
                     [Quick Warning]: `AsyncSpec.current?.testRun` was unexpectededly `nil`.
                """ + messageSuffix)
                return
            }

            guard let skippedTestContextAny = testSkippedError.errorUserInfo["XCTestErrorUserInfoKeySkippedTestContext"] else {
                print("""
                [Quick Warning]: The internals of Apple's XCTestCaseRun have changed.
                    We expected the `errorUserInfo` dictionary of the XCTSKip error to contain a value for the key
                    "XCTestErrorUserInfoKeySkippedTestContext", but it didn't.
                """ + messageSuffix)
                return
            }

            // Uses an internal type "XCTSkippedTestContext", but "NSObject" will be sufficient for `perform(_:with:_with:)`.
            guard let skippedTestContext = skippedTestContextAny as? NSObject else {
                print("""
                [Quick Warning]: The internals of Apple's XCTestCaseRun have changed.
                    We expected `skippedTestContextAny` to have type `NSObject`,
                    but we got an object of type \(type(of: skippedTestContextAny))
                """ + messageSuffix)
                return
            }

            guard let sourceCodeContextAny = skippedTestContext.value(forKey: "sourceCodeContext") else {
                print("""
                [Quick Warning]: The internals of Apple's XCTestCaseRun have changed.
                    We expected `XCTSkippedTestContext` to have a `sourceCodeContext` property, but it did not.
                """ + messageSuffix)
                return
            }

            guard let sourceCodeContext = sourceCodeContextAny as? XCTSourceCodeContext else {
                print("""
                    [Quick Warning]: The internals of Apple's XCTestCaseRun have changed.
                    We expected `XCTSkippedTestContext.sourceCodeContext` to have type `XCTSourceCodeContext`,
                    but we got an object of type \(type(of: sourceCodeContextAny)).
                """ + messageSuffix)
                return
            }

            guard testRun.responds(to: Self.recordSkipSelector) else {
                print("""
                [Quick Warning]: The internals of Apple's XCTestCaseRun have changed, as it no longer responds to
                    the -[XCTSkip \(NSStringFromSelector(Self.recordSkipSelector))] message necessary to report skipped tests to Xcode.
                """ + messageSuffix)
               return
            }

            testRun.perform(Self.recordSkipSelector, with: testSkippedError.message, with: sourceCodeContext)
        #endif
    }

    internal func reportFailedTest(_ error: Error, name: String, callsite: Callsite) {
        let description = "Test \(name) threw unexpected error: \(error.localizedDescription)"

        #if canImport(Darwin)
            let file = callsite.file
            let location = XCTSourceCodeLocation(filePath: file, lineNumber: Int(callsite.line))
            let sourceCodeContext = XCTSourceCodeContext(location: location)
            let issue = XCTIssue(
                type: .thrownError,
                compactDescription: description,
                sourceCodeContext: sourceCodeContext
            )
            AsyncSpec.current?.record(issue)
        #else
            let file = callsite.file.description
            AsyncSpec.current?.recordFailure(
                withDescription: description,
                inFile: file,
                atLine: Int(callsite.line),
                expected: false
            )
        #endif
    }

    internal func reportStoppedTest(_ stopTestError: StopTest) {
        guard stopTestError.reportError else { return }

        let callsite = stopTestError.callsite

        #if canImport(Darwin)
            let file = callsite.file
            let location = XCTSourceCodeLocation(filePath: file, lineNumber: Int(callsite.line))
            let sourceCodeContext = XCTSourceCodeContext(location: location)
            let issue = XCTIssue(
                type: .assertionFailure,
                compactDescription: stopTestError.failureDescription,
                sourceCodeContext: sourceCodeContext
            )
            AsyncSpec.current?.record(issue)
        #else
            let file = callsite.file.description
            AsyncSpec.current?.recordFailure(
                withDescription: stopTestError.failureDescription,
                inFile: file,
                atLine: Int(callsite.line),
                expected: true
            )
        #endif
    }
}

extension AsyncExample {
    /**
        Returns a boolean indicating whether two Example objects are equal.
        If two examples are defined at the exact same callsite, they must be equal.
    */
    @nonobjc public static func == (lhs: AsyncExample, rhs: AsyncExample) -> Bool {
        return lhs.callsite == rhs.callsite
    }
}
