<p align="center">
<img src="https://user-images.githubusercontent.com/381273/204187386-ec93e173-a6fa-40b1-8b74-c52a0c5048b3.png" />
</p>

# Birch
![Tests](https://github.com/gruffins/birch-ios/actions/workflows/tests.yml/badge.svg)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
[![CocoaPods compatible](https://img.shields.io/cocoapods/v/Birch.svg)](https://cocoapods.org/pods/Birch)
[![Swift Package Manager compatible](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg)](https://github.com/apple/swift-package-manager)
[![codecov](https://codecov.io/gh/gruffins/birch-ios/branch/main/graph/badge.svg?token=EQB1TQO74C)](https://codecov.io/gh/gruffins/birch-ios)

Simple, lightweight remote logging for iOS.

Sign up for your free account at [Birch](https://birch.ryanfung.com).

# Installation

## Using CocoaPods
```ruby
pod 'Birch'
pod 'BirchLumberjack' # optional. only used if you use CocoaLumberjack
pod 'BirchXCGLogger' # optional. only used if you use XCGLogger
```

## Using Carthage
```ruby
github "gruffins/birch-ios"
```

## Using Swift Package Manager
```
.package(url: "https://github.com/gruffins/birch-ios.git", majorVersion: 1)
```

# Setup

In your app delegate class, initialize the logger.
```swift
import Birch

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        Birch.initialize("YOUR_API_KEY", publicKey: "YOUR_PUBLIC_ENCRYPTION_KEY")
        Birch.debug = true // this should be turned off in a production build. Debug mode allows you to see Birch operating and artificially lowers the log level and flush period.

        return true
    }
}
```
# Logging
Use the logger as you would with the default Android logger.

```swift
Birch.t("trace message") // simplest
Birch.t { "trace message" } // most performant especially if it's expensive to build the log message.

Birch.d("debug message")
Birch.d { "debug message" }

Birch.i("info message")
Birch.i { "info message" }

Birch.w("warn message")
Birch.w { "warn message" }

Birch.e("error message")
Birch.e { "error message" }
```

Block based logging is more performant since the blocks do not get executed unless the current log level includes the level of the log. See the following example:

```swift
Birch.d {
  return "hello" + someExpensiveFunction()
}
```

If the current log level is `INFO`, the log will not get constructed.

# Configuration
Device level configuration is left to the server so you can remotely control it. There are a few things you can control on the client side.

### Debugging
Debug mode will lower the log level to `TRACE` and set the upload period to every 30 seconds. You should turn this __OFF__ in a production build otherwise you will not be able to modify the log settings remotely.
```swift
Birch.debug = true
```

### Default Configuration

The default configuration is `ERROR` and log flushing every hour. This means any logs lower than `ERROR` are skipped and logs will only be delivered once an hour to preserve battery life. You can change these settings on a per source level by visiting your Birch dashboard.

### Encryption

We **HIGHLY** recommend using encryption to encrypt your logs at rest. If you leave out the public encryption key, Birch will save logs on the device in clear text.

An invalid public key will throw an exception.

To learn more, see our [Encryption](https://github.com/gruffins/birch-ios/wiki/Encryption) documentation.

# Identification
You should set an identifier so you can identify the source in the dashboard. If you do not set one, you will only be able to find devices by the assigned uuid via `Birch.uuid`.

You can also set custom properties on the source that will propagate to all drains.

```swift
func onLogin(user: User) {
  Birch.identifier = user.id
  Birch.customProperties = ["country": user.country]
}
```

# Opt Out

To comply with different sets of regulations such as GDPR or CCPA, you may be required to allow users to opt out of log collection.

```swift
Birch.optOut = true
```

Your application is responsible for changing this and setting it to the correct value at launch. Birch will not remember the last setting and it defaults to `false`.

# Log Scrubbing

Birch comes preconfigured with an email and password scrubber to ensure sensitive data is __NOT__ logged. Emails and passwords are replaced with `[FILTERED]` at the logger level so the data never reaches Birch servers.

If you wish to configure additional scrubbers, implement the `Scrubber` protocol and initialize the logger with all the scrubbers you want to use.

```swift
import Birch

class YourScrubber: Scrubber {

    init() {}

    public func scrub(input: String) -> String {
        return input.replacingOccurrences(
            of: "YOUR_REGEX",
            with: "[FILTERED]",
            options: [.regularExpression, .caseInsensitive]
        )
    }
}
```

```swift
Birch.initialize("API_KEY", publicKey: "YOUR_PUBLIC_ENCRYPTION_KEY", scrubbers: [PasswordScrubber(), EmailScrubber(), YourScrubber()])
```

# CocoaLumberjack
You can use the supplied wrapper if you want to send your logs from CocoaLumberjack to Birch.

See [Birch-Lumberjack](https://github.com/gruffins/birch-lumberjack) for more details.

```swift
import BirchLumberjack

DDLog.add(DDBirchLogger())
```

# XCGLogger
You can use the supplied wrapper if you want to send your logs from XCGLogger to Birch.

See [Birch-XCGLogger](https://github.com/gruffins/birch-xcglogger) for more details.

```swift
import BirchXCGLogger

let logger = XCGLogger(identifier: "your_identifier", includeDefaultDestinations: false)
logger.add(destination: BirchXCGLogger())
```
